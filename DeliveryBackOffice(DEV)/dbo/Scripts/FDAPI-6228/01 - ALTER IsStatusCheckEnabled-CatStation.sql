BEGIN TRY
    IF COL_LENGTH('dbo.CatStation', 'IsStatusCheckEnabled') IS NULL
    BEGIN
        ALTER TABLE DeliveryBackOffice.dbo.CatStation
        ADD IsStatusCheckEnabled BIT NOT NULL
        CONSTRAINT DF_CatStation_IsStatusCheckEnabled DEFAULT 0;
    
        EXECUTE sp_addextendedproperty 
            @name = N'MS_Description',
            @value = N'Indica si la validación de estados predecesores está habilitada.',
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'TABLE',
            @level1name = N'CatStation',
            @level2type = N'COLUMN',
            @level2name = N'IsStatusCheckEnabled';
    END
    ELSE
    BEGIN
        PRINT 'Ya existe la columna IsStatusCheckEnabled.'
    END
END TRY
BEGIN CATCH
    PRINT 'Error: ' + ERROR_MESSAGE();
    THROW;
END CATCH;