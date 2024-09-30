--pendiente
/****************PAQUETE BASICO********************/
DECLARE @CatSubscription1 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Básico' AND IdCountry = 'HN')

INSERT INTO CatSubscriptionAtribute (CatSubscriptionId, 
									 CatAttributeId,
									 SubscriptionAttributeValue,
									 SubscriptionAttributeDescription, 
									 SubscriptionAttributePosition, 
									 RowStatus, 
									 TokenCreated, 
									 DateCreated,
									 SubscriptionAttributeDescriptionLong,
									 CatSubscriptionAttributeIcon)
	   VALUES(@CatSubscription1,1,1,'50 guías a L99 c/u.',1,1,'SYS-BHERRERA',GETDATE(),'50 guías a L99 c/u.','fa fa-check-circle fa-2x'),
			  (@CatSubscription1,1,1,'Costo único para todos tus clientes.',3,1,'SYS-BHERRERA',GETDATE(),'Costo único para todos tus clientes.','bi bi-cash fa-2x'),
			  (@CatSubscription1,1,1,'Tarifa ánica en todo el país.',2,1,'SYS-BHERRERA',GETDATE(),'Tarifa única en todo el país.','fa fa-map fa-2x'),
			  (@CatSubscription1,1,1,'Hasta 10 Libras.',4,1,'SYS-BHERRERA',GETDATE(),'La tarifa más barata del mercado.','fa fa-archive fa-2x'),
			  (@CatSubscription1,1,1,'La tarifa más barata del mercado.',5,1,'SYS-BHERRERA',GETDATE(),'La tarifa más barata del mercado.','bi bi-cash fa-2x'),
			  (@CatSubscription1,1,1,'Vigencia de 6 meses.',6,1,'SYS-BHERRERA',GETDATE(),'Vigencia de 6 meses.','fa fa-check-circle fa-2x')



/****************PAQUETE PLUS********************/
DECLARE @CatSubscription2 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Plus' AND IdCountry = 'HN')

INSERT INTO CatSubscriptionAtribute (CatSubscriptionId, 
									 CatAttributeId,
									 SubscriptionAttributeValue,
									 SubscriptionAttributeDescription, 
									 SubscriptionAttributePosition, 
									 RowStatus, 
									 TokenCreated, 
									 DateCreated,
									 SubscriptionAttributeDescriptionLong,
									 CatSubscriptionAttributeIcon)
		VALUES(@CatSubscription2,1,1,'100 guías a L92.62 c/u.',1,1,'SYS-BHERRERA',GETDATE(),'100 guías a L92.62 c/u.','fa fa-check-circle fa-2x'),
			  (@CatSubscription2,1,1,'Costo único para todos tus clientes.',2,1,'SYS-BHERRERA',GETDATE(),'Costo único para todos tus clientes.','bi bi-cash fa-2x'),
			  (@CatSubscription2,1,1,'Tarifa única en todo el país.',3,1,'SYS-BHERRERA',GETDATE(),'Tarifa única en todo el país.','fa fa-map fa-2x'),
			  (@CatSubscription2,1,1,'La tarifa más barata del mercado.',5,1,'SYS-BHERRERA',GETDATE(),'La tarifa más barata del mercado.','bi bi-cash fa-2x'),
			  (@CatSubscription2,1,1,'Hasta 10 Libras.',4,1,'SYS-BHERRERA',GETDATE(),'Hasta 10 Libras.','fa fa-archive fa-2x'),
			  (@CatSubscription2,1,1,'Vigencia de 6 meses.',6,1,'SYS-BHERRERA',GETDATE(),'Vigencia de 6 meses.','fa fa-check-circle fa-2x')



/****************PAQUETE GOLD********************/
DECLARE @CatSubscription3 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Gold' AND IdCountry = 'HN')

INSERT INTO CatSubscriptionAtribute (CatSubscriptionId, 
									 CatAttributeId,
									 SubscriptionAttributeValue,
									 SubscriptionAttributeDescription, 
									 SubscriptionAttributePosition, 
									 RowStatus, 
									 TokenCreated, 
									 DateCreated,
									 SubscriptionAttributeDescriptionLong,
									 CatSubscriptionAttributeIcon)
		VALUES(@CatSubscription3,1,1,'200 guías a L86.23 c/u.',1,1,'SYS-BHERRERA',GETDATE(),'200 guías a L86.23 c/u.','fa fa-check-circle fa-2x'),
			   (@CatSubscription3,1,1,'Costo único para todos tus clientes.',2,1,'SYS-BHERRERA',GETDATE(),'Costo único para todos tus clientes.','bi bi-cash fa-2x'),
			   (@CatSubscription3,1,1,'Tarifa única en todo el país.',3,1,'SYS-BHERRERA',GETDATE(),'Tarifa única en todo el país.','fa fa-map fa-2x'),
			   (@CatSubscription3,1,1,'La tarifa más barata del mercado.',5,1,'SYS-BHERRERA',GETDATE(),'La tarifa más barata del mercado.','bi bi-cash fa-2x'),
			   (@CatSubscription3,1,1,'Hasta 10 Libras.',4,1,'SYS-BHERRERA',GETDATE(),'Hasta 10 Libras.','fa fa-archive fa-2x'),
			   (@CatSubscription3,1,1,'Vigencia de 6 meses.',6,1,'SYS-BHERRERA',GETDATE(),'Vigencia de 6 meses.','fa fa-check-circle fa-2x')



/****************PLAN AMIGO********************/
DECLARE @CatSubscription4 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Plan Amigo' AND IdCountry = 'HN')

INSERT INTO CatSubscriptionAtribute (CatSubscriptionId, 
									 CatAttributeId,
									 SubscriptionAttributeValue,
									 SubscriptionAttributeDescription, 
									 SubscriptionAttributePosition, 
									 RowStatus, 
									 TokenCreated, 
									 DateCreated,
									 SubscriptionAttributeDescriptionLong,
									 CatSubscriptionAttributeIcon)
		VALUES(@CatSubscription4,1,1,'Descuento del 10% en envíos a nivel nacional sobre tarifa vigente.',1,1,'SYS-BHERRERA',GETDATE(),'Descuento del 10% en envíos a nivel nacional sobre tarifa vigente.','fa fa-check-circle fa-2x'),
			   (@CatSubscription4,1,1,'Precio de acuerdo a tipo de servicio y destino.',2,1,'SYS-BHERRERA',GETDATE(),'Acumulación de puntos para envíos gratis.','bi bi-cash fa-2x'),
			   (@CatSubscription4,1,1,'+3.8% C.O.D. con Acreditamiento Inmediato.',6,1,'SYS-BHERRERA',GETDATE(),'+3.8% C.O.D. con Acreditamiento Inmediato.','fa fa-map fa-2x'),
			   (@CatSubscription4,1,1,'Desde la primer guía, de acuerdo al consumo.',3,1,'SYS-BHERRERA',GETDATE(),'+L3.19.00 libra extra.','bi bi-cash fa-2x'),
			   (@CatSubscription4,1,1,'Hasta 10 libras.',5,1,'SYS-BHERRERA',GETDATE(),'Vigencia: 6 meses','fa fa-archive fa-2x'),
			   (@CatSubscription4,1,1,'Permite servicio Collect L12.78',4,1,'SYS-BHERRERA',GETDATE(),'25 envíos incluidos','fa fa-check-circle fa-2x')


/****************PAQUETE PETIT********************/
DECLARE @CatSubscription5 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Petit' AND IdCountry = 'HN')

INSERT INTO CatSubscriptionAtribute (CatSubscriptionId, 
									 CatAttributeId,
									 SubscriptionAttributeValue,
									 SubscriptionAttributeDescription, 
									 SubscriptionAttributePosition, 
									 RowStatus, 
									 TokenCreated, 
									 DateCreated,
									 SubscriptionAttributeDescriptionLong,
									 CatSubscriptionAttributeIcon)
		VALUES(@CatSubscription5,1,1,'25 guías a L105.39 c/u.',1,1,'SYS-BHERRERA',GETDATE(),'25 guías a L105.39 c/u.','fa fa-check-circle fa-2x'),
			   (@CatSubscription5,1,1,'Tarifa única en todo el país.',2,1,'SYS-BHERRERA',GETDATE(),'Tarifa única en todo el país.','bi bi-cash fa-2x'),
			   (@CatSubscription5,1,1,'Costo único para todos tus clientes..',3,1,'SYS-BHERRERA',GETDATE(),'Costo único para todos tus clientes.','fa fa-map fa-2x'),		   
			   (@CatSubscription5,1,1,'Hasta 10 Libras.',4,1,'SYS-BHERRERA',GETDATE(),'Hasta 10 Libras.','fa fa-archive fa-2x'),
			   (@CatSubscription5,1,1,'+L 3.19 libra extra.',7,1,'SYS-BHERRERA',GETDATE(),'+L 3.19 libra extra.','fa fa-check-circle fa-2x')



/****************PAQUETE PLATINO********************/
DECLARE @CatSubscription6 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Platino' AND IdCountry = 'HN')

INSERT INTO CatSubscriptionAtribute (CatSubscriptionId, 
									 CatAttributeId,
									 SubscriptionAttributeValue,
									 SubscriptionAttributeDescription, 
									 SubscriptionAttributePosition, 
									 RowStatus, 
									 TokenCreated, 
									 DateCreated,
									 SubscriptionAttributeDescriptionLong,
									 CatSubscriptionAttributeIcon)
		VALUES(@CatSubscription6,1,1,'400 guías a L79.84 c/u.',1,1,'SYS-BHERRERA',GETDATE(),'400 guías a L79.84 c/u.','fa fa-check-circle fa-2x'),
			   (@CatSubscription6,1,1,'Tarifa única en todo el país.',2,1,'SYS-BHERRERA',GETDATE(),'Tarifa única en todo el país.','bi bi-cash fa-2x'),
			   (@CatSubscription6,1,1,'Costo único para todos tus clientes..',3,1,'SYS-BHERRERA',GETDATE(),'Costo único para todos tus clientes.','fa fa-map fa-2x'),
			   (@CatSubscription6,1,1,'La tarifa más barata del mercado.',5,1,'SYS-BHERRERA',GETDATE(),'La tarifa más barata del mercado.','bi bi-cash fa-2x'),
			   (@CatSubscription6,1,1,'Hasta 10 Libras.',4,1,'SYS-BHERRERA',GETDATE(),'Hasta 10 Libras.','fa fa-archive fa-2x'),
			   (@CatSubscription6,1,1,'Vigencia de 6 meses.',6,1,'SYS-BHERRERA',GETDATE(),'Vigencia de 6 meses.','fa fa-check-circle fa-2x')