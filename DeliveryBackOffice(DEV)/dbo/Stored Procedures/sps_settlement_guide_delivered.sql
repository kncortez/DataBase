




-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-11-22>
-- Description:	<Registrar transacción de liquidación para comprobante de entrega>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_guide_delivered]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@Token NVARCHAR(50),
		@IdManifest INT,
		@NameReceiver NVARCHAR(200)
AS
BEGIN
	DECLARE @RModified INT
	DECLARE @Amount DECIMAL (14,2)
	DECLARE @Times INT -- cantidad de veces que se encuentra el registro con estado de entregado
	DECLARE @StatusDelivery TINYINT = (SELECT so.StatusOrderId FROM StatusOrder so WHERE so.OrderDescription = 'Entregado')
	DECLARE @StatusReturn TINYINT = (SELECT so.StatusOrderId FROM StatusOrder so WHERE so.OrderDescription = 'Devuelto')
	DECLARE @StatusTransfer TINYINT = (SELECT so.StatusOrderId FROM StatusOrder so WHERE so.OrderDescription = 'Traslado a Express Center')
	DECLARE @StatusId tinyint = (SELECT CASE WHEN do.IsLastMileReturn = 1 THEN @StatusReturn ELSE @StatusDelivery END FROM DeliveryOrder do WITH(NOLOCK) WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber) --Status of delivery 
	
	BEGIN TRANSACTION

		BEGIN TRY
			
			/*** SIMULAR ENTREGA DE GUÍA COMO CONFIRMACION DE ENTREGA ***/
	
			-- Buscar si la guía ya cuenta con estado de entrega previa, en caso que exista no se procede a registrar transacción para evitar registro duplicado
			SET @Times = (SELECT COUNT(Guide_Number) FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber AND (StatusOrderId IN (@StatusDelivery,@StatusReturn,@StatusTransfer)))

			IF (@Times = 0)
			BEGIN
				-- Actualizar registro de guía a último estado 
				UPDATE DeliveryBackOffice.dbo.DeliveryOrder
				SET StatusOrderId = @StatusId, --Status of delivery 			
				NameOfReceiver = @NameReceiver
				WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber			
			
				-- Insertar nuevo estado de guía en tabla histórica
				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
				([Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated],[DateCreatedInSystem])			
				select @GuideSerie, @GuideNumber, @StatusId, @Token,CONVERT(Datetime,GETDATE(), 120), GETDATE()
				WHERE EXISTS
				(
					SELECT 1 
					FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)			 
					WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
				)

				-----------------WEBHOOK.INI-----------------------		
				DECLARE @WebhookCustomerId INT = -1;
				DECLARE @CustomerEndpointId INT = -1;
				-- Debido a que se procesa únicamente 1 guía
				DECLARE @GuideCurrentStatus INT = -1;

				BEGIN TRY
					DECLARE @GuideStatusChangeWebhook INT = (SELECT TOP 1 WT.IdWebhookType FROM [DeliveryBackOffice].[dbo].[WebhookType] WT WITH(NOLOCK) WHERE WT.WebhookName = 'GuideStatusChange' COLLATE Latin1_General_CI_AI AND WT.RowStatus = 1);

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
				END TRY
				BEGIN CATCH

				END CATCH
				-------------------WEBHOOK.FIN------------------------------		
			END
	
			/*DECLARE @Results AS TABLE(
				StatusCode INT,
				[Description] NVARCHAR(200),
				NumTransferID BIGINT
			)
			DECLARE @DateDelivered VARCHAR(50) = CONVERT(varchar, GETDATE(), 120)*/
	
			--INSERT INTO @Results
			--EXEC sps_set_Confirmation_of_delivery @Guide_Serie = @GuideSerie, @Guide_Number = @GuideNumber, @DateOfDelivery = @DateDelivered, @NameOfReceiver = @NameReceiver, @TokenId = @Token
			/*** FIN SIMULAR ENTREGA DE GUÍA EN FORMULARIO CONFIRMACION DE ENTREGA ***/


			SET @Amount = (SELECT CASE WHEN IsLastMileReturn = 1 THEN 0 ELSE ISNULL(Collect_OnDelivery, 0) END FROM DeliveryOrder WITH(NOLOCK) WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber)

			-- actualizar guía debido al proceso de liquidación
			UPDATE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]
			SET 
				Settlement_Collect_OnDelivery = @Amount, 
				SettlementCollect_TokenCreated = @Token, 
				SettlementCollect_DateCreated = GETDATE(), 
				Guide_Settlement = 1, -- guía liquidada en bodega
				Guide_Returned = 0,  -- guía liquidada vía material devuelto
				Guide_Delivered = 1  -- guía liquidada vía comprobante de entrega
			WHERE 
				Guide_Serie = @GuideSerie 
				AND Guide_Number = @GuideNumber 
				AND ID_DeliveryOrderBySettlement = @IdManifest

			SET @RModified = @@ROWCOUNT
						
		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@Amount AS 'Amount',
				0 AS 'SubStatusCode',
				0 AS RetriesMade,
				0 AS RetriesAllowed
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
			(   ERROR_MESSAGE(),     -- ErrorDescription - varchar(300)
			    ERROR_NUMBER(),     -- ErrorNumber - int
			    ERROR_PROCEDURE(),     -- ErrorProcedure - varchar(100)
			    ERROR_LINE(),     -- ErrorLine - int
			    @GuideSerie,     -- GuideSerie - nvarchar(2)
			    @GuideNumber,     -- GuideNumber - int
			    @Token,       -- TokenCreated - varchar(50)
			    GETDATE() -- DateCreated - datetime
			    )
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RModified > 0)
				SELECT
					1 AS 'StatusCode'
				   ,'Registro guardado correctamente' AS 'Description'
				   ,@@TRANCOUNT AS 'NumTransferID'
				   ,@GuideSerie + CONVERT(NVARCHAR, @GuideNumber) AS 'Guide'
				   ,@Amount AS 'Amount'
				   ,1 AS 'SubStatusCode'
				   ,CASE
						WHEN DOR.IsLastMileReturn = 1 THEN ISNULL(doad.GuideReturnAttemptCount, 1)
						ELSE ISNULL(doad.GuideDeliveryAttemptCount, 1)
					END AS RetriesMade--Numero intentos de entrega fallidas
				   ,CASE
						WHEN DOR.IsLastMileReturn = 1 THEN ISNULL(doad.GuideReturnMaxAttemptCount, 2)
						ELSE ISNULL(doad.GuideDeliveryMaxAttemptCount, 2)
					END AS RetriesAllowed ---Numero de intentos permitidos
				   ,'' 'Retries'
				   ,0 ValidateAbandonedPackage
				   ,0 IsMarkedReturn
				   ,CASE 
				       WHEN COI.LiquidatorRemarks IS NULL THEN 
					   'Sin Observaciones'
				       WHEN COI.LiquidatorRemarks='' THEN 
					   'Sin Observaciones' 
				       ELSE COI.LiquidatorRemarks 
				   END AS LiquidatorRemarks
				FROM DeliveryOrder DOR WITH (NOLOCK)
				LEFT JOIN DeliveryOrderAttemptData doad WITH (NOLOCK)
					ON doad.GuideSerie = DOR.Guide_Serie
						AND doad.GuideNumber = DOR.Guide_Number
						AND doad.RowStatus = 1
				LEFT JOIN [dbo].[DeliveryAttempt] DA WITH (NOLOCK)
				    ON     DOR.Guide_Serie = DA.Guide_Serie 
					   AND DOR.Guide_Number = DA.Guide_Number
				LEFT JOIN [dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
				    ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
				WHERE DOR.Guide_Serie = @GuideSerie
				AND DOR.Guide_Number = @GuideNumber	
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@Amount AS 'Amount',
					0 AS 'SubStatusCode',
					0 AS RetriesMade,
					0 AS RetriesAllowed

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@Amount AS 'Amount',
				0 AS 'SubStatusCode'
END
