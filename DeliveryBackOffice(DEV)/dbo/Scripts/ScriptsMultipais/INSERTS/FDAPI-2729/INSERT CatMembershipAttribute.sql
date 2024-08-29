

INSERT INTO CatMembershipAttribute (CatMembershipId,
								    CatAttributeId,
									MembershipAttributeValue,
									MembershipAttributeDescription,
									MembershipAttributePosition,
									RowStatus,
									TokenCreated,
									DateCreated,
									MembershipAttributeDescriptionLong,
									CatMembershipAttributeIcon)
		VALUES(3,1,1,'Acumulación de puntos para envíos gratis',1,1,'SYS-ARUIZ',GETDATE(),'1 año de vigencia','fa fa-truck fa-2x'),
			  (3,1,1,'Promociones en comercios Afiliados',4,1,'SYS-ARUIZ',GETDATE(),'10% de descuento en las tarifas bases vigentes de acuerdo al tipo de destino para servicios Estándar o COD.','fa fa-shopping-cart fa-2x'),
			  (3,1,1,'Recolecciones SIN COSTO',5,1,'SYS-BHERRERA',GETDATE(),'Descuento desde la primer guía, sin tener que comprar saldo, ideal para clientes que envían de 10 a 15 envíos mensuales.','fa fa-check-circle fa-2x'),
			  (3,1,1,'Envío de devoluciones SIN COSTO',6,1,'SYS-BHERRERA',GETDATE(),'El envío lo puede pagar el remitente o puedes solicitar el servicio cobrar al destinatario (collect + L 12.77).','fa fa-check-circle fa-2x'),
			  (3,1,1,'Pagos de reclamo en 24 horas',7,1,'SYS-BHERRERA',GETDATE(),'Generas tu guía desde el portal web y puedes llevar tu envío a cualquiera de las Agencias Express Center o solicitar una recolección.','fa fa-check-circle fa-2x')