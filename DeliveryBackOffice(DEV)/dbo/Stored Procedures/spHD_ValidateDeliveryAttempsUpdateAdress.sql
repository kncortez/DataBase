-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-11-29>
-- Description:	<Obtiene listado de guías que se modifico dirección de confirmación de incidnecias.>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_ValidateDeliveryAttempsUpdateAdress]
    -- Add the parameters for the stored procedure here
    @DeliveryOrderBySettlementId bigint
as
begin
   
    BEGIN TRANSACTION;
    BEGIN TRY
       
	   SELECT 1 'StatusCode',
                'Registros obtenidos correctamente.' 'Description';

		Select DO.Guide_Serie, DO.Guide_Number 
         FROM [dbo].[DeliveryOrder] [DO] WITH (NOLOCK)
                INNER JOIN [dbo].[DeliveryAttempt] DA WITH (NOLOCK)
                    ON [DO].[Guide_Serie] = [DA].[Guide_Serie]
                       AND [DO].[Guide_Number] = [DA].[Guide_Number]
                INNER JOIN [dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                    ON [DA].[ConfirmationOfIncidenceId] = [COI].[IdConfirmationOfIncidence]
            WHERE 
                  DA.ID_DeliveryOrderBySettlement= @DeliveryOrderBySettlementId
                  AND 
				  COI.IsAddressModificationRequested=1;

		    UPDATE COI 
			       SET [COI].IsAddressModificationRequested = 0 
            FROM [dbo].[DeliveryOrder] [DO]
                INNER JOIN [dbo].[DeliveryAttempt] DA WITH (NOLOCK)
                    ON [DO].[Guide_Serie] = [DA].[Guide_Serie]
                       AND [DO].[Guide_Number] = [DA].[Guide_Number]
                INNER JOIN [dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                    ON [DA].[ConfirmationOfIncidenceId] = [COI].[IdConfirmationOfIncidence]
            WHERE 
                 DA.ID_DeliveryOrderBySettlement = @DeliveryOrderBySettlementId
                  AND COI.IsAddressModificationRequested=1;

				

              COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT 0 'StatusCode',
                ERROR_MESSAGE() 'Description';
    END CATCH;
END;