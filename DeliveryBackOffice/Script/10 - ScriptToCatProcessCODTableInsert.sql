USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LOS PROCESOS A EJECUTAR
INSERT INTO [dbo].[CatProcessCOD] 
			([Name],[Description],[TokenCreated])
	VALUES	('GENERADOR DE ARCHIVOS COD',
			 'Se crean los archivos que se cargarán en las plataformas de los bancos para realizar la transferencia del COD al cliente.',
			 'AORTIZ')

--COMMIT


