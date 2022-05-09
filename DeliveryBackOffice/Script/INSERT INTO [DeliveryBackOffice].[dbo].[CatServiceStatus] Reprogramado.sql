USE [DeliveryBackOffice]
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WHERE CSS.[Name] = 'Reprogramado' COLLATE Latin1_General_CI_AI)
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[CatServiceStatus]
		(Name, Description, RowStatus, TokenCreated, DateCreated)
	VALUES
		('Reprogramado', NULL, 1, 'SYS-ARUIZ', GETDATE())
	PRINT 'YA INSERTE EL NUEVO ESTADO PARA SERVICIOS.'
END
ELSE
BEGIN
	PRINT 'YA EXISTE, NO INSERTE NADA.'
END