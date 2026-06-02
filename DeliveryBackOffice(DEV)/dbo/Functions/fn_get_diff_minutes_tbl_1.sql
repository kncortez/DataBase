-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <16-06-2025>
-- Description:	<Funcion tipo Table-Value que reemplaza fn_get_diff_minutes_without_holidays_by_country en query Power Bi.>
-- =============================================

CREATE FUNCTION dbo.fn_get_diff_minutes_tbl
(
    @StartDate DATETIME,
    @EndDate   DATETIME,
    @IdCountry VARCHAR(2)
)
RETURNS TABLE
AS
RETURN
(
    WITH Ajustes AS (
        SELECT
            StartAdj = CASE 
				WHEN EXISTS (
                    SELECT 1 FROM DeliveryBackOffice.dbo.NoLaborCalendar nlc
                    WHERE nlc.RowStatus = 1
                      AND nlc.IdCountry = @IdCountry
                      AND nlc.NoLaborDate = CAST(@StartDate AS DATE)
                )
                THEN DATEADD(DAY, 1, CAST(@StartDate AS DATE))
                ELSE @StartDate
            END,
            EndAdj = CASE 
                WHEN EXISTS (
                    SELECT 1 FROM DeliveryBackOffice.dbo.NoLaborCalendar nlc
                    WHERE nlc.RowStatus = 1
                      AND nlc.IdCountry = @IdCountry
                      AND nlc.NoLaborDate = CAST(@EndDate AS DATE)
                )
                THEN DATEADD(MINUTE, 1439, CAST(DATEADD(DAY, -1, CAST(@EndDate AS DATE)) AS DATETIME))
                ELSE @EndDate
            END
    ),
    Feriados AS (
        SELECT COUNT(1) AS HolidayCount
        FROM Ajustes A
        JOIN DeliveryBackOffice.dbo.NoLaborCalendar nlc WITH (NOLOCK)
            ON nlc.IdCountry = @IdCountry
           AND nlc.RowStatus = 1
           AND nlc.NoLaborDate BETWEEN CAST(A.StartAdj AS DATE) AND CAST(A.EndAdj AS DATE)
    )
    SELECT ResultMinutes = 
        CASE 
            WHEN @StartDate IS NULL OR @EndDate IS NULL THEN NULL
            WHEN DATEDIFF(DAY, @StartDate, @EndDate) > 365 THEN 365 * 1440
            ELSE
                CASE 
                    WHEN DATEDIFF(MINUTE, A.StartAdj, A.EndAdj) - ISNULL(F.HolidayCount, 0) * 1440 < 0 THEN 0
                    ELSE DATEDIFF(MINUTE, A.StartAdj, A.EndAdj) - ISNULL(F.HolidayCount, 0) * 1440
                END
        END
    FROM Ajustes A
    CROSS JOIN Feriados F
);