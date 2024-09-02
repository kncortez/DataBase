--pendiente

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
		VALUES(3,1,1,'Acumulaci�n de puntos para env�os gratis',1,1,'SYS-ARUIZ',GETDATE(),'1 a�o de vigencia','fa fa-truck fa-2x'),
			  (3,1,1,'Promociones en comercios Afiliados',4,1,'SYS-ARUIZ',GETDATE(),'10% de descuento en las tarifas bases vigentes de acuerdo al tipo de destino para servicios Est�ndar o COD.','fa fa-shopping-cart fa-2x'),
			  (3,1,1,'Recolecciones SIN COSTO',5,1,'SYS-BHERRERA',GETDATE(),'Descuento desde la primer gu�a, sin tener que comprar saldo, ideal para clientes que env�an de 10 a 15 env�os mensuales.','fa fa-check-circle fa-2x'),
			  (3,1,1,'Env�o de devoluciones SIN COSTO',6,1,'SYS-BHERRERA',GETDATE(),'El env�o�lo puede pagar el remitente o puedes solicitar el�servicio cobrar al destinatario (collect + L 12.77).','fa fa-check-circle fa-2x'),
			  (3,1,1,'Pagos de reclamo en 24 horas',7,1,'SYS-BHERRERA',GETDATE(),'Generas tu gu�a desde el portal web y puedes llevar tu env�o a cualquiera de las Agencias Express Center o solicitar una recolecci�n.','fa fa-check-circle fa-2x')