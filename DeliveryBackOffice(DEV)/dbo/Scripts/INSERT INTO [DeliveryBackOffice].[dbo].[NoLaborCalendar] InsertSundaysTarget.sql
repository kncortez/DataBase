USE DeliveryBackOffice;

DECLARE @TargetYear INT = 2022;

DECLARE @SundaysAsTable TABLE (
	SundayDate DATE NULL
);

DECLARE @StartOfTargetYear DATETIME = DATEFROMPARTS(@TargetYear, 1, 1);

;WITH FechasDomingo AS (
   SELECT DATEADD(DAY, (1 - DATEPART(WEEKDAY, @StartOfTargetYear)), @StartOfTargetYear) AS Fecha, 1 AS NumeroSemana
   UNION ALL
   SELECT DATEADD(DAY, 7, Fecha), NumeroSemana + 1 AS NumeroSemana
   FROM FechasDomingo
   WHERE NumeroSemana <= 53
)
INSERT INTO @SundaysAsTable
(
    [SundayDate]
)
SELECT Fecha
FROM FechasDomingo
WHERE YEAR(Fecha) = YEAR(@StartOfTargetYear) AND Fecha <= DATEFROMPARTS(YEAR(@StartOfTargetYear), 12, 31)

--SELECT * FROM @SundaysAsTable

INSERT INTO [DeliveryBackOffice].[dbo].[NoLaborCalendar]
	(
		[NoLaborDate]
		, TokenCreated
		, DateCreated
	)
SELECT
	[SAT].[SundayDate]
	,'SYS-ARUIZ'
	,GETDATE()
FROM
	@SundaysAsTable SAT