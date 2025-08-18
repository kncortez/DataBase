--Currency SV

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[DeliveryCurrency]([Currency_Id],[Currency_Name],[Currency_Symbol],
	[Currency_Description],[Currency_Order],[Currency_IdCountry],[Currency_Status],[Currency_TokenCreated],
	[Currency_DateCreated],[Currency_TokenUpdate],[Currency_DateUpdate],[IdCurrencyCOD],[DefaultPerCountry])
	VALUES(14,'Dolar','($.)','Moneda SV Dolar',1,'SV',1,'SYS-WOROZCO',GETDATE(),NULL,NULL,2,1)

    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
