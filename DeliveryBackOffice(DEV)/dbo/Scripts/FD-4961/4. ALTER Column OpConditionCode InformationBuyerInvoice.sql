BEGIN TRY
    BEGIN TRAN;

    -- Agregar la columna
    ALTER TABLE dbo.InformationBuyerInvoice
    ADD OperationConditionCode INT NULL;

    -- Agregar descripción a la columna
    EXEC sys.sp_addextendedproperty 
        @name = N'MS_Description',
        @value = N'Código de condición de operación(1 contado, 2 crédito)',
        @level0type = N'SCHEMA',
        @level0name = 'dbo',
        @level1type = N'TABLE',
        @level1name = 'InformationBuyerInvoice',
        @level2type = N'COLUMN',
        @level2name = 'OperationConditionCode';

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    -- Retornar el error
    DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
    SELECT 
        @ErrMsg = ERROR_MESSAGE(),
        @ErrSeverity = ERROR_SEVERITY();

    RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
