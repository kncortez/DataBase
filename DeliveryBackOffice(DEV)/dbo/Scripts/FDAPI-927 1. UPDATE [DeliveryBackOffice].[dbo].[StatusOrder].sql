DECLARE @UpdateStatusTrackingDescription AS TABLE(
	StatusId INT,
	StatusTrackingDescription NVARCHAR(200)
);

INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (1,'Guía lista para recolectar o llevar a Express Center')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (2,'Guía recolectada')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (3,'Guía lista para salir a ruta')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (4,'Guía en ruta para entrega')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (5,'Guía entregada')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (6,'Guía procesada para devolución al origen')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (7,'Guía anulada por origen')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (8,'Guía regresa a bodegas Forza')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (9,'Guía entregada con piezas incompletas')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (10,'Guía inventariada en bodega')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (11,'Guía ingreso a bodega')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (12,'Se intenta entrega de guía, se programara de nuevo para entrega')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (13,'Guía necesita ser evaluada')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (14,'Guía entregada a origen como devolución')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (15,'Guía se genero, revise metodo de pago')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (16,'Servicio de recolección asignado a ruta')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (17,'Guía lista para salir a ruta de devolución')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (18,'Guía en ruta para entrega de devolución a origen')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (19,'Guía en ruta de traslado a bodega departamental')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (20,'Guía se encuentra en Express Center')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (21,'Guía se recibio en Express Center')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (22,'Guía entregada a travez de Express Center')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (23,'Guía entregada por devolución a travez de Express Center')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (24,'Efectivo fue liquidado.')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (25,'Transferencia de pago por Cobro contra entrega realizado')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (26,'Guía en investigación')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (27,'Guía en investigación por perdida')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (28,'Guía pendiente de solución')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (29,'Guía en ruta de traslado a bodega departamental')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (30,'Mercaderia destruida')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (31,'Guía inventariada en bodega para devolución')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (32,'Guía sera preparada para devolución')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (33,'Guía con proceso administrativo finalizado')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (34,'Guía en proceso por posible riesgo')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (35,'Producto dañado en proceso operativo')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (36,'Producto evaluado sin incidencia')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (37,'Ingreso incompleto del producto')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (38,'Guía sera reprogramada para entrega')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (39,'Guía en gestión administrativa')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (40,'')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (41,'Producto sin reclamar por el cliente')
INSERT INTO @UpdateStatusTrackingDescription (StatusId, StatusTrackingDescription) VALUES (42,'')

UPDATE
	SO
SET
	SO.StatusOrderTrackingDescription = USTD.StatusTrackingDescription,
	SO.RowStatus = 1,
	SO.TokenUpdated = 'SYS-ARUIZ',
	SO.DateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
	INNER JOIN
		@UpdateStatusTrackingDescription USTD
		ON
			SO.StatusOrderId = USTD.StatusId
