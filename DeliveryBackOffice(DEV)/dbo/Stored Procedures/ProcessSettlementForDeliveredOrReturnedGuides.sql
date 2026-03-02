/* =================================================
   SP:        ProcessSettlementForDeliveredOrReturnedGuides
   Propósito: Registrar transacción de liquidación para material devuelto/Registrar transacción de liquidación para comprobante de entrega
   Autor:     Erick Hernandez
   Historia:  ---
   Fecha:     2026-02-23

=== CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[ProcessSettlementForDeliveredOrReturnedGuides]
	@GuideSerie AS VARCHAR(2),
	@GuideNumber AS INT,
	@Token NVARCHAR(50),
	@IdManifest INT,
	@StationId INT = NULL,
	@RecipientName NVARCHAR(200) = NULL
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY

	DECLARE @RModified INT
	DECLARE @IsMarkedReturn BIT = 0;
	DECLARE @CurrencySymbol NVARCHAR(20);

	DECLARE @Returned BIT, @Delivered BIT, @Status INT;
	DECLARE @IsDeliveryAttempted BIT = 0;
	DECLARE @ApplyLastMileReturnLogic BIT = 0;
	DECLARE @Amount DECIMAL (14,2);

	DECLARE @OriginResult DECIMAL(12,6);
	DECLARE @ResultDestination DECIMAL(12,6);
	DECLARE @TypeService NVARCHAR(3);
	DECLARE	@ReceiverCountry NVARCHAR(2),
			@SenderCountry NVARCHAR(2),
			@GuideType NVARCHAR(3),
			@CurrencyOrigin INT,
			@CurrencyDestination INT,
			@Today DATE = CAST(GETDATE() AS DATE);

	DECLARE 
    @DeliveredStatus TINYINT,
    @ReturnedStatus TINYINT,
	@MarkedForReturnStatus TINYINT,
	@ReturnedForReprocessingStatus TINYINT,
    @TransferredStatus TINYINT;

	SELECT
		@DeliveredStatus   = MAX(CASE WHEN SO.OrderDescription = 'Entregado' THEN SO.StatusOrderId END),
		@ReturnedStatus    = MAX(CASE WHEN SO.OrderDescription = 'Devuelto' THEN SO.StatusOrderId END),
		@MarkedForReturnStatus	= MAX(CASE WHEN SO.OrderDescription = 'Declarado para Devolución' THEN SO.StatusOrderId END),
		@ReturnedForReprocessingStatus	= MAX(CASE WHEN SO.OrderDescription = 'Paquete Retornado para Reproceso' THEN SO.StatusOrderId END),
		@TransferredStatus = MAX(CASE WHEN SO.OrderDescription = 'Traslado a Express Center' THEN SO.StatusOrderId END)
	FROM DeliveryBackOffice.dbo.StatusOrder SO WITH(NOLOCK)
	WHERE SO.OrderDescription IN ('Entregado', 'Devuelto', 'Declarado para Devolución', 'Paquete Retornado para Reproceso','Traslado a Express Center')
	AND SO.RowStatus = 1;
	
	SELECT 
		@ApplyLastMileReturnLogic = IsLastMileReturn,
		@Amount = ISNULL(Collect_OnDelivery, 0)
	FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
	WHERE Guide_Serie = @GuideSerie
	AND Guide_Number = @GuideNumber;
	
	-- Buscar si la guía ya cuenta con estado de entrega previa, en caso que exista no se procede a registrar transacción para evitar registro duplicado
	IF EXISTS (
		SELECT 1 
		FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH(NOLOCK) 
		WHERE Guide_Serie = @GuideSerie 
		AND Guide_Number = @GuideNumber 
		AND (StatusOrderId IN (@DeliveredStatus, @ReturnedStatus, @TransferredStatus))
	)
	BEGIN
		SET @IsDeliveryAttempted = 1;
	END	
	
	IF @RecipientName IS NOT NULL AND LTRIM(RTRIM(@RecipientName)) <> N''
	BEGIN
		SET @Returned = 0; 
		SET @Delivered = 1;
		SET @Status = @DeliveredStatus; --Guia entregada
		
		IF @ApplyLastMileReturnLogic = 1
		BEGIN
			SET @Amount = 0;
		END
	END
	ELSE
	BEGIN
		SET @IsDeliveryAttempted = 0;
		
		SET @Returned = 1;
		SET @Delivered = 0;
		SET @Status = @ReturnedForReprocessingStatus; --Guia regresa a bodegas de FORZA
	END
	
	UPDATE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]
	SET 
		Settlement_Collect_OnDelivery = @Amount,
		SettlementCollect_TokenCreated = @Token,
		SettlementCollect_DateCreated = GETDATE(),
		Guide_Settlement = 1, -- guía liquidada en bodega
		Guide_Returned = @Returned, -- guía liquidada vía material devuelto
		Guide_Delivered = @Delivered, -- guía liquidada vía comprobante de entrega
		StatusOrderId = @Status
	WHERE Guide_Serie = @GuideSerie
	AND Guide_Number = @GuideNumber
	AND ID_DeliveryOrderBySettlement = @IdManifest;
	
	IF @RecipientName IS NOT NULL AND LTRIM(RTRIM(@RecipientName)) <> N''
	BEGIN
		IF @ApplyLastMileReturnLogic = 1
		BEGIN
			SET @Status = @ReturnedStatus;
		END
		ELSE
		BEGIN
			SET @Status = @DeliveredStatus;
		END
	END
	
	IF @IsDeliveryAttempted = 0
	BEGIN
		--INSERTAR NUEVO ESTADO GUIA EN TABLA HISTORICA
		INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
		(Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations, Temperature_Celsius, StationId)
		VALUES(@GuideSerie, @GuideNumber, @Status, @Token, GETDATE(), GETDATE(), NULL, NULL,@StationId);

		-- ACTUALIZAR GUIA A ULTIMO ESTADO
		UPDATE DeliveryBackOffice.dbo.DeliveryOrder
		SET StatusOrderId = @Status,
		NameOfReceiver = ISNULL(@RecipientName, NameOfReceiver)
		WHERE Guide_Serie = @GuideSerie
		AND Guide_Number = @GuideNumber;
	END
	
	--COMPROBANTE DE ENTREGA
	IF @RecipientName IS NOT NULL AND LTRIM(RTRIM(@RecipientName)) <> N''
	BEGIN
		SELECT @ReceiverCountry = ReceiverCountryId,
			   @SenderCountry = SenderCountryId,
			   @TypeService = TypeService,
			   @GuideType = GuideType
		FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
		WHERE Guide_Serie = @GuideSerie
		AND Guide_Number = @GuideNumber
		
		IF @IsDeliveryAttempted = 0
		BEGIN
			-----------------WEBHOOK.INI-----------------------		
			DECLARE @WebhookCustomerId INT = -1;
			DECLARE @CustomerEndpointId INT = -1;
			-- Debido a que se procesa únicamente 1 guía
			DECLARE @GuideCurrentStatus INT = -1;

			BEGIN TRY
				DECLARE @GuideStatusChangeWebhook INT = (SELECT TOP 1 WT.IdWebhookType FROM [DeliveryBackOffice].[dbo].[WebhookType] WT WITH(NOLOCK) WHERE WT.WebhookName = 'GuideStatusChange' AND WT.RowStatus = 1);

				SET @WebhookCustomerId = ISNULL((SELECT TOP 1 DO.IdCustomer FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber),-1);
				SET @CustomerEndpointId = ISNULL((SELECT TOP 1 WE.IdWebhookEndpoint FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK) WHERE WE.CustomerId = @WebhookCustomerId AND  WE.WebhookTypeId = @GuideStatusChangeWebhook),-1);

				SET @GuideCurrentStatus = (SELECT TOP 1 DO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber);

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
		
		IF @GuideType = 'INT'
		BEGIN
			DECLARE @ExchangeReceiver DECIMAL(12,6);
			/***************CONVERSION MONEDA ORIGEN A DOLAR****************************/
			SET @CurrencyOrigin = (
				SELECT CodCurrency FROM DeliveryBackOffice.dbo.Cost WITH(NOLOCK) 
				WHERE GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie)

			SELECT @OriginResult = 
				CASE 
					WHEN @SenderCountry = 'GT' THEN @Amount / ExchangeRate 
					ELSE @Amount * ExchangeRate 
				END  
			FROM DeliveryBackOffice.dbo.CurrencyExchangeRates WITH(NOLOCK) 
			WHERE IdCountry = @SenderCountry 
			AND CAST(ExchangeDate AS DATE) = @Today
			AND SourceCurrency = @CurrencyOrigin
			ORDER BY ExchangeDate DESC
			
			/**********************CONVERSION DOLAR A MONEDA LOCAL***********************/
			
			SET @Currencydestination  =  (
				SELECT IdCatCurrencyCOD 
				FROM DeliveryBackOffice.dbo.CatCurrencyCOD C WITH(NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
					ON C.IdCatCurrencyCOD = DC.IdCurrencyCOD 
				WHERE DC.Currency_IdCountry = @ReceiverCountry
				AND DC.Currency_Status = 1 
				AND DC.DefaultPerCountry = 1)

			SELECT @ResultDestination = @OriginResult * ExchangeRate,
					@ExchangeReceiver = ExchangeRate
			FROM DeliveryBackOffice.dbo.CurrencyExchangeRates WITH(NOLOCK) 
			WHERE IdCountry = @ReceiverCountry
			AND CAST(ExchangeDate AS DATE) = @Today
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
				WHERE GuideSerie = @GuideSerie
				AND GuideNumber = @GuideNumber
			END
			ELSE
			BEGIN
				UPDATE DeliveryBackOffice.dbo.Cost
				SET DeliveryPaymentCurrency = @CurrencyDestination,
					DeliveryPaymentExchangeRate = @ExchangeReceiver
				WHERE GuideSerie = @GuideSerie
				AND GuideNumber = @GuideNumber
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
				WHERE GuideSerie = @GuideSerie
				AND  GuideNumber = @GuideNumber 
			END
			ELSE
			BEGIN
				UPDATE DeliveryBackOffice.dbo.Cost
				SET DeliveryPaymentCurrency = ShippingCurrency,
					DeliveryPaymentExchangeRate =ShippingExchangeRate
				WHERE GuideSerie = @GuideSerie
				AND GuideNumber = @GuideNumber
			END
		END
		
		SELECT @CurrencySymbol = CONCAT(CUR.Symbol, CONVERT(NVARCHAR,CAST(ROUND(@ResultDestination, 2) AS DECIMAL(12,2))))
		FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.Cost CO WITH (NOLOCK)
			ON DOR.Guide_Serie = CO.GuideSerie
			AND DOR.Guide_Number= CO.GuideNumber 
		LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD	CUR WITH (NOLOCK)
			ON ISNULL(co.ShippingCurrency,1) = CUR.IdCatCurrencyCOD
		WHERE DOR.Guide_Serie = @GuideSerie
		AND DOR.Guide_Number = @GuideNumber	
		
		SET @RModified = @@ROWCOUNT
	END
	ELSE
	BEGIN
		--MATERIAL DEVUELTO
		
		--FDAPI-1374 <Oscar Morales 2023-02-16> 
        -- invalidar token de incidencias
        UPDATE COI
        SET COI.ConfirmationOfIncidentToken += 'TIMEOUT'
        FROM DeliveryBackOffice.dbo.ConfirmationOfIncidence COI
		INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt DA WITH (NOLOCK)
			ON COI.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId
		WHERE DA.Guide_Serie = @GuideSerie
		AND DA.Guide_Number = @GuideNumber
		AND DA.ID_DeliveryOrderBySettlement = @IdManifest;
        -- FIN FDAPI-1374 <Oscar Morales 2023-02-16>
		
		--FDD-1071 <Oscar Morales 2023-02-16> 
        --Detectar desacatos courier
        UPDATE COI
        SET CourierContempt = 1
          , TokenUpdated = @Token
          , DateUpdated = GETDATE()
        FROM DeliveryBackOffice.dbo.ConfirmationOfIncidence COI
        INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt DA WITH (NOLOCK)
			ON COI.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId
        WHERE COI.IsActionIssued = 1
        AND DA.Guide_Serie = @GuideSerie
        AND DA.Guide_Number = @GuideNumber
        AND DA.ID_DeliveryOrderBySettlement = @IdManifest;
        --FIN FDD-1071 <Oscar Morales 2023-02-16> 

        --FDD-1071 <Oscar Morales 2023-02-22> 
        --Detectar marcado como devolución por cliente
		
		IF EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.ConfirmationOfIncidence COI WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt DA WITH (NOLOCK)
				ON COI.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId     
            WHERE COI.ClientConfirmsReturn = 1
            AND DA.Guide_Serie = @GuideSerie
            AND DA.Guide_Number = @GuideNumber
            AND DA.ID_DeliveryOrderBySettlement = @IdManifest
        )
        BEGIN
            SET @IsMarkedReturn = 1;

            -- registrar checkpoint histórico de devolución
            INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
			(Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations, Temperature_Celsius, StationId)
            VALUES(@GuideSerie, @GuideNumber, @MarkedForReturnStatus, @Token, GETDATE(), GETDATE(), NULL, NULL,@StationId);

            -- registrar último checkpoint de devolución
            UPDATE DeliveryBackOffice.dbo.DeliveryOrder
            SET StatusOrderId = @MarkedForReturnStatus
            WHERE Guide_Serie = @GuideSerie
            AND Guide_Number = @GuideNumber;

        END;
		--FDD-1073 <Oscar Morales 2023-02-22> 

        --FDD-1075 <Oscar Morales 2023-02-24> 
        --Actualizar inténtos de entrega/devolución 

        --Si no existe el registro, crearlo
		IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.DeliveryOrderAttemptData WITH (NOLOCK)
            WHERE GuideSerie = @GuideSerie
            AND GuideNumber = @GuideNumber
            AND RowStatus = 1
        )
        BEGIN
            INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderAttemptData
            (GuideSerie, GuideNumber, GuideDeliveryAttemptCount, GuideDeliveryMaxAttemptCount, GuideReturnAttemptCount, 
			 GuideReturnMaxAttemptCount, RowStatus, DateCreated, TokenCreated, DateUptaded, TokenUpdated)
            SELECT TOP 1
				DO.Guide_Serie, 
				DO.Guide_Number,
                CASE
                    WHEN COI.IdConfirmationOfIncidence IS NOT NULL
						AND SO.OrderDescription = 'Incidencia Validada' /* 'Intento de entrega fallida'*/
                        AND (DO.IsLastMileReturn IS NULL OR DO.IsLastMileReturn = 0 OR COI.ClientConfirmsReturn = 1) THEN 1
                    ELSE 0
                END,
                RH.Attempt,
                CASE
					WHEN COI.IdConfirmationOfIncidence IS NOT NULL
						AND SO.OrderDescription = 'Intento de entrega fallida'
						AND DO.IsLastMileReturn = 1
						AND (COI.ClientConfirmsReturn IS NULL OR COI.ClientConfirmsReturn = 0) THEN	1
					ELSE 0
				END,
				RH.AttemptReturn,
				1,
				GETDATE(),
				@Token,
				NULL,
				NULL
            FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
			LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
				ON DO.Sender_ID = VPC.CodeOfReference
			INNER JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH (NOLOCK)
				ON ISNULL(DO.IdCustomer, VPC.CustomerID) = RBC.RbcIdCustomer
				AND RBC.RbcRowStatus = 1
				AND (RBC.RbcCodeOfReference = VPC.CodeOfReference OR RBC.RbcCodeOfReference IS NULL)
			INNER JOIN DeliveryBackOffice.dbo.RateHeader RH WITH (NOLOCK)
				ON RBC.RbcIdRate = RH.RheId
			INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt DA WITH (NOLOCK)
				ON DO.Guide_Serie = DA.Guide_Serie
				AND DO.Guide_Number = DA.Guide_Number
			LEFT JOIN DeliveryBackOffice.dbo.ConfirmationOfIncidence COI WITH (NOLOCK)
				ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
			LEFT JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH(NOLOCK)
				ON COI.StatusOrderId = SO.StatusOrderId
			WHERE DO.Guide_Serie = @GuideSerie
			AND DO.Guide_Number = @GuideNumber
			AND DA.ID_DeliveryOrderBySettlement = @IdManifest
			ORDER BY RBC.RbcCodeOfReference DESC;
        END;
        ELSE
        BEGIN
            UPDATE DOAD
				SET DOAD.GuideDeliveryAttemptCount = 
						CASE
							WHEN SO.OrderDescription = 'Incidencia Validada' 
								AND ISNULL(CTI.IncidenceClasificationId,0) = 1 THEN DOAD.GuideDeliveryAttemptCount + 1
							ELSE DOAD.GuideDeliveryAttemptCount
						END,
					DOAD.GuideReturnAttemptCount = 
						CASE
							WHEN DO.IsLastMileReturn = 1 
								AND (COI.ClientConfirmsReturn IS NULL OR COI.ClientConfirmsReturn = 0) THEN DOAD.GuideReturnAttemptCount + 1
							ELSE DOAD.GuideReturnAttemptCount
						END,
					DOAD.DateUptaded = GETDATE(),
					DOAD.TokenUpdated = @Token
            FROM DeliveryBackOffice.dbo.DeliveryOrderAttemptData DOAD
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
				ON DOAD.GuideSerie = DO.Guide_Serie
				AND DOAD.GuideNumber = DO.Guide_Number
			INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt DA WITH (NOLOCK)
				ON DOAD.GuideSerie = DA.Guide_Serie
				AND DOAD.GuideNumber = DA.Guide_Number
			INNER JOIN DeliveryBackOffice.dbo.ConfirmationOfIncidence COI WITH (NOLOCK)
				ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
			INNER JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH (NOLOCK)
				ON COI.StatusOrderId = SO.StatusOrderId
			INNER JOIN DeliveryBackOffice.dbo.CatTypeIncidence CTI WITH (NOLOCK)
				ON DA.ID_Incident = CTI.IdIncidenceType
			WHERE DOAD.GuideSerie = @GuideSerie
			AND DOAD.GuideNumber = @GuideNumber
			AND DA.ID_DeliveryOrderBySettlement = @IdManifest
			AND ISNULL(CTI.IncidenceClasificationId, 0) = 1
			AND COI.IsDenied = 0 --no esté denegada
			AND SO.OrderDescription IN ('Incidencia Validada', 'Intento de entrega fallida');
        END;
		
		SET @CurrencySymbol = '';
		
		SET @RModified = @@ROWCOUNT;
	END
	
	END TRY
    BEGIN CATCH
        SELECT 0                                             AS 'StatusCode',
			ERROR_MESSAGE()                               AS 'Description',
			CONVERT(BIGINT, 0)                            AS 'NumTransferID',
			@GuideSerie + CONVERT(NVARCHAR, @GuideNumber) AS 'Guide',
			@Amount                                       AS 'Amount',
			0                                             AS 'SubStatusCode',
			0 AS RetriesMade,
			0 AS RetriesAllowed,
			ERROR_LINE() AS ErrorLine;
        ROLLBACK TRANSACTION;
		
		IF @RecipientName IS NOT NULL AND LTRIM(RTRIM(@RecipientName)) <> N''
		BEGIN
			INSERT INTO DeliveryBackOffice.dbo.RoutePreparationLogError
			(ErrorDescription, ErrorNumber, ErrorProcedure, ErrorLine, GuideSerie, GuideNumber,TokenCreated, DateCreated)
			VALUES
			(ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_PROCEDURE(), ERROR_LINE(), @GuideSerie, @GuideNumber, @Token, GETDATE())
		END
    END CATCH;
	
	IF @@TRANCOUNT > 0
	BEGIN
		IF (@RModified > 0)
			SELECT 1                                      AS 'StatusCode',
			'Registro guardado correctamente'             AS 'Description',
			@@TRANCOUNT                                   AS 'NumTransferID',
			@GuideSerie + CONVERT(NVARCHAR, @GuideNumber) AS 'Guide',
			@Amount                                       AS 'Amount',
			1                                             AS 'SubStatusCode',
			CASE
				WHEN DOR.IsLastMileReturn = 1 THEN ISNULL(DOAD.GuideReturnAttemptCount, 1)
				ELSE ISNULL(DOAD.GuideDeliveryAttemptCount, 1)
			END                                           AS RetriesMade,
			CASE
				WHEN DOR.IsLastMileReturn = 1 THEN ISNULL(DOAD.GuideReturnMaxAttemptCount, 2)
				ELSE ISNULL(DOAD.GuideDeliveryMaxAttemptCount, 2)
			END                                           AS RetriesAllowed,
			''                                            'Retries',
			CASE
				WHEN @RecipientName IS NOT NULL AND LTRIM(RTRIM(@RecipientName)) <> N'' THEN 0
				ELSE DOR.IsLastMileReturn
			END		                          AS ValidateAbandonedPackage,
			CASE
				WHEN @RecipientName IS NOT NULL AND LTRIM(RTRIM(@RecipientName)) <> N'' THEN 0
				ELSE @IsMarkedReturn
			END								  AS IsMarkedReturn,
			ISNULL(NULLIF(COI.LiquidatorRemarks, ''), 'Sin Observaciones') AS LiquidatorRemarks,
			@CurrencySymbol AS 'CurrencySymbol'
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
			LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderAttemptData DOAD WITH (NOLOCK)
				ON DOAD.GuideSerie = DOR.Guide_Serie AND DOAD.GuideNumber = DOR.Guide_Number
			LEFT JOIN DeliveryBackOffice.dbo.DeliveryAttempt DA WITH (NOLOCK)
				ON DOR.Guide_Serie = DA.Guide_Serie	AND DOR.Guide_Number = DA.Guide_Number
			LEFT JOIN DeliveryBackOffice.dbo.ConfirmationOfIncidence COI WITH (NOLOCK)
				ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
			WHERE DOR.Guide_Serie = @GuideSerie
			AND DOR.Guide_Number = @GuideNumber
			AND DOAD.RowStatus = 1;

		ELSE
			SELECT 0                                      AS 'StatusCode',
			'Registro no encontrado'                      AS 'Description',
			0                                             AS 'NumTransferID',
			@GuideSerie + CONVERT(NVARCHAR, @GuideNumber) AS 'Guide',
			@Amount                                       AS 'Amount',
			0                                             AS 'SubStatusCode',
			0                                             AS RetriesMade,
			0                                             AS RetriesAllowed,
			''                                            AS 'Retries',
			0                                             AS ValidateAbandonedPackage,
			0                                             AS IsMarkedReturn;

		COMMIT TRANSACTION;
	END;
	ELSE
		BEGIN
			SELECT 0                                      AS 'StatusCode',
			ERROR_MESSAGE()                               AS 'Description',
			CONVERT(BIGINT, 0)                            AS 'NumTransferID',
			@GuideSerie + CONVERT(NVARCHAR, @GuideNumber) AS 'Guide',
			@Amount                                       AS 'Amount',
			0                                             AS 'SubStatusCode',
			0                                             AS RetriesMade,
			0                                             AS RetriesAllowed,
			''                                            AS 'Retries',
			0                                             AS ValidateAbandonedPackage,
			0                                             AS IsMarkedReturn;
		END
		
		
END;

