BEGIN TRY
    IF COL_LENGTH('dbo.RoutePreparation', 'IsAutoFinished') IS NULL
    BEGIN
        ALTER TABLE DeliveryBackOffice.dbo.RoutePreparation
        ADD IsAutoFinished BIT NOT NULL 
        CONSTRAINT DF_RoutePreparation_IsAutoFinished DEFAULT 1;

        EXECUTE sp_addextendedproperty 
            @name = N'MS_Description',
            @value = N'Indica si la recepción de la ruta de preparación automática ya fue finalizada.',
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'TABLE',
            @level1name = N'RoutePreparation',
            @level2type = N'COLUMN',
            @level2name = N'IsAutoFinished';
    END
    ELSE
    BEGIN
        PRINT 'Ya existe la columna IsAutoFinished.'
    END
END TRY
BEGIN CATCH
    PRINT 'Error: ' + ERROR_MESSAGE();
    THROW;
END CATCH;