-----SUSTITUIR CUALQUIER INSERT DE LA TABLA CatStatusProcess POR ESTE, ESTE TIENE LOS 5 ESTADOS SOLICITADOS 
INSERT INTO CatStatusProcess (NameStatusProcess, DescriptionStatusProcess, RowStatus, UserCreated, DateCreated,Icon)
VALUES 
('Creado', 'Estado que se usa cuando una guía se encuentra generada o solicitada.', 1, 'SYS-WOROZCO', GETDATE(),'bi bi-record-circle'),
('Recibido','Indica que la guÍa se recibio',1,'SYS-CSUAZO',GETDATE(),'bi bi-archive'),
('En instalaciones', 'Estado que indica que el proceso está en ejecuciÓn.', 1, 'SYS-WOROZCO', GETDATE(),'bi bi-house-door'),
('En Ruta', 'El proceso está en transporte hacia su destino.', 1, 'SYS-WOROZCO', GETDATE(),'bi bi-truck'),
('Entregado', 'El proceso ha llegado a su destino final.', 1, 'SYS-WOROZCO', GETDATE(),'bi bi-geo-alt');

