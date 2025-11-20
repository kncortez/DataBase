------------------------------------------------------------
--ACTUALIZACION DE STATION ID DE USUARIO DE HERMES DESKTOP--
------------------------------------------------------------

DECLARE @BatchSize INT = 5000;
DECLARE @Rows INT = 1;
DECLARE @RowsAffected INT = 1;
DECLARE @BatchesDone INT = 0;

BEGIN TRY
	------------------------------------------------------------
	-- 1) Obtenenemos usuarios de Hermes Desktop
	----------------------------------------------------------
	IF OBJECT_ID('tempdb..#LastLogin') IS NOT NULL DROP TABLE #LastLogin;

	SELECT 
		l.SSN_IdUser,
		MAX(l.SSN_DateLogin) AS LastLogin
	INTO #LastLogin
	FROM DenariusUser_Dev.dbo.LGN_LogByToken l WITH (NOLOCK)
	GROUP BY l.SSN_IdUser;

	CREATE INDEX IX_LL_IdUser ON #LastLogin(SSN_IdUser);

	------------------------------------------------------------
	-- 2) Obtener mapping Token -> Station usando último login
	------------------------------------------------------------
	IF OBJECT_ID('tempdb..#TokenStation') IS NOT NULL DROP TABLE #TokenStation;

	SELECT DISTINCT
		t.TknIdToken AS UserCreated,
		r.StationId
	INTO #TokenStation
	FROM TokenLog t WITH (NOLOCK)
	INNER JOIN RolByUserBySystem r WITH (NOLOCK)
		ON t.TknIdUser = r.RusIdUser AND r.RusRowStatus = 1 AND r.StationId IS NOT NULL
	INNER JOIN InternalUser iu WITH (NOLOCK)
		ON iu.RegisterUserID = r.RusIdUser
	INNER JOIN #LastLogin ll
		ON ll.SSN_IdUser = iu.IdUser
	INNER JOIN DenariusUser_Dev.dbo.LGN_LogByToken l WITH (NOLOCK)
		ON l.SSN_IdUser = iu.IdUser AND l.SSN_DateLogin = ll.LastLogin;

	CREATE INDEX IX_TS_UserCreated ON #TokenStation(UserCreated);

	------------------------------------------------------------
	-- 3) Crear tabla de guías a actualizar
	------------------------------------------------------------
	IF OBJECT_ID('tempdb..#GuidesToUpdate') IS NOT NULL DROP TABLE #GuidesToUpdate;

	SELECT DISTINCT
		d.Guide_Serie AS GuideSerie,
		d.Guide_Number AS GuideNumber,
		ts.StationId
	INTO #GuidesToUpdate
	FROM DeliveryOrderDetail d WITH (NOLOCK)
	INNER JOIN #TokenStation ts ON ts.UserCreated = d.UserCreated;

	CREATE INDEX IX_GTU_Guide ON #GuidesToUpdate(GuideSerie, GuideNumber);

	------------------------------------------------------------
	-- 4) WHILE por lotes para actualizar DeliveryOrderDetail
	------------------------------------------------------------


	WHILE @Rows = 1
	BEGIN
		/*******DETENEMOS SI YA NO HAY GUIAS POR PROCESAR*********/
		IF (SELECT COUNT(*) FROM #GuidesToUpdate) = 0
		BEGIN
			PRINT 'No quedan guías por procesar. Terminando.';
			BREAK;
		END

		BEGIN TRAN;

		IF OBJECT_ID('tempdb..#Batch') IS NOT NULL DROP TABLE #Batch;

		SELECT TOP (@BatchSize)
			GuideSerie,
			GuideNumber
		INTO #Batch
		FROM #GuidesToUpdate
		ORDER BY GuideSerie, GuideNumber;

		IF OBJECT_ID('tempdb..#Batch') IS NULL
		BEGIN
			PRINT 'ERROR: Falló la creación de #Batch. Abortando.';
			ROLLBACK TRAN;
			BREAK;
		END

		/********ACTUALIZAMOS REGISTROS************/
		UPDATE d
		SET d.StationId = g.StationId
		FROM dbo.DeliveryOrderDetail d
		INNER JOIN #Batch b
			ON d.Guide_Serie = b.GuideSerie
		   AND d.Guide_Number = b.GuideNumber
		INNER JOIN #GuidesToUpdate g
			ON g.GuideSerie = d.Guide_Serie
		   AND g.GuideNumber = d.Guide_Number
		WHERE D.StationId IS NULL

		SET @RowsAffected = @@ROWCOUNT;

		/***********ELIMINAMOS GUIAS PROCESADAS********/
		DELETE gu
		FROM #GuidesToUpdate gu
		INNER JOIN #Batch b2
			ON gu.GuideSerie = b2.GuideSerie
		   AND gu.GuideNumber = b2.GuideNumber;

		COMMIT;

		SET @BatchesDone = @BatchesDone + 1;
		PRINT CONCAT('Batch ', @BatchesDone, ' - Filas actualizadas: ', @RowsAffected);

		-- limpiamos la tabla #Batch  antes del siguiente ciclo
		IF OBJECT_ID('tempdb..#Batch') IS NOT NULL DROP TABLE #Batch;

	END
	PRINT 'Proceso finalizado.';

END TRY
BEGIN CATCH
	ROLLBACK TRAN;

	SELECT @@ERROR,
			ERROR_MESSAGE(),
			ERROR_LINE()
END CATCH


