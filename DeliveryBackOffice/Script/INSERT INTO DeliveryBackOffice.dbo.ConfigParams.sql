
--*******************************  NOTA  ****************************************************
--En produccion y QA el encargado de cada ambiente tiene que configurar el correo a utilizar
--el correo que se deja en este script es solo de referencia, 
--este correo ejemplo se configuro para ambiente develop.

DECLARE @email NVARCHAR(100)= 'manifiestosrecolecciondevelop@gmail.com' 

INSERT INTO DeliveryBackOffice.dbo.ConfigParams
(
[Name],
[Description],
[Value],
[Status],
[CreateDate]
)
VALUES
(
'PickUpManifestEmailCAPP',
'Correo default para enviar manifiestos de recoleccion',
@email,
1,
GETDATE()
)

SELECT * FROM DeliveryBackOffice.dbo.ConfigParams ORDER BY ConfigParamsId DESC