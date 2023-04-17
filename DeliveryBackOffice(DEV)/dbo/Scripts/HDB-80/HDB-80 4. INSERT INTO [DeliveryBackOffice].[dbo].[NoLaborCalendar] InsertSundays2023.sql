DECLARE @SundaysAsTable TABLE (
	SundayDate DATE NULL
);

WITH FechasDomingo AS (
   SELECT DATEADD(DAY, (7 - DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS Fecha, 1 AS NumeroSemana
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
WHERE YEAR(Fecha) = YEAR(GETDATE()) AND Fecha <= DATEFROMPARTS(YEAR(GETDATE()), 12, 31)

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

INSERT INTO [DeliveryBackOffice].[dbo].[NoLaborCalendar]
	(
		[NoLaborDate]
		, TokenCreated
		, DateCreated
	)
VALUES
	-- Día del trabajo
	(
		'2023-05-01'
		,'SYS-ARUIZ'
		,GETDATE()
	),
	-- Día del ejercito
	(
		'2023-07-03'
		,'SYS-ARUIZ'
		,GETDATE()
	),
	-- Día de la asunción
	(
		'2023-08-15'
		,'SYS-ARUIZ'
		,GETDATE()
	),
	-- Día de la independencia
	(
		'2023-09-15'
		,'SYS-ARUIZ'
		,GETDATE()
	),
	-- Día de la revolución
	(
		'2023-10-20'
		,'SYS-ARUIZ'
		,GETDATE()
	),
	-- Navidad
	(
		'2023-12-25'
		,'SYS-ARUIZ'
		,GETDATE()
	)