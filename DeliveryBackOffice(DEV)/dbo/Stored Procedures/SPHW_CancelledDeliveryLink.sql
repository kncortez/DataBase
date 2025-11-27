-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-09-25>
-- Description:	<Anulacion de links de entregas>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_CancelledDeliveryLink]
	@IdDeliveryLink INT
AS
BEGIN
    BEGIN TRY
        DECLARE @Status INT = (
                                  SELECT IdDeliveryLinkStatus FROM DeliveryBackOffice.dbo.DeliveryLinkStatus WHERE Name = 'Anulado'
                              )
        IF EXISTS
        (
            SELECT IdDeliveryLink
            FROM DeliveryBackOffice.dbo.DeliveryLink
            WHERE IdDeliveryLink = @IdDeliveryLink
                  AND DeliveryLinkStatusId IN (SELECT IdDeliveryLinkStatus FROM DeliveryBackOffice.dbo.DeliveryLinkStatus  WITH(NOLOCK)
				  WHERE [Name] IN ('Completado','Caducado','Enviado','Aperturado','Recibido'))
        )
        BEGIN
            BEGIN TRANSACTION;
            UPDATE DeliveryBackOffice.dbo.DeliveryLink
            SET DeliveryLinkStatusId = @Status
            WHERE IdDeliveryLink = @IdDeliveryLink
            COMMIT TRANSACTION;

            SELECT 200 AS StatusCode,
                   'Link anulado correctamente' AS Description
        END
        ELSE
        BEGIN
            SELECT 0 AS StatusCode,
                   'No se puede anular: Registro no encontrado' AS Description
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 0 AS StatusCode,
               ERROR_MESSAGE() AS Description,
               ERROR_LINE() AS LineError
    END CATCH
END