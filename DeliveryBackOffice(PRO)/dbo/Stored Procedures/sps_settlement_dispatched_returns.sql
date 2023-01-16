

CREATE PROCEDURE [dbo].[sps_settlement_dispatched_returns] 
@Route NVARCHAR(20),
--@GuideQuantity INT,
--	@RouteReceived DATETIME,
@Token NVARCHAR(50),
@PiecesDry SMALLINT,
@PiecesCold SMALLINT,
@GuidesQuantity SMALLINT,
@InGuides NVARCHAR(MAX) = 'FD22221-1,FD22361-1,FD22223-2,FD22359-1,FD22226-1',
@IdCourier INT,
@DateRoute AS VARCHAR(50),
@StartingKilometers AS VARCHAR(100)


AS
BEGIN

	-- control de actualizaciones para transacción
	DECLARE @RUpdated INT
	DECLARE @Idd INT
	DECLARE @IdManifest INT
	DECLARE @IdRouteAssigment INT
	DECLARE @ExisteDetail INT
	

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
			FROM DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK)
			WHERE ra.IdRoute = CAST(@Route AS INT)
			AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126))



		SELECT
			dop.GuideSerie
		   ,dop.GuideNumber
		   ,dop.NoPiece
		INTO #listGuidesPieces_Dispatch
		FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder serv WITH(NOLOCK)
			ON serv.Guide_Serie = dop.GuideSerie
				AND serv.Guide_Number = dop.GuideNumber
		INNER JOIN #listGuides ls
			ON ls.ItemSerie = dop.GuideSerie
				AND ls.ItemNumber = dop.GuideNumber
		WHERE dop.StatusOrderId = 18
		ORDER BY dop.NoPiece ASC

		SELECT
			dop.GuideSerie
		   ,dop.GuideNumber
		   ,dop.NoPiece INTO #listGuidesPieces_NO_Dispatch
		FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
		INNER JOIN #listGuides ls
			ON ls.ItemSerie = dop.GuideSerie
				AND ls.ItemNumber = dop.GuideNumber
		WHERE dop.StatusOrderId != 18
		ORDER BY dop.NoPiece ASC



		IF (SELECT TOP 1
					ISNULL(COUNT(1), 0)
				FROM SettlementByPickup
				WHERE RouteAssigmentId = @IdRouteAssigment and DateCreated =  CONVERT(CHAR(10), GETDATE(), 126))
			= 0
		BEGIN
			SET @IdManifest = NEXT VALUE FOR returns_IdManifiest
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
				   ,(
					SELECT COUNT(DISTINCT lg.ItemNumber)
					FROM #listGuides lg
					INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop1 WITH(NOLOCK)
						ON lg.ItemSerie = dop1.GuideSerie
						AND lg.ItemNumber = dop1.GuideNumber
						AND lg.ItemPiece = dop1.NoPiece
					INNER JOIN DeliveryBackOffice.dbo.PieceByService pbs WITH(NOLOCK)
						ON pbs.GuidePieceId = dop1.GuidePiece
					WHERE CONVERT(char(10), pbs. DateCreated,126) =  CONVERT(CHAR(10), GETDATE(), 126)
				   )
				   ,NULL
				   ,NULL
				   ,NULL
				   ,@IdCourier
				   ,@IdManifest
				   ,3
				   ,@StartingKilometers
				   ,NULL
				   ,null
				FROM (SELECT
						COUNT(ISNULL(dop.Pieces_Dry, 0)) AS TotalDry
					   ,0 AS TotalCold
					FROM DeliveryBackOffice.dbo.PieceByService pbs WITH(NOLOCK)
					INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop1 WITH(NOLOCK)
						ON pbs.GuidePieceId = dop1.GuidePiece
					INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder dop WITH(NOLOCK)
						ON dop.Guide_Serie = dop1.GuideSerie
						AND dop.Guide_Number = dop1.GuideNumber
					WHERE CONVERT(char(10), pbs. DateCreated,126) =  CONVERT(CHAR(10), GETDATE(), 126)
					AND ISNULL(dop1.IsDry, 0) = 1
					AND CONCAT( dop1.GuideSerie, dop1.GuideNumber, '-',dop1.NoPiece) IN (SELECT CONCAT(GuideSerie,GuideNumber,'-',NoPiece) FROM #listGuidesPieces_Dispatch)
					--GROUP BY dop.Pieces_Dry, dop.Pieces_Cold, g.ItemSerie,g.ItemNumber
					UNION ALL
					SELECT
						0 AS TotalDry
					   ,COUNT(ISNULL(dop.Pieces_Cold, 0)) AS TotalCold
					FROM DeliveryBackOffice.dbo.PieceByService pbs WITH(NOLOCK)
					INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop1 WITH(NOLOCK)
						ON pbs.GuidePieceId = dop1.GuidePiece
					INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder dop WITH(NOLOCK)
						ON dop.Guide_Serie = dop1.GuideSerie
						AND dop.Guide_Number = dop1.GuideNumber
					WHERE CONVERT(char(10), pbs. DateCreated,126) =  CONVERT(CHAR(10), GETDATE(), 126)
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

			SET @Idd = (SELECT TOP 1
					ISNULL(SettlementByPickup.Id, 0)
				FROM DeliveryBackOffice.dbo.SettlementByPickup WITH(NOLOCK)
				WHERE RouteAssigmentId = @IdRouteAssigment
				AND  DateCreated =  CONVERT(CHAR(10), GETDATE(), 126))
			SET @IdManifest = (SELECT TOP 1
					ISNULL(SequenceCode, 0)
				FROM DeliveryBackOffice.dbo.SettlementByPickup WITH(NOLOCK)
				WHERE RouteAssigmentId = @IdRouteAssigment
				AND  DateCreated =  CONVERT(CHAR(10), GETDATE(), 126))

			PRINT '@Idd';
			PRINT @Idd;
			PRINT 'manifiesto';
			PRINT @IdManifest;

		END

		SET @ExisteDetail = (SELECT TOP 1
				ISNULL(COUNT(1), 0)
			FROM DeliveryBackOffice.dbo.SettlementByPickupDetail sbpd WITH(NOLOCK)
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

			---------Implementing Brain to get prices when applicable

			declare @guides nvarchar (MAX) = (select stuff((select DISTINCT ','+concat(GuideSerie,GuideNumber) 
										FROM #listGuidesPieces_Dispatch
										GROUP BY GuideSerie, GuideNumber
											FOR XML PATH ('')),1,1,''))

			declare @TempPrice as table
					(	GuideSerie			nvarchar (25) null,
						GuideNumber			nvarchar (25) null,
						IsCollect			nvarchar (25) null,
						Price				decimal (14,2) null,
						COD					decimal (14,2) null,
						AmountPaid			decimal (14,2) null,
						CODPaid				decimal (14,2) null,
						CODIsPaid			decimal (14,2) null,
						PaymentTime			int null,
						TimeSequence		int null,
						FelNumber			nvarchar (50) null,
						IsPaid				int null,
						IsCustomer			int null,
						ConditionPayment	nvarchar(200) null,
						HaveCredit			nvarchar (50) null,
						CollectCOD			nvarchar (50) null,
						ReturnRate			decimal (14,2) null,
						AmountToPay			decimal (14,2) null,
						CODAmount			decimal (14,2) null,
						ReturnRates			decimal (14,2) null)

			INSERT INTO @TempPrice (GuideSerie,GuideNumber,IsCollect,Price,COD,AmountPaid,CODPaid
				,CODIsPaid,PaymentTime,TimeSequence	,FelNumber,IsPaid,IsCustomer
				,ConditionPayment,HaveCredit,CollectCOD,ReturnRate,AmountToPay,CODAmount,ReturnRates)
			EXEC  [dbo].[spws_get_guide_pending_payment]
				@InGuides = @guides,
				@InTime = 3,
				@IsReturn = 1,
				@CodeApp = 'SIFDCECOM300720201459',
				@IdModule = 1,
				@Token = 'SYSTEM'

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
			IsDispatched,
			Price)
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
				   ,(CASE WHEN tp.AmountToPay > 0 AND tp.HaveCredit = 1 THEN 0.00 ELSE
						  CASE WHEN tp.AmountToPay > 0 AND tp.HaveCredit = 0 THEN tp.AmountToPay ELSE
						  0.00
						  END
					  END) 
				FROM #listGuidesPieces_Dispatch ls
				INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece pc WITH(NOLOCK)
					ON pc.GuideSerie = ls.GuideSerie
						AND pc.GuideNumber = ls.GuideNumber
						AND pc.NoPiece = ls.NoPiece
				INNER JOIN DeliveryBackOffice.dbo.PieceByService pbs WITH(NOLOCK)
					ON pc.GuidePiece = pbs.GuidePieceId
				INNER JOIN DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
					ON pbs.ServiceManagmentId = sm.IdServiceManagement
				INNER JOIN DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK)
					ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
						AND   ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126)
				INNER JOIN @TempPrice tp ON tp.GuideSerie = pc.GuideSerie AND tp.GuideNumber = pc.GuideNumber




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
