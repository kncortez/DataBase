
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-12-01>
-- Description: <Actualizar registros vinculados a una guía en específico cuando se hace una reversión.>
-- =============================================
-- FDD-699: Se valida que no este generado el lote en BatchDetailCOD y se agrega update para poder actualizar la tabla
-- =============================================
-- =============================================
-- Author:      <Edelman ,Vasquez>
-- Create date: <2022-07-26>
-- Description: <Agregar filtros y valdiaciones para reversión de estado.>
-- =============================================

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
            @dateBatchCOD DATE,
			@LastState AS INT
	

   --Al estar en estado COD Pagado o COD Liquidado no debe permitir la reversión
    SELECT 
        @current_BatchCODId  = ISNULL(PGD.BatchCODId,BDC.BatchCODId), 
        @current_BatchCODIdCommission = ISNULL(PGD.BatchCODIdCommission,BDCCM.BatchCODId),
        @dateBatchCOD = Date
    FROM 
        DeliveryBackOffice.dbo.ProcessedGuideCOD PGD WITH (NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.BatchDetailCOD BDC WITH (NOLOCK) 		
		ON BDC.GuideSerie = PGD.GuideSerie
        AND BDC.GuideNumber = PGD.GuideNumber
		AND BDC.CatConceptCODId = 2
		LEFT JOIN DeliveryBackOffice.dbo.BatchDetailCOD BDCCM WITH (NOLOCK)
		ON BDCCM.GuideSerie = PGD.GuideSerie
        AND BDCCM.GuideNumber = PGD.GuideNumber
		AND BDCCM.CatConceptCODId = 1
    WHERE 
        PGD.GuideSerie = @Guide_Serie
        AND PGD.GuideNumber = @Guide_Number

		--No permitir reversión si la guía ya cuenta con BatchID
    IF (@current_BatchCODId IS NULL AND @current_BatchCODIdCommission IS NULL OR @current_BatchCODId  ='' AND @current_BatchCODIdCommission ='') --Se hace la reversión si ambos valores son NULL
    BEGIN
		BEGIN TRANSACTION
			  BEGIN TRY
			--Regresar a estado anterior en tabla DeliveryOrder
			DECLARE @currentState TINYINT,
					@NewState TINYINT
			SELECT 
				@currentState = StatusOrderId
			FROM 
				DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
			WHERE 
				Guide_Serie =  @Guide_Serie
				AND Guide_Number = @Guide_Number

			----- Obtener último estado de la guía
					SELECT
						   TOP 1   @LastState = StatusOrderId 
					FROM [dbo].[DeliveryOrderDetail] WITH (NOLOCK)
					WHERE   Guide_Serie = @Guide_Serie AND  Guide_Number = @Guide_Number
							AND RowStatus = 1 AND StatusOrderId<> @currentState
					ORDER BY DateCreated DESC
           -- Se deberá actualizar al estado anterior en DeliveryOrder, según registros de DeliveryOrderDetail.
				UPDATE 
					DeliveryBackOffice.dbo.DeliveryOrder 
				SET 
					StatusOrderId = @LastState
				WHERE 
					Guide_Serie =  @Guide_Serie
					AND Guide_Number = @Guide_Number
			
			--Actualizamos el registro en la tabla DeliveryOrderDetail
			
			UPDATE 
				DeliveryBackOffice.dbo.DeliveryOrderDetail ---Se deberá inactivar estado actual
			SET 
				RowStatus = 0,
				Observations = 'Guía revertida desde modulo de reversión de estados.'
				
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
		--Al estar en estado Entregado deberá inactivar el registro en la ProcessedGuide, siempre y cuando el BatchID y BatchCommision sean NULL
			IF (@currentState = 5)
			BEGIN
					UPDATE
					   DeliveryBackOffice.dbo.ProcessedGuideCOD 
					SET
					   RowStatus = 0 
					WHERE
					   GuideSerie = @Guide_Serie 
					   AND GuideNumber = @Guide_Number
					   AND BatchCODId IS NULL
					   AND BatchCODIdCommission IS NULL

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

		COMMIT TRANSACTION
		END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
			END CATCH
    END
    ELSE
    BEGIN
	    
        SELECT @current_BatchCODId, @dateBatchCOD AS BatchCODId
    END
END