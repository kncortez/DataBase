
CREATE FUNCTION [dbo].[fn_get_diff_minutes_without_sundays]
(
    @StartDate DATETIME,
    @EndDate DATETIME
)
RETURNS INT
AS
BEGIN

	DECLARE @NewStartDate DATETIME -- new date in case startdate is sunday
	DECLARE @NewEndDate DATETIME -- new date in case enddate is sunday
	DECLARE @result INT; -- for function result
	DECLARE @SundayDays INT; -- number of Sunday days
	DECLARE @tableNotWorkingDays TABLE ( -- the dates of of Sunday days
		NotWorkingDays DATETIME NULL
	);
	DECLARE @WorkingMinutes INT; -- total of minutes between two dates minus sundays minutes

IF (@StartDate IS NOT NULL AND @EndDate IS NOT NULL)
BEGIN


IF (DATEDIFF(DAY, @StartDate, @EndDate) <= 365)
BEGIN

	-- Check if Sunday to avoid substract hours from StartDate, set new date on Monday
	IF ((DATEPART(WEEKDAY, @StartDate) = 1))
	BEGIN
		SET @NewStartDate = (DATEADD(DAY, 1, SMALLDATETIMEFROMPARTS(YEAR(@StartDate), MONTH(@StartDate), DAY(@StartDate), 0, 0)))
	END
	ELSE
	BEGIN
		SET @NewStartDate = @StartDate
	END

	-- Check if Sunday to avoid substract hours from EndDate, set new date on Saturday
	IF ((DATEPART(WEEKDAY, @EndDate) = 1))
	BEGIN
		SET @NewEndDate = (DATEADD(DAY, -1, SMALLDATETIMEFROMPARTS(YEAR(@EndDate), MONTH(@EndDate), DAY(@EndDate), 23, 59)))
	END
	ELSE
	BEGIN
		SET @NewEndDate = @EndDate
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
    WHERE DATEPART(WEEKDAY, date_list) IN ( 1 )
	OPTION (MAXRECURSION 365); -- maximum of days between StartDate and EndDate
    /*In the where clause at last we are checking 
	each day from the list whether it is in Sunday list or not*/

	-- number of sunday days
	SET @SundayDays = (
		SELECT COUNT(NotWorkingDays) FROM @tableNotWorkingDays
	)

	-- total of minutes between two dates minus sundays minutes
	SET @WorkingMinutes = (SELECT DATEDIFF(MINUTE, @NewStartDate, @NewEndDate) - (@SundayDays*1440))

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



