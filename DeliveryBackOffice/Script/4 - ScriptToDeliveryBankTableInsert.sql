USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LOS BANCOS FALTANTES
INSERT INTO [dbo].[DeliveryBank] 
			([Id_bank],[Name],[create_date],[Id_status],[Id_country],[ACHCode])
	VALUES	(94,'BANCO AMERICANO, S.A.',GETDATE(),1,'GT',39)

INSERT INTO [dbo].[DeliveryBank] 
			([Id_bank],[Name],[create_date],[Id_status],[Id_country],[ACHCode])
	VALUES	(95,'BANCO CITIBANK GUATEMALA',GETDATE(),1,'GT',43)

INSERT INTO [dbo].[DeliveryBank] 
			([Id_bank],[Name],[create_date],[Id_status],[Id_country],[ACHCode])
	VALUES	(96,'CITIBANK N.A. GUATEMALA',GETDATE(),1,'GT',30)

INSERT INTO [dbo].[DeliveryBank] 
			([Id_bank],[Name],[create_date],[Id_status],[Id_country],[ACHCode])
	VALUES	(97,'BANCO INMOBILIARIO, S.A.',GETDATE(),1,'GT',13)

INSERT INTO [dbo].[DeliveryBank] 
			([Id_bank],[Name],[create_date],[Id_status],[Id_country],[ACHCode])
	VALUES	(98,'BANCO REFORMADOR, S.A.',GETDATE(),1,'GT',42)

INSERT INTO [dbo].[DeliveryBank] 
			([Id_bank],[Name],[create_date],[Id_status],[Id_country],[ACHCode])
	VALUES	(99,'BANCO DE CREDITO, S.A.',GETDATE(),1,'GT',46)

INSERT INTO [dbo].[DeliveryBank] 
			([Id_bank],[Name],[create_date],[Id_status],[Id_country],[ACHCode])
	VALUES	(100,'CREDITO HIPOTECARIO NACIONAL',GETDATE(),1,'GT',04)

INSERT INTO [dbo].[DeliveryBank] 
			([Id_bank],[Name],[create_date],[Id_status],[Id_country],[ACHCode])
	VALUES	(101,'VIVIBANCO, S.A.',GETDATE(),1,'GT',36)

INSERT INTO [dbo].[DeliveryBank] 
			([Id_bank],[Name],[create_date],[Id_status],[Id_country],[ACHCode])
	VALUES	(102,'BANCO DE GUATEMALA',GETDATE(),1,'GT',01)

INSERT INTO [dbo].[DeliveryBank] 
			([Id_bank],[Name],[create_date],[Id_status],[Id_country],[ACHCode])
	VALUES	(103,'BANCO DE ANTIGUA, S.A.',GETDATE(),1,'GT',41)

INSERT INTO [dbo].[DeliveryBank] 
			([Id_bank],[Name],[create_date],[Id_status],[Id_country],[ACHCode])
	VALUES	(104,'BANCASOL, S.A.',GETDATE(),1,'GT',40)

INSERT INTO [dbo].[DeliveryBank] 
			([Id_bank],[Name],[create_date],[Id_status],[Id_country],[ACHCode])
	VALUES	(105,'FINANCIERA DE OCCIDENTE',GETDATE(),1,'GT',NULL)

--COMMIT

SELECT * 
FROM dbo.DeliveryBank
WHERE Id_status = 1
AND Id_country = 'GT'