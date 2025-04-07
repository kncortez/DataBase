-- =============================================
-- Author:      Daniel Ramirez
-- Create date: 2024/10/17
-- Description: Se valida si ya se ha generado el id de certificacion de guia de remisión
-- =============================================
CREATE PROCEDURE [dbo].[UpdateSendManifestLinehaul]
(
    @IdManifest      BIGINT, --@IdLinehaulRoutePreparation
    @User            NVARCHAR(100) = 'SYSTEM'
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
             IF EXISTS
             (
               SELECT TOP 1 1
                 FROM [DeliveryBackOffice].[dbo].[InvoiceBatchDetailLinehaul]
                WHERE LinehaulRoutePreparationId = @IdManifest
             )
             BEGIN
                  UPDATE [DeliveryBackOffice].[dbo].[InvoiceBatchDetailLinehaul]
                     SET SendManifest = 1
                   WHERE LinehaulRoutePreparationId = @IdManifest
             END

             SELECT 1 AS [StatusCode],
                    'Actualizado correctamente' AS [Message]

        COMMIT TRANSACTION 
    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0 
        BEGIN
           ROLLBACK TRANSACTION;
        END 
             SELECT 0 AS [StatusCode],
                    'Error al actualizar' AS [Message]

    END CATCH

END;