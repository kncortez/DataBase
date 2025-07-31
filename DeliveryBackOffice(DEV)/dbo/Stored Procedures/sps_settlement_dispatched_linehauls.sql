
-- =============================================
-- Author:		<Andres,Ruiz>
-- Update date: <2022-07-26>
-- Description:	< Mejora de rendimiento del SP, adicionando WITH(NOLOCK) y especificando tipos de JOIN >
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_dispatched_linehauls]
	@Route INT,
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

		SELECT
			SUBSTRING(Item, 1, 2) ItemSerie
		   ,SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(item)), (CHARINDEX('-', Item) - 3))) ItemNumber
		   ,SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(item)) ItemPiece
		INTO #listGuides
		FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',')

		SET @IdRouteAssigment = (
			SELECT
				ra.IdRouteAssigment
			FROM 
				DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK)
			WHERE 
				ra.IdRoute = @Route
				AND 
				ra.DateOfRoute = @DateOfRoute
		)

		/*LINEHAULS-27072021.INI*/	
		UPDATE 
			DeliveryBackOffice.dbo.RouteAssigment
		SET 
			IdCurrierMan = @IdCourier, 
			IdVehicle    = @IdVehicle
		WHERE 
			(
				IdCurrierMan IS NULL
				OR 
				IdVehicle IS NULL
			)
			AND 
			IdRouteAssigment = @IdRouteAssigment 
			
		UPDATE 
			DeliveryBackOffice.dbo.ServiceManagement
		SET 
			IdPuCourrier = @IdCourier
		WHERE 
			IdPuCourrier IS NULL
			AND 
			IdPuRouteAssigment = @IdRouteAssigment 
			AND 
			IdServiceManagement = @ServiceID
			AND 
			CONVERT(CHAR(10), DateCreated, 126) = @DateOfRoute
		/*LINEHAULS-27072021.FIN*/	


		SELECT 
			X.GuideSerie,
			X.GuideNumber,
			X.NoPiece,
			X.IdHUB
		INTO #listGuidesPieces_Dispatch
		FROM (
				SELECT
					dop.GuideSerie
				   ,dop.GuideNumber
				   ,dop.NoPiece
				   ,hl_destino.IdHublogistic AS IdHUB 
				FROM 
					DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
				INNER JOIN 
					DeliveryBackOffice.dbo.DeliveryOrder serv WITH(NOLOCK)
					ON 
						serv.Guide_Serie = dop.GuideSerie
						AND 
						serv.Guide_Number = dop.GuideNumber		
				INNER JOIN 
					DeliveryBackOffice.dbo.HubLogistics hl_destino WITH(NOLOCK)
					ON 
						serv.HubDestinationId = hl_destino.IdHublogistic
				INNER JOIN 
					#listGuides ls
					ON 
						ls.ItemSerie = dop.GuideSerie
						AND 
						ls.ItemNumber = dop.GuideNumber
				WHERE dop.StatusOrderId = 19		
				UNION 
				SELECT
						dop.GuideSerie
					   ,dop.GuideNumber
					   ,dop.NoPiece
					   ,hl_destino.IdHublogistic AS IdHUB 
					FROM 
						DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
					INNER JOIN 
						DeliveryBackOffice.dbo.DeliveryOrder serv WITH(NOLOCK)
						ON 
							serv.Guide_Serie = dop.GuideSerie
							AND 
							serv.Guide_Number = dop.GuideNumber
					INNER JOIN 
						DeliveryBackOffice.dbo.TownshipByHubLogistic tbh_destino WITH(NOLOCK)
						ON 
							serv.ReceiverIdTownship = tbh_destino.IdTownship
					INNER JOIN 
						DeliveryBackOffice.dbo.HubLogistics hl_destino WITH(NOLOCK)
						ON 
							tbh_destino.IdHublogistic = hl_destino.IdHublogistic
					INNER JOIN 
						#listGuides ls
						ON 
							ls.ItemSerie = dop.GuideSerie
							AND 
							ls.ItemNumber = dop.GuideNumber
					WHERE dop.StatusOrderId = 19 AND tbh_destino.StatusTownshipHub = 1		
				)X
				ORDER BY 
					X.NoPiece ASC

		SELECT
			dop.GuideSerie
		   ,dop.GuideNumber
		   ,dop.NoPiece 
		INTO #listGuidesPieces_NO_Dispatch
		FROM 
			DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
			INNER JOIN 
				#listGuides ls
				ON 
					ls.ItemSerie = dop.GuideSerie
					AND 
					ls.ItemNumber = dop.GuideNumber
		WHERE 
			dop.StatusOrderId != 19
		ORDER BY 
			dop.NoPiece ASC



		IF (
			SELECT 
				TOP 1
					ISNULL(COUNT(1), 0)
			FROM 
				DeliveryBackOffice.dbo.SettlementByPickup WITH(NOLOCK)
			WHERE 
				RouteAssigmentId = @IdRouteAssigment
				AND 
				ServiceManagmentId = @ServiceID
			)
			= 0
		BEGIN
			SET @IdManifest = NEXT VALUE FOR linehauls_IdManifiest;

			INSERT INTO DeliveryBackOffice.dbo.SettlementByPickup (RouteAssigmentId,
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
						SELECT
							COUNT(A.GuideNumber)
						FROM (SELECT DISTINCT
								dop2.GuideNumber
							FROM 
								DeliveryBackOffice.dbo.PieceByService pbs WITH(NOLOCK)
								INNER JOIN 
									DeliveryBackOffice.dbo.DeliveryOrderPiece dop2 WITH(NOLOCK)
									ON 
									dop2.GuidePiece = pbs.GuidePieceId
							WHERE 
								pbs.ServiceManagmentId = @ServiceID) A
					)
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
					FROM 
						DeliveryBackOffice.dbo.PieceByService pbs WITH(NOLOCK)
						INNER JOIN 
							DeliveryBackOffice.dbo.DeliveryOrderPiece dop1 WITH(NOLOCK)
							ON 
								pbs.GuidePieceId = dop1.GuidePiece
						INNER JOIN 
							DeliveryBackOffice.dbo.DeliveryOrder dop WITH(NOLOCK)
							ON 
								dop.Guide_Serie = dop1.GuideSerie
								AND 
								dop.Guide_Number = dop1.GuideNumber
					WHERE 
						pbs.ServiceManagmentId = @ServiceID
						AND 
						ISNULL(dop1.IsDry, 0) = 1
						AND 
						CONCAT( dop1.GuideSerie, dop1.GuideNumber, '-',dop1.NoPiece) IN (SELECT CONCAT(GuideSerie,GuideNumber,'-',NoPiece) FROM #listGuidesPieces_Dispatch)

					UNION ALL
					SELECT
						0 AS TotalDry
					   ,COUNT(ISNULL(dop.Pieces_Cold, 0)) AS TotalCold
					FROM 
						DeliveryBackOffice.dbo.PieceByService pbs WITH(NOLOCK)
						INNER JOIN 
							DeliveryBackOffice.dbo.DeliveryOrderPiece dop1 WITH(NOLOCK)
							ON 
								pbs.GuidePieceId = dop1.GuidePiece
						INNER JOIN 
							DeliveryBackOffice.dbo.DeliveryOrder dop WITH(NOLOCK)
							ON 
								dop.Guide_Serie = dop1.GuideSerie
								AND 
								dop.Guide_Number = dop1.GuideNumber
					WHERE 
						pbs.ServiceManagmentId = @ServiceID
						AND 
						ISNULL(dop1.IsDry, 0) = 0
						AND 
						CONCAT( dop1.GuideSerie, dop1.GuideNumber, '-',dop1.NoPiece) IN (SELECT CONCAT(GuideSerie,GuideNumber,'-',NoPiece) FROM #listGuidesPieces_Dispatch)
				) x

			SET @RUpdated = @@rowcount
			SET @Idd = SCOPE_IDENTITY();

		END
		ELSE
		BEGIN

			SELECT TOP 1
				@Idd = ISNULL(Id, 0),
				@IdManifest = ISNULL(SequenceCode, 0)
				FROM 
					DeliveryBackOffice.dbo.SettlementByPickup WITH(NOLOCK)
					WHERE 
						RouteAssigmentId = @IdRouteAssigment
						AND 
						ServiceManagmentId = @ServiceID

			IF @IdManifest = 0
			BEGIN

				SET @IdManifest = NEXT VALUE FOR linehauls_IdManifiest

				UPDATE 
					DeliveryBackOffice.dbo.SettlementByPickup
				SET 
					DatePrinted = GETDATE(),
					IdCourier = @IdCourier,
					SequenceCode = @IdManifest,
					StartingKilometers = @StartingKilometers,
					DateUpdated = GETDATE(),
					TokenUpdated = @Token
				WHERE 
					Id = @Idd
			END

		END

		SET 
			@ExisteDetail = (SELECT TOP 1 ISNULL(COUNT(1), 0)
		FROM 
			DeliveryBackOffice.dbo.SettlementByPickupDetail sbpd WITH(NOLOCK)
			INNER JOIN 
				#listGuidesPieces_Dispatch ls
				ON 
					sbpd.GuideSerie = ls.GuideSerie
					AND 
					sbpd.GuideNumber = ls.GuideNumber
					AND 
					sbpd.NoPiece = ls.NoPiece
		WHERE 
			SettlementByPickupId = @Idd
			AND 
			sbpd.RowStatus = 1)

		IF (@ExisteDetail = 0
			AND @Idd > 0)
		BEGIN

			INSERT INTO DeliveryBackOffice.dbo.SettlementByPickupDetail (SettlementByPickupId,
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
				INNER JOIN 
					DeliveryBackOffice.dbo.DeliveryOrderPiece pc WITH(NOLOCK)
					ON 
						pc.GuideSerie = ls.GuideSerie
						AND 
						pc.GuideNumber = ls.GuideNumber
						AND 
						pc.NoPiece = ls.NoPiece
				INNER JOIN 
					DeliveryBackOffice.dbo.PieceByService pbs WITH(NOLOCK)
					ON 
						pc.GuidePiece = pbs.GuidePieceId
				INNER JOIN 
					DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
					ON 
						pbs.ServiceManagmentId = sm.IdServiceManagement
				INNER JOIN 
					DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK)
					ON 
						sm.IdPuRouteAssigment = ra.IdRouteAssigment
						AND 
						ra.DateOfRoute = @DateOfRoute


		/*LINEHAULS-27072021.INI*/
		-- Actualizar registro de guía a último estado 

	UPDATE 
		   do
		SET 
			do.StatusOrderId = 19,
			do.Courier_Route = (SELECT CONCAT(CodeRoute,' ',Description) FROM CatRoute WHERE IdRoute = @Route),
			do.Courier_Name  = (SELECT CONCAT(First_Name, ' ', Last_Name) FROM SenderReceiver where ID = @IdCourier)
		FROM 
			DeliveryBackOffice.dbo.DeliveryOrder AS do WITH(NOLOCK)
			INNER JOIN 
				DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK) 
				ON 
					do.Guide_Serie = dop.GuideSerie 
					AND 
					do.Guide_Number = dop.GuideNumber
			INNER JOIN 
				#listGuidesPieces_Dispatch gp
				ON 
					gp.GuideSerie = dop.GuideSerie 
					AND 
					gp.GuideNumber = dop.GuideNumber 
					AND 
					gp.NoPiece = dop.NoPiece
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