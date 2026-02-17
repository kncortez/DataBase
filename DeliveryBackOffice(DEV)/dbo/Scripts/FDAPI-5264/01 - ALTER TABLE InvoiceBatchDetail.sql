BEGIN TRY
    BEGIN TRANSACTION;

	ALTER TABLE [dbo].[InvoiceBatchDetail]
	ADD [IsCompleted] TINYINT  NULL

    EXEC sp_addextendedproperty 
         @name=N'MS_Description'
        ,@value=N'Indica si el batch de facturación ya fue procesado'
        ,@level0type=N'SCHEMA'
        ,@level0name=N'dbo' 
        ,@level1type=N'TABLE'
        ,@level1name=N'InvoiceBatchDetail'
        ,@level2type=N'COLUMN'
        ,@level2name=N'IsCompleted';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;