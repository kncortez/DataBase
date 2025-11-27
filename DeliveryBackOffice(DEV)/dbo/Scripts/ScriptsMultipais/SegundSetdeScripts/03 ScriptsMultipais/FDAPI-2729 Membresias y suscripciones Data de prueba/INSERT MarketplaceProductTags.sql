--pendiente

INSERT INTO MarketplaceProductTags (MarketplaceProductTagsName, 
									MarketplaceProductTagsDescription, 
									MarketplaceProductTagsOrder, 
									RowStatus, 
									TokenCreated, 
									DateCreated, 
									IdCountry)
		VALUES('LO MÁS VENDIDO','En esta sección, encontrarás una selección de los productos más populares entre nuestros clientes',1,1,'SYS-BHERRERA',GETDATE(),'HN'),
			  ('NOVEDADES','En esta sección, encontrarás lo más reciente de nuestra tienda virtual',2,1,'SYS-BHERRERA',GETDATE(),'HN'),
			  ('TODOS LOS PRODUCTOS','Desde membresías, planes con descuento hasta guías prepago con tarifa única todo destino',3,1,'SYS-BHERRERA',GETDATE(),'HN')