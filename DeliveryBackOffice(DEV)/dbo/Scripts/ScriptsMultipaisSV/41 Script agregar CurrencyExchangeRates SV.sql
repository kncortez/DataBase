--SELECT * FROM CurrencyExchangeRates

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[CurrencyExchangeRates]
           ([ExchangeDate]
           ,[IdCountry]
           ,[SourceCurrency]
           ,[TargetCurrency]
           ,[ExchangeRate])
     VALUES
           (GETDATE()
           ,'SV'
           ,2
           ,2
           ,1)
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
