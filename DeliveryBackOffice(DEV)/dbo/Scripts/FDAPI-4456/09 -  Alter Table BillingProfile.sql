BEGIN TRY
    BEGIN TRANSACTION;
    --    1. Agregar columnas si no existen

    IF COL_LENGTH('DeliveryBackOffice.dbo.BillingProfile', 'NRC') IS NULL
        ALTER TABLE DeliveryBackOffice.dbo.BillingProfile
        ADD NRC NVARCHAR(200) NULL;
    ELSE
    BEGIN
        PRINT 'COLUMNA: NRC YA EXISTE'
    END

    IF COL_LENGTH('DeliveryBackOffice.dbo.BillingProfile', 'TypeIdentificationDocumentCode') IS NULL
        ALTER TABLE DeliveryBackOffice.dbo.BillingProfile
        ADD TypeIdentificationDocumentCode NVARCHAR(100) NULL;
    ELSE
    BEGIN
        PRINT 'COLUMNA: TypeIdentificationDocumentCode YA EXISTE'
    END

    IF COL_LENGTH('DeliveryBackOffice.dbo.BillingProfile', 'IdDocument') IS NULL
        ALTER TABLE DeliveryBackOffice.dbo.BillingProfile
        ADD IdDocument NVARCHAR(20) NULL;
    ELSE
    BEGIN
        PRINT 'COLUMNA: IdDocument YA EXISTE'
    END

    IF COL_LENGTH('DeliveryBackOffice.dbo.BillingProfile', 'DistrictId') IS NULL
        ALTER TABLE DeliveryBackOffice.dbo.BillingProfile ADD DistrictId INT NULL;
    ELSE
    BEGIN
        PRINT 'COLUMNA: DistrictId YA EXISTE'
    END


    IF COL_LENGTH('DeliveryBackOffice.dbo.BillingProfile', 'StateId') IS NULL
        ALTER TABLE DeliveryBackOffice.dbo.BillingProfile ADD StateId INT NULL;
    ELSE
    BEGIN
        PRINT 'COLUMNA: StateId YA EXISTE'
    END

    IF COL_LENGTH('DeliveryBackOffice.dbo.BillingProfile', 'ActivityCode') IS NULL
        ALTER TABLE DeliveryBackOffice.dbo.BillingProfile
        ADD ActivityCode NVARCHAR(100) NULL;
    ELSE
    BEGIN
        PRINT 'COLUMNA: ActivityCode YA EXISTE'
    END

    IF COL_LENGTH('DeliveryBackOffice.dbo.BillingProfile', 'Inv_type') IS NULL
        ALTER TABLE DeliveryBackOffice.dbo.BillingProfile ADD Inv_type INT NULL;
    ELSE
    BEGIN
        PRINT 'COLUMNA: Inv_type YA EXISTE'
    END


    --  2. Agregar descripciones de tabla y columnas faltantes
    -- Descripción de la tabla
    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.extended_properties ep
            INNER JOIN sys.tables t
                ON t.object_id = ep.major_id
        WHERE ep.name = 'MS_Description'
              AND t.name = 'BillingProfile'
              AND ep.minor_id = 0
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Tabla que almacena información de facturación favoritos, clientes individuales',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'BillingProfile';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: BillingProfile YA TIENE DESCRIPCION'
    END


    -- NRC
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
              AND t.name = 'BillingProfile'
              AND c.name = 'NRC'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Número de Registro del Contribuyente (NRC)',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'BillingProfile',
                                    @level2type = N'COLUMN',
                                    @level2name = N'NRC';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: NRC YA TIENE DESCRIPCION'
    END


    -- TypeIdentificationDocumentCode
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
              AND t.name = 'BillingProfile'
              AND c.name = 'TypeIdentificationDocumentCode'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Tipo de documento de identificación del comprador',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'BillingProfile',
                                    @level2type = N'COLUMN',
                                    @level2name = N'TypeIdentificationDocumentCode';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: TypeIdentificationDocumentCode YA TIENE DESCRIPCION'
    END


    -- IdDocument
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
              AND t.name = 'BillingProfile'
              AND c.name = 'IdDocument'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Número de identificación',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'BillingProfile',
                                    @level2type = N'COLUMN',
                                    @level2name = N'IdDocument';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: IdDocument YA TIENE DESCRIPCION'
    END


    -- DistrictId
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
              AND t.name = 'BillingProfile'
              AND c.name = 'DistrictId'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Identificador del distrito',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'BillingProfile',
                                    @level2type = N'COLUMN',
                                    @level2name = N'DistrictId';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: DistrictId YA TIENE DESCRIPCION'
    END


    -- StateId
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
              AND t.name = 'BillingProfile'
              AND c.name = 'StateId'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Identificador del estado',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'BillingProfile',
                                    @level2type = N'COLUMN',
                                    @level2name = N'StateId';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: StateId YA TIENE DESCRIPCION'
    END


    -- ActivityCode
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
              AND t.name = 'BillingProfile'
              AND c.name = 'ActivityCode'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Código de actividad económica del cliente',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'BillingProfile',
                                    @level2type = N'COLUMN',
                                    @level2name = N'ActivityCode';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: ActivityCode YA TIENE DESCRIPCION'
    END


    -- Inv_type
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
              AND t.name = 'BillingProfile'
              AND c.name = 'Inv_type'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Tipo de factura asociada al perfil',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'BillingProfile',
                                    @level2type = N'COLUMN',
                                    @level2name = N'Inv_type';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: Inv_type YA TIENE DESCRIPCION'
    END



    COMMIT TRANSACTION;
    PRINT 'Tabla BillingProfile actualizada exitosamente.';


    --3. Mostrar descripcion de columnas
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
    WHERE t.name = 'BillingProfile'
    ORDER BY c.column_id;


END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Se produjo un error en la ejecución.';
    PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH;