-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-09-25>
-- Description:	<Anulacion de links de entregas>
-- =============================================
CREATE PROCEDURE SPHW_CancelledDeliveryLink
				@IdDeliveryLink INT
AS
BEGIN
    BEGIN TRY
        DECLARE @Status INT = (
                                  SELECT IdDeliveryLinkStatus FROM DeliveryLinkStatus WHERE Name = 'Anulado'
                              )
        DECLARE @StatusAcepted INT = (
                                         SELECT IdDeliveryLinkStatus
                                         FROM DeliveryLinkStatus
                                         WHERE Name = 'Aperturado'
                                     )

        IF EXISTS
        (
            SELECT IdDeliveryLink
            FROM DeliveryLink
            WHERE IdDeliveryLink = @IdDeliveryLink
                  AND DeliveryLinkStatusId = @StatusAcepted
        )
        BEGIN
            BEGIN TRANSACTION;
            UPDATE DeliveryLink
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