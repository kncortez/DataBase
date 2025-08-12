BEGIN TRY
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.columns 
        WHERE name = 'RestrictionByArticle' 
          AND object_id = OBJECT_ID('dbo.Customer')
    )
    BEGIN
        ALTER TABLE Customer ADD RestrictionByArticle BIT NULL;
        EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                                       @value = N'Bandera que indica si se utilizará tarifario por artículo', 
                                       @level0type = N'SCHEMA', 
                                       @level0name = N'dbo', 
                                       @level1type = N'TABLE',
                                       @level1name = N'Customer', 
                                       @level2type = N'COLUMN',
                                       @level2name = N'RestrictionByArticle';
        PRINT 'columna creada exitosamente en la tabla Customer.';
    END
    ELSE
    BEGIN
        PRINT 'La columna ya existe en la tabla Customer.';
    END
    
    
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.columns 
        WHERE name = 'RestrictionByArticle' 
          AND object_id = OBJECT_ID('dbo.VisitPointClient')
    )
    BEGIN
         ALTER TABLE VisitPointClient ADD RestrictionByArticle BIT NULL;
         EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                                        @value = N'Bandera que indica si se utilizará tarifario por artículo', 
                                        @level0type = N'SCHEMA', 
                                        @level0name = N'dbo', 
                                        @level1type = N'TABLE',
                                        @level1name = N'VisitPointClient', 
                                        @level2type = N'COLUMN',
                                        @level2name = N'RestrictionByArticle';
         PRINT 'columna creada exitosamente en la tabla VisitPointClient.';
    END
    ELSE
    BEGIN
        PRINT 'La columna ya existe en la tabla VisitPointClient.';
    END
END TRY
BEGIN CATCH
    PRINT 'Ocurrió un error al crear el índice:';
    PRINT ERROR_MESSAGE();
    PRINT 'Número de error:';
    PRINT ERROR_NUMBER();
    PRINT 'Línea:';
    PRINT ERROR_LINE();
END CATCH;