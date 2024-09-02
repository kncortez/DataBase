--CLONAR AMBOS TARIFARIOS
SELECT * FROM DeliveryBackOffice.dbo.RateHeader
WHERE RheId = 2285 or  RheId = 2286

SELECT TOP 20 * FROM DeliveryBackOffice.dbo.RateHeader
WHERE CountryId = 'HN' OR RheId = 2285 or  RheId = 2286

SELECT * FROM  DeliveryBackOffice.dbo.DeliveryCurrency 
WHERE Currency_Id IN (1,9)

SELECT * FROM DeliveryBackOffice.dbo.CatTypeRate 
WHERE IdTypeRate IN (3,8,9,10)

SELECT * FROM  DeliveryBackOffice.dbo.CatBusinessSegment
WHERE IdBusinessSegment = 21

SELECT * FROM DeliveryBackOffice.dbo.CatCurrencyCOD 

INSERT INTO [dbo].[RateHeader]
           ([RheName]
           ,[RheShortName]
           ,[RheDescription]
           ,[RheDefault]
           ,[RheRowStatus]
           ,[RheTokenCreated]
           ,[RheDateCreated]
           ,[RheTokenUpdated]
           ,[RheCreateUpdated]
           ,[RateTypeId]
           ,[FragilRate]
           ,[InsuranceRate]
           ,[InsuranceExempt]
           ,[AdditionalWeightRate]
           ,[WeightLimit]
           ,[CreditCardRate]
           ,[PickupRate]
           ,[Attempt]
           ,[CountryId]
           ,[CurrencyId]
           ,[IsTemplate]
           ,[RateByPiece]
           ,[ReturnRate]
           ,[CollectRate]
           ,[PiecesIncluded]
           ,[AttemptReturn]
           ,[CutOffDate]
           ,[CatBusinessSegmentId]
           ,[PackagesRangeId]
           ,[IdCurrency])
     VALUES
           ('Tarifario de servicio estandar'
           ,''
           ,'Nuevo esquema de tarifas generales.'
           ,0
           ,1
           ,'SYS-WOROZCO'
           ,'2024-06-13 09:55:00.000'
           ,NULL
           ,NULL
           ,10
           ,0.00
           ,1.00
           ,1000.00
           ,1.00
           ,100.00
           ,0.00
           ,4.00
           ,2
           ,'HN'
           ,9
           ,1
           ,0
           ,100.00
           ,10.00
           ,2.00
           ,2
           ,NULL
           ,21
           ,NULL
           ,NULL)

INSERT INTO [dbo].[RateHeader]
           ([RheName]
           ,[RheShortName]
           ,[RheDescription]
           ,[RheDefault]
           ,[RheRowStatus]
           ,[RheTokenCreated]
           ,[RheDateCreated]
           ,[RheTokenUpdated]
           ,[RheCreateUpdated]
           ,[RateTypeId]
           ,[FragilRate]
           ,[InsuranceRate]
           ,[InsuranceExempt]
           ,[AdditionalWeightRate]
           ,[WeightLimit]
           ,[CreditCardRate]
           ,[PickupRate]
           ,[Attempt]
           ,[CountryId]
           ,[CurrencyId]
           ,[IsTemplate]
           ,[RateByPiece]
           ,[ReturnRate]
           ,[CollectRate]
           ,[PiecesIncluded]
           ,[AttemptReturn]
           ,[CutOffDate]
           ,[CatBusinessSegmentId]
           ,[PackagesRangeId]
           ,[IdCurrency])
     VALUES
           ('Tarifario destinos express center'
           ,''
           ,'Nuevo esquema de tarifas generales con descuento a destino Express Center.'
           ,0
           ,1
           ,'SYS-WOROZCO'
           ,'2024-06-13 09:55:00.000'
           ,NULL
           ,NULL
           ,10
           ,0.00
           ,1.00
           ,1000.00
           ,1.00
           ,100.00
           ,0.00
           ,4.00
           ,2
           ,'HN'
           ,9
           ,1
           ,0
           ,100.00
           ,10.00
           ,2.00
           ,2
           ,NULL
           ,NULL
           ,NULL
           ,NULL)
