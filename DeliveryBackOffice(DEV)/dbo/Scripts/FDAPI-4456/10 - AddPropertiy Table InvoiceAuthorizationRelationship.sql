BEGIN TRY
    BEGIN TRANSACTION;
    --1. Agregar descripciones de tabla y columnas faltantes
    -- IdInvoiceAuthorizationRelationships
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
              AND t.name = 'InvoiceAuthorizationRelationships'
              AND c.name = 'IdInvoiceAuthorizationRelationships'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Llave primaria de la tabla',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'InvoiceAuthorizationRelationships',
                                    @level2type = N'COLUMN',
                                    @level2name = N'IdInvoiceAuthorizationRelationships';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: IdInvoiceAuthorizationRelationships YA TIENE DESCRIPCION'
    END


    -- CodeOfReference
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
              AND t.name = 'InvoiceAuthorizationRelationships'
              AND c.name = 'CodeOfReference'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Código del punto de venta activo para generación de facturas',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'InvoiceAuthorizationRelationships',
                                    @level2type = N'COLUMN',
                                    @level2name = N'CodeOfReference';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: CodeOfReference YA TIENE DESCRIPCION'
    END


    -- InvoiceAuthorizationHeaderId
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
              AND t.name = 'InvoiceAuthorizationRelationships'
              AND c.name = 'InvoiceAuthorizationHeaderId'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Id de la autorización asignada al punto de venta',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'InvoiceAuthorizationRelationships',
                                    @level2type = N'COLUMN',
                                    @level2name = N'InvoiceAuthorizationHeaderId';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: InvoiceAuthorizationHeaderId YA TIENE DESCRIPCION'
    END


    -- RowStatus
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
              AND t.name = 'InvoiceAuthorizationRelationships'
              AND c.name = 'RowStatus'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Estado de la fila, TRUE o FALSE.',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'InvoiceAuthorizationRelationships',
                                    @level2type = N'COLUMN',
                                    @level2name = N'RowStatus';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: RowStatus YA TIENE DESCRIPCION'
    END


    -- TokenCreated
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
              AND t.name = 'InvoiceAuthorizationRelationships'
              AND c.name = 'TokenCreated'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Token que creó la fila.',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'InvoiceAuthorizationRelationships',
                                    @level2type = N'COLUMN',
                                    @level2name = N'TokenCreated';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: TokenCreated YA TIENE DESCRIPCION'
    END


    -- DateCreated
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
              AND t.name = 'InvoiceAuthorizationRelationships'
              AND c.name = 'DateCreated'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Fecha y hora en la que se creó la fila.',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'InvoiceAuthorizationRelationships',
                                    @level2type = N'COLUMN',
                                    @level2name = N'DateCreated';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: DateCreated YA TIENE DESCRIPCION'
    END


    -- TokenUpdated
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
              AND t.name = 'InvoiceAuthorizationRelationships'
              AND c.name = 'TokenUpdated'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Token que modificó la fila.',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'InvoiceAuthorizationRelationships',
                                    @level2type = N'COLUMN',
                                    @level2name = N'TokenUpdated';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: TokenUpdated YA TIENE DESCRIPCION'
    END


    -- DateUpdated
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
              AND t.name = 'InvoiceAuthorizationRelationships'
              AND c.name = 'DateUpdated'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Fecha y hora en la que se modificó la fila.',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'InvoiceAuthorizationRelationships',
                                    @level2type = N'COLUMN',
                                    @level2name = N'DateUpdated';
    END
    ELSE
    BEGIN
        PRINT 'COLUMNA: DateUpdated YA TIENE DESCRIPCION'
    END

    COMMIT TRANSACTION;
    PRINT 'Tabla InvoiceAuthorizationRelationships actualizada exitosamente.';

    --2. Mostrar descripcion de columnas
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
    WHERE t.name = 'InvoiceAuthorizationRelationships'
    ORDER BY c.column_id;


END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Se produjo un error en la ejecución.';
    PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH;