--CLONAR AMBOS TARIFARIOS
--SELECT * FROM DeliveryBackOffice.dbo.RateHeader
--WHERE RheId = 2285 or  RheId = 2286 --EJEMPLO DE DEVELOP

--SELECT * FROM DeliveryBackOffice.dbo.RateHeader
--WHERE RheId = 3675 or  RheId = 3676 --EJEMPLO DE DEVELOP HN

DECLARE @IdCurrency INT;
DECLARE @IdTypeRate INT;
DECLARE @IdBusinessSegment INT;
DECLARE @IdCatCurrencyCOD INT;

BEGIN TRY
    BEGIN TRANSACTION;

	SELECT @IdCurrency = Currency_Id FROM  DeliveryBackOffice.dbo.DeliveryCurrency 
	WHERE Currency_Name = 'Lempira' AND Currency_IdCountry = 'HN' AND DefaultPerCountry = 1

	SELECT @IdTypeRate = IdTypeRate FROM DeliveryBackOffice.dbo.CatTypeRate 
	WHERE Name = 'Tipo de Artículo' AND RowStatus = 1

	SELECT @IdBusinessSegment = IdBusinessSegment FROM  DeliveryBackOffice.dbo.CatBusinessSegment
	WHERE BusinessSegmentName = 'C2C' and IdCountry ='HN' and RowStatus = 1

	SELECT @IdCatCurrencyCOD = IdCatCurrencyCOD FROM DeliveryBackOffice.dbo.CatCurrencyCOD 
	WHERE Name = 'LEMPIRA' AND RowStatus = 1 

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
			   ,'2024-08-13 09:55:00.000'
			   ,NULL
			   ,NULL
			   ,@IdTypeRate
			   ,0.00
			   ,1.00 --1.50 GT
			   ,1000.00 --800.00 GT
			   ,1.00
			   ,100.00 --60.00 GT
			   ,0.00
			   ,4.00
			   ,2
			   ,'HN'
			   ,@IdCurrency
			   ,1
			   ,0
			   ,100.00 --0.00 GT
			   ,10.00 --4.00 GT
			   ,2.00 --1.00 GT
			   ,2
			   ,NULL
			   ,@IdBusinessSegment
			   ,NULL
			   ,@IdCatCurrencyCOD)

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
			   ,'2024-08-13 09:55:00.000'
			   ,NULL
			   ,NULL
			   ,@IdTypeRate
			   ,0.00
			   ,1.00
			   ,1000.00
			   ,1.00
			   ,100.00
			   ,0.00
			   ,4.00
			   ,2
			   ,'HN'
			   ,@IdCurrency
			   ,1
			   ,0
			   ,100.00
			   ,10.00
			   ,2.00
			   ,2
			   ,NULL
			   ,NULL
			   ,NULL
			   ,@IdCatCurrencyCOD)

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
