BEGIN TRY

    IF COL_LENGTH('dbo.CatStation', 'RackPositionDefault') IS NULL
    BEGIN
        ALTER TABLE CatStation
        ADD RackPositionDefault NVARCHAR(60) NULL;

        EXEC sys.sp_addextendedproperty 
            @name = N'MS_Description',
            @value = N'Posición de rack por defecto de la estación',
            @level0type = N'SCHEMA', @level0name = 'dbo',
            @level1type = N'TABLE',  @level1name = 'CatStation',
            @level2type = N'COLUMN', @level2name = 'RackPositionDefault';
    END

END TRY
BEGIN CATCH

    PRINT 'Error: ' + ERROR_MESSAGE();

END CATCH;