-- =============================================
-- Author:		<Oscar Rodriguez>
-- Create date: <2025-03-21>
-- Description:	<Obtencion de clientes para mensaje promocional en servicio Hermes Webhook Sender>
-- =============================================
CREATE PROCEDURE [dbo].[sphwGetWhatsappClientsNotification]
	--@IdCountry NVARCHAR(2)= 'GT'
AS
BEGIN
	SELECT TOP 5000 UsrIdUser, UsrIdPerson, UsrNickName, UsrEmail, PrefixCallingCode, Phone 
	FROM DeliveryBackOffice.dbo.RegisterUser
	WHERE Phone is not null
	AND Phone <> ''
	AND UsrRowStatus = 1
	order by UsrIdUser desc
END;