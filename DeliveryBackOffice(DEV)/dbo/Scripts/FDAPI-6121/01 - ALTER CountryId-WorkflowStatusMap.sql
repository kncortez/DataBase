BEGIN TRY

    IF COL_LENGTH('dbo.WorkflowStatusMap', 'CountryId') IS NULL
    BEGIN
        ALTER TABLE DeliveryBackOffice.dbo.WorkflowStatusMap
        ADD CountryId VARCHAR(2) NOT NULL
        CONSTRAINT DF_WorkflowStatusMap_CountryId DEFAULT 'GT'
        CONSTRAINT FK_WorkflowStatusMap_Country 
        FOREIGN KEY REFERENCES dbo.CatCountry(IdCountry);

        EXECUTE sp_addextendedproperty 
            @name = N'MS_Description',
            @value = N'ID de CatCountry (pais).',
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'TABLE',
            @level1name = N'WorkflowStatusMap',
            @level2type = N'COLUMN',
            @level2name = N'CountryId';
    END
    ELSE
    BEGIN
        PRINT 'Ya existe la columna CountryId.'
    END

END TRY
BEGIN CATCH
    PRINT 'Error: ' + ERROR_MESSAGE();
    THROW;
END CATCH;