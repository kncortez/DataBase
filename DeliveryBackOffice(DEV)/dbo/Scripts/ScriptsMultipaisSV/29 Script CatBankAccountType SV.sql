--SELECT  * FROM dbo.CatBankAccountType
--Información de prueba para SV faltan posiblemente más tipos de cuenta

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[CatBankAccountType]
           ([BankAccountType]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[IdCountry])
	VALUES
           ('AHORRO'
           ,1
           ,'SYS-WOROZCO'
           ,GETDATE()
           ,NULL
           ,NULL
           ,'SV') 
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
