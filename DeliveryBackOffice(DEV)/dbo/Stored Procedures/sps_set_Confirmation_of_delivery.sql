-- =============================================
-- Author:		<Bidcar, Herrera>
-- Create date: <2020-06-12>
-- Description:	<Confirmar entrega de guía>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-06-28>
-- Description:	<Agregar Filtro para saber si tiene pago con tarjeta o datafono en CostDetail>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-08-01>
-- Description:	<Agregar validación para impedir entrega cuando el destino sea un express center: reviosión 01/09/2022>
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-09-26>
-- Description:	<Al momento de finalizar el proceso de devolución se debe realizar update en la tabla warehouse al campo Rack_Position, colocarlo como NULL>
-- =============================================

CREATE PROCEDURE [dbo].[sps_set_Confirmation_of_delivery]
		@Guide_Serie AS VARCHAR(2), --guide serie
		@Guide_Number AS INT, --guide number
		@DateOfDelivery VARCHAR(50),--Date of delivery
		@NameOfReceiver VARCHAR(200), --Name of receiver
		@TokenId AS VARCHAR(50) --token user
AS
BEGIN
    DECLARE @StatusId TINYINT = 5; --Status of delivery 
    DECLARE @ValidateOperation BIGINT;
    DECLARE @Times INT; -- cantidad de veces que se encuentra el registro con estado de entregado
    DECLARE @CatModuleId INT; -- CatModuleId del modulo
    DECLARE @CourierId INT; -- CourierId de la guía
    DECLARE @COD DECIMAL(14, 2); -- COD de la guía
    DECLARE @Datetime DATETIME; -- Fecha y hora del último checkpoint

	BEGIN TRANSACTION;
		BEGIN TRY
			-- Buscar si la guía ya cuenta con estado de entrega previa, en caso que exista no se procede a registrar transacción para evitar registro duplicado
			SET @Times = 
			 (
			 
			     SELECT COUNT(Guide_Number) 
			     FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH (NOLOCK) 
			     WHERE Guide_Serie = @Guide_Serie 
			           AND Guide_Number = @Guide_Number 
			           AND (
			                     StatusOrderId = @StatusId  
			                     OR StatusOrderId = 14
						   )
			 );

			 
       IF(NOT EXISTS 
       (  
          SELECT TOP 1 
                 1 FROM dbo.DeliveryOrder WITH (NOLOCK)
				   WHERE IdDeliveryOption = 3
						 AND Guide_Serie=@Guide_Serie 
						 AND Guide_Number= @Guide_Number
		)
		   )
	   BEGIN
			IF (@Times = 0)
			BEGIN

				SET @Datetime = 
				(
				     SELECT TOP 1 
				            DateCreated 
					 FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH (NOLOCK)
					 WHERE Guide_Serie = @Guide_Serie 
					       AND Guide_Number = @Guide_Number 
					 ORDER BY DateCreated DESC
				);

				IF (@DateOfDelivery > @Datetime)
				BEGIN


				  --al cambiar estado de guia  debe realizar update en la tabla warehouse al campo Rack_Position, colocarlo como NULL
				  UPDATE  dbo.warehouse SET Active =0,
				          UserUpdated = @TokenId,
						  DateUpdated = GETDATE()

				  where Guide_Serie = @Guide_Serie AND 
                        Guide_Number = @Guide_Number

					-- Actualizar registro de guía a último estado 
					UPDATE DeliveryBackOffice.dbo.DeliveryOrder
					SET StatusOrderId = @StatusId, --Status of delivery 			
					    NameOfReceiver = @NameOfReceiver
					WHERE Guide_Serie = @Guide_Serie 
					      AND Guide_Number = @Guide_Number;	

					UPDATE DeliveryBackOffice.dbo.DeliveryAttempt
					SET Delivered = 1 --Status of delivery 	
					WHERE Guide_Serie = @Guide_Serie 
					      AND Guide_Number = @Guide_Number 
					      AND CAST(Date_Created AS Date) = CAST(GETDATE() AS Date);
			
					-- Insertar nuevo estado de guía en tabla histórica
					INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
					(
					    [Guide_Serie],
					    [Guide_Number], 
					    [StatusOrderId], 
					    [UserCreated],
					    [DateCreated],
					    [DateCreatedInSystem]
					)			
					SELECT @Guide_Serie, 
					       @Guide_Number, 
					       @StatusId, 
					       @TokenId,
					       CONVERT(Datetime,@DateOfDelivery, 120),
					       GETDATE()
					WHERE EXISTS
					(
					 
					      SELECT 1 
					      FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)			 
					      WHERE Guide_Serie = @Guide_Serie 
					            AND Guide_Number = @Guide_Number
					);
			
					SET @ValidateOperation = COALESCE(@@ROWCOUNT,0);
					

					-----------------WEBHOOK.INI-----------------------		
					DECLARE @WebhookCustomerId INT = -1;
					DECLARE @CustomerEndpointId INT = -1;
					-- Debido a que se procesa únicamente 1 guía
					DECLARE @GuideCurrentStatus INT = -1;

					BEGIN TRY
						DECLARE @GuideStatusChangeWebhook INT = (SELECT TOP 1 WT.IdWebhookType FROM [DeliveryBackOffice].[dbo].[WebhookType] WT WITH(NOLOCK) WHERE WT.WebhookName = 'GuideStatusChange' COLLATE Latin1_General_CI_AI AND WT.RowStatus = 1);

						SET @WebhookCustomerId = ISNULL((SELECT TOP 1 DO.IdCustomer FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Number = @Guide_Number AND DO.Guide_Serie = @Guide_Serie),-1);
						SET @CustomerEndpointId = ISNULL((SELECT TOP 1 WE.IdWebhookEndpoint FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK) WHERE WE.CustomerId = @WebhookCustomerId AND  WE.WebhookTypeId = @GuideStatusChangeWebhook),-1);

						SET @GuideCurrentStatus = (SELECT TOP 1 DO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Number = @Guide_Number AND DO.Guide_Serie = @Guide_Serie);

						-- Cliente tiene webhook configurado para el tipo especificado
						-- Estado actual de la guía coincide dentro de las restricciónes por usuario
						IF ( @WebhookCustomerId > 0 AND @CustomerEndpointId > 0 AND @GuideCurrentStatus IN (SELECT WRBU.StatusOrderId FROM [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH(NOLOCK) WHERE WRBU.CustomerId = @WebhookCustomerId AND WRBU.WebhookTypeId = @GuideStatusChangeWebhook) )
						BEGIN 

							DECLARE @ResponseTable AS TABLE (
								InsertedId BIGINT
							);

							IF( 
								NOT EXISTS (
									SELECT 
										TOP 1 
											1 
									FROM 
										[DeliveryBackOffice].[dbo].[WebhookTrackingQueue] WTQ WITH(NOLOCK) 
									WHERE 
										WTQ.GuideSerie = @Guide_Serie 
										AND 
										WTQ.GuideNumber = @Guide_Number 
										AND WTQ.StatusOrderId IN (
											SELECT
												WRBU.StatusOrderId 
											FROM 
												[DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH(NOLOCK) 
											WHERE 
												WRBU.CustomerId = @WebhookCustomerId 
												AND 
												WRBU.WebhookTypeId = @GuideStatusChangeWebhook
								) ) )
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
										@Guide_Serie
										,@Guide_Number
										,@WebhookCustomerId
										,@GuideCurrentStatus
										,@CustomerEndpointId
										,0
										,@TokenId
										,GETDATE()
									)
							END
						END
					END TRY
					BEGIN CATCH

					END CATCH
					-------------------WEBHOOK.FIN------------------------------		

					DECLARE @IdCustomer INT;
					DECLARE @COLLECT INT = 0;
					-- se obtiene COD de la guía
					SELECT 
						@COD =  ord.Collect_OnDelivery,
						@IdCustomer = cus.IdCustomer
					FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH (NOLOCK)
							LEFT JOIN dbo.VisitPointClient vp 
							    ON vp.CodeOfReference = ord.Sender_ID
							LEFT JOIN dbo.Customer cus 
							    ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
					WHERE ord.Guide_Serie = @Guide_Serie 
					      AND  ord.Guide_Number = @Guide_Number;

					SELECT @COLLECT =  1
					FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH (NOLOCK)
							LEFT JOIN dbo.VisitPointClient vp 
							     ON vp.CodeOfReference = ord.Sender_ID
							LEFT JOIN dbo.Customer cus 
							     ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
					WHERE ord.Guide_Serie = @Guide_Serie 
					      AND  ord.Guide_Number = @Guide_Number 
					      AND ord.IsCollect = 'true';

					-- se verifica que no exita en ProcessGuideCOD Y COD > 0
					IF (
					          @COD > 0 
					          OR @COLLECT = 1
					    )  
						AND NOT EXISTS 
					(
					        SELECT 1
							FROM DeliveryBackOffice.dbo.ProcessedGuideCOD WITH (NOLOCK)
							WHERE GuideSerie = @Guide_Serie 
							      AND GuideNumber = @Guide_Number
					)  AND NOT EXISTS
                    (
                        SELECT 1
                        FROM DeliveryBackOffice.dbo.Cost C WITH (NOLOCK)
                           INNER JOIN CostDetail CD WITH (NOLOCK)
                                ON CD.IdCost = C.IdCost
                                   AND CD.IdTypeOfMoney IN ( 2, 6 )
                        WHERE C.ProductNumber = CONCAT(@Guide_Serie, CAST(@Guide_Number AS VARCHAR(50)))
                    )
					BEGIN
						--Buscar ID modulo liquidación COD
						SET @CatModuleId = ISNULL(
						                   (
						                        SELECT ModIdModule
												FROM DeliveryBackOffice.dbo.CatModule
												WHERE ModName = 'Confirmación de Entrega'
											),
											0
											      );
						-- Obtener ID de Courier
						SELECT TOP 1 @CourierId = ID_Courier 
						FROM DeliveryBackOffice.dbo.DeliveryAttempt WITH (NOLOCK)
						WHERE Guide_Serie = @Guide_Serie
							AND Guide_Number = @Guide_Number
						ORDER BY Date_Created DESC
						INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD
						   (GuideSerie
						   ,GuideNumber
						   ,CourierManId
						   ,Date
						   ,BatchCODId
						   ,BatchCODIdCommission
						   ,DataOriginId
						   ,Notificated
						   ,Token
						   ,CustomerId)
						VALUES 
							(@Guide_Serie
							,@Guide_Number
							,@CourierId
							,GETDATE()
							,NULL
							,NULL
							,@CatModuleId
							,0
							,@TokenId
							,@IdCustomer)

					END
			


				END
				ELSE
					SET @ValidateOperation = -2
				
			END
			-- registro existente
			ELSE
				SET @ValidateOperation = -1
         
		 -- si destino es Ex C
		 END
		 ELSE
				SET @ValidateOperation = -3
		END TRY
		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			if (@ValidateOperation >0 )
			 BEGIN
				 SELECT			  
					1 AS 'StatusCode',
					'Registros guardados correctamente' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			 
				 SELECT TOP 10 
				        Guide_Serie + CAST(Guide_Number as varchar) Guide,
						Ticket_Number Ticket, 
						Receiver_FirstName + ' '+ Receiver_LastName Name, 
						Courier_Route Route, 
						convert(varchar, Dispatched_Date, 103) RouteDate 
				 FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
				 WHERE Guide_Serie = @Guide_Serie 
				       AND Guide_Number = @Guide_Number;

				 PRINT 'REGISTER EXISTS ' + CAST(COALESCE(@ValidateOperation,0) AS VARCHAR);
			END
			ELSE IF (@ValidateOperation = -1)
			BEGIN
				SELECT			  
					-1 AS 'StatusCode',
					'Registro duplicado' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			END
			ELSE IF (@ValidateOperation = -2)
			BEGIN
				SELECT			  
					-2 AS 'StatusCode',
					'Fecha y hora incorrecta' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			END
			
			ELSE IF (@ValidateOperation = -3)
			BEGIN
				SELECT			  
					-3 AS 'StatusCode',
					'Guías cuyo destino sea un express center no pueden ser entregadas' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			END
			ELSE
			BEGIN
				SELECT 
					0 AS 'StatusCode',
					'El registro no existe' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
				print 'REGISTER NOT EXISTS ' + CAST(COALESCE(@ValidateOperation,0) as varchar)
			END
			COMMIT TRANSACTION;			
		END
END
