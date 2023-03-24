

-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-12-29>
-- Description:	<Guarda información del despacho de entregas.>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-01-12>
-- Description:	<Mejora para manejo de cambio de orden al reasignar o quitar guías.>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-08-05>
-- Description:	< Cambio para uso de orden como decimal y ETA de servicio.>
-- =============================================

CREATE PROCEDURE [dbo].[SetSettlementDispatched]
    -- Add the parameters for the stored procedure here
	@IdRoute INT,
	@IdRoutePreparation INT,
	@Date DATE,
	@DateTime DATETIME,
	@GuidesQuantity INT,
	@PiecesDry SMALLINT,
	@PiecesCold SMALLINT,
    @ListGuides TblGuideOrderETA READONLY,
	@IdVehicle INT,
	@IdCourier INT,
	@CourierName NVARCHAR(200),
	@StartingKilometers NVARCHAR(50),
	@StationId INT,
	@Token NVARCHAR(50),
	@iduser INT=NULL,
	@username NVARCHAR(50)=NULL
AS
BEGIN
	DECLARE @ValidateOperation INT = 0
	-- control de inserción de manifiesto de despacho
	DECLARE @ID_Manifest INT

	DECLARE @GuidesToSendMessage AS TABLE(
		GuideSerie NVARCHAR(2)
		,GuideNumber INT
		,GuideToken NVARCHAR(50)
		,GuideOriginName NVARCHAR(200)
		,GuideDestinyName NVARCHAR(200)
		,GuideOriginPhone NVARCHAR(100)
		,GuideDestinyPhone NVARCHAR(100)
		,GuideOriginAddress NVARCHAR(600)
		,GuideDestinyAddress NVARCHAR(600)
		,IsDelivery BIT
	);

	BEGIN TRANSACTION
		BEGIN TRY
		
			--Desactivar las piezas de las filas si no están incluídas
			UPDATE rpdp
			SET rpdp.RowStatus = 0
				,rpdp.TokenUpdated = @Token
				,rpdp.DateUpdated = GETDATE()
			FROM RoutePreparationDetailPiece rpdp WITH(NOLOCK) 
			inner JOIN RoutePreparationDetail rpd WITH(NOLOCK) 
				ON rpdp.RoutePreparationDetailId = rpd.IdRoutePreparationDetail
				and rpd.RowStatus = 1
			WHERE rpd.RoutePreparationId = @IdRoutePreparation
			AND NOT EXISTS (
				SELECT 1 
				FROM @ListGuides lg
				WHERE lg.Guide_Serie = rpd.Guide_Serie AND lg.Guide_Number = rpd.Guide_Number
			)
			AND rpdp.RowStatus = 1
			
			--Desactivar filas en RoutePreparationDetail si no están incluídas
			UPDATE rpd
			SET rpd.RowStatus = 0
				,rpd.TokenUpdated = @Token
				,rpd.DateUpdated = GETDATE()
			FROM RoutePreparationDetail rpd WITH(NOLOCK) 
			WHERE rpd.RoutePreparationId = @IdRoutePreparation
			AND NOT EXISTS (
				SELECT 1 
				FROM @ListGuides lg
				WHERE lg.Guide_Serie = rpd.Guide_Serie AND lg.Guide_Number = rpd.Guide_Number
			)
			AND rpd.RowStatus = 1

			--Actualizar el registros para la piezas que deseamos reubicar
			UPDATE wh
			SET wh.Active = 0
				,wh.UserUpdated = @Token
				,wh.DateUpdated = GETDATE()
			FROM Warehouse wh WITH(NOLOCK) 
			INNER JOIN @ListGuides lg
				ON wh.Guide_Serie = lg.Guide_Serie AND wh.Guide_Number = lg.Guide_Number
			WHERE wh.Active = 1  

			--- Actualizar el estado de las piezas
			UPDATE dop
			SET
				StatusOrderId = 4
			FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop WITH(NOLOCK) 
			INNER JOIN @ListGuides lg
				ON dop.GuideSerie = lg.Guide_Serie AND dop.GuideNumber = lg.Guide_Number
				
			-- Actualizar registro de guía a estado 4
			UPDATE do
			SET StatusOrderId = 4
				,Courier_Name = @courierName
				,Dispatched_Date = GETDATE()
				,TokenUpdated = @Token
				,DateUpdated = GETDATE()
			FROM DeliveryOrder do WITH(NOLOCK) 
			INNER JOIN @ListGuides lg
				ON do.Guide_Serie = lg.Guide_Serie AND do.Guide_Number = lg.Guide_Number
			
			--operation 1
			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation + 1

			-- Activar bandera de proceso de SMS
			IF((select top 1 ue.UpdateStatus
						from [DeliveryBackOffice].[dbo].[SMS_UpdatedElements] ue WITH(NOLOCK) 
						where ue.RowStatus=1
						and ue.ElementId=1001)=0)
			BEGIN
				update [DeliveryBackOffice].[dbo].[SMS_UpdatedElements]
				set UpdateStatus=1, UpdateDateTime=GETDATE()
				where RowStatus=1
				and ElementId=1001
			END

			-- Insertar nuevo estado de guía en tabla histórica
			INSERT INTO DeliveryOrderDetail (
				[Guide_Serie]
				,[Guide_Number]
				,[StatusOrderId]
				,[UserCreated]
				,[DateCreated]
				,[DateCreatedInSystem])
			SELECT Guide_Serie, Guide_Number, 4, @Token, GETDATE(), GETDATE()
			FROM @ListGuides

			--operation 2
			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation + 1
			

			----------------------------------------------------------
				----------------
				--INICIO --CREANDO ALERTA POR CADA GUÍA QUE HAYA SIDO PUESTO EN RUTA 2 O MAS VECES Y QUE NO POSEAN ALERTA	
				
				IF @iduser IS NOT NULL 
				BEGIN
					DECLARE @SubTypeDelivery BIGINT = (SELECT IdSubTypeServiceManagment FROM SubTypeServiceManagment WHERE [Name] = 'Entrega' AND RowStatus = 1)
					DECLARE @SubTypeReturn BIGINT = (SELECT IdSubTypeServiceManagment FROM SubTypeServiceManagment WHERE [Name] = 'Devolución' AND RowStatus = 1)
					DECLARE @GuidesTableWithRetries TABLE (GuideSerie NVARCHAR(2), GuideNumber INT, SubTypeServiceManagmentId BIGINT, RetriesMade INT);
					DECLARE @CatTypeAlertId INT = (SELECT IdCatTypeAlert FROM CatTypeAlert WHERE AlertName='Prioritario')

					INSERT INTO @GuidesTableWithRetries
						SELECT
							lg.Guide_Serie
						   ,lg.Guide_Number
						   ,(CASE
								WHEN do.IsLastMileReturn = 1 THEN @SubTypeReturn
								ELSE @SubTypeDelivery
							END)
							,(CASE
								WHEN do.IsLastMileReturn = 1 THEN doad.GuideReturnAttemptCount
								ELSE doad.GuideDeliveryAttemptCount
							END)
						FROM @ListGuides lg
						INNER JOIN DeliveryOrderAttemptData doad
							ON lg.Guide_Serie = doad.GuideSerie
								AND lg.Guide_Number = doad.GuideNumber
						INNER JOIN DeliveryOrder do WITH (NOLOCK)
							ON lg.Guide_Serie = do.Guide_Serie
								AND lg.Guide_Number = do.Guide_Number
						LEFT JOIN DeliveryOrderAlert doa WITH (NOLOCK)
							ON lg.Guide_Serie = doa.GuideSerie
								AND lg.Guide_Number = doa.GuideNumber
								AND doa.AlertTypeId = (CASE
									WHEN do.IsLastMileReturn = 1 THEN @SubTypeReturn
									ELSE @SubTypeDelivery
								END)
								AND doa.RowStatus = 1
						WHERE (do.IsLastMileReturn = 1
						AND doad.GuideReturnAttemptCount > 0)
						OR (do.IsLastMileReturn <> 1
						AND doad.GuideDeliveryAttemptCount > 0)
						AND doa.IdDeliveryOrderAlert IS NULL
					
					INSERT INTO DeliveryOrderAlert (GuideSerie,
					GuideNumber,
					ServiceTypeId,
					AlertDescription,
					AlertTypeId,
					RowStatus,
					TokenCreated,
					DateCreated)
						SELECT
							gtwr.GuideSerie
						   ,gtwr.GuideNumber
						   ,gtwr.SubTypeServiceManagmentId
						   ,'Entrega prioritaria'
						   ,@CatTypeAlertId
						   ,1
						   ,@Token
						   ,GETDATE()
						FROM @GuidesTableWithRetries gtwr

					INSERT INTO DBO.DeliveryOrderAlertDetail (author,
					username,
					comment,
					DeliveryOrderAlertId,
					RowStatus,
					TokenCreated,
					DateCreated)
						SELECT
							@iduser
						   ,@username
						   ,'ALERTA: El paquete ya ha salido a ruta ' + CONVERT(NVARCHAR, gtwr.RetriesMade) + ' veces'
						   ,doa.IdDeliveryOrderAlert
						   ,1
						   ,@Token
						   ,GETDATE()
						FROM @GuidesTableWithRetries gtwr
						LEFT JOIN DeliveryOrderAlert doa WITH (NOLOCK)
							ON doa.GuideSerie = gtwr.GuideSerie
								AND doa.GuideNumber = gtwr.GuideNumber
						WHERE doa.AlertTypeId = gtwr.SubTypeServiceManagmentId
						AND doa.RowStatus = 1
					
				END
				--FIN --CREANDO ALERTA POR CADA GUÍA QUE HAYA SIDO PUESTO EN RUTA 2 O MAS VECES Y QUE NO POSEAN ALERTA				
				------------------------------------------------------------------------
			-----------------------------------------------------------

			-- Insertar registro en control de manifiestos de despacho
			INSERT INTO [dbo].[DeliveryOrderBySettlement]
				   ([Date_Printed]
				   ,[User_Dispatched]
				   ,[Date_Dispatched]
				   ,[Pieces_Dry_Dispatched]
				   ,[Pieces_Cold_Dispatched]
				   ,[Guides_Dispatched]
				   ,[User_Received]
				   ,[Date_Received]
				   ,[Pieces_Dry_Received]
				   ,[Pieces_Cold_Received]
				   ,[Guides_Received]
				   ,[ID_Courier]
				   ,[Route_Dispatched]
				   ,[Route_Received]
				   ,[DispatchedStationId]
				   ,[CatVehicleId]
				   ,[CatRouteId]
				   ,[StartingKilometers])
			 VALUES
				   (NULL
				   ,@Token
				   ,GETDATE()
				   ,@PiecesDry
				   ,@PiecesCold
				   ,@GuidesQuantity
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,@IdCourier
				   ,@DateTime
				   ,NULL
				   ,IIF( ISNULL(@StationId,0) > 0, @StationId, NULL)
				   ,@IdVehicle
				   ,@IdRoute
				   ,@StartingKilometers)

			SET @ID_Manifest = SCOPE_IDENTITY()

			--operation 3
			IF (@ID_Manifest > 0)
				SET @ValidateOperation = @ValidateOperation + 1

			-- registrar nuevo intento de entrega
			INSERT INTO DeliveryAttempt (
				[Guide_Serie]
				,[Guide_Number]
				,[Dry]
				,[Cold]
				,[Latitude]
				,[Longitude]
				,[Delivered]
				,[ID_Courier]
				,[ID_DeliveryOrderBySettlement]
				,[User_Created]
				,[Date_Created]
				,[Guide_Piece]) 
			SELECT lg.Guide_Serie, lg.Guide_Number, 
				COALESCE(dop.IsDry,1), CASE WHEN dop.IsDry IS NULL THEN 0 ELSE 1-dop.IsDry END,
				'','',0, @IdCourier, @ID_Manifest, @Token, GETDATE(), dop.NoPiece
			FROM @ListGuides lg
			INNER JOIN DeliveryOrderPiece dop WITH(NOLOCK) 
				ON lg.Guide_Serie = dop.GuideSerie AND lg.Guide_Number = dop.GuideNumber

			--operation 4
			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation + 1

			-- Deshabilitar filas si ya existieran en otro Manifiesto
			UPDATE dsd
			SET dsd.RowStatus = 0,
				dsd.TokenUpdated = @Token,
				dsd.DateUpdated = GETDATE()
			FROM  DeliverySettlementDetail dsd WITH(NOLOCK) 
			INNER JOIN DeliveryOrderBySettlement dobs  WITH(NOLOCK) 
				ON dsd.ID_DeliveryOrderBySettlement = dobs.ID
			INNER JOIN @ListGuides lg
				ON dsd.Guide_Serie = lg.Guide_Serie AND dsd.Guide_Number = lg.Guide_Number
			WHERE dsd.RowStatus = 1
				AND CONVERT(date,dobs.Route_Dispatched) = @Date

			-- Actualizar orden de guías en preparación
			UPDATE rpd
			SET rpd.GuideOrder = IIF(lg.Guide_Order IS NULL, rpd.GuideOrder, lg.Guide_Order), rpd.DateUpdated = GETDATE(), rpd.TokenUpdated = @Token, rpd.ETAGuide = IIF(lg.Guide_ETA IS NULL, rpd.ETAGuide, lg.Guide_ETA)
			FROM RoutePreparationDetail rpd WITH(NOLOCK) 
			INNER JOIN @ListGuides lg
			ON rpd.Guide_Serie = lg.Guide_Serie AND rpd.Guide_Number = lg.Guide_Number
			WHERE rpd.RoutePreparationId = @IdRoutePreparation AND rpd.RowStatus = 1

			-- Insertar información histórica (para propósito de bitácora)
			INSERT INTO DeliverySettlementDetail (
				[ID_DeliveryOrderBySettlement]
				,[Guide_Serie]
				,[Guide_Number]
				,[GuideOrder]
				,[GuideETA]
				,[DateCreated]
				,[TokenCreated])
			SELECT @ID_Manifest,lg.Guide_Serie,lg.Guide_Number,lg.Guide_Order, lg.Guide_ETA,GETDATE(),@Token
			FROM @ListGuides lg
			INNER JOIN RoutePreparationDetail rpd WITH(NOLOCK) 
				ON lg.Guide_Serie = rpd.Guide_Serie AND lg.Guide_Number = rpd.Guide_Number
				AND rpd.RoutePreparationId = @IdRoutePreparation AND rpd.RowStatus = 1

			--operation 5
			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation + 1

			--Actualizar manifiesto en RoutePreparation
			UPDATE RoutePreparation
			SET DeliveryOrderBySettlementId = @ID_Manifest
				,TokenUpdated = @Token
				,DateUpdated = GETDATE()
			WHERE IdRoutePreparation = @IdRoutePreparation

			--operation 6
			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation + 1

			--establecer ruta y fecha de ruta de las guías
			DECLARE @CodeRoute VARCHAR(100) = (SELECT TOP 1 CodeRoute FROM CatRoute WHERE IdRoute = @IdRoute)

			UPDATE do 
			SET do.Courier_Route = @CodeRoute
				,do.Dispatched_Date = @DateTime
			FROM DeliveryOrder do WITH(NOLOCK) 
			INNER JOIN @ListGuides lg
				ON lg.Guide_Serie = do.Guide_Serie
				AND lg.Guide_Number = do.Guide_Number


			--Revalorizar guías collect con priceshipment 0
			DECLARE @GuideSerieRevalue NVARCHAR(2)
			DECLARE @GuideNumberRevalue INT
			DECLARE @RevalueGuides AS TABLE(
				GuideSerie NVARCHAR(2)
				,GuideNumber INT
			)
			DECLARE @CatModuleId INT = (SELECT TOP 1 ModIdModule FROM CatModule WHERE ModPath = 'frmCheckpoint')

			INSERT INTO @RevalueGuides
				SELECT
					lg.Guide_Serie
				   ,lg.Guide_Number
				FROM @ListGuides lg
				INNER JOIN DeliveryOrder do WITH (NOLOCK)
					ON do.Guide_Serie = lg.Guide_Serie
						AND do.Guide_Number = lg.Guide_Number
				WHERE do.PriceShippment = 0
				AND do.IsCollect = 1


			WHILE EXISTS (SELECT TOP 1 1 FROM @RevalueGuides)
			BEGIN
				SELECT TOP 1
					@GuideSerieRevalue = GuideSerie
				   ,@GuideNumberRevalue = GuideNumber
				FROM @RevalueGuides

				EXECUTE DeliveryBackOffice.dbo.spws_revalue_guide
					@GuideSerie = @GuideSerieRevalue,
					@GuideNumber = @GuideNumberRevalue,
					@CodeApp = '',
					@Format = 'Non',
					@CalculateTaxes = 'true',
					@IdModule = @CatModuleId,
					@SetUpdate = 'true',
					@Token = @Token,
					@IsReturn = 'false'

				DELETE FROM @RevalueGuides
				WHERE GuideSerie = @GuideSerieRevalue
					AND GuideNumber = @GuideNumberRevalue
			END
			--Termina revalorziar guías
			
			-- Manejo de envío de mensajitos de whatsapp en despacho
			INSERT INTO [DeliveryBackOffice].[dbo].[ServiceDataForGuide]
				( 
					GuideSerie
					, GuideNumber
					, IsDelivery
					, IsInRoute
					, GuideToken
					, RowStatus
					, DateCreated
					, TokenCreated 
				)
			OUTPUT 
				inserted.GuideSerie
				, inserted.GuideNumber
				, inserted.GuideToken
				, inserted.IsDelivery 
			INTO 
				@GuidesToSendMessage
				(
					GuideSerie
					, GuideNumber
					, GuideToken
					, IsDelivery
				)
			SELECT
				DISTINCT
				LG.Guide_Serie
				, LG.Guide_Number
				, 1 -- ~DO.IsLastMileReturn cuando se integre DOHKO
				, 1
				, CONCAT(LG.Guide_Serie, LG.Guide_Number, RIGHT ('00000'+CAST( ( (FLOOR(RAND()*(99999-0+1))+0) ) AS NVARCHAR),5))
				--, CONCAT(LG.Guide_Serie, LG.Guide_Number, RIGHT ('00000'+CAST( ( (FLOOR(RAND(LG.Guide_Number + CAST(FORMAT(GETDATE(),'MMyyyymmss','en') AS INT) )*(99999-0+1))+0) ) AS NVARCHAR),5))
				
				, 1
				, GETDATE()
				, @Token
			FROM
				@ListGuides LG
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
					ON
						LG.Guide_Serie = DO.Guide_Serie
						AND
						LG.Guide_Number = DO.Guide_Number

			UPDATE
				GTSM
			SET
				GuideOriginPhone = ISNULL(DO.Sender_Phone, '')
				,GuideDestinyPhone = ISNULL(DO.Receiver_Phone, '')
				,GuideOriginName = LTRIM(RTRIM(CONCAT(DO.Sender_FirstName, ' ',DO.Sender_LastName)))
				,GuideDestinyName = LTRIM(RTRIM(CONCAT(DO.Receiver_FirstName, ' ', DO.Receiver_LastName)))
				,GuideOriginAddress = Sender_Address
				,GuideDestinyAddress = Receiver_Address
			FROM
				@GuidesToSendMessage GTSM
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
					ON
						GTSM.GuideSerie = DO.Guide_Serie
						AND
						GTSM.GuideNumber = DO.Guide_Number
			-- Manejo de envío de mensajitos de whatsapp en despacho

			-----------------------------------------------------------------------------------------------------------------
			--FDD-975 ACTUALIZACIÓN DE  INFORMACIÓN DE COURIER Y VEHÍCULO DE ASIGNACIÓN DE RUTA AL DESPACHAR UNA RUTA DE ENTREGA
			UPDATE RA SET
				RA.IdCurrierMan=@IdCourier,
				RA.IdVehicle=@IdVehicle,
				RA.TokenUpdated=@Token,
				RA.DateUpdated=GETDATE()
			FROM DBO.RoutePreparationDetail RPD WITH(NOLOCK)
				INNER JOIN DBO.ServiceManagementDetail SMD WITH(NOLOCK) 
					ON RPD.ServiceManagementDetailId=SMD.IdServiceManagementDetail
				INNER JOIN DBO.ServiceManagement SM WITH(NOLOCK)
					ON SM.IdServiceManagement=SMD.ServiceManagement
				INNER JOIN DBO.RouteAssigment RA WITH(NOLOCK) 
					ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
			WHERE
				RPD.RoutePreparationId = @IdRoutePreparation;

			DECLARE @IdRouteAssigment INT= (SELECT TOP 1 IdRouteAssigment FROM dbo.RouteAssigment RA WITH(NOLOCK) WHERE IdRoute = @IdRoute AND DateOfRoute=@Date AND RA.IdCurrierMan=@IdCourier)

			UPDATE  SM SET
				SM.IdPuCourrier=@IdCourier,
				SM.IdPuRouteAssigment=@IdRouteAssigment
			FROM @ListGuides LG  
				INNER JOIN DBO.RoutePreparationDetail RPD WITH(NOLOCK)
					ON RPD.Guide_Serie=LG.Guide_Serie
					AND RPD.Guide_Number=LG.Guide_Number
				INNER JOIN DBO.ServiceManagementDetail SMD WITH(NOLOCK)
					ON RPD.ServiceManagementDetailId=SMD.IdServiceManagementDetail
				INNER JOIN DBO.ServiceManagement SM  WITH(NOLOCK) 
					ON SM.IdServiceManagement=SMD.ServiceManagement
				LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD  WITH(NOLOCK) ON 							
					URSD.GuideSerie=RPD.Guide_Serie
					AND URSD.GuideNumber=RPD.Guide_Number
					AND URSD.RowStatus=1
					AND URSD.ServiceManagementId=SM.IdServiceManagement
				LEFT JOIN DBO.UnifiedRouteSettlement URS WITH(NOLOCK) ON
					URSD.UnifiedRouteSettlementId=URS.IdUnifiedRouteSettlement
				LEFT JOIN DBO.RouteAssigment RA WITH(NOLOCK) ON
					RA.IdRouteAssigment= URS.RouteAssignmentId
			WHERE URS.UserSettlement IS NULL AND RA.DateOfRoute=CONVERT(DATE,GETDATE()) AND RA.IdCurrierMan=@IdCourier
			-----------------------------------------------------------------------------------------------------------------

		END TRY
		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			ROLLBACK TRANSACTION

			INSERT INTO dbo.RoutePreparationLogError
			(
				ErrorDescription,
				ErrorNumber,
				ErrorProcedure,
				ErrorLine,
				GuideSerie,
				GuideNumber,
				TokenCreated,
				DateCreated
			)
			VALUES
			 (
				CAST(ERROR_MESSAGE() AS VARCHAR(300))
				,ERROR_NUMBER()
				,CAST(ERROR_PROCEDURE() AS VARCHAR(100))
				,ERROR_LINE()
				,''
				,0
				,CONCAT('Error en manifiesto ', ISNULL(@CodeRoute,CAST(@IdRoute AS NVARCHAR)))
				,GETDATE()
			)
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@ValidateOperation = 6)
			BEGIN
				COMMIT TRANSACTION
				SELECT			  
					@ID_Manifest AS 'StatusCode',
					'Registros guardados correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID'

				SELECT
					GTSM.GuideSerie
					,GTSM.GuideNumber
					,GTSM.GuideToken
					,CAST(ISNULL(GTSM.IsDelivery, 0) AS BIT) 'IsDelivery'
					,GTSM.GuideOriginName
					,GTSM.GuideDestinyName
					,GTSM.GuideOriginPhone
					,GTSM.GuideDestinyPhone
					,GTSM.GuideOriginAddress
					,GTSM.GuideDestinyAddress
				FROM
					@GuidesToSendMessage GTSM
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION
				SELECT			  
					0 AS 'StatusCode',
					CONCAT('Registros no guardados','-',@ValidateOperation) AS 'Description', 
					0 AS 'NumTransferID'
			END		
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'

END;