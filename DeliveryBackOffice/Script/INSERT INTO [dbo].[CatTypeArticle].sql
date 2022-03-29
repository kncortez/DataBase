USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatTypeArticle] ([TarIdPackage]
, [TarName]
, [TarRowStatus]
, [TarTokenCreated]
, [TarDateCreated]
, [TarTokenUpdated]
, [TarDateUpdated])
	VALUES (3, 'Bicicleta', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
    (3, 'Deporte', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
	(3, 'Electrodomésticos', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
	(3, 'Fotocopiadora', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
	(3, 'Herramienta', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
	(3, 'Motocicleta', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
	(3, 'Mueble', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
	(3, 'Oficina', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
	(3, 'Recámara', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
	(3, 'Refrigeración', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
	(3, 'Repuestos Carro', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
	(3, 'Silla Ruedas', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL)