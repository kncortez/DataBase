-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-09-26>
-- Description:	<Link de Entrega - Reactivación de links de entregas cuando se encuentren en estado caducado.>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_ReactivateDeliveryLink]
@IdDeliveryLink INT
AS
BEGIN
    BEGIN TRY
        DECLARE @Status INT = (
                                  SELECT IdDeliveryLinkStatus FROM DeliveryBackOffice.dbo.DeliveryLinkStatus WHERE Name = 'Enviado'
                              )
        DECLARE @StatusAcepted INT = (
                                         SELECT IdDeliveryLinkStatus
                                         FROM DeliveryLinkStatus
                                         WHERE Name = 'Caducado'
                                     )

        IF EXISTS
        (
            SELECT 1 FROM DeliveryBackOffice.dbo.DeliveryLink WHERE IdDeliveryLink = @IdDeliveryLink
            AND DeliveryLinkStatusId = @StatusAcepted
        )
        BEGIN
            BEGIN TRANSACTION;

            UPDATE DeliveryBackOffice.dbo.DeliveryLink
            SET DeliveryLinkStatusId = @Status, ExpirationDate = DATEADD(DAY, 1, GETDATE())
            WHERE IdDeliveryLink = @IdDeliveryLink
            COMMIT TRANSACTION;

            SELECT 200 AS StatusCode
                   ,'Link reactivado correctamente.' AS Description
				   , RU.UsrNickName AS 'SenderName'
				   , ReceiverEmail
				   , ReceiverName
				   , ReceiverPhone
			FROM DeliveryBackOffice.dbo.DeliveryLink DL WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.Account A WITH(NOLOCK)
			ON DL.AccountId = A.AccIdAccount
			INNER JOIN DeliveryBackOffice.dbo.RolByUserByAccount RBUBA WITH(NOLOCK)
			ON A.IdCustomer = RBUBA.RuaIdAccount
			INNER JOIN DeliveryBackOffice.dbo.RegisterUser RU WITH(NOLOCK)
			ON RBUBA.RuaIdUser = RU.UsrIdUser
			WHERE IdDeliveryLink = @IdDeliveryLink
				 
        END
        ELSE
        BEGIN
            SELECT 400 AS StatusCode,
                   'No se puede reactivar el Link, revise el estado.' AS Description
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