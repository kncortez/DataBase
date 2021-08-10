USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_settlement_dispatched_linehauls]    Script Date: 9/08/2021 20:43:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sps_settlement_dispatched_linehauls] @Route INT,
--@GuideQuantity INT,
--	@RouteReceived DATETIME,
@Token NVARCHAR(50),
@PiecesDry SMALLINT,
@PiecesCold SMALLINT,
@GuidesQuantity SMALLINT,
@InGuides NVARCHAR(400) = 'FD22221-1,FD22361-1,FD22223-2,FD22359-1,FD22226-1',
@IdCourier INT,
@DateRoute AS VARCHAR(50),
@StartingKilometers AS VARCHAR(100),
@ServiceID INT,
@IdVehicle INT,
@DateOfRoute DATE


AS
BEGIN

	-- control de actualizaciones para transacción
	DECLARE @RUpdated INT
	DECLARE @Idd INT
	DECLARE @IdManifest INT
	DECLARE @IdRouteAssigment INT
	DECLARE @ExisteDetail INT
	DECLARE @HUB_Destino INT

	BEGIN TRANSACTION

	BEGIN TRY
		IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
			DROP TABLE #listGuides;
		IF OBJECT_ID('tempdb.dbo.#listGuidesPieces_NO_Dispatch', 'U') IS NOT NULL
			DROP TABLE #listGuidesPieces_NO_Dispatch;
		IF OBJECT_ID('tempdb.dbo.#UpdOrd', 'U') IS NOT NULL
			DROP TABLE #UpdOrd;
		IF OBJECT_ID('tempdb.dbo.#listGuidesPieces_Dispatch', 'U') IS NOT NULL
			DROP TABLE #listGuidesPieces_Dispatch;

		---===============ALMACENAR ID HUB DESTINO
		--SET @HUB_Destino = (SELECT
		--		ISNULL(hl_destino.IdHublogistic, 0) AS ID_HUB_DESTINO
		--	FROM DeliveryBackOffice.dbo.DeliveryOrder serv
		--	JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh_destino
		--		ON serv.ReceiverIdTownship = tbh_destino.IdTownship
		--		AND tbh_destino.StatusTownshipHub = 1
		--	JOIN DeliveryBackOffice.dbo.HubLogistics hl_destino
		--		ON tbh_destino.IdHublogistic = hl_destino.IdHublogistic
		--	JOIN DeliveryOrderPiece pc
		--		ON serv.Guide_Number = pc.GuideNumber
		--		AND serv.Guide_Serie = pc.GuideSerie
		--	WHERE CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) = @InGuides
		--	AND hl_destino.IdHublogistic IN (SELECT
		--			cl.IdHubDestination
		--		FROM CatLinehaul cl
		--		WHERE cl.IdRoute = cast(@Route as int )))

		--		PRINT @HUB_Destino

		--select SUBSTRING(Item, 1,2) ItemSerie,SUBSTRING(Item,3,len(Item)) ItemNumber 
		--	into #listGuides
		--	from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')

		--declare @InGuides   NVARCHAR(400) = 'FD198907-3,FD198910-1,FD198910-2,FD198941-1'

		SELECT
			SUBSTRING(Item, 1, 2) ItemSerie
		   ,SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(item)), (CHARINDEX('-', Item) - 3))) ItemNumber
		   ,SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(item)) ItemPiece
		--, 
		--SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
		--CHARINDEX('-',Item) charinde,  
		--len(Item) len
		INTO #listGuides
		FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',')

		SET @IdRouteAssigment = (SELECT
				ra.IdRouteAssigment
			FROM RouteAssigment ra
			WHERE ra.IdRoute = @Route
			AND ra.DateOfRoute = @DateOfRoute)

		/*LINEHAULS-27072021.INI*/	
		UPDATE 
		   RouteAssigment
		SET 
			IdCurrierMan = @IdCourier, 
			IdVehicle    = @IdVehicle
		WHERE 
			(IdCurrierMan IS NULL
			OR IdVehicle IS NULL)
			AND IdRouteAssigment = @IdRouteAssigment 
			

		UPDATE 
		   ServiceManagement
		SET 
			IdPuCourrier = @IdCourier
		WHERE 
			IdPuCourrier IS NULL
			AND IdPuRouteAssigment = @IdRouteAssigment 
			AND IdServiceManagement = @ServiceID
			AND CONVERT(CHAR(10), DateCreated, 126) = @DateOfRoute
		/*LINEHAULS-27072021.FIN*/	


SELECT X.* 
INTO #listGuidesPieces_Dispatch
FROM (
		SELECT
			dop.GuideSerie
		   ,dop.GuideNumber
		   ,dop.NoPiece
		   ,hl_destino.IdHublogistic AS IdHUB 
		FROM DeliveryOrderPiece dop
		JOIN DeliveryBackOffice.dbo.DeliveryOrder serv
			ON serv.Guide_Serie = dop.GuideSerie
				AND serv.Guide_Number = dop.GuideNumber		
		JOIN DeliveryBackOffice.dbo.HubLogistics hl_destino
			ON serv.HubDestinationId = hl_destino.IdHublogistic
		INNER JOIN #listGuides ls
			ON ls.ItemSerie = dop.GuideSerie
				AND ls.ItemNumber = dop.GuideNumber
		WHERE dop.StatusOrderId = 19		
		UNION 
		SELECT
				dop.GuideSerie
			   ,dop.GuideNumber
			   ,dop.NoPiece
			   ,hl_destino.IdHublogistic AS IdHUB 
			FROM DeliveryOrderPiece dop
			JOIN DeliveryBackOffice.dbo.DeliveryOrder serv
				ON serv.Guide_Serie = dop.GuideSerie
					AND serv.Guide_Number = dop.GuideNumber
			JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh_destino
				ON serv.ReceiverIdTownship = tbh_destino.IdTownship
					AND tbh_destino.StatusTownshipHub = 1
			JOIN DeliveryBackOffice.dbo.HubLogistics hl_destino
				ON tbh_destino.IdHublogistic = hl_destino.IdHublogistic
			INNER JOIN #listGuides ls
				ON ls.ItemSerie = dop.GuideSerie
					AND ls.ItemNumber = dop.GuideNumber
			WHERE dop.StatusOrderId = 19			
		)X
		ORDER BY X.NoPiece ASC


		SELECT
			dop.GuideSerie
		   ,dop.GuideNumber
		   ,dop.NoPiece INTO #listGuidesPieces_NO_Dispatch
		FROM DeliveryOrderPiece dop
		INNER JOIN #listGuides ls
			ON ls.ItemSerie = dop.GuideSerie
				AND ls.ItemNumber = dop.GuideNumber
		WHERE dop.StatusOrderId != 19
		ORDER BY dop.NoPiece ASC



		IF (SELECT TOP 1
					ISNULL(COUNT(1), 0)
				FROM SettlementByPickup
				WHERE RouteAssigmentId = @IdRouteAssigment
				AND ServiceManagmentId = @ServiceID)
			= 0
		BEGIN
			SET @IdManifest = NEXT VALUE FOR linehauls_IdManifiest
			PRINT 'ingresa a insertar settlementbypickup'
			INSERT INTO dbo.SettlementByPickup (RouteAssigmentId,
			DatePrinted,
			TokenCreated,
			DateCreated,
			PiecesDry,
			PiecesCold,
			GuidesQuantity,
			PiecesDryReceived,
			PiecesColdReceived,
			GuidesQuantityReceived
			, IdCourier
			, SequenceCode
			, SubTypeServiceManagmentId
			, StartingKilometers
			, ArrivalKilometers
			, ServiceManagmentId)
				SELECT
					@IdRouteAssigment
				   ,GETDATE()
				   ,@Token
				   ,GETDATE()
				   ,SUM(x.TotalDry)
				   ,SUM(x.TotalCold)
				   ,(SELECT
							COUNT(A.GuideNumber)
						FROM (SELECT DISTINCT
								dop2.GuideNumber
							FROM PieceByService pbs
							INNER JOIN DeliveryOrderPiece dop2
								ON dop2.GuidePiece = pbs.GuidePieceId
							WHERE pbs.ServiceManagmentId = @ServiceID) A)
				   ,NULL
				   ,NULL
				   ,NULL
				   ,@IdCourier
				   ,@IdManifest
				   ,4
				   ,@StartingKilometers
				   ,NULL
				   ,@ServiceID
				FROM (SELECT
						COUNT(ISNULL(dop.Pieces_Dry, 0)) AS TotalDry
					   ,0 AS TotalCold
					FROM PieceByService pbs
					INNER JOIN DeliveryOrderPiece dop1
						ON pbs.GuidePieceId = dop1.GuidePiece
					INNER JOIN DeliveryOrder dop
						ON dop.Guide_Serie = dop1.GuideSerie
						AND dop.Guide_Number = dop1.GuideNumber
					WHERE pbs.ServiceManagmentId = @ServiceID
					AND ISNULL(dop1.IsDry, 0) = 1
					AND CONCAT( dop1.GuideSerie, dop1.GuideNumber, '-',dop1.NoPiece) IN (SELECT CONCAT(GuideSerie,GuideNumber,'-',NoPiece) FROM #listGuidesPieces_Dispatch)

					--GROUP BY dop.Pieces_Dry, dop.Pieces_Cold, g.ItemSerie,g.ItemNumber
					UNION ALL
					SELECT
						0 AS TotalDry
					   ,COUNT(ISNULL(dop.Pieces_Cold, 0)) AS TotalCold
					FROM PieceByService pbs
					INNER JOIN DeliveryOrderPiece dop1
						ON pbs.GuidePieceId = dop1.GuidePiece
					INNER JOIN DeliveryOrder dop
						ON dop.Guide_Serie = dop1.GuideSerie
						AND dop.Guide_Number = dop1.GuideNumber
					WHERE pbs.ServiceManagmentId = @ServiceID
					AND ISNULL(dop1.IsDry, 0) = 0
					AND CONCAT( dop1.GuideSerie, dop1.GuideNumber, '-',dop1.NoPiece) IN (SELECT CONCAT(GuideSerie,GuideNumber,'-',NoPiece) FROM #listGuidesPieces_Dispatch)
				--GROUP BY dop.Pieces_Dry, dop.Pieces_Cold, g.ItemSerie,g.ItemNumber
				) x


			SET @RUpdated = @@rowcount
			SET @Idd = SCOPE_IDENTITY();
			PRINT '@Idd';
			PRINT @Idd;
		END
		ELSE
		BEGIN
			PRINT 'ingresa en else'

			SELECT TOP 1
				@Idd = ISNULL(Id, 0),
				@IdManifest = ISNULL(SequenceCode, 0)
				FROM SettlementByPickup
				WHERE RouteAssigmentId = @IdRouteAssigment
				AND ServiceManagmentId = @ServiceID

			IF @IdManifest = 0
			BEGIN
				PRINT 'Entra a idManifest = 0'
				SET @IdManifest = NEXT VALUE FOR linehauls_IdManifiest

				UPDATE SettlementByPickup
				SET DatePrinted = GETDATE(),
					IdCourier = @IdCourier,
					SequenceCode = @IdManifest,
					StartingKilometers = @StartingKilometers,
					DateUpdated = GETDATE(),
					TokenUpdated = @Token
				
				WHERE Id = @Idd
			END

			PRINT '@Idd';
			PRINT @Idd;
			PRINT 'manifiesto';
			PRINT @IdManifest;

		END

		SET @ExisteDetail = (SELECT TOP 1
				ISNULL(COUNT(1), 0)
			FROM SettlementByPickupDetail sbpd
			INNER JOIN #listGuidesPieces_Dispatch ls
				ON sbpd.GuideSerie = ls.GuideSerie
				AND sbpd.GuideNumber = ls.GuideNumber
				AND sbpd.NoPiece = ls.NoPiece
			WHERE SettlementByPickupId = @Idd
			AND sbpd.RowStatus = 1)
		--SET @ExisteDetail = (SELECT COUNT(pbs.IdServiceManagementByPiece) FROM #listGuides ls
		--INNER JOIN DeliveryOrderPiece pc ON pc.GuideSerie = ls.ItemSerie AND pc.GuideNumber = ls.ItemNumber AND pc.NoPiece = ls.ItemPiece
		--		INNER JOIN  dbo.PieceByService pbs 		
		--				ON pc.GuidePiece = pbs.GuidePieceId				
		--		JOIN ServiceManagement sm
		--				ON pbs.ServiceManagmentId = sm.IdServiceManagement	
		--		JOIN RouteAssigment ra ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
		--		AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126)
		--		INNER JOIN dbo.SettlementByPickup sbp ON sbp.RouteAssigmentId = ra.IdRouteAssigment
		--		INNER JOIN SettlementByPickupDetail sbpd ON sbp.Id = sbpd.SettlementByPickupId AND sbpd.RowStatus = 1
		--		)

		PRINT '@ExisteDetail'
		PRINT @ExisteDetail

		--		SELECT DISTINCT sbpd.* FROM #listGuides ls
		--INNER JOIN DeliveryOrderPiece pc ON pc.GuideSerie = ls.ItemSerie AND pc.GuideNumber = ls.ItemNumber AND pc.NoPiece = ls.ItemPiece
		--		INNER JOIN  dbo.PieceByService pbs 		
		--				ON pc.GuidePiece = pbs.GuidePieceId				
		--		JOIN ServiceManagement sm
		--				ON pbs.ServiceManagmentId = sm.IdServiceManagement	
		--		JOIN RouteAssigment ra ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
		--		AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126)
		--		INNER JOIN dbo.SettlementByPickup sbp ON sbp.RouteAssigmentId = ra.IdRouteAssigment
		--		INNER JOIN SettlementByPickupDetail sbpd ON sbp.Id = sbpd.SettlementByPickupId AND sbpd.RowStatus = 1
		--		where sbpd.SettlementByPickupId = 71




		IF (@ExisteDetail = 0
			AND @Idd > 0)
		BEGIN
			PRINT 'ingresa en insertar settlementbypickupdetail'
			INSERT INTO dbo.SettlementByPickupDetail (SettlementByPickupId,
			GuideSerie,
			GuideNumber,
			RowStatus,
			TokenCreated,
			DateCreated,
			TokenUpdated,
			DateUpdated,
			IsPieceLiquidaded,
			NoPiece,
			IsDispatched)
				SELECT
					@Idd
				   ,pc.GuideSerie
				   ,pc.GuideNumber
				   ,1
				   ,@Token
				   ,GETDATE()
				   ,NULL
				   ,NULL
				   ,0
				   ,pc.NoPiece
				   ,1
				FROM #listGuidesPieces_Dispatch ls
				INNER JOIN DeliveryOrderPiece pc
					ON pc.GuideSerie = ls.GuideSerie
						AND pc.GuideNumber = ls.GuideNumber
						AND pc.NoPiece = ls.NoPiece
				INNER JOIN dbo.PieceByService pbs
					ON pc.GuidePiece = pbs.GuidePieceId
				JOIN ServiceManagement sm
					ON pbs.ServiceManagmentId = sm.IdServiceManagement
				JOIN RouteAssigment ra
					ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
						AND ra.DateOfRoute = @DateOfRoute




		--=============== Se almacenan las piezas de las guías que no fueron despachadas ===============

		--INSERT INTO dbo.SettlementByPickupDetail (SettlementByPickupId,
		--GuideSerie,
		--GuideNumber,
		--RowStatus,
		--TokenCreated,
		--DateCreated,
		--TokenUpdated,
		--DateUpdated,
		--IsPieceLiquidaded,
		--NoPiece,
		--IsDispatched)
		--	SELECT
		--		@Idd
		--	   ,ls.GuideSerie
		--	   ,ls.GuideNumber
		--	   ,1
		--	   ,@Token
		--	   ,GETDATE()
		--	   ,NULL
		--	   ,NULL
		--	   ,0
		--	   ,ls.NoPiece
		--	   ,0
		--	FROM #listGuidesPieces_NO_Dispatch ls

		----======================== Registrar Servicio por cada HUB ============================

		--INSERT INTO dbo.ServiceManagement (IdPuCourrier, IdDlCourrier, CiPuDate, CoPuDate,
		--CiDlDate, CoDlDate, IdPuRouteAssigment, IdDlRouteAssigment, IdSchedulePickup,
		--IdProofOnDelivery, RowStatus, TokenCreated, DateCreated, TokenUpdated,
		--DateUpdated, ServiceStatusId, PuSignaturePath, DiSignaturePath,
		--SubTypeServiceManagmentId)
		--	SELECT
		--		@IdCourier
		--	   ,NULL
		--	   ,NULL
		--	   ,NULL
		--	   ,NULL
		--	   ,NULL
		--	   ,@Route
		--	   ,NULL
		--	   ,NULL
		--	   ,NULL
		--	   ,1
		--	   ,@Token
		--	   ,GETDATE()
		--	   ,NULL
		--	   ,NULL
		--	   ,1
		--	   ,NULL
		--	   ,NULL
		--	   ,4

		--SET @ServiceID = SCOPE_IDENTITY();

		----========================== Se registra en una tabla de control el id de servicio y de piezas ======

		--INSERT INTO dbo.PieceByService (ServiceManagmentId, GuidePieceId, RowStatus,
		--TokenCreated, DateCreated, TokenUpdated, DateUpdated)
		--	SELECT
		--		@ServiceID
		--	   ,@Idd
		--	   ,1
		--	   ,@Token
		--	   ,GETDATE()
		--	   ,NULL
		--	   ,NULL
		--	   FROM  DeliveryOrderPiece pc
		--	WHERE CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) = @Guide_Number
		--	   --se debe cambiar para que inserte el guidepiece de la tabla deliveryorderpiece


		/*LINEHAULS-27072021.INI*/
		-- Actualizar registro de guía a último estado 

	UPDATE 
		   do
		SET 
			do.StatusOrderId = 19,
			do.Courier_Route = (SELECT CONCAT(CodeRoute,' ',Description) FROM CatRoute WHERE IdRoute = @Route),
			do.Courier_Name  = (SELECT CONCAT(First_Name, ' ', Last_Name) FROM SenderReceiver where ID = @IdCourier)

		FROM 
			DeliveryBackOffice.dbo.DeliveryOrder AS do	
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop ON do.Guide_Serie = dop.GuideSerie AND do.Guide_Number = dop.GuideNumber
			INNER JOIN #listGuidesPieces_Dispatch gp ON gp.GuideSerie = dop.GuideSerie AND gp.GuideNumber = dop.GuideNumber AND gp.NoPiece = dop.NoPiece
			/*LINEHAULS-27072021.FIN*/
		


		END
	END TRY

	BEGIN CATCH
		SELECT
			0 AS 'idManifest'
		   ,ERROR_MESSAGE() AS 'Description'
		   ,CONVERT(BIGINT, 0) AS 'NumTransferID'
		ROLLBACK TRANSACTION
	END CATCH;

	IF @@trancount > 0
	BEGIN
		IF (@Idd > 0)
			SELECT
				@IdManifest AS 'idManifest'
			   ,'Registro guardado correctamente' AS 'Description'
			   ,@@trancount AS 'NumTransferID'
		ELSE
			SELECT
				0 AS 'idManifest'
			   ,'Registro no encontrado' AS 'Description'
			   ,0 AS 'NumTransferID'

		COMMIT TRANSACTION;
	END
	ELSE
		SELECT
			0 AS 'idManifest'
		   ,ERROR_MESSAGE() AS 'Description'
		   ,CONVERT(BIGINT, 0) AS 'NumTransferID'

END