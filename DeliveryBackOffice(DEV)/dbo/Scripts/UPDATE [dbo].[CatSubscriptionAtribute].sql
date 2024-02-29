
--- Modificar descripción, icono y orden paquete básico

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='50 guías a Q31 c/u.',
SubscriptionAttributePosition=1,
SubscriptionAttributeDescriptionLong='50 guías a Q31 c/u.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x'
WHERE 
SubscriptionAttributeDescription='50 envíos a'
AND RowStatus=1
AND CatSubscriptionId=9

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Costo único para todos tus clientes.',
SubscriptionAttributePosition=2,
SubscriptionAttributeDescriptionLong='Costo único para todos tus clientes.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x'
WHERE 
SubscriptionAttributeDescription='Q31 c/u.'
AND RowStatus=1
AND CatSubscriptionId=9

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Tarifa única en todo el país.',
SubscriptionAttributePosition=3,
SubscriptionAttributeDescriptionLong='Tarifa única en todo el país.',
CatSubscriptionAttributeIcon='fa fa-map fa-2x'
WHERE 
SubscriptionAttributeDescription='Tarifa única a todo el país.'
AND RowStatus=1
AND CatSubscriptionId=9

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Hasta 10 Libras.',
SubscriptionAttributePosition=4,
SubscriptionAttributeDescriptionLong='Hasta 10 Libras.',
CatSubscriptionAttributeIcon='fa fa-archive fa-2x'
WHERE 
SubscriptionAttributeDescription='No se permite servicio Collect.'
AND RowStatus=1
AND CatSubscriptionId=9

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='La tarifa más barata del mercado.',
SubscriptionAttributePosition=5,
SubscriptionAttributeDescriptionLong='La tarifa más barata del mercado.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x'
WHERE 
SubscriptionAttributeDescription='Hasta 10 Libras.'
AND RowStatus=1
AND CatSubscriptionId=9

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Vigencia de 6 meses.',
SubscriptionAttributePosition=6,
SubscriptionAttributeDescriptionLong='Vigencia de 6 meses.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x'
WHERE 
SubscriptionAttributeDescription='+3.5% C.O.D. con ''Acreditamiento Inmediato''.'
AND RowStatus=1
AND CatSubscriptionId=9


UPDATE [dbo].[CatSubscriptionAtribute]
SET 
RowStatus=0
WHERE 
SubscriptionAttributeDescription='+Q 1.00 libra extra.'
AND RowStatus=1
AND CatSubscriptionId=9

---####### Modificar descripción, icono y orden paquete Plus
--###############################################################
--################################################################

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='200 guías a Q27 c/u.',
SubscriptionAttributePosition=1,
SubscriptionAttributeDescriptionLong='200 guías a Q27 c/u.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x'
WHERE 
SubscriptionAttributeDescription='100 envíos a'
AND RowStatus=1
AND CatSubscriptionId=11

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Costo único para todos tus clientes.',
SubscriptionAttributePosition=2,
SubscriptionAttributeDescriptionLong='Costo único para todos tus clientes.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x'
WHERE 
SubscriptionAttributeDescription='Q29 c/u.'
AND RowStatus=1
AND CatSubscriptionId=10

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Tarifa única en todo el país.',
SubscriptionAttributePosition=3,
SubscriptionAttributeDescriptionLong='Tarifa única en todo el país.',
CatSubscriptionAttributeIcon='fa fa-map fa-2x'
WHERE 
SubscriptionAttributeDescription='Tarifa única a todo el país.'
AND RowStatus=1
AND  CatSubscriptionId=10

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='La tarifa más barata del mercado.',
SubscriptionAttributePosition=4,
SubscriptionAttributeDescriptionLong='La tarifa más barata del mercado.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x'
WHERE 
SubscriptionAttributeDescription='No se permite servicio Collect.'
AND RowStatus=1
AND CatSubscriptionId=10

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Hasta 10 Libras.',
SubscriptionAttributePosition=5,
SubscriptionAttributeDescriptionLong='Hasta 10 Libras.',
CatSubscriptionAttributeIcon='fa fa-archive fa-2x'
WHERE 
SubscriptionAttributeDescription='Hasta 10 Libras.'
AND RowStatus=1
AND  CatSubscriptionId=10

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Vigencia de 6 meses.',
SubscriptionAttributePosition=6,
SubscriptionAttributeDescriptionLong='Vigencia de 6 meses.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x'
WHERE 
SubscriptionAttributeDescription='+3.5% C.O.D. con ''Acreditamiento Inmediato''.'
AND RowStatus=1
AND CatSubscriptionId=10


UPDATE [dbo].[CatSubscriptionAtribute]
SET 
RowStatus=0
WHERE 
SubscriptionAttributeDescription='+Q 1.00 libra extra.'
AND RowStatus=1
AND CatSubscriptionId=10



---####### Modificar descripción, icono y orden paquete gold
--###############################################################
--################################################################

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='200 guías a Q27 c/u.',
SubscriptionAttributePosition=1,
SubscriptionAttributeDescriptionLong='100 guías a Q29 c/u.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x'
WHERE 
SubscriptionAttributeDescription='200 envíos a'
AND RowStatus=1
AND CatSubscriptionId=11

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Costo único para todos tus clientes.',
SubscriptionAttributePosition=2,
SubscriptionAttributeDescriptionLong='Costo único para todos tus clientes.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x'
WHERE 
SubscriptionAttributeDescription='Q27 c/u.'
AND RowStatus=1
AND CatSubscriptionId=11

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Tarifa única en todo el país.',
SubscriptionAttributePosition=3,
SubscriptionAttributeDescriptionLong='Tarifa única en todo el país.',
CatSubscriptionAttributeIcon='fa fa-map fa-2x'
WHERE 
SubscriptionAttributeDescription='Tarifa única a todo el país.'
AND RowStatus=1
AND CatSubscriptionId=11

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='La tarifa más barata del mercado.',
SubscriptionAttributePosition=4,
SubscriptionAttributeDescriptionLong='La tarifa más barata del mercado.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x'
WHERE 
SubscriptionAttributeDescription='No se permite servicio Collect.'
AND RowStatus=1
AND CatSubscriptionId=11

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Hasta 10 Libras.',
SubscriptionAttributePosition=5,
SubscriptionAttributeDescriptionLong='Hasta 10 Libras.',
CatSubscriptionAttributeIcon='fa fa-archive fa-2x'
WHERE 
SubscriptionAttributeDescription='Hasta 10 Libras.'
AND RowStatus=1
AND  CatSubscriptionId=11

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Vigencia de 6 meses.',
SubscriptionAttributePosition=6,
SubscriptionAttributeDescriptionLong='Vigencia de 6 meses.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x'
WHERE 
SubscriptionAttributeDescription='+3.5% C.O.D. con ''Acreditamiento Inmediato''.'
AND RowStatus=1
AND CatSubscriptionId=11


UPDATE [dbo].[CatSubscriptionAtribute]
SET 
RowStatus=0
WHERE 
SubscriptionAttributeDescription='+Q 1.00 libra extra.'
AND RowStatus=1
AND CatSubscriptionId=11

---####### Modificar descripción, icono y orden Plan Amigo
--###############################################################
--################################################################

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Descuento del 10% en envíos a nivel nacional sobre tarifa vigente.',
SubscriptionAttributePosition=1,
SubscriptionAttributeDescriptionLong='Descuento del 10% en envíos a nivel nacional sobre tarifa vigente.',
CatSubscriptionAttributeIcon='fa fa-percent fa-2x'
WHERE 
SubscriptionAttributeDescription='Descuento del 10% en envíos a nivel nacional sobre tarifa vigente.'
AND RowStatus=1
AND CatSubscriptionId=12

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Precio de acuerdo a tipo de servicio y destino.',
SubscriptionAttributePosition=2,
SubscriptionAttributeDescriptionLong='Precio de acuerdo a tipo de servicio y destino.',
CatSubscriptionAttributeIcon='bi bi-cash fa-3x'
WHERE 
SubscriptionAttributeDescription='Acumulación de puntos para envíos gratis.'
AND RowStatus=1
AND CatSubscriptionId=12

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Desde la primer guía, de acuerdo al consumo.',
SubscriptionAttributePosition=3,
SubscriptionAttributeDescriptionLong='Desde la primer guía, de acuerdo al consumo.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x'
WHERE 
SubscriptionAttributeDescription='Precio de acuerdo a tipo de servicio y destino.'
AND RowStatus=1
AND CatSubscriptionId=12

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Permite servicio Collect Q 4.00',
SubscriptionAttributePosition=4,
SubscriptionAttributeDescriptionLong='Permite servicio Collect Q 4.00',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x'
WHERE 
SubscriptionAttributeDescription='Desde la primer guía, de acuerdo al consumo.'
AND RowStatus=1
AND CatSubscriptionId=12

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Hasta 10 Libras.',
SubscriptionAttributePosition=5,
SubscriptionAttributeDescriptionLong='Hasta 10 Libras.',
CatSubscriptionAttributeIcon='fa fa-archive fa-2x'
WHERE 
SubscriptionAttributeDescription='Permite servicio Collect Q 3.00'
AND RowStatus=1
AND  CatSubscriptionId=12

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='+3.8% C.O.D. con "Acreditamiento Inmediato".',
SubscriptionAttributePosition=6,
SubscriptionAttributeDescriptionLong='+3.8% C.O.D. con "Acreditamiento Inmediato".',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x'
WHERE 
SubscriptionAttributeDescription='Hasta 10 libras.'
AND RowStatus=1
AND CatSubscriptionId=12



UPDATE [dbo].[CatSubscriptionAtribute]
SET 
RowStatus=0
WHERE 
SubscriptionAttributeDescription='+Q 1.00 libra extra.'
AND RowStatus=1
AND CatSubscriptionId=12

---####### Modificar descripción, icono y orden Paquete Petit
--###############################################################
--################################################################

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='25 guías a Q33 c/u.',
SubscriptionAttributePosition=1,
SubscriptionAttributeDescriptionLong='25 guías a Q33 c/u.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x'
WHERE 
SubscriptionAttributeDescription='25 envíos incluidos </br> Q.33 cada uno.'
AND RowStatus=1
AND CatSubscriptionId=14

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Costo único para todos tus clientes.',
SubscriptionAttributePosition=2,
SubscriptionAttributeDescriptionLong='Costo único para todos tus clientes.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x'
WHERE 
SubscriptionAttributeDescription='Tarifa única a todo el país.'
AND RowStatus=1
AND CatSubscriptionId=14

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Tarifa única en todo el país.',
SubscriptionAttributePosition=3,
SubscriptionAttributeDescriptionLong='Tarifa única en todo el país.',
CatSubscriptionAttributeIcon='fa fa-map fa-2x'
WHERE 
SubscriptionAttributeDescription='No se permite servicio Collect.'
AND RowStatus=1
AND CatSubscriptionId=14

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='La tarifa más barata del mercado.',
SubscriptionAttributePosition=4,
SubscriptionAttributeDescriptionLong='La tarifa más barata del mercado.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x'
WHERE 
SubscriptionAttributeDescription='Hasta 10 Libras.'
AND RowStatus=1
AND CatSubscriptionId=14

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Vigencia de 6 meses.',
SubscriptionAttributePosition=5,
SubscriptionAttributeDescriptionLong='Vigencia de 6 meses.',
CatSubscriptionAttributeIcon='fa fa-archive fa-2x'
WHERE 
SubscriptionAttributeDescription='+3.5% C.O.D. con ''Acreditamiento Inmediato''.'
AND RowStatus=1
AND  CatSubscriptionId=14

---####### Modificar descripción, icono y orden Paquete Platino
--###############################################################
--################################################################
UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='400 guías a Q25 c/u.',
SubscriptionAttributePosition=1,
SubscriptionAttributeDescriptionLong='400 guías a Q25 c/u.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x'
WHERE 
SubscriptionAttributeDescription='400 envíos incluidos </br> Q.25 cada uno.'
AND RowStatus=1
AND CatSubscriptionId=15

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Costo único para todos tus clientes.',
SubscriptionAttributePosition=2,
SubscriptionAttributeDescriptionLong='Costo único para todos tus clientes.',
CatSubscriptionAttributeIcon='bi bi-cash fa-2x'
WHERE 
SubscriptionAttributeDescription='Tarifa única a todo el país.'
AND RowStatus=1
AND CatSubscriptionId=15

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Tarifa única en todo el país.',
SubscriptionAttributePosition=3,
SubscriptionAttributeDescriptionLong='Tarifa única en todo el país.',
CatSubscriptionAttributeIcon='fa fa-map fa-2x'
WHERE 
SubscriptionAttributeDescription='No se permite servicio Collect.'
AND RowStatus=1
AND CatSubscriptionId=15

UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='La tarifa más barata del mercado.',
SubscriptionAttributePosition=4,
SubscriptionAttributeDescriptionLong='La tarifa más barata del mercado.',
CatSubscriptionAttributeIcon='fa fa-archive fa-2x'
WHERE 
SubscriptionAttributeDescription='Hasta 10 Libras.'
AND RowStatus=1
AND CatSubscriptionId=15


UPDATE [dbo].[CatSubscriptionAtribute]
SET 
SubscriptionAttributeDescription='Vigencia de 6 meses.',
SubscriptionAttributePosition=5,
SubscriptionAttributeDescriptionLong='Vigencia de 6 meses.',
CatSubscriptionAttributeIcon='fa fa-check-circle fa-2x'
WHERE 
SubscriptionAttributeDescription='+3.5% C.O.D. con ''Acreditamiento Inmediato''.'
AND RowStatus=1
AND CatSubscriptionId=15


UPDATE [dbo].[CatSubscriptionAtribute]
SET 
RowStatus=0
WHERE 
SubscriptionAttributeDescription='+Q 1.00 libra extra.'
AND RowStatus=1
AND CatSubscriptionId=15