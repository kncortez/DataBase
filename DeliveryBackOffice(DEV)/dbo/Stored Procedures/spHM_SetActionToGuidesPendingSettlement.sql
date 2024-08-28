-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-10-12>
-- Description:	<Realiza acciones para guías pendientes de liquidar en liquidación de rutas unificadas>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_SetActionToGuidesPendingSettlement]
	-- Add the parameters for the stored procedure here
	@Action TINYINT, --1=entrega, 2=devuelto, 3=traslado, 4=incidencia, 5=extraviado
	@CourierId INT,
	@ReceiverName NVARCHAR(200) = '',
	@GuideSerie NVARCHAR(2) = '',
	@GuideNumber INT = 0,
	@ServiceManagementId INT = 0,
	@CodeOfReference INT = 0,
	@IncidenceTypeId INT = 0,
	@Observations NVARCHAR(200) = '',
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TimesDelivered INT
	DECLARE @StatusOrderId INT
	DECLARE @IsValidOperation BIT = 1
	DECLARE @Register BIT = 0

	DECLARE @CatModuleId INT
	DECLARE @COD DECIMAL(14,2)
	DECLARE @IdCustomer INT
	DECLARE @COLLECT INT = 0

	DECLARE @ErrorCode INT = 0
	DECLARE @ErrorDescription NVARCHAR(100);

	DECLARE @CanceledStatusId INT
	DECLARE @IncidenceDescription VARCHAR(200)

	--- Variables para manejo de piezas
	DECLARE @GuideExists BIT;

	--- Variables para manejo de ruta unificada
	DECLARE @UserSettlement NVARCHAR(50);
	DECLARE @IdUnifiedRouteSettlement INT;
	DECLARE @IdUnifiedRouteSettlementDetail INT;
	DECLARE @IdUnifiedRouteSettlementDetailPiece INT;

	--- Variables para control de RouteAssignment
	DECLARE @RouteAssignmentId INT
	DECLARE @RouteAssignmentCourierId INT

	--- Control de monto de servicio y COD
	DECLARE @IsCollect BIT = 0
	DECLARE @HasInsurance BIT = 0
	DECLARE @IsLastMileReturn BIT = 0
	DECLARE @ServiceAmount DECIMAL(14,2) = 0
	DECLARE @CODAmount DECIMAL(14,2) = 0
	DECLARE @InsuranceAmount DECIMAL(14,2) = 0

	--- Control de piezas
	DECLARE @GuidePiece INT
	DECLARE @GuidePieceIsDry BIT
	DECLARE @Pieces AS TABLE(
		NoPiece INT,
		IsDry BIT
	)

	BEGIN TRANSACTION

	BEGIN TRY 

		-- Si es una guía
		IF @GuideNumber <> 0
		BEGIN

			--- Verificar si la pieza existe
			SELECT
				@GuideExists = 1
			FROM DeliveryOrderPiece dop WITH (NOLOCK)
			WHERE dop.GuideSerie = @GuideSerie
			AND dop.GuideNumber = @GuideNumber

			IF @GuideExists = 1
			BEGIN

				-- Si es entrega
				IF @Action = 1
				BEGIN

					SET @StatusOrderId = (SELECT so.StatusOrderId FROM StatusOrder so WITH (NOLOCK) WHERE so.OrderDescription = 'Entregado')

					-- Buscar si la guía ya cuenta con estado de entrega previa, en caso que exista no se procede a registrar transacción para evitar registro duplicado
					SET @TimesDelivered = (SELECT
							COUNT(1)
						FROM DeliveryOrderDetail dod WITH (NOLOCK)
						INNER JOIN StatusOrder so WITH (NOLOCK)
							ON dod.StatusOrderId = so.StatusOrderId
						WHERE dod.Guide_Serie = @GuideSerie
						AND dod.Guide_Number = @GuideNumber
						AND so.OrderDescription IN ('Entregado', 'Devuelto', 'Traslado a Express Center', 'Entregado En Express Center', 'Devuelto en Express Center'))

					IF @TimesDelivered = 0
					BEGIN 
				
						-- Actualizar registro de pieza a último estado 
						UPDATE DeliveryOrderPiece
						SET StatusOrderId = @StatusOrderId
						WHERE GuideSerie = @GuideSerie
						AND GuideNumber = @GuideNumber

						-- Actualizar registro de guía a último estado 
						UPDATE DeliveryOrder
						SET StatusOrderId = @StatusOrderId
						   ,NameOfReceiver = @ReceiverName
						WHERE Guide_Serie = @GuideSerie
						AND Guide_Number = @GuideNumber		

						-- Insertar nuevo estado de guía en tabla histórica
						INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail ([Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated], [DateCreatedInSystem])
							VALUES (@GuideSerie, @GuideNumber, @StatusOrderId, @Token, GETDATE(), GETDATE())
				
						-----------------WEBHOOK.INI-----------------------		
						DECLARE @WebhookCustomerId INT = -1;
						DECLARE @CustomerEndpointId INT = -1;
						-- Debido a que se procesa únicamente 1 guía
						DECLARE @GuideCurrentStatus INT = -1;

						BEGIN TRY
							DECLARE @GuideStatusChangeWebhook INT = (SELECT TOP 1 WT.IdWebhookType FROM [DeliveryBackOffice].[dbo].[WebhookType] WT WITH(NOLOCK) WHERE WT.WebhookName = 'GuideStatusChange' AND WT.RowStatus = 1);

							SET @WebhookCustomerId = ISNULL((SELECT TOP 1 DO.IdCustomer FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Number = @GuideNumber AND DO.Guide_Serie = @GuideSerie),-1);
							SET @CustomerEndpointId = ISNULL((SELECT TOP 1 WE.IdWebhookEndpoint FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK) WHERE WE.CustomerId = @WebhookCustomerId AND  WE.WebhookTypeId = @GuideStatusChangeWebhook),-1);

							SET @GuideCurrentStatus = (SELECT TOP 1 DO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Number = @GuideNumber AND DO.Guide_Serie = @GuideSerie);

							-- Cliente tiene webhook configurado para el tipo especificado
							-- Estado actual de la guía coincide dentro de las restricciónes por usuario
							IF ( @WebhookCustomerId > 0 AND @CustomerEndpointId > 0 AND @GuideCurrentStatus IN (SELECT WRBU.StatusOrderId FROM [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH(NOLOCK) WHERE WRBU.CustomerId = @WebhookCustomerId AND WRBU.WebhookTypeId = @GuideStatusChangeWebhook) )
							BEGIN 

								DECLARE @ResponseTable AS TABLE (
									InsertedId BIGINT
								);

								DECLARE @TypeConnect INT = 0;

						SET @TypeConnect = (SELECT top 1 TypeConnectionId 
								FROM WebhookEndpoint wh
								INNER JOIN WebhookCatTypeConnection wc
									ON wh.TypeConnectionId = wc.IdCatTypeConnection
								WHERE wh.CustomerId = @WebhookCustomerId)

						IF(@TypeConnect = 1)
							 BEGIN

								INSERT INTO 
									[DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
									(
										[GuideSerie]
										,[GuideNumber]
										,[CustomerId]
										,[StatusOrderId]
										,[WebhookEndpointId]
										,[HasNotified]
										,[TokenCreated]
										,[DateCreated]
									)
								OUTPUT inserted.IdWebhookTrackingQueue INTO @ResponseTable (InsertedId)
								VALUES
									(
										@GuideSerie
										,@GuideNumber
										,@WebhookCustomerId
										,@GuideCurrentStatus
										,@CustomerEndpointId
										,0
										,@Token
										,GETDATE()
									)

							END
						ELSE
							BEGIN
								-----------------------------------
									 DECLARE @GuidePiecesTable AS TABLE
									(
									    CustomerId INT,
									    CustomerEndpointId BIGINT,
									    WebhookType INT,
									    GuideSerie NVARCHAR(2),
									    GuideNumber INT,
									    GuideStatusId TINYINT,
										NumberPieces INT,
										NumberRelatedPieces INT
										
									);

									INSERT INTO @GuidePiecesTable 
												( 
											CustomerId,
									        GuideSerie,
									        GuideNumber,
									        GuideStatusId,
											NumberPieces
											)
											SELECT @WebhookCustomerId,
											dop.GuideSerie,dop.GuideNumber, 
											@GuideCurrentStatus,
											Count(dop.GuideNumber)
											FROM DeliveryOrder do WITH(NOLOCK)
											INNER JOIN DeliveryOrderPiece dop WITH(NOLOCK)
												ON do.Guide_Number = dop.GuideNumber
												INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
											    ON do.IdCustomer = WHE.CustomerId
												WHERE do.Guide_Number = @GuideNumber
													AND WHE.TypeConnectionId = 2
												GROUP BY dop.GuideSerie,dop.GuideNumber

									   DECLARE @PiecesGuideRelatedTable AS TABLE
									(
									    CustomerId INT,
									    CustomerEndpointId BIGINT,
									    WebhookType INT,
									    GuideSerie NVARCHAR(2),
									    GuideNumber INT,
									    GuideStatusId TINYINT,
										NumberRelatedPieces INT
										
									);

									INSERT INTO @PiecesGuideRelatedTable 
												( 
											CustomerId,
									        GuideSerie,
									        GuideNumber,
									        GuideStatusId,
											NumberRelatedPieces
											)
											SELECT @WebhookCustomerId,
											dop.GuideSerie,dop.GuideNumber, 
											@GuideCurrentStatus,
											Count(dop.GuideNumber)
											FROM DeliveryOrder do WITH(NOLOCK)
											INNER JOIN DeliveryOrderPiece dop WITH(NOLOCK)
												ON do.Guide_Number = dop.GuideNumber
												INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
											    ON do.IdCustomer = WHE.CustomerId
												WHERE do.Guide_Number = @GuideNumber
												AND dop.ExternalPieceId IS NOT NULL
												AND WHE.TypeConnectionId = 2
												GROUP BY dop.GuideSerie,dop.GuideNumber
					  
					  					INSERT INTO WebhookTrackingQueueDetailForSFTP 
											(CustomerId,
											GuideSerie,
											GuideNumber,
											GuidePiece,
											ExternalNumber,
											ExternalPieceId,
											StatusOrderId,
											RowStatus,
											DateCreated,
											TokenCreated)
										SELECT @WebhookCustomerId,
										dop.GuideSerie,dop.GuideNumber, dop.NoPiece, do.Ticket_Number,dop.ExternalPieceId, 
										@GuideCurrentStatus, 1 AS RowStatus, GETDATE()AS DateCreated,@Token AS TokenCreated
										FROM DeliveryOrderPiece dop WITH(NOLOCK)
										INNER JOIN DeliveryOrder do WITH(NOLOCK)
											ON dop.GuideNumber = do.Guide_Number
										INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
										    ON do.IdCustomer = WHE.CustomerId
										INNER JOIN @GuidePiecesTable gpt
										    ON dop.GuideNumber = gpt.GuideNumber
										INNER JOIN @PiecesGuideRelatedTable pgt
										    ON gpt.GuideNumber = pgt.GuideNumber
											WHERE gpt.NumberPieces = pgt.NumberRelatedPieces
												AND WHE.TypeConnectionId = 2

							END

							END
						END TRY
						BEGIN CATCH

						END CATCH
						-------------------WEBHOOK.FIN------------------------------	
					END

				

					-- se obtiene COD de la guía
					SELECT
						@COD = do.Collect_OnDelivery
					   ,@IdCustomer = cu.IdCustomer
					   ,@COLLECT = IIF(do.IsCollect = 1 AND NOT EXISTS (SELECT
								1
							FROM Cost C WITH (NOLOCK)
							INNER JOIN CostDetail CD WITH (NOLOCK)
								ON CD.IdCost = C.IdCost
								AND CD.IdTypeOfMoney IN (2, 6)
							WHERE C.ProductNumber = CONCAT(do.Guide_Serie, CAST(do.Guide_Number AS VARCHAR(50))))
						, 1, 0)
					FROM DeliveryOrder do WITH (NOLOCK)
					LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
						ON vp.CodeOfReference = do.Sender_ID
					LEFT JOIN Customer cu WITH (NOLOCK)
						ON cu.IdCustomer = ISNULL(do.IdCustomer, vp.CustomerID)
					WHERE do.Guide_Serie = @GuideSerie
					AND do.Guide_Number = @GuideNumber

					-- se verifica que no exita en ProcessGuideCOD Y COD > 0
					IF (@COD > 0
						OR @COLLECT = 1)
						AND NOT EXISTS (SELECT
								1
							FROM DeliveryBackOffice.dbo.ProcessedGuideCOD WITH (NOLOCK)
							WHERE GuideSerie = @GuideSerie
							AND GuideNumber = @GuideNumber)
					BEGIN

						--Buscar ID modulo liquidación COD
						SET @CatModuleId = ISNULL((SELECT
								ModIdModule
							FROM DeliveryBackOffice.dbo.CatModule WITH (NOLOCK)
							WHERE ModName = 'Confirmación de Entrega')
						, 0)

						INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD (GuideSerie
						, GuideNumber
						, CourierManId
						, Date
						, BatchCODId
						, BatchCODIdCommission
						, DataOriginId
						, Notificated
						, Token
						, CustomerID)
							VALUES (@GuideSerie, @GuideNumber, @CourierId, GETDATE(), NULL, NULL, @CatModuleId, 0, @Token, @IdCustomer)

					END
					ELSE
					IF EXISTS (SELECT
								1
							FROM DeliveryOrder ord WITH (NOLOCK)
							INNER JOIN DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
								ON ord.Guide_Serie = DOP.GuideSerie
								AND ord.Guide_Number = DOP.GuideNumber
							LEFT JOIN VisitPointClient vp WITH (NOLOCK)
								ON vp.CodeOfReference = ord.Sender_ID
							LEFT JOIN Customer cus WITH (NOLOCK)
								ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
							WHERE ord.Guide_Serie = @GuideSerie
							AND ord.Guide_Number = @GuideNumber
							AND ord.IsCollect = 'false'
							AND DOP.TimePlaId = 2
							AND NOT EXISTS (SELECT
									1
								FROM Cost C WITH (NOLOCK)
								INNER JOIN CostDetail CD WITH (NOLOCK)
									ON CD.IdCost = C.IdCost
									AND CD.IdTypeOfMoney IN (2, 6)
								WHERE C.ProductNumber = CONCAT(ord.Guide_Serie, CAST(ord.Guide_Number AS VARCHAR(50))))
							AND NOT EXISTS (SELECT
									1
								FROM ProcessedGuideCOD WITH (NOLOCK)
								WHERE GuideSerie = @GuideSerie
								AND GuideNumber = @GuideNumber))

					BEGIN
						--Buscar ID modulo liquidación COD
						SET @CatModuleId = ISNULL((SELECT
								ModIdModule
							FROM DeliveryBackOffice.dbo.CatModule WITH (NOLOCK)
							WHERE ModName = 'Confirmación de Entrega')
						, 0)

						INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD (GuideSerie
						, GuideNumber
						, CourierManId
						, Date
						, BatchCODId
						, BatchCODIdCommission
						, DataOriginId
						, Notificated
						, Token
						, CustomerId)
							VALUES (@GuideSerie, @GuideNumber, @CourierId, GETDATE(), NULL, NULL, @CatModuleId, 0, @Token, @IdCustomer)

					END

					SET @Register = 1
				END
				-- Si es devolución
				ELSE IF @Action = 2 -- 
				BEGIN
				
					SET @StatusOrderId = (SELECT so.StatusOrderId FROM StatusOrder so WITH (NOLOCK) WHERE so.OrderDescription = 'Devuelto')

					-- Buscar si la guía ya cuenta con estado de entrega previa, en caso que exista no se procede a registrar transacción para evitar registro duplicado
					SET @TimesDelivered = (SELECT
							COUNT(1)
						FROM DeliveryOrderDetail dod WITH (NOLOCK)
						INNER JOIN StatusOrder so WITH (NOLOCK)
							ON dod.StatusOrderId = so.StatusOrderId
						WHERE dod.Guide_Serie = @GuideSerie
						AND dod.Guide_Number = @GuideNumber
						AND so.OrderDescription IN ('Entregado', 'Devuelto', 'Traslado a Express Center', 'Entregado En Express Center', 'Devuelto en Express Center'))

					IF @TimesDelivered = 0
					BEGIN 
				
						-- Actualizar registro de pieza a último estado 
						UPDATE DeliveryOrderPiece
						SET StatusOrderId = @StatusOrderId
						WHERE GuideSerie = @GuideSerie
						AND GuideNumber = @GuideNumber

						-- Actualizar registro de guía a último estado 
						UPDATE DeliveryOrder
						SET StatusOrderId = @StatusOrderId
						   ,NameOfReceiver = @ReceiverName
						WHERE Guide_Serie = @GuideSerie
						AND Guide_Number = @GuideNumber		

						-- Insertar nuevo estado de guía en tabla histórica
						INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail ([Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated], [DateCreatedInSystem])
							VALUES (@GuideSerie, @GuideNumber, @StatusOrderId, @Token, GETDATE(), GETDATE())
					END

					-- se obtiene información de la guía
					SELECT
						@IdCustomer = cu.IdCustomer
					   ,@COLLECT = IIF(do.IsCollect = 1 AND NOT EXISTS (SELECT
								1
							FROM Cost C WITH (NOLOCK)
							INNER JOIN CostDetail CD WITH (NOLOCK)
								ON CD.IdCost = C.IdCost
								AND CD.IdTypeOfMoney IN (2, 6)
							WHERE C.ProductNumber = CONCAT(do.Guide_Serie, CAST(do.Guide_Number AS VARCHAR(50))))
						, 1, 0)
					FROM DeliveryOrder do WITH (NOLOCK)
					LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
						ON vp.CodeOfReference = do.Sender_ID
					LEFT JOIN Customer cu WITH (NOLOCK)
						ON cu.IdCustomer = ISNULL(do.IdCustomer, vp.CustomerID)
					WHERE do.Guide_Serie = @GuideSerie
					AND do.Guide_Number = @GuideNumber

					-- se verifica que no exita en ProcessGuideCOD Y COD > 0
					IF (@COLLECT = 1)
						AND NOT EXISTS (SELECT
								1
							FROM DeliveryBackOffice.dbo.ProcessedGuideCOD WITH (NOLOCK)
							WHERE GuideSerie = @GuideSerie
							AND GuideNumber = @GuideNumber)
					BEGIN

						--Buscar ID modulo liquidación COD
						SET @CatModuleId = ISNULL((SELECT
								ModIdModule
							FROM DeliveryBackOffice.dbo.CatModule WITH (NOLOCK)
							WHERE ModName = 'Confirmación de Entrega')
						, 0)

						INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD (GuideSerie
						, GuideNumber
						, CourierManId
						, Date
						, BatchCODId
						, BatchCODIdCommission
						, DataOriginId
						, Notificated
						, Token
						, CustomerID)
							VALUES (@GuideSerie, @GuideNumber, @CourierId, GETDATE(), NULL, NULL, @CatModuleId, 0, @Token, @IdCustomer)

					END
					ELSE
					IF EXISTS (SELECT
								1
							FROM DeliveryOrder ord WITH (NOLOCK)
							INNER JOIN DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
								ON ord.Guide_Serie = DOP.GuideSerie
								AND ord.Guide_Number = DOP.GuideNumber
							LEFT JOIN VisitPointClient vp WITH (NOLOCK)
								ON vp.CodeOfReference = ord.Sender_ID
							LEFT JOIN Customer cus WITH (NOLOCK)
								ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
							WHERE ord.Guide_Serie = @GuideSerie
							AND ord.Guide_Number = @GuideNumber
							AND ord.IsCollect = 'false'
							AND DOP.TimePlaId = 2
							AND NOT EXISTS (SELECT
									1
								FROM Cost C WITH (NOLOCK)
								INNER JOIN CostDetail CD WITH (NOLOCK)
									ON CD.IdCost = C.IdCost
									AND CD.IdTypeOfMoney IN (2, 6)
								WHERE C.ProductNumber = CONCAT(ord.Guide_Serie, CAST(ord.Guide_Number AS VARCHAR(50))))
							AND NOT EXISTS (SELECT
									1
								FROM ProcessedGuideCOD WITH (NOLOCK)
								WHERE GuideSerie = @GuideSerie
								AND GuideNumber = @GuideNumber))

					BEGIN
						--Buscar ID modulo liquidación COD
						SET @CatModuleId = ISNULL((SELECT
								ModIdModule
							FROM DeliveryBackOffice.dbo.CatModule WITH (NOLOCK)
							WHERE ModName = 'Confirmación de Entrega')
						, 0)

						INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD (GuideSerie
						, GuideNumber
						, CourierManId
						, Date
						, BatchCODId
						, BatchCODIdCommission
						, DataOriginId
						, Notificated
						, Token
						, CustomerId)
							VALUES (@GuideSerie, @GuideNumber, @CourierId, GETDATE(), NULL, NULL, @CatModuleId, 0, @Token, @IdCustomer)

					END

					SET @Register = 1
				END
				-- Si es traslado a express center
				ELSE IF @Action = 3
				BEGIN
				
					-- Validar que la guía esté estado correcto
					IF EXISTS (SELECT
								1
							FROM DeliveryOrder do WITH (NOLOCK)
							INNER JOIN StatusOrder so WITH (NOLOCK)
								ON do.StatusOrderId = so.StatusOrderId
							WHERE do.Guide_Serie = @GuideSerie
							AND do.Guide_Number = @GuideNumber
							AND so.OrderDescription IN ('Traslado a Express Center', 'Recibido En Express Center', 'Entregado En Express Center'))
					BEGIN
						IF @CodeOfReference <> 0
						BEGIN

							INSERT INTO TransferLog (IdCourier, CourierName, DPI, IdIncidence, IncidenceName, Comentary, GuideSerie, GuideNumber, TokenCreated, DateCreated, TokenUpdate, DateUpdate, CodeOfReference)
								SELECT
									@CourierId
								   ,CONCAT(sr.First_Name, ' ', sr.Last_Name)
								   ,sr.CUI
								   ,NULL
								   ,NULL
								   ,NULL
								   ,@GuideSerie
								   ,@GuideNumber
								   ,@Token
								   ,GETDATE()
								   ,NULL
								   ,NULL
								   ,@CodeOfReference
								FROM SenderReceiver sr WITH (NOLOCK)
								WHERE sr.ID = @CourierId
						
							SET @Register = 1
						END 
						ELSE 
						BEGIN
							SET @IsValidOperation = 0
							SET @ErrorCode = 3 
							SET @ErrorDescription = 'No se ha ingresado un express center valido.'
						END
					END
					ELSE 
					BEGIN
						SET @IsValidOperation = 0
						SET @ErrorCode = 2 
						SET @ErrorDescription = 'La guía no se encuentra en estado válido.'
					END
				END
				-- si es incidencia
				ELSE IF @Action = 4
				BEGIN 
				
					IF @IncidenceTypeId <> 0
					BEGIN
					
						SET @StatusOrderId = (SELECT so.StatusOrderId FROM StatusOrder so WITH (NOLOCK) WHERE so.OrderDescription = 'Intento de entrega fallida')

						-- Actualizar registro de pieza a último estado 
						UPDATE DeliveryOrderPiece
						SET StatusOrderId = @StatusOrderId
						WHERE GuideSerie = @GuideSerie
						AND GuideNumber = @GuideNumber

						-- Actualizar registro de guía a último estado 
						UPDATE DeliveryOrder
						SET StatusOrderId = @StatusOrderId
						   ,NameOfReceiver = @ReceiverName
						WHERE Guide_Serie = @GuideSerie
						AND Guide_Number = @GuideNumber		

						-- Insertar nuevo estado de guía en tabla histórica
						INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail ([Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated], [DateCreatedInSystem])
							VALUES (@GuideSerie, @GuideNumber, @StatusOrderId, @Token, GETDATE(), GETDATE())

						INSERT INTO DeliveryAttempt (Guide_Serie, Guide_Number, Dry, Cold, Latitude, Longitude, Delivered, ID_Courier, ID_DeliveryOrderBySettlement, User_Created, Date_Created, ID_Proof, Verified, Accepted, User_Verified, Date_Verified, Accuracy, ID_Incident, Guide_Piece, LogLatitude, LogLongitude)
							VALUES (@GuideSerie, @GuideNumber, 1, 0, NULL, NULL, 0, @CourierId, NULL, @Token, GETDATE(), NULL, NULL, NULL, NULL, NULL, NULL, @IncidenceTypeId, NULL, NULL, NULL);
							
						SET @Register = 1
					END
					ELSE 
					BEGIN
						SET @IsValidOperation = 0
						SET @ErrorCode = 4
						SET @ErrorDescription = 'Código de incidencia no válido.'
					END
				END
				-- si es un paquete extraviado
				ELSE IF @Action = 5
				BEGIN
				
					SET @StatusOrderId = (SELECT so.StatusOrderId FROM StatusOrder so WITH (NOLOCK) WHERE so.OrderDescription = 'Paquete Extraviado')

					-- Actualizar registro de pieza a último estado 
						UPDATE DeliveryOrderPiece
						SET StatusOrderId = @StatusOrderId
						WHERE GuideSerie = @GuideSerie
						AND GuideNumber = @GuideNumber

					-- Actualizar registro de guía a último estado 
					UPDATE DeliveryOrder
					SET StatusOrderId = @StatusOrderId
						,NameOfReceiver = @ReceiverName
					WHERE Guide_Serie = @GuideSerie
					AND Guide_Number = @GuideNumber		

					-- Insertar nuevo estado de guía en tabla histórica
					INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail ([Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated], [DateCreatedInSystem],[Observations])
						VALUES (@GuideSerie, @GuideNumber, @StatusOrderId, @Token, GETDATE(), GETDATE(), @Observations)


					SET @Register = 1
				END
				ELSE
				BEGIN
					SET @IsValidOperation = 0
					SET @ErrorCode = 5
					SET @ErrorDescription = 'Código de acción no válido para una guía.'
				END 
			END
			ELSE
			BEGIN
				SET @IsValidOperation = 0
				SET @ErrorCode = 6
				SET @ErrorDescription = 'Guía no existe.'
			END
		END
		ELSE IF @ServiceManagementId <> 0
		BEGIN
			IF @Action = 4
			BEGIN
				
				SET @IncidenceDescription = (SELECT
						cti.DescriptionIncidence
					FROM CatTypeIncidence cti WITH (NOLOCK)
					WHERE cti.IdIncidenceType = @IncidenceTypeId)

				INSERT INTO IncidenceServices (ServiceManagementId, IncidenceTypeId, DescriptionIncidence, Latitude, Longitude, Accuracy, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated, Guide, Observations)
					VALUES (@ServiceManagementId, @IncidenceTypeId, @IncidenceDescription, NULL, NULL, NULL, 1, @Token, GETDATE(), NULL, NULL, NULL, NULL)

				SET @StatusOrderId = (SELECT
						css.IdServiceStatus
					FROM CatServiceStatus css WITH (NOLOCK)
					WHERE [Name] = 'Incidencia')

				SET @CanceledStatusId = (SELECT TOP 1
						css.IdServiceStatus
					FROM CatServiceStatus css WITH (NOLOCK)
					WHERE css.[Name] = 'Cancelado');

				
				UPDATE ServiceManagement
				SET ServiceStatusId = @StatusOrderId
				   ,DateUpdated = GETDATE()
				   ,TokenUpdated = @Token
				WHERE IdServiceManagement = @ServiceManagementId

				INSERT INTO EventService (ServiceManagementId, ServiceStatusId, RowStauts, TokenCreated, DateCreated, Observations)
					VALUES (@ServiceManagementId, @StatusOrderId, 1, @Token, GETDATE(), @IncidenceDescription)

				IF (@IncidenceTypeId IN (SELECT
							cti.IdIncidenceType
						FROM CatTypeIncidence cti WITH (NOLOCK)
						WHERE cti.NameIncidence IN ('Servicio duplicado', 'Cliente cancelo servicio', 'Recolectada en otra ruta'))
					)
				BEGIN
					UPDATE ServiceManagement
					SET ServiceStatusId = @CanceledStatusId
					   ,DateUpdated = GETDATE()
					   ,TokenUpdated = @Token
					FROM ServiceManagement
					WHERE IdServiceManagement = @ServiceManagementId

					INSERT INTO EventService (ServiceManagementId, ServiceStatusId, RowStauts, TokenCreated, DateCreated, Observations)
						VALUES (@ServiceManagementId, @CanceledStatusId, 1, @Token, GETDATE(), @IncidenceDescription)

					--Se cancela la solicitud
					UPDATE sp
					SET sp.SchedulePickupStatus = 0
					FROM SchedulePickup sp
					INNER JOIN ServiceManagement sm
						ON sm.IdSchedulePickup = sp.SchedulePickupId
					WHERE sm.IdServiceManagement = @ServiceManagementId
				END
			END
			ELSE
			BEGIN
				SET @IsValidOperation = 0
				SET @ErrorCode = 5
				SET @ErrorDescription = 'Código de acción no válido para un servicio.'
			END
		END
		ELSE 
		BEGIN 
			SET @IsValidOperation = 0
			SET @ErrorCode = 5
			SET @ErrorDescription = 'Se debe envíar una guía o un servicio.'
		END

		IF @Register = 1
		BEGIN

			-- Verificar información de la guía
			SELECT TOP 1
				@RouteAssignmentId = ra.IdRouteAssigment
			   ,@RouteAssignmentCourierId = ra.IdCurrierMan
			   ,@ServiceManagementId = sm.IdServiceManagement
			   ,@IsCollect = do.IsCollect
			   ,@HasInsurance = do.IsInsuarance
			   ,@ServiceAmount = do.PriceShippment
			   ,@CODAmount = ISNULL(do.Collect_OnDelivery, 0)
			   ,@IsLastMileReturn = ISNULL(do.IsLastMileReturn, 0)
			   ,@InsuranceAmount = ISNULL(do.InsuranceAmount, 0)
			FROM RouteAssigment ra WITH (NOLOCK)
			INNER JOIN ServiceManagement sm WITH (NOLOCK)
				ON ra.IdRouteAssigment = sm.IdPuRouteAssigment	
			INNER JOIN ServiceManagementDetail smd WITH (NOLOCK)
				ON sm.IdServiceManagement = smd.ServiceManagement
			INNER JOIN RoutePreparationDetail rpd WITH (NOLOCK)
				ON smd.IdServiceManagementDetail = rpd.ServiceManagementDetailId		
			INNER JOIN DeliveryOrder do WITH (NOLOCK)
				ON rpd.Guide_Serie = do.Guide_Serie
					AND rpd.Guide_Number = do.Guide_Number
			WHERE ra.DateOfRoute = CAST(GETDATE() AS DATE)
			AND do.Guide_Serie = @GuideSerie
			AND do.Guide_Number = @GuideNumber
			AND sm.RowStatus = 1
			AND smd.RowStatus = 1
			AND rpd.RowStatus = 1
			ORDER BY ra.DateCreated DESC 


			IF @RouteAssignmentId IS NOT NULL
			BEGIN
				
				--- Verificar si existe la ruta unificada y si ya fue liquidada
				SELECT
					@IdUnifiedRouteSettlement = urs.IdUnifiedRouteSettlement
				   ,@UserSettlement = urs.UserSettlement
				FROM UnifiedRouteSettlement urs WITH (NOLOCK)
				WHERE urs.RouteAssignmentId = @RouteAssignmentId
				AND urs.RowStatus = 1

				IF @IdUnifiedRouteSettlement IS NULL 
				BEGIN

					--- No existe la ruta unificada debe ser generado
					INSERT INTO UnifiedRouteSettlement (RouteAssignmentId, TotalGuidesSettled, TotalPiecesSettled, TotalPiecesMissing, UserSettlement, DateSettlement, SettlementStation, TotalCODGuidesSettled, UserCODSettlement, DateCODSettlement, CODSettlementStation, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
						VALUES (@RouteAssignmentId, DEFAULT, DEFAULT, DEFAULT, NULL, NULL, NULL, DEFAULT, NULL, NULL, NULL, DEFAULT, @Token, GETDATE(), NULL, NULL);

					SET @IdUnifiedRouteSettlement = SCOPE_IDENTITY()
				END

				IF @IdUnifiedRouteSettlement IS NOT NULL
				BEGIN
					--- Validar que la ruta no haya sido liquidada
					IF @UserSettlement IS NULL
					BEGIN
						
						-- Verificar si existe la guía en el detalle de la preparación de ruta
						SELECT
							@IdUnifiedRouteSettlementDetail = ursd.IdUnifiedRouteSettlementDetail
						FROM UnifiedRouteSettlementDetail ursd
						WHERE ursd.UnifiedRouteSettlementId = @IdUnifiedRouteSettlement
						AND ursd.GuideSerie = @GuideSerie
						AND ursd.GuideNumber = @GuideNumber
						AND (ursd.RowStatus = 1 OR ursd.IsOpenProcess = 1) 

						IF @IdUnifiedRouteSettlementDetail IS NULL
						BEGIN
							
							INSERT INTO 
								DeliveryBackOffice.dbo.UnifiedRouteSettlementDetail 
								(
									UnifiedRouteSettlementId
									, ServiceManagementId
									, GuideSerie
									, GuideNumber
									, ServiceSettlementAmount
									, ServiceCODSettlementAmount
									, IsArrival
									, IsReturn
									, IsDelivered
									, IsTransfered
									, RowStatus
									, TokenCreated
									, DateCreated
									, IsLost
								)
							VALUES 
								(
									@IdUnifiedRouteSettlement
									, @ServiceManagementId
									, @GuideSerie
									, @GuideNumber
									, CASE WHEN @Action IN (1, 2) THEN IIF(@IsCollect = 1, @ServiceAmount, 0) ELSE 0 END
									, CASE WHEN @Action IN (5) AND @HasInsurance = 1 THEN @InsuranceAmount WHEN @Action = 1 AND @IsLastMileReturn = 0 THEN @CODAmount ELSE 0 END
									, 0
									, CASE WHEN @Action IN (4) THEN 1 ELSE 0 END
									, CASE WHEN @Action IN (1, 2) THEN 1 ELSE 0 END
									, CASE WHEN @Action IN (3) THEN 1 ELSE 0 END
									, 1
									, @Token
									, GETDATE()
									, CASE WHEN @Action IN (5) THEN 1 ELSE 0 END
								);
							
							SET @IdUnifiedRouteSettlementDetail = SCOPE_IDENTITY()

							--- Actualizar contadores de guías si no es un proceso abierto 
							UPDATE UnifiedRouteSettlement
							SET TotalGuidesSettled += 1
							WHERE IdUnifiedRouteSettlement = @IdUnifiedRouteSettlement

							IF(@Action = 5)
							BEGIN
							
								SET @StatusOrderId = (SELECT TOP 1 so.StatusOrderId FROM StatusOrder so WITH (NOLOCK) WHERE so.OrderDescription = 'Paquete Extraviado')
								DECLARE @UpdatedGuide AS TABLE (
									IdUpdated INT
								)

								UPDATE
									DO
								SET
									DO.StatusOrderId = @StatusOrderId
								OUTPUT inserted.Guide_Number INTO @UpdatedGuide(IdUpdated)
								FROM
									[DeliveryBackOffice].[dbo].[DeliveryOrder] DO 
								WHERE
									DO.Guide_Serie = @GuideSerie
									AND
									DO.Guide_Number = @GuideNumber
									AND
									DO.StatusOrderId != @StatusOrderId

								IF(EXISTS(SELECT TOP 1 1 FROM @UpdatedGuide))
								BEGIN
									INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
										(
											Guide_Serie
											,Guide_Number
											,StatusOrderId
											,DateCreated
											,DateCreatedInSystem
											,UserCreated
											,RowStatus
										)
									VALUES
										(
											@GuideSerie
											,@GuideNumber
											,@StatusOrderId
											,GETDATE()
											,GETDATE()
											,@Token
											,1
										)
								END
							END
						END

						IF @IdUnifiedRouteSettlementDetail IS NOT NULL
						BEGIN
							INSERT INTO @Pieces
							SELECT
								dop.NoPiece,
								dop.IsDry
							FROM DeliveryOrderPiece dop WITH (NOLOCK)
							WHERE dop.GuideSerie = @GuideSerie
							AND dop.GuideNumber = @GuideNumber
							
							WHILE EXISTS (SELECT TOP 1 1 FROM @Pieces)
							BEGIN

								SELECT TOP 1
									@GuidePiece = NoPiece,
									@GuidePieceIsDry = ISNULL(IsDry, 1)
								FROM @Pieces

								--- Verificar si existe la pieza de la guía dentro del detalle de la ruta unificada
								SELECT 
									@IdUnifiedRouteSettlementDetailPiece = ursdp.IdUnifiedRouteSettlementDetailPiece
								FROM UnifiedRouteSettlementDetailPiece ursdp
								INNER JOIN UnifiedRouteSettlementDetail ursd
									ON ursdp.UnifiedRouteSettlementDetailId = ursd.IdUnifiedRouteSettlementDetail
								WHERE ursdp.UnifiedRouteSettlementDetailId = @IdUnifiedRouteSettlementDetail
								AND ursdp.PieceNumber = @GuidePiece
								AND (ursdp.RowStatus = 1 OR (ursd.IsOpenProcess = 1 AND ursd.UserProcess IS NOT NULL))

								IF @IdUnifiedRouteSettlementDetailPiece IS NULL 
								BEGIN 

									INSERT INTO UnifiedRouteSettlementDetailPiece (UnifiedRouteSettlementDetailId, PieceNumber, IsDryPiece, RowStatus, TokenCreated, DateCreated)
										VALUES (@IdUnifiedRouteSettlementDetail, @GuidePiece, @GuidePieceIsDry, 1, @Token, GETDATE());

									SET @IdUnifiedRouteSettlementDetailPiece = SCOPE_IDENTITY()

									--- Actualizar contadores de piezas
									UPDATE UnifiedRouteSettlement
									SET TotalPiecesSettled += 1
									WHERE IdUnifiedRouteSettlement = @IdUnifiedRouteSettlement

									UPDATE UnifiedRouteSettlementDetail
									SET PiecesSettled += 1
									WHERE IdUnifiedRouteSettlementDetail = @IdUnifiedRouteSettlementDetail
								END

								SET @IdUnifiedRouteSettlementDetailPiece = NULL

								DELETE FROM @Pieces
								WHERE NoPiece = @GuidePiece
							END

						END
						ELSE
						BEGIN
							SET @IsValidOperation = 0
							SET @ErrorCode = 10
							SET @ErrorDescription = 'Ocurrió un error al crear el detalle de la ruta unificada.'
						END

					END
					ELSE
					BEGIN
						SET @IsValidOperation = 0
						SET @ErrorCode = 9
						SET @ErrorDescription = 'La ruta ya ha sido liquidada.'
					END
				END
				ELSE
				BEGIN
					SET @IsValidOperation = 0
					SET @ErrorCode = 8
					SET @ErrorDescription = 'Ocurrió un error al crear la ruta unificada.'
				END
			END
			ELSE
			BEGIN
				SET @IsValidOperation = 0
				SET @ErrorCode = 7
				SET @ErrorDescription = 'La guía no está asignada a una ruta o no pertenece al Courier.'
			END
		END
		IF @IsValidOperation = 1
		BEGIN
			COMMIT TRANSACTION

			SELECT
				1 'StatusCode'
			   ,'Transacción realizada correctamente.' 'Description'
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION

			SELECT
				@ErrorCode 'StatusCode'
			   ,@ErrorDescription 'Description'
		END

	END TRY
	BEGIN CATCH
    	ROLLBACK TRANSACTION

		SELECT
			0 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
    END CATCH
END