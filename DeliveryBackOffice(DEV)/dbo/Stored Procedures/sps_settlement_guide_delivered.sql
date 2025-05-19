-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-11-22>
-- Description:	<Registrar transacción de liquidación para comprobante de entrega>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-06-19>
-- Description:	<Se calcula la tasa de cambio y la conversion de la moneda del pais orgigen a pais destino>
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
	
	DECLARE @OriginResult DECIMAL(12,6);
	DECLARE @ResultDestination DECIMAL(12,6);
	DECLARE @TypeService NVARCHAR(3);
	DECLARE	@ReceiverCountry NVARCHAR(2),
			@SenderCountry NVARCHAR(2),
			@GuideType NVARCHAR(3),
			@CurrencyOrigin INT,
			@CurrencyDestination INT;

	BEGIN TRANSACTION

		BEGIN TRY

			SELECT @ReceiverCountry = ReceiverCountryId,
				   @SenderCountry = SenderCountryId,
				   @TypeService = TypeService,
				   @GuideType = GuideType
			FROM DeliveryOrder  WITH(NOLOCK)
			WHERE Guide_Serie = @GuideSerie
			AND Guide_Number = @GuideNumber

			/*** SIMULAR ENTREGA DE GUÍA COMO CONFIRMACION DE ENTREGA ***/
	
			-- Buscar si la guía ya cuenta con estado de entrega previa, en caso que exista no se procede a registrar transacción para evitar registro duplicado
			SET @Times = (SELECT COUNT(Guide_Number) FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH(NOLOCK) WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber AND (StatusOrderId IN (@StatusDelivery,@StatusReturn,@StatusTransfer)))

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
												ON do.Guide_Serie = dop.GuideSerie
												AND do.Guide_Number = dop.GuideNumber
												INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
											    ON do.IdCustomer = WHE.CustomerId
												WHERE do.Guide_Serie = @GuideSerie 
												AND do.Guide_Number = @GuideNumber
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
												ON do.Guide_Serie = dop.GuideSerie
												AND do.Guide_Number = dop.GuideNumber
												INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
											    ON do.IdCustomer = WHE.CustomerId
												WHERE do.Guide_Serie = @GuideSerie 
												AND do.Guide_Number = @GuideNumber
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
										dop.GuideSerie,dop.GuideNumber, dop.GuidePiece, do.Ticket_Number,dop.ExternalPieceId, 
										@GuideCurrentStatus, 1 AS RowStatus, GETDATE()AS DateCreated,@Token AS TokenCreated
										FROM DeliveryOrderPiece dop WITH(NOLOCK)
										INNER JOIN DeliveryOrder do WITH(NOLOCK)
											ON dop.GuideSerie = do.Guide_Serie
											AND dop.GuideNumber = do.Guide_Number
										INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
										    ON do.IdCustomer = WHE.CustomerId
										INNER JOIN @GuidePiecesTable gpt
										    ON dop.GuideSerie = gpt.GuideSerie
											AND dop.GuideNumber = gpt.GuideNumber
										INNER JOIN @PiecesGuideRelatedTable pgt
										    ON gpt.GuideSerie = pgt.GuideSerie
											AND gpt.GuideNumber = pgt.GuideNumber
                                            AND gpt.NumberPieces = pgt.NumberRelatedPieces
											WHERE WHE.TypeConnectionId = 2

							END

					
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

			IF @GuideType = 'INT'
			BEGIN

				DECLARE @ExchangeReceiver DECIMAL(12,6);
					/***************CONVERSION MONEDA ORIGEN A DOLAR****************************/
					SET @CurrencyOrigin = (SELECT CodCurrency FROM Cost WITH(NOLOCK) WHERE GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie)

					SELECT @OriginResult = CASE WHEN @SenderCountry = 'GT' THEN @Amount / ExchangeRate ELSE @Amount * ExchangeRate END  
					FROM CurrencyExchangeRates WITH(NOLOCK) 
					WHERE IdCountry = @SenderCountry 
					AND CAST(ExchangeDate AS DATE) = CAST(GETDATE() AS DATE) 
					AND SourceCurrency = @CurrencyOrigin
					ORDER BY ExchangeDate DESC
					
					/**********************CONVERSION DOLAR A MONEDA LOCAL***********************/
					
					SET @Currencydestination  =  (SELECT IdCatCurrencyCOD 
					                              FROM CatCurrencyCOD C WITH(NOLOCK)
                                                  INNER JOIN DeliveryCurrency DC WITH(NOLOCK)
                                                      ON C.IdCatCurrencyCOD = DC.IdCurrencyCOD 
											      WHERE DC.Currency_IdCountry = @ReceiverCountry
												      AND DC.Currency_Status = 1 
                                                      AND DC.DefaultPerCountry = 1)

					SELECT @ResultDestination = @OriginResult * ExchangeRate,
							@ExchangeReceiver = ExchangeRate
					FROM CurrencyExchangeRates WITH(NOLOCK) 
					WHERE IdCountry = @ReceiverCountry
					AND CAST(ExchangeDate AS DATE) = CAST(GETDATE() AS DATE) 
					AND TargetCurrency = @Currencydestination
					ORDER BY ExchangeDate DESC
					
					IF @ResultDestination IS NULL
					BEGIN
						RAISERROR ('The exchange rate conversion could not be performed, the value cannot be null', 16, 1);
					END

				IF @TypeService = 'COD'
				BEGIN				
					/*********************ACTUALIZACION DE DATOS EN COST*************************/

					UPDATE DeliveryBackOffice.dbo.Cost
					SET CODPaymentCurrency = @Currencydestination,
						CODPaymentExchangeRate = @ExchangeReceiver
					WHERE GuideNumber = @GuideNumber
					AND GuideSerie = @GuideSerie
				END
				ELSE
				BEGIN
					UPDATE DeliveryBackOffice.dbo.Cost
					SET DeliveryPaymentCurrency = @CurrencyDestination,
						DeliveryPaymentExchangeRate = @ExchangeReceiver
					WHERE GuideNumber = @GuideNumber
					AND GuideSerie = @GuideSerie
				END

			END
			ELSE
			BEGIN
				/******EL MONTO NO SUFRE NINGUNA TAZA DE CAMBIO******/
				SET @ResultDestination = @Amount
				/**********NO SE DEBE CALCULAR TASA DE CAMBIO PARA GUIAS DOMESTICAS**************/
				IF @TypeService = 'COD'
				BEGIN
					UPDATE DeliveryBackOffice.dbo.Cost
					SET CODPaymentCurrency = CodCurrency,
						CODPaymentExchangeRate = CodExchangeRate
					WHERE GuideNumber = @GuideNumber
					AND GuideSerie = @GuideSerie
				END
				ELSE
				BEGIN
					UPDATE DeliveryBackOffice.dbo.Cost
					SET DeliveryPaymentCurrency = ShippingCurrency,
						DeliveryPaymentExchangeRate =ShippingExchangeRate
					WHERE GuideNumber = @GuideNumber
					AND GuideSerie = @GuideSerie
				END
			END

			-- actualizar guía debido al proceso de liquidación
			UPDATE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]
			SET 
				Settlement_Collect_OnDelivery = @Amount, 
				SettlementCollect_TokenCreated = @Token,  
				SettlementCollect_DateCreated = GETDATE(), 
				Guide_Settlement = 1, -- guía liquidada en bodega
				Guide_Returned = 0,  -- guía liquidada vía material devuelto
				Guide_Delivered = 1,  -- guía liquidada vía comprobante de entrega
				StatusOrderId =5
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
				0 AS RetriesAllowed,
				ERROR_LINE() AS ErrorLine
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
				   , CONCAT(cur.Symbol, CONVERT(NVARCHAR,CAST(ROUND(@ResultDestination, 2) AS DECIMAL(12,2)))) AS 'CurrencySymbol'
				FROM DeliveryOrder DOR WITH (NOLOCK)
				LEFT JOIN [DeliveryBackOffice].[dbo].[Cost]	co WITH (NOLOCK)
					ON	DOR.Guide_Number= co.GuideNumber 
					AND DOR.Guide_Serie = co.GuideSerie
				LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]	cur WITH (NOLOCK)
					ON ISNULL(co.ShippingCurrency,1) = cur.IdCatCurrencyCOD 
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
GO

