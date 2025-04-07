--SELECT * FROM DeliveryBackOffice.dbo.ClosureAccount

BEGIN TRY
    BEGIN TRANSACTION;
    
    --DATA DE PRUEBA, VERIFICAR VALORES ANTES DE EJECUTAR
	INSERT INTO [dbo].[ClosureAccount]
           ([AccountNumber]
           ,[Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[IdCountry])
     VALUES
           ('763','Cuenta Express Center','Cuenta Express Center',1,'SYS-WOROZCO',GETDATE(),NULL,NULL,'SV'),
           ('249','Cuenta Área COD','Cuenta Área COD',1,'SYS-WOROZCO',GETDATE(),NULL,NULL,'SV');
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
