--pendiente
/****************PAQUETE BASICO********************/
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
	   VALUES(13,1,1,'50 gu�as a L99 c/u.',1,1,'SYS-BHERRERA',GETDATE(),'50 gu�as a L99 c/u.','fa fa-check-circle fa-2x'),
			  (13,1,1,'Costo �nico para todos tus clientes.',3,1,'SYS-BHERRERA',GETDATE(),'Costo �nico para todos tus clientes.','bi bi-cash fa-2x'),
			  (13,1,1,'Tarifa �nica en todo el pa�s.',2,1,'SYS-BHERRERA',GETDATE(),'Tarifa �nica en todo el pa�s.','fa fa-map fa-2x'),
			  (13,1,1,'Hasta 10 Libras.',4,1,'SYS-BHERRERA',GETDATE(),'La tarifa m�s barata del mercado.','fa fa-archive fa-2x'),
			  (13,1,1,'La tarifa m�s barata del mercado.',5,1,'SYS-BHERRERA',GETDATE(),'La tarifa m�s barata del mercado.','bi bi-cash fa-2x'),
			  (13,1,1,'Vigencia de 6 meses.',6,1,'SYS-BHERRERA',GETDATE(),'Vigencia de 6 meses.','fa fa-check-circle fa-2x')



/****************PAQUETE PLUS********************/
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
		VALUES(14,1,1,'100 gu�as a L92.62 c/u.',1,1,'SYS-BHERRERA',GETDATE(),'100 gu�as a L92.62 c/u.','fa fa-check-circle fa-2x'),
			  (14,1,1,'Costo �nico para todos tus clientes.',2,1,'SYS-BHERRERA',GETDATE(),'Costo �nico para todos tus clientes.','bi bi-cash fa-2x'),
			  (14,1,1,'Tarifa �nica en todo el pa�s.',3,1,'SYS-BHERRERA',GETDATE(),'Tarifa �nica en todo el pa�s.','fa fa-map fa-2x'),
			  (14,1,1,'La tarifa m�s barata del mercado.',5,1,'SYS-BHERRERA',GETDATE(),'La tarifa m�s barata del mercado.','bi bi-cash fa-2x'),
			  (14,1,1,'Hasta 10 Libras.',4,1,'SYS-BHERRERA',GETDATE(),'Hasta 10 Libras.','fa fa-archive fa-2x'),
			  (14,1,1,'Vigencia de 6 meses.',6,1,'SYS-BHERRERA',GETDATE(),'Vigencia de 6 meses.','fa fa-check-circle fa-2x')



/****************PAQUETE GOLD********************/
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
		VALUES(15,1,1,'200 gu�as a L86.23 c/u.',1,1,'SYS-BHERRERA',GETDATE(),'200 gu�as a L86.23 c/u.','fa fa-check-circle fa-2x'),
			   (15,1,1,'Costo �nico para todos tus clientes.',2,1,'SYS-BHERRERA',GETDATE(),'Costo �nico para todos tus clientes.','bi bi-cash fa-2x'),
			   (15,1,1,'Tarifa �nica en todo el pa�s.',3,1,'SYS-BHERRERA',GETDATE(),'Tarifa �nica en todo el pa�s.','fa fa-map fa-2x'),
			   (15,1,1,'La tarifa m�s barata del mercado.',5,1,'SYS-BHERRERA',GETDATE(),'La tarifa m�s barata del mercado.','bi bi-cash fa-2x'),
			   (15,1,1,'Hasta 10 Libras.',4,1,'SYS-BHERRERA',GETDATE(),'Hasta 10 Libras.','fa fa-archive fa-2x'),
			   (14,1,1,'Vigencia de 6 meses.',6,1,'SYS-BHERRERA',GETDATE(),'Vigencia de 6 meses.','fa fa-check-circle fa-2x')



/****************PLAN AMIGO********************/
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
		VALUES(16,1,1,'Descuento del 10% en env�os a nivel nacional sobre tarifa vigente.',1,1,'SYS-BHERRERA',GETDATE(),'Descuento del 10% en env�os a nivel nacional sobre tarifa vigente.','fa fa-check-circle fa-2x'),
			   (16,1,1,'Precio de acuerdo a tipo de servicio y destino.',2,1,'SYS-BHERRERA',GETDATE(),'Acumulaci�n de puntos para env�os gratis.','bi bi-cash fa-2x'),
			   (16,1,1,'+3.8% C.O.D. con Acreditamiento Inmediato.',6,1,'SYS-BHERRERA',GETDATE(),'+3.8% C.O.D. con Acreditamiento Inmediato.','fa fa-map fa-2x'),
			   (16,1,1,'Desde la primer gu�a, de acuerdo al consumo.',3,1,'SYS-BHERRERA',GETDATE(),'+L3.19.00 libra extra.','bi bi-cash fa-2x'),
			   (16,1,1,'Hasta 10 libras.',5,1,'SYS-BHERRERA',GETDATE(),'Vigencia: 6 meses','fa fa-archive fa-2x'),
			   (16,1,1,'Permite servicio Collect L12.78',4,1,'SYS-BHERRERA',GETDATE(),'25 env�os incluidos','fa fa-check-circle fa-2x')


/****************PAQUETE PETIT********************/
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
		VALUES(17,1,1,'25 gu�as a L105.39 c/u.',1,1,'SYS-BHERRERA',GETDATE(),'25 gu�as a L105.39 c/u.','fa fa-check-circle fa-2x'),
			   (17,1,1,'Tarifa �nica en todo el pa�s.',2,1,'SYS-BHERRERA',GETDATE(),'Tarifa �nica en todo el pa�s.','bi bi-cash fa-2x'),
			   (17,1,1,'Costo �nico para todos tus clientes..',3,1,'SYS-BHERRERA',GETDATE(),'Costo �nico para todos tus clientes.','fa fa-map fa-2x'),		   
			   (17,1,1,'Hasta 10 Libras.',4,1,'SYS-BHERRERA',GETDATE(),'Hasta 10 Libras.','fa fa-archive fa-2x'),
			   (17,1,1,'+L 3.19 libra extra.',7,1,'SYS-BHERRERA',GETDATE(),'+L 3.19 libra extra.','fa fa-check-circle fa-2x')



/****************PAQUETE PLATINO********************/
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
		VALUES(18,1,1,'400 gu�as a L79.84 c/u.',1,1,'SYS-BHERRERA',GETDATE(),'400 gu�as a L79.84 c/u.','fa fa-check-circle fa-2x'),
			   (18,1,1,'Tarifa �nica en todo el pa�s.',2,1,'SYS-BHERRERA',GETDATE(),'Tarifa �nica en todo el pa�s.','bi bi-cash fa-2x'),
			   (18,1,1,'Costo �nico para todos tus clientes..',3,1,'SYS-BHERRERA',GETDATE(),'Costo �nico para todos tus clientes.','fa fa-map fa-2x'),
			   (18,1,1,'La tarifa m�s barata del mercado.',5,1,'SYS-BHERRERA',GETDATE(),'La tarifa m�s barata del mercado.','bi bi-cash fa-2x'),
			   (18,1,1,'Hasta 10 Libras.',4,1,'SYS-BHERRERA',GETDATE(),'Hasta 10 Libras.','fa fa-archive fa-2x'),
			   (18,1,1,'Vigencia de 6 meses.',6,1,'SYS-BHERRERA',GETDATE(),'Vigencia de 6 meses.','fa fa-check-circle fa-2x')