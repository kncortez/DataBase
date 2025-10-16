INSERT INTO CatExternalPlatform VALUES ('SMSZigiPaymentLink',1,'SYS-BPEDROZA',GETDATE(),NULL,NULL);

DECLARE @ExternalPlatformId INT = (SELECT IdExternalPlatform FROM CatExternalPlatform WITH(NOLOCK) WHERE 	NameExternalPlatform = 'SMSZigiPaymentLink')

INSERT INTO ConfigExternalPlatform VALUES (@ExternalPlatformId,'SMSZigiPaymentLink','Hola <DESTINATARIO> En Forza Delivery hemos recibido una solicitud de pago vía Zigi del paquete <GUIA> por monto de <MONEDA><MONTO>. Paga en línea: <LINK>',NULL,1,'SYS-BPEDROZA',GETDATE(), NULL, NULL);