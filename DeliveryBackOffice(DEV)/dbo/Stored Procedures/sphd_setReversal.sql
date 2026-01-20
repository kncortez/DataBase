/* =================================================
   SP:        sphd_setReversal
   Propósito: Actualizar registros vinculados a una guía específica cuando se realiza una reversión
   Autor:     Cesar Sazo
   Historia:  ---
   Fecha:     2021-12-01

=== CHANGELOG ============================

---- -- -- | Historia/épica: FDD-699    | Autor: --- | Se valida que no esté generado el lote en BatchDetailCOD y se agrega update para permitir actualizar la tabla
2026-01-18 | Historia/épica: FDAPI-5378 | Autor: Brandon Pedroza | Se agrega notificación webhook para reversion de entrega

=========================================== */

CREATE PROCEDURE [dbo].[sphd_setReversal]
    @Guide_Serie VARCHAR(2),
    @Guide_Number INT,
    @Comment VARCHAR(150),
    @UserToken VARCHAR(50)
AS
BEGIN
    
    --Variables que deben verificarse si son NULL antes de hacer la reversión
    DECLARE @current_BatchCODId INT,
            @current_BatchCODIdCommission INT,
            @dateBatchCOD DATE;
	
	DECLARE @ReversalDelivery INT = NULL -- bandera que indica Reversión de entrega -- 
	DECLARE @WebhookReversalType INT = (SELECT IdWebhookType FROM DeliveryBackOffice.dbo.WebhookType WITH(NOLOCK) WHERE WebhookName = 'ReversalDeliveredGuides')
   --FDD-699
    SELECT 
        @current_BatchCODId  = ISNULL(PGD.BatchCODId,BDC.BatchCODId), 
        @current_BatchCODIdCommission = ISNULL(PGD.BatchCODIdCommission,BDCCM.BatchCODId),
        @dateBatchCOD = Date
    FROM 
        DeliveryBackOffice.dbo.ProcessedGuideCOD PGD WITH(NOLOCK) 
		LEFT JOIN DeliveryBackOffice.dbo.BatchDetailCOD BDC  WITH(NOLOCK) 		
		ON BDC.GuideSerie = PGD.GuideSerie
        AND BDC.GuideNumber = PGD.GuideNumber
		AND BDC.CatConceptCODId = 2
		LEFT JOIN DeliveryBackOffice.dbo.BatchDetailCOD BDCCM  WITH(NOLOCK) 
		ON BDCCM.GuideSerie = PGD.GuideSerie
        AND BDCCM.GuideNumber = PGD.GuideNumber
		AND BDCCM.CatConceptCODId = 1
    WHERE 
        PGD.GuideSerie = @Guide_Serie
        AND PGD.GuideNumber = @Guide_Number

    IF @current_BatchCODId IS NULL AND @current_BatchCODIdCommission IS NULL --Se hace la reversión si ambos valores son NULL
    BEGIN
        --Regresar a estado anterior en tabla DeliveryOrder
        DECLARE @currentState TINYINT,
                @NewState TINYINT
        SELECT 
            @currentState = StatusOrderId
        FROM 
            DeliveryBackOffice.dbo.DeliveryOrder do  WITH(NOLOCK) 
        WHERE 
            Guide_Serie =  @Guide_Serie
            AND Guide_Number = @Guide_Number

        IF @currentState = 5
            SET @NewState = 4
        ELSE IF @currentState = 22
            SET @NewState = 21
        
        UPDATE 
            DeliveryBackOffice.dbo.DeliveryOrder 
        SET 
            StatusOrderId = ISNULL(@NewState,@currentState)
        WHERE 
            Guide_Serie =  @Guide_Serie
            AND Guide_Number = @Guide_Number

        --Actualizamos el registro en la tabla DeliveryOrderDetail
        UPDATE 
            DeliveryBackOffice.dbo.DeliveryOrderDetail 
        SET 
            RowStatus = IIF(@NewState  = NULL,1,0),
            Observations = 'Guía revertida desde módulo de reversión de estados.'
        WHERE 
            Guide_Serie =  @Guide_Serie
            AND Guide_Number = @Guide_Number
            AND StatusOrderId = @currentState

		--FDD-699: Revertimos guía en tabla DeliverySettlementDetail, para evitar que se liquide una guía que fue reversada
		UPDATE
			 DeliveryBackOffice.dbo.DeliverySettlementDetail
		SET
			 Guide_Returned  = 1 , 
			 Guide_Delivered = 0 
        WHERE 
			 Guide_Serie =  @Guide_Serie
             AND Guide_Number = @Guide_Number

        --Revertimos guía en tabla ProcessedGuideCOD
        UPDATE
           DeliveryBackOffice.dbo.ProcessedGuideCOD 
        SET
           RowStatus = 0 
        WHERE
           GuideSerie = @Guide_Serie 
           AND GuideNumber = @Guide_Number

   				-------------------WEBHOOK.INI------------------------------

		IF( @currentState IN (5, 22, 25)) -- Entregado, entregado en express center o COD Pagado
		BEGIN
			DECLARE @WebhookCustomerId INT = -1;
			DECLARE @CustomerEndpointId INT = -1;
			DECLARE @GuideCurrentStatus INT = -1;
			DECLARE @GuideStatusChangeWebhook INT = -1;

			BEGIN TRY
				;WITH GuideData AS
				(
					SELECT 
						DO.IdCustomer,
						@ReversalDelivery AS StatusOrderId,
						WE.IdWebhookEndpoint,
						WT.IdWebhookType
					FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.WebhookEndpoint WE WITH (NOLOCK)
						ON WE.CustomerId = DO.IdCustomer
					INNER JOIN DeliveryBackOffice.dbo.WebhookType WT WITH (NOLOCK)
						ON WT.IdWebhookType = WE.WebhookTypeId
					WHERE DO.Guide_Serie  = @Guide_Serie
						AND DO.Guide_Number = @Guide_Number
						AND WE.WebhookTypeId = @WebhookReversalType
						AND WT.RowStatus = 1
				)
				SELECT TOP 1
					@WebhookCustomerId      = ISNULL(IdCustomer, -1),
					@CustomerEndpointId     = ISNULL(IdWebhookEndpoint, -1),
					@GuideCurrentStatus     = StatusOrderId,
					@GuideStatusChangeWebhook = ISNULL(IdWebhookType, -1)
				FROM GuideData;

				-- Validar que el cliente y endpoint existan y que el estado esté permitido
				IF (@WebhookCustomerId > 0
					AND @CustomerEndpointId > 0)
				BEGIN
					INSERT INTO DeliveryBackOffice.dbo.WebhookTrackingQueue
					(
						GuideSerie,
						GuideNumber,
						CustomerId,
						StatusOrderId,
						WebhookEndpointId,
						HasNotified,
						TokenCreated,
						DateCreated
					)
					VALUES
					(@Guide_Serie, @Guide_Number, @WebhookCustomerId, @GuideCurrentStatus,
						@CustomerEndpointId, 0, @UserToken, GETDATE());
				END
				ELSE
				BEGIN
					UPDATE
						[DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
					SET
						RowStatus = 0
						,TokenUpdated = @UserToken
						,DateUpdated = GETDATE()
					WHERE
						GuideSerie = @Guide_Serie
						AND
						GuideNumber = @Guide_Number
						AND
						RowStatus = 1
						AND
						StatusOrderId = @currentState;
				END;
			END TRY
			BEGIN CATCH
				PRINT 'Error en el procesamiento de webhook: ' + ERROR_MESSAGE();
			END CATCH;
				-------------------WEBHOOK.FIN------------------------------

		END

        --Por ultimo se inserta en la tabla DeliveryOrderReversalStatus para tener un log de las reversiones.
        INSERT INTO [dbo].[DeliveryOrderReversalStatus]
               ([Guide_Serie]
               ,[Guide_Number]
               ,[Comment]
               ,[RowStatus]
               ,[TokenCreated]
               ,[DateCreated])
         VALUES
               (@Guide_Serie
               ,@Guide_Number
               ,@Comment
               ,1
               ,@UserToken
               ,GETDATE())
        SELECT 0 AS BatchCODId
    END
    ELSE
    BEGIN
        SELECT @current_BatchCODId, @dateBatchCOD AS BatchCODId
    END
END
