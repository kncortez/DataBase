	

	DECLARE @BatchSize INT = 50000;   -- ajustar según pruebas
	DECLARE @RowsAffected INT = 1;
	DECLARE @StartTime DATETIME = GETDATE();

	-- rango del año actual (inicio inclusive, fin exclusivo)
	DECLARE @StartDate DATE = DATEFROMPARTS(YEAR(GETDATE()),1,1);
	DECLARE @EndDate   DATE = DATEADD(DAY,1, DATEFROMPARTS(YEAR(GETDATE()),12,31));


	---- 1) Precalcular mapping Token -> StationId
	IF OBJECT_ID('tempdb..#TokenToStation') IS NOT NULL DROP TABLE #TokenToStation;

	SELECT DISTINCT
		TKL.TknIdToken AS Token,
		RBS.RusIdUser,
		RBS.StationId
	INTO #TokenToStation
	FROM dbo.RolByUserBySystem RBS WITH (NOLOCK)
	INNER JOIN dbo.TokenLog TKL WITH (NOLOCK) ON TKL.TknIdUser = RBS.RusIdUser
	WHERE RBS.RusRowStatus = 1
	  AND RBS.StationId IS NOT NULL;

	CREATE NONCLUSTERED INDEX IX_TokenToStation_Token ON #TokenToStation(Token);

	-- 2) Log por lotes
	IF OBJECT_ID('tempdb..#UpdateLog') IS NOT NULL DROP TABLE #UpdateLog;
	CREATE TABLE #UpdateLog (
		BatchNumber INT IDENTITY(1,1),
		RowsUpdated INT,
		BatchStart DATETIME,
		BatchEnd DATETIME
	);

	-- 3) Detectar si existe PK 'Id', si no, usaremos clave compuesta (Guide_Serie + Guide_Number)
	DECLARE @HasIdCol BIT = 0;
	IF COL_LENGTH('dbo.DeliveryOrderDetail', 'Id') IS NOT NULL
	--	SET @HasIdCol = 1;

	-- 4) Loop por lotes (solo para el año actual)
	WHILE (1=1)
	BEGIN
		BEGIN TRAN;
		BEGIN
			;WITH ToUpd AS (
				SELECT TOP (@BatchSize) DOD.Guide_Serie, DOD.Guide_Number
				FROM dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
				INNER JOIN #TokenToStation M
					ON M.Token = DOD.UserCreated
				WHERE DOD.DateCreated >= @StartDate
				  AND DOD.DateCreated <  @EndDate
				  AND (DOD.StationId IS NULL OR DOD.StationId <> M.StationId)
				ORDER BY DOD.Guide_Serie, DOD.Guide_Number
			)
			UPDATE DOD
			SET StationId = M.StationId
			FROM dbo.DeliveryOrderDetail DOD
			INNER JOIN ToUpd TU 
				ON TU.Guide_Serie = DOD.Guide_Serie
			   AND TU.Guide_Number = DOD.Guide_Number
			INNER JOIN #TokenToStation M ON M.Token = DOD.UserCreated;

			SET @RowsAffected = @@ROWCOUNT;
		END

		INSERT INTO #UpdateLog (RowsUpdated, BatchStart, BatchEnd)
		VALUES (@RowsAffected, DATEADD(SECOND, -1, GETDATE()), GETDATE());

		COMMIT TRAN;

		PRINT CONCAT('Batch finished. RowsUpdated=', @RowsAffected);
		IF @RowsAffected = 0 BREAK;

		-- Espera opcional para reducir contención; ajustar o quitar según pruebas
		WAITFOR DELAY '00:00:00.200';
	END

	-- Resultados
	SELECT SUM(RowsUpdated) AS TotalUpdated, MIN(BatchStart) AS StartAt, MAX(BatchEnd) AS EndAt
	FROM #UpdateLog;
	SELECT * FROM #UpdateLog ORDER BY BatchNumber;
	SELECT DATEDIFF(SECOND, @StartTime, GETDATE()) AS SecondsElapsed;



