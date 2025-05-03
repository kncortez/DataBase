--CLONAR AMBOS TARIFARIOS
--SELECT * FROM DeliveryBackOffice.dbo.RateHeader
--WHERE RheName = 'Tarifario de servicio estandar' OR RheName = 'Tarifario destinos express center'

DECLARE @IdCurrency INT;
DECLARE @IdTypeRate INT;
DECLARE @IdBusinessSegment INT;
DECLARE @IdCatCurrencyCOD INT;

BEGIN TRY
    BEGIN TRANSACTION;

	SELECT @IdCurrency = Currency_Id FROM  DeliveryBackOffice.dbo.DeliveryCurrency 
	WHERE Currency_Name = 'Dolar' AND Currency_IdCountry = 'SV' AND DefaultPerCountry = 1

	SELECT @IdTypeRate = IdTypeRate FROM DeliveryBackOffice.dbo.CatTypeRate 
	WHERE Name = 'Tipo de Artículo' AND RowStatus = 1

	SELECT @IdBusinessSegment = IdBusinessSegment FROM  DeliveryBackOffice.dbo.CatBusinessSegment
	WHERE BusinessSegmentName = 'C2C' and IdCountry ='SV' and RowStatus = 1

	SELECT @IdCatCurrencyCOD = IdCatCurrencyCOD FROM DeliveryBackOffice.dbo.CatCurrencyCOD 
	WHERE Name = 'DOLAR ESTADOUNIDENSE' AND RowStatus = 1 

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
			   ,[IdCurrency]
			   ,[GuideAmountCOD]
			   ,[ReturnPercent]
			   ,[IsOldest]
			   ,[MinGuidesPerMonth])
		 VALUES
			   ('Tarifario de servicio estandar'
			   ,''
			   ,'Nuevo esquema de tarifas generales.'
			   ,0
			   ,1
			   ,'SYS-WOROZCO'
			   ,GETDATE()
			   ,NULL
			   ,NULL
			   ,@IdTypeRate
			   ,0.00
			   ,1.50 --1.50 GT
			   ,100.00 --800.00 GT / 8 = $
			   ,0.15  --$
			   ,60.00
			   ,0.00
			   ,4.00
			   ,2
			   ,'SV'
			   ,@IdCurrency
			   ,1
			   ,0
			   ,0.00
			   ,1.00 --$
			   ,1.00
			   ,2
			   ,NULL
			   ,@IdBusinessSegment
			   ,NULL
			   ,@IdCatCurrencyCOD
			   ,NULL
			   ,NULL
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
			   ,[IdCurrency]
			   ,[GuideAmountCOD]
			   ,[ReturnPercent]
			   ,[IsOldest]
			   ,[MinGuidesPerMonth])
		 VALUES
			   ('Tarifario destinos express center'
			   ,''
			   ,'Nuevo esquema de tarifas generales con descuento a destino Express Center.'
			   ,0
			   ,1
			   ,'SYS-WOROZCO'
			   ,GETDATE()
			   ,NULL
			   ,NULL
			   ,@IdTypeRate
			   ,0.00
			   ,1.50
			   ,100.00
			   ,0.15
			   ,60.00
			   ,0.00
			   ,4.00
			   ,2
			   ,'SV'
			   ,@IdCurrency
			   ,1
			   ,0
			   ,0.00
			   ,1.00
			   ,1.00
			   ,2
			   ,NULL
			   ,NULL
			   ,NULL
			   ,@IdCatCurrencyCOD
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL)

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
