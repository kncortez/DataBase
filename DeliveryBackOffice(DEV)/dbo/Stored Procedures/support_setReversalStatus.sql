
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-12-01>
-- Description: <Actualizar registros vinculados a una guía en específico cuando se hace una reversión.>
-- =============================================
-- FDD-699: Se valida que no este generado el lote en BatchDetailCOD y se agrega update para poder actualizar la tabla
-- =============================================

CREATE PROCEDURE [dbo].[support_setReversalStatus]
    @Guide_Serie VARCHAR(2),
    @Guide_Number INT,
    @Comment VARCHAR(150),
    @SupportToken VARCHAR(50)
AS
BEGIN
    
    --Variables que deben verificarse si son NULL antes de hacer la reversión
    DECLARE @current_BatchCODId INT,
            @current_BatchCODIdCommission INT,
            @dateBatchCOD DATE
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

        --IF @currentState = 5
        --    SET @NewState = 4
        --ELSE IF @currentState = 22
        --    SET @NewState = 21
        


		         
        SELECT  TOP 1
            @NewState = dop.StatusOrderId
        FROM 
            DeliveryBackOffice.dbo.DeliveryOrderDetail dop  WITH(NOLOCK) 
        WHERE 
            dop.Guide_Serie =  @Guide_Serie
            AND dop.Guide_Number = @Guide_Number
			AND dop.StatusOrderId NOT IN (@currentState)
		ORDER BY dop.DateCreated DESC



        UPDATE 
            DeliveryBackOffice.dbo.DeliveryOrder 
        SET 
            StatusOrderId = ISNULL(@NewState,@currentState)
        WHERE 
            Guide_Serie =  @Guide_Serie
            AND Guide_Number = @Guide_Number

        --Actualizamos el registro en la tabla DeliveryOrderDetail
        --UPDATE 
        --    DeliveryBackOffice.dbo.DeliveryOrderDetail 
        --SET 
        --    RowStatus = IIF(@NewState  = NULL,1,0),
        --    Observations = CONCAT('Guía revertida por soporte de aplicaciones  - ', @SupportToken) 
        --WHERE 
        --    Guide_Serie =  @Guide_Serie
        --    AND Guide_Number = @Guide_Number
        --    AND StatusOrderId = @currentState


		DECLARE @Fecha DATETIME
		DECLARE @token NVARCHAR(100)

		SELECT TOP 1 @Fecha = dt.DateCreated
			, @token = dt.UserCreated
		FROM dbo.DeliveryOrderDetail dt
		WHERE dt.Guide_Serie =@Guide_Serie AND dt.Guide_Number = @Guide_Number AND dt.StatusOrderId = @currentState AND dt.RowStatus = 1
		ORDER BY dt.DateCreated DESC

		DELETE dbo.DeliveryOrderDetail
		WHERE Guide_Serie = @Guide_Serie AND Guide_Number =@Guide_Number AND UserCreated = @token AND DateCreated = @Fecha



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

		IF( @currentState IN (5, 22, 25)) -- Entregado, entregado en express center o COD Pagado
		BEGIN
		
				-------------------WEBHOOK.INI------------------------------
					UPDATE
						[DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
					SET
						RowStatus = 0
						,TokenUpdated = @SupportToken
						,DateUpdated = GETDATE()
					WHERE
						GuideSerie = @Guide_Serie
						AND
						GuideNumber = @Guide_Number
						AND
						RowStatus = 1
						AND
						StatusOrderId = @currentState;



				    UPDATE
						[DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailForSFTP]
					SET
						RowStatus = 0
						,TokenUpdated = @SupportToken
						,DateUpdated = GETDATE()
					WHERE
						GuideSerie = @Guide_Serie
						AND
						GuideNumber = @Guide_Number
						AND
						RowStatus = 1
						AND
						StatusOrderId = @currentState;
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
               ,@SupportToken
               ,GETDATE())
        SELECT 0 AS BatchCODId
    END
    ELSE
    BEGIN
        SELECT @current_BatchCODId, @dateBatchCOD AS BatchCODId
    END
END