USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LOS BANCOS FALTANTES
INSERT INTO [dbo].[DeliveryBank] 
			([Id_bank],[Name],[create_date],[Id_status],[Id_country],[ACHCode])
	VALUES	(106,'BANCO INV',GETDATE(),1,'GT',NULL)

INSERT INTO [dbo].[DeliveryBank] 
			([Id_bank],[Name],[create_date],[Id_status],[Id_country],[ACHCode])
	VALUES	(107,'FINANCIERA SUMMA',GETDATE(),1,'GT',NULL)

--COMMIT

SELECT * 
FROM dbo.DeliveryBank
WHERE Id_status = 1
AND Id_country = 'GT'