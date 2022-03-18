/****** Se agrega Columna IdHubDestination para poder tener el ID del HUB destino asociado al servicio ******/

  ALTER TABLE dbo.ServiceManagement
	ADD IdHubDestination INT NULL 
GO