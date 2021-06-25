USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LOS TIPOS DE MONEDA
INSERT INTO [dbo].[CatCurrencyCOD] 
			([Name],[CodeISO],[NumISO],[TokenCreated])
	VALUES	('QUETZAL','GTQ',320,'AORTIZ')

INSERT INTO [dbo].[CatCurrencyCOD] 
			([Name],[CodeISO],[NumISO],[TokenCreated])
	VALUES	('DOLAR ESTADOUNIDENSE','USD',840,'AORTIZ')

INSERT INTO [dbo].[CatCurrencyCOD] 
			([Name],[CodeISO],[NumISO],[TokenCreated])
	VALUES	('EURO','EUR',978,'AORTIZ')

--COMMIT


