-- =============================================
-- Author:      Daniel Ramirez
-- Create date: 2024/10/17
-- Description: Se valida si ya se ha generado el id de certificacion de guia de remisión
-- =============================================
CREATE PROCEDURE [dbo].[ValidateCertificationGuide]
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
                   SELECT 1 AS IfManifestExists
              END
              ELSE
              BEGIN
                   SELECT 0 AS IfManifestExists
              END

         COMMIT TRANSACTION 
     END TRY
     BEGIN CATCH
         IF @@TRANCOUNT > 0
         BEGIN 
            ROLLBACK TRANSACTION;
         END 

         SELECT 0 AS IfManifestExists
     END CATCH
END;