--pendiente

INSERT INTO MarketplaceProductTags (MarketplaceProductTagsName, 
									MarketplaceProductTagsDescription, 
									MarketplaceProductTagsOrder, 
									RowStatus, 
									TokenCreated, 
									DateCreated, 
									IdCountry)
		VALUES('LO M�S VENDIDO','En esta secci�n, encontrar�s una selecci�n de los productos m�s populares entre nuestros clientes',1,1,'SYS-BHERRERA',GETDATE(),'HN'),
			  ('NOVEDADES','En esta secci�n, encontrar�s lo m�s reciente de nuestra tienda virtual',2,1,'SYS-BHERRERA',GETDATE(),'HN'),
			  ('TODOS LOS PRODUCTOS','Desde membres�as, planes con descuento hasta gu�as prepago con tarifa �nica todo destino',3,1,'SYS-BHERRERA',GETDATE(),'HN')