BEGIN TRY
    BEGIN TRANSACTION;

    -- Agregar nuevo campo
    ALTER TABLE [dbo].[AccountingClosuresHeader]
    ADD 
        [ClosureDate] DATETIME NULL;

    -- Agregar comentario del campo
    EXEC sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Fecha lógica del cierre (día que se está cerrando)', 
        @level0type = N'SCHEMA',
        @level0name = N'dbo', 
        @level1type = N'TABLE',
        @level1name = N'AccountingClosuresHeader', 
        @level2type = N'COLUMN',
        @level2name = N'ClosureDate';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();

    PRINT 'Error: ' + @ErrorMessage;
END CATCH;