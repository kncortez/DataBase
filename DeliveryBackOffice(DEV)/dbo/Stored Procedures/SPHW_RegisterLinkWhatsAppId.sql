CREATE PROCEDURE [dbo].[SPHW_RegisterLinkWhatsAppId]
  @LinkId INT,
  @WhatsAppId NVARCHAR(200)
AS 
BEGIN 
	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE DeliveryBackOffice.dbo.DeliveryLink
		SET WhatsappId = @WhatsAppId
		WHERE IdDeliveryLink = @LinkId
		COMMIT TRANSACTION

		SELECT
		200 AS 'StatusCode',
		'Registro guardado correctamente' AS 'Description'
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT
		400 AS 'StatusCode',
		'Error al registrar Link de Entrega' AS 'Description'
	END CATCH
END