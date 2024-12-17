
-- =============================================
-- Modified:	<Cristian Suazo>
-- Create date: <2024-12-16>
-- Description:	<Se actualiza el estado a no enviado en el proyecto de envio de mensajes de WhatsApp>
-- =============================================
CREATE PROCEDURE spg_update_sendstatus
    @Guide_Serie NVARCHAR(2) = 'FD',
    @Guide_Number INT,
    @StatusOrder INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        UPDATE SMS_Sent
        SET Sent = 0,
			TokenUpdate = 'SYS-SMS-spg_update_sendstatus',
			UpdatedDatetime = GETDATE()
        WHERE Sent_Guide_Series = @Guide_Serie
              AND Sent_Guide_Number = @Guide_Number
              AND StatusOrderId = @StatusOrder

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

		SELECT 200 AS StatusCode

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

		SELECT 0  AS StatusCode

    END CATCH
END