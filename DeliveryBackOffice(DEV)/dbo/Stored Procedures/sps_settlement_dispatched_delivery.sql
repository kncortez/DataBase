

CREATE PROCEDURE [dbo].[sps_settlement_dispatched_delivery] 
	@Route NVARCHAR(20),
	@Token NVARCHAR(50),
	@PiecesDry SMALLINT,
	@PiecesCold SMALLINT,
	@GuidesQuantity SMALLINT,
	@InGuides NVARCHAR(400) = 'FD22221-1,FD22361-1,FD22223-2,FD22359-1,FD22226-1',
	@IdCourier INT,
	@DateRoute AS VARCHAR(50),
	@StartingKilometers AS VARCHAR(100),	
	@IdManifest INT
AS
BEGIN
	-- control de actualizaciones para transacción
	DECLARE @RUpdated INT
	DECLARE @Idd INT
	--DECLARE @IdManifest INT
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

		SELECT
			SUBSTRING(Item, 1, 2) ItemSerie
		   ,SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(item)), (CHARINDEX('-', Item) - 3))) ItemNumber
		   ,SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(item)) ItemPiece
		INTO #listGuides
		FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides, ',')

		SET @IdRouteAssigment = (SELECT ra.IdRouteAssigment
								FROM RouteAssigment ra WITH(NOLOCK)
								WHERE ra.IdRoute = CAST(@Route AS INT) AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126))

		SELECT
			dop.GuideSerie,
			dop.GuideNumber,
			dop.NoPiece
		INTO #listGuidesPieces_Dispatch
		FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder serv WITH(NOLOCK) ON serv.Guide_Serie = dop.GuideSerie AND serv.Guide_Number = dop.GuideNumber
			INNER JOIN #listGuides ls ON ls.ItemSerie = dop.GuideSerie AND ls.ItemNumber = dop.GuideNumber
		WHERE dop.StatusOrderId = 4
		ORDER BY dop.NoPiece ASC

		SELECT
			dop.GuideSerie,
			dop.GuideNumber,
			dop.NoPiece 
		INTO #listGuidesPieces_NO_Dispatch
		FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
			INNER JOIN #listGuides ls ON ls.ItemSerie = dop.GuideSerie AND ls.ItemNumber = dop.GuideNumber
		WHERE dop.StatusOrderId != 4
		ORDER BY dop.NoPiece ASC		

		IF (SELECT TOP 1 ISNULL(COUNT(1), 0)
			FROM SettlementByPickup WITH(NOLOCK)
			WHERE RouteAssigmentId = @IdRouteAssigment and DateCreated =  CONVERT(CHAR(10), GETDATE(), 126)) = 0
		BEGIN

			---SET @IdManifest = NEXT VALUE FOR delivery_IdManifiest
			
			PRINT 'ingresa a insertar settlementbypickup'
			
			INSERT INTO dbo.SettlementByPickup (
				RouteAssigmentId,
				DatePrinted,
				TokenCreated,
				DateCreated,
				PiecesDry,
				PiecesCold,
				GuidesQuantity,
				PiecesDryReceived,
				PiecesColdReceived,
				GuidesQuantityReceived, 
				IdCourier,
				SequenceCode, 
				SubTypeServiceManagmentId, 
				StartingKilometers, 
				ArrivalKilometers, 
				ServiceManagmentId)
			SELECT
				@IdRouteAssigment,
				GETDATE(),
				@Token,
				GETDATE(),
				SUM(x.TotalDry),
				SUM(x.TotalCold),
				(SELECT COUNT(A.GuideNumber)
				FROM (SELECT DISTINCT dop2.GuideNumber
					FROM PieceByService pbs WITH(NOLOCK)
						INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop2 WITH(NOLOCK) ON dop2.GuidePiece = pbs.GuidePieceId
					WHERE pbs.DateCreated =  CONVERT(CHAR(10), GETDATE(), 126)) A)
				,NULL,
				NULL,
				NULL,
				@IdCourier,
				@IdManifest,
				2,
				@StartingKilometers,
				NULL,
				null
			FROM (SELECT COUNT(ISNULL(dop.Pieces_Dry, 0)) AS TotalDry,
					0 AS TotalCold
					FROM PieceByService pbs WITH(NOLOCK)
						INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop1 WITH(NOLOCK) ON pbs.GuidePieceId = dop1.GuidePiece
						INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder dop WITH(NOLOCK) ON dop.Guide_Serie = dop1.GuideSerie AND dop.Guide_Number = dop1.GuideNumber
					WHERE CONVERT(char(10), pbs. DateCreated,126) =  CONVERT(CHAR(10), GETDATE(), 126) AND ISNULL(dop1.IsDry, 0) = 1
					UNION ALL
					SELECT
						0 AS TotalDry,
						COUNT(ISNULL(dop.Pieces_Cold, 0)) AS TotalCold
					FROM PieceByService pbs WITH(NOLOCK)
						INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop1 WITH(NOLOCK) ON pbs.GuidePieceId = dop1.GuidePiece
						INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder dop WITH(NOLOCK) ON dop.Guide_Serie = dop1.GuideSerie AND dop.Guide_Number = dop1.GuideNumber
					WHERE CONVERT(char(10), pbs. DateCreated,126) =  CONVERT(CHAR(10), GETDATE(), 126) AND ISNULL(dop1.IsDry, 0) = 0
				) x

			SET @Idd = SCOPE_IDENTITY();

			PRINT '@Idd';
			PRINT @Idd;

		END
		ELSE
		BEGIN
			PRINT 'ingresa en else'

			SET @Idd = (SELECT TOP 1
							ISNULL(SettlementByPickup.Id, 0)
						FROM SettlementByPickup WITH(NOLOCK)
						WHERE RouteAssigmentId = @IdRouteAssigment AND  DateCreated =  CONVERT(CHAR(10), GETDATE(), 126))

			SET @IdManifest = (SELECT TOP 1
									ISNULL(SequenceCode, 0)
								FROM SettlementByPickup WITH(NOLOCK)
								WHERE RouteAssigmentId = @IdRouteAssigment AND  DateCreated =  CONVERT(CHAR(10), GETDATE(), 126))

			PRINT '@Idd';
			PRINT @Idd;
			PRINT 'manifiesto';
			PRINT @IdManifest;

		END

		SET @ExisteDetail = (SELECT TOP 1 ISNULL(COUNT(1), 0)
							FROM SettlementByPickupDetail sbpd WITH(NOLOCK)
								INNER JOIN #listGuidesPieces_Dispatch ls ON sbpd.GuideSerie = ls.GuideSerie
								AND sbpd.GuideNumber = ls.GuideNumber
								AND sbpd.NoPiece = ls.NoPiece
							WHERE SettlementByPickupId = @Idd AND sbpd.RowStatus = 1)
		
		PRINT '@ExisteDetail'
		PRINT @ExisteDetail


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
				@Idd,
				pc.GuideSerie,
				pc.GuideNumber,
				1,
				@Token,
				GETDATE(),
				NULL,
				NULL,
				0,
				pc.NoPiece,
				1
			FROM #listGuidesPieces_Dispatch ls
				INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece pc WITH(NOLOCK) ON pc.GuideSerie = ls.GuideSerie
						AND pc.GuideNumber = ls.GuideNumber
						AND pc.NoPiece = ls.NoPiece
				INNER JOIN dbo.PieceByService pbs WITH(NOLOCK) ON pc.GuidePiece = pbs.GuidePieceId
				INNER JOIN ServiceManagement sm WITH(NOLOCK) ON pbs.ServiceManagmentId = sm.IdServiceManagement
				INNER JOIN RouteAssigment ra WITH(NOLOCK) ON sm.IdDlRouteAssigment = ra.IdRouteAssigment
					AND   ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126)

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
