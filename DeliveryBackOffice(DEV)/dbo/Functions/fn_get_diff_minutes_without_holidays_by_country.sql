
CREATE FUNCTION [dbo].[fn_get_diff_minutes_without_holidays_by_country]
(
    @StartDate DATETIME,
    @EndDate DATETIME,
	@IdCountry VARCHAR(2)
)
RETURNS INT
AS
BEGIN

	DECLARE @NewStartDate DATETIME -- new date in case startdate is Holiday
	DECLARE @NewEndDate DATETIME -- new date in case enddate is Holiday
	DECLARE @result INT; -- for function result
	DECLARE @NoLaborDays INT; -- number of Holiday days found
	DECLARE @tableNotWorkingDays TABLE ( -- the dates of of Holiday days
		NotWorkingDays DATETIME NULL
	);
	DECLARE @WorkingMinutes INT; -- total of minutes between two dates minus sundays minutes

IF (@StartDate IS NOT NULL AND @EndDate IS NOT NULL)
BEGIN


IF (DATEDIFF(DAY, @StartDate, @EndDate) <= 365)
BEGIN

	-- Check if Holiday to avoid substract hours from StartDate, set new date the next day
	IF CAST(@StartDate AS DATE) IN (SELECT nlc.NoLaborDate FROM DeliveryBackOffice.dbo.NoLaborCalendar nlc WITH (NOLOCK) WHERE nlc.RowStatus = 1 and nlc.IdCountry = @IdCountry) 
    BEGIN
        SET @NewStartDate
            = (DATEADD(DAY, 1, SMALLDATETIMEFROMPARTS(YEAR(@StartDate), MONTH(@StartDate), DAY(@StartDate), 0, 0)));
    END;
    ELSE
    BEGIN
        SET @NewStartDate = @StartDate;
    END;

    -- Check if Holiday to avoid substract hours from EndDate, set new date the day before
	IF CAST(@EndDate AS DATE) IN (SELECT nlc.NoLaborDate FROM DeliveryBackOffice.dbo.NoLaborCalendar nlc WITH (NOLOCK) WHERE nlc.RowStatus = 1 and nlc.IdCountry = @IdCountry) 
    BEGIN
        SET @NewEndDate
            = (DATEADD(DAY, -1, SMALLDATETIMEFROMPARTS(YEAR(@EndDate), MONTH(@EndDate), DAY(@EndDate), 23, 59)));
    END;
    ELSE
    BEGIN
        SET @NewEndDate = @EndDate;
    END

	/*Creating a temporary view in sql(CTE) which recursively 
	calls itself to find next date by incrementing the 
	previous date and stores the result in it till the end date is reached*/
    ;WITH CTE (date_list)
    AS (SELECT @NewStartDate
        UNION ALL
        SELECT DATEADD(DAY, 1, date_list)
        FROM CTE
        WHERE (date_list < CAST(@NewEndDate AS DATE))) -- It needs to cast to Date because any minute of the current day sums another day
    
	INSERT INTO @tableNotWorkingDays
    SELECT date_list AS "List of sundays"
    FROM CTE
    --WHERE DATENAME(weekday ,date_list) IN ('Sunday');
    --WHERE DATEPART(WEEKDAY, date_list) IN ( 1 )
	WHERE CAST(CTE.date_list AS DATE) IN (SELECT nlc.NoLaborDate FROM DeliveryBackOffice.dbo.NoLaborCalendar nlc WITH(NOLOCK) WHERE nlc.RowStatus = 1 and nlc.IdCountry = @IdCountry)
	OPTION (MAXRECURSION 365); -- maximum of days between StartDate and EndDate
    /*In the where clause at last we are checking 
	each day from the list whether it is in Holiday list or not*/

	-- number of Holiday days
	SET @NoLaborDays = (
		SELECT COUNT(NotWorkingDays) FROM @tableNotWorkingDays
	)

	-- total of minutes between two dates minus sundays minutes
	SET @WorkingMinutes = (SELECT DATEDIFF(MINUTE, @NewStartDate, @NewEndDate) - (@NoLaborDays*1440))

	-- validation for negative minutes (date swap)
    SELECT @result = CASE
                         WHEN (@WorkingMinutes < 0) THEN
                             0
                         ELSE
							@WorkingMinutes
                     END;

END
ELSE
	SELECT @result = 365 * 1440; -- if CTE recursion exceed 365 days return max value allowed in minutes
END
ELSE
	SELECT @result = NULL;

RETURN @result;

END;