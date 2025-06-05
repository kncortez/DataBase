DECLARE @ExternalPlatformId INT = (SELECT IdExternalPlatform FROM CatExternalPlatform WITH(NOLOCK) WHERE 	NameExternalPlatform = 'SMSZigiPaymentLink')

UPDATE ConfigExternalPlatform
SET ConfigParameterValue = 'Hola <DESTINATARIO>. En Forza Delivery hemos recibido una solicitud de pago vía Zigi del paquete <GUIA> por monto de <MONEDA><MONTO>. Paga en línea: <LINK>'
WHERE ExternalPlatformId = @ExternalPlatformId

