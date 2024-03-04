DECLARE @IdProduct INT = 0
SELECT @IdProduct = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription
WHERE SubscriptionName LIKE '%Plan Amigo%'
AND RowStatus = 1



UPDATE DeliveryBackOffice.dbo.CatSubscription
SET SubscriptionCost = 99 --antes 100
,TokenUpdated = 'SYS-BHERRERA'
,DateUpdated = GETDATE()
WHERE SubscriptionName LIKE '%Plan Amigo%'
AND RowStatus = 1

SELECT * FROM DeliveryBackOffice.dbo.CatSubscriptionAtribute
WHERE CatSubscriptionId = @IdProduct
AND RowStatus =1

--Inhabilitar Acumulaci�n de puntos
update DeliveryBackOffice.dbo.CatSubscriptionAtribute
SET RowStatus = 0
,TokenUpdated = 'SYS-BHERRERA'
,DateUpdated = GETDATE()
WHERE CatSubscriptionId = @IdProduct
AND SubscriptionAttributeDescription LIKE '%Acumulación de puntos para envíos gratis.%'
AND RowStatus =1


--Quitar de descripci�n acumulaci�n de puntos
--backup Descuento del 10% en env�os a nivel nacional sobre tarifa vigente.;  Acumulaci�n de puntos para env�os gratis.;  Precio de acuerdo a tipo de servicio y destino.;  Desde la primer gu�a, de acuerdo al consumo.;  Permite servicio Collect Q 4.00;  Hasta 10 libras.;  +3.8% C.O.D. con "Acreditamiento Inmediato".;  +Q 1.00 libra extra.
update dbo.CatSubscriptionDescription
SET Description = 'Descuento del 10% en envíos a nivel nacional sobre tarifa vigente.;Precio de acuerdo a tipo de servicio y destino.;  Desde la primer guía, de acuerdo al consumo.;  Permite servicio Collect Q 4.00;  Hasta 10 libras.;  +3.8% C.O.D. con "Acreditamiento Inmediato".;  +Q 1.00 libra extra.'
,TokenUpdated = 'SYS-BHERRERA'
,DateUpdated = GETDATE()
WHERE CatSubscriptionId = @IdProduct
AND Title = 'Beneficios'
AND RowStatus =1

/*****************************************************/
SELECT * FROM dbo.CatModule
WHERE ModName LIKE '%Venta de Pr%'

UPDATE DeliveryBackOffice.dbo.CatModule
SET ModName = 'Tienda Virtual'
WHERE ModName LIKE '%Venta de Productos%'
AND ModRowStatus = 1 

/*****************************************************/
SELECT * FROM DeliveryBackOffice.dbo.ContentDetail
WHERE ContentDetailDescription LIKE '%desde Q19%'

UPDATE DeliveryBackOffice.dbo.ContentDetail
--backup Servicio de agencia a agencia, con cobertura a nivel nacional desde Q19.
SET ContentDetailDescription = 'Servicio de agencia a agencia, con cobertura a nivel nacional.'
WHERE ContentDetailDescription LIKE '%desde Q19%'
AND ContentDetailTitle = 'Servicio Agencia - Agencia'



UPDATE DeliveryBackOffice.dbo.ContentDetail
--backup Soluci�n para que tus productos se�n correctamente protegidos para prevenir da�os y deterioros y los mantendr� intactos para la entrega a tus clientes.
SET ContentDetailDescription = 'Solución para que tus productos sean correctamente protegidos para prevenir daños y deterioros y los mantendrá intactos para la entrega a tus clientes.'
WHERE ContentDetailDescription LIKE '%sean%'
AND  ContentDetailTitle LIKE '%Material de Empaque%'

--- Modificar descripción, icono y orden paquete básico

UPDATE CSA
SET 
SubscriptionAttributeDescription='50 guías a Q31 c/u.',
SubscriptionAttributePosition=1,
SubscriptionAttributeDescriptionLong='50 guías a Q31 c/u.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x'
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='50 envíos a'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Básico'

UPDATE CSA
SET 
SubscriptionAttributeDescription='Costo único para todos tus clientes.',
SubscriptionAttributePosition=2,
SubscriptionAttributeDescriptionLong='Costo único para todos tus clientes.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x'
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Q31 c/u.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Básico'

UPDATE CSA
SET 
SubscriptionAttributeDescription='Tarifa única en todo el país.',
SubscriptionAttributePosition=3,
SubscriptionAttributeDescriptionLong='Tarifa única en todo el país.',
CatSubscriptionAttributeIcon='fa fa-map fa-2x'
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Tarifa única a todo el país.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Básico'



UPDATE CSA
SET 
SubscriptionAttributeDescription='Hasta 10 Libras.',
SubscriptionAttributePosition=4,
SubscriptionAttributeDescriptionLong='Hasta 10 Libras.',
CatSubscriptionAttributeIcon='fa fa-archive fa-2x'
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='No se permite servicio Collect.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Básico'

UPDATE CSA
SET 
SubscriptionAttributeDescription='La tarifa más barata del mercado.',
SubscriptionAttributePosition=5,
SubscriptionAttributeDescriptionLong='La tarifa más barata del mercado.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x'
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Hasta 10 Libras.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Básico'

UPDATE CSA
SET 
SubscriptionAttributeDescription='Vigencia de 6 meses.',
SubscriptionAttributePosition=6,
SubscriptionAttributeDescriptionLong='Vigencia de 6 meses.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x'
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='+3.5% C.O.D. con ''Acreditamiento Inmediato''.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Básico'


UPDATE [dbo].[CatSubscriptionAtribute]
SET 
RowStatus=0
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='+Q 1.00 libra extra.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Básico'


---####### Modificar descripción, icono y orden paquete Plus
--###############################################################
--################################################################

UPDATE  CSA
SET 
SubscriptionAttributeDescription='200 guías a Q27 c/u.',
SubscriptionAttributePosition=1,
SubscriptionAttributeDescriptionLong='200 guías a Q27 c/u.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='100 envíos a'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Plus'

UPDATE CSA
SET 
SubscriptionAttributeDescription='Costo único para todos tus clientes.',
SubscriptionAttributePosition=2,
SubscriptionAttributeDescriptionLong='Costo único para todos tus clientes.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Q29 c/u.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Plus'

UPDATE CSA
SET 
SubscriptionAttributeDescription='Tarifa única en todo el país.',
SubscriptionAttributePosition=3,
SubscriptionAttributeDescriptionLong='Tarifa única en todo el país.',
CatSubscriptionAttributeIcon='fa fa-map fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Tarifa única a todo el país.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Plus'

UPDATE CSA
SET 
SubscriptionAttributeDescription='La tarifa más barata del mercado.',
SubscriptionAttributePosition=4,
SubscriptionAttributeDescriptionLong='La tarifa más barata del mercado.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='No se permite servicio Collect.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Plus'

UPDATE CSA
SET 
SubscriptionAttributeDescription='Hasta 10 Libras.',
SubscriptionAttributePosition=5,
SubscriptionAttributeDescriptionLong='Hasta 10 Libras.',
CatSubscriptionAttributeIcon='fa fa-archive fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Hasta 10 Libras.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Plus'

UPDATE CSA
SET 
SubscriptionAttributeDescription='Vigencia de 6 meses.',
SubscriptionAttributePosition=6,
SubscriptionAttributeDescriptionLong='Vigencia de 6 meses.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='+3.5% C.O.D. con ''Acreditamiento Inmediato''.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Plus'


UPDATE CSA
SET 
RowStatus=0,
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='+Q 1.00 libra extra.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Plus'



---####### Modificar descripción, icono y orden paquete gold
--###############################################################
--################################################################

UPDATE CSA
SET 
SubscriptionAttributeDescription='200 guías a Q27 c/u.',
SubscriptionAttributePosition=1,
SubscriptionAttributeDescriptionLong='100 guías a Q29 c/u.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='200 envíos a'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Gold'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Costo único para todos tus clientes.',
SubscriptionAttributePosition=2,
SubscriptionAttributeDescriptionLong='Costo único para todos tus clientes.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Q27 c/u.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Gold'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Tarifa única en todo el país.',
SubscriptionAttributePosition=3,
SubscriptionAttributeDescriptionLong='Tarifa única en todo el país.',
CatSubscriptionAttributeIcon='fa fa-map fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Tarifa única a todo el país.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Gold'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='La tarifa más barata del mercado.',
SubscriptionAttributePosition=4,
SubscriptionAttributeDescriptionLong='La tarifa más barata del mercado.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='No se permite servicio Collect.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Gold'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Hasta 10 Libras.',
SubscriptionAttributePosition=5,
SubscriptionAttributeDescriptionLong='Hasta 10 Libras.',
CatSubscriptionAttributeIcon='fa fa-archive fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Hasta 10 Libras.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Gold'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Vigencia de 6 meses.',
SubscriptionAttributePosition=6,
SubscriptionAttributeDescriptionLong='Vigencia de 6 meses.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='+3.5% C.O.D. con ''Acreditamiento Inmediato''.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Gold'


UPDATE [dbo].[CatSubscriptionAtribute]
SET 
RowStatus=0,
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='+Q 1.00 libra extra.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Gold'

---####### Modificar descripción, icono y orden Plan Amigo
--###############################################################
--################################################################

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Descuento del 10% en envíos a nivel nacional sobre tarifa vigente.',
SubscriptionAttributePosition=1,
SubscriptionAttributeDescriptionLong='Descuento del 10% en envíos a nivel nacional sobre tarifa vigente.',
CatSubscriptionAttributeIcon='fa fa-percent fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Descuento del 10% en envíos a nivel nacional sobre tarifa vigente.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Plan Amigo'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Precio de acuerdo a tipo de servicio y destino.',
SubscriptionAttributePosition=2,
SubscriptionAttributeDescriptionLong='Precio de acuerdo a tipo de servicio y destino.',
CatSubscriptionAttributeIcon='bi bi-cash fa-3x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Acumulación de puntos para envíos gratis.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Plan Amigo'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Desde la primer guía, de acuerdo al consumo.',
SubscriptionAttributePosition=3,
SubscriptionAttributeDescriptionLong='Desde la primer guía, de acuerdo al consumo.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Precio de acuerdo a tipo de servicio y destino.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Plan Amigo'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Permite servicio Collect Q 4.00',
SubscriptionAttributePosition=4,
SubscriptionAttributeDescriptionLong='Permite servicio Collect Q 4.00',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Desde la primer guía, de acuerdo al consumo.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Plan Amigo'


UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Hasta 10 Libras.',
SubscriptionAttributePosition=5,
SubscriptionAttributeDescriptionLong='Hasta 10 Libras.',
CatSubscriptionAttributeIcon='fa fa-archive fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Permite servicio Collect Q 3.00'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Plan Amigo'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='+3.8% C.O.D. con "Acreditamiento Inmediato".',
SubscriptionAttributePosition=6,
SubscriptionAttributeDescriptionLong='+3.8% C.O.D. con "Acreditamiento Inmediato".',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Hasta 10 libras.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Plan Amigo'



UPDATE [dbo].[CatSubscriptionAtribute]
SET 
RowStatus=0,
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='+Q 1.00 libra extra.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Plan Amigo'

---####### Modificar descripción, icono y orden Paquete Petit
--###############################################################
--################################################################

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='25 guías a Q33 c/u.',
SubscriptionAttributePosition=1,
SubscriptionAttributeDescriptionLong='25 guías a Q33 c/u.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='25 envíos incluidos </br> Q.33 cada uno.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Petit'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Costo único para todos tus clientes.',
SubscriptionAttributePosition=2,
SubscriptionAttributeDescriptionLong='Costo único para todos tus clientes.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Tarifa única a todo el país.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Petit'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Tarifa única en todo el país.',
SubscriptionAttributePosition=3,
SubscriptionAttributeDescriptionLong='Tarifa única en todo el país.',
CatSubscriptionAttributeIcon='fa fa-map fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='No se permite servicio Collect.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Petit'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='La tarifa más barata del mercado.',
SubscriptionAttributePosition=4,
SubscriptionAttributeDescriptionLong='La tarifa más barata del mercado.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Hasta 10 Libras.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Petit'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Vigencia de 6 meses.',
SubscriptionAttributePosition=5,
SubscriptionAttributeDescriptionLong='Vigencia de 6 meses.',
CatSubscriptionAttributeIcon='fa fa-archive fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='+3.5% C.O.D. con ''Acreditamiento Inmediato''.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Petit'

---####### Modificar descripción, icono y orden Paquete Platino
--###############################################################
--################################################################
UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='400 guías a Q25 c/u.',
SubscriptionAttributePosition=1,
SubscriptionAttributeDescriptionLong='400 guías a Q25 c/u.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='400 envíos incluidos </br> Q.25 cada uno.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Platino'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Costo único para todos tus clientes.',
SubscriptionAttributePosition=2,
SubscriptionAttributeDescriptionLong='Costo único para todos tus clientes.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Tarifa única a todo el país.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Platino'

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Tarifa única en todo el país.',
SubscriptionAttributePosition=3,
SubscriptionAttributeDescriptionLong='Tarifa única en todo el país.',
CatSubscriptionAttributeIcon='fa fa-map fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='No se permite servicio Collect.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Platino'


UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='La tarifa más barata del mercado.',
SubscriptionAttributePosition=4,
SubscriptionAttributeDescriptionLong='La tarifa más barata del mercado.',
CatSubscriptionAttributeIcon='fa fa-archive fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='Hasta 10 Libras.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Platino'


UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Vigencia de 6 meses.',
SubscriptionAttributePosition=5,
SubscriptionAttributeDescriptionLong='Vigencia de 6 meses.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='+3.5% C.O.D. con ''Acreditamiento Inmediato''.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Platino'


UPDATE [dbo].[CatSubscriptionAtribute]
SET 
RowStatus=0,
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatSubscriptionAtribute] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE 
CSA.SubscriptionAttributeDescription='+Q 1.00 libra extra.'
AND CSA.RowStatus=1
AND CS.SubscriptionName='Paquete Platino'




