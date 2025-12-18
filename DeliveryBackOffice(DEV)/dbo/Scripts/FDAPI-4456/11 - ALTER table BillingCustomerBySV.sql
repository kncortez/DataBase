BEGIN TRY
    BEGIN TRANSACTION;
    --1. Agregar columnas si no existen
    IF COL_LENGTH('dbo.BillingCustomerBySV', 'IdProvince') IS NULL
    BEGIN
        ALTER TABLE dbo.BillingCustomerBySV ADD IdProvince INT NULL;
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: IdProvince YA EXISTE'
    END


    IF COL_LENGTH('dbo.BillingCustomerBySV', 'IdTownship') IS NULL
    BEGIN
        ALTER TABLE dbo.BillingCustomerBySV ADD IdTownship INT NULL;
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: IdTownship YA EXISTE'
    END


    --2. Agregar llaves foráneas si no existen
    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_BillingCustomerBySV_Province'
              AND parent_object_id = OBJECT_ID('dbo.BillingCustomerBySV')
    )
    BEGIN
        ALTER TABLE dbo.BillingCustomerBySV
        ADD CONSTRAINT FK_BillingCustomerBySV_Province
            FOREIGN KEY (IdProvince)
            REFERENCES dbo.Province (IdProvince);
    END
    ELSE
    BEGIN
        PRINT 'LLAVE : FK_BillingCustomerBySV_Province YA EXISTE'
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_BillingCustomerBySV_Township'
              AND parent_object_id = OBJECT_ID('dbo.BillingCustomerBySV')
    )
    BEGIN
        ALTER TABLE dbo.BillingCustomerBySV
        ADD CONSTRAINT FK_BillingCustomerBySV_Township
            FOREIGN KEY (IdTownship)
            REFERENCES dbo.Township (IdTownship);
    END
    ELSE
    BEGIN
        PRINT 'LLAVE : FK_BillingCustomerBySV_Township YA EXISTE'
    END

    --3. Agregar descripciones a las columnas faltantes
    -- IdProvince
    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.extended_properties ep
            INNER JOIN sys.columns c
                ON ep.major_id = c.object_id
                   AND ep.minor_id = c.column_id
            INNER JOIN sys.tables t
                ON t.object_id = c.object_id
        WHERE ep.name = 'MS_Description'
              AND t.name = 'BillingCustomerBySV'
              AND c.name = 'IdProvince'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Id de departamento asociado al cliente',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'BillingCustomerBySV',
                                    @level2type = N'COLUMN',
                                    @level2name = N'IdProvince';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: IdProvince YA TIENE DESCRIPCION'
    END


    -- IdTownship
    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.extended_properties ep
            INNER JOIN sys.columns c
                ON ep.major_id = c.object_id
                   AND ep.minor_id = c.column_id
            INNER JOIN sys.tables t
                ON t.object_id = c.object_id
        WHERE ep.name = 'MS_Description'
              AND t.name = 'BillingCustomerBySV'
              AND c.name = 'IdTownship'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Id de municipio asociado al cliente',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'BillingCustomerBySV',
                                    @level2type = N'COLUMN',
                                    @level2name = N'IdTownship';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: IdTownship YA TIENE DESCRIPCION'
    END

    COMMIT TRANSACTION;
    PRINT 'Tabla BillingCustomerBySV actualizada exitosamente.';

    --4. Mostrar descripcion de columnas
    SELECT t.name AS TableName,
           c.name AS ColumnName,
           ep.value AS ColumnDescription
    FROM sys.tables t
        INNER JOIN sys.columns c
            ON c.object_id = t.object_id
        LEFT JOIN sys.extended_properties ep
            ON ep.major_id = c.object_id
               AND ep.minor_id = c.column_id
               AND ep.name = 'MS_Description'
    WHERE t.name = 'BillingCustomerBySV' -- 
    ORDER BY c.column_id;

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Se produjo un error en la ejecución.';
    PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH;