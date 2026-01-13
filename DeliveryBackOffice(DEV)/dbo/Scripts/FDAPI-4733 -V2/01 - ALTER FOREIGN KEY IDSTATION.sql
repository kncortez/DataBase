BEGIN TRY
BEGIN TRANSACTION

-- AGREGAR COLUMNA
	IF COL_LENGTH('DeliveryBackOffice.dbo.FinishPickUpHeader', 'StationId') IS NULL
    ALTER TABLE DeliveryBackOffice.dbo.FinishPickUpHeader
          ADD StationId INT NULL;
    ELSE
    BEGIN
        PRINT 'columna: StationId YA EXISTE'
    END


-- AGREGAR DESCRIPCION COLUMNA
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
              AND t.name = 'FinishPickUpHeader'
              AND c.name = 'StationId'
    )
    BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description',
                                    @value = N'Id de la estacion donde fue procesada el servicio de recoleccion',
                                    @level0type = N'SCHEMA',
                                    @level0name = N'dbo',
                                    @level1type = N'TABLE',
                                    @level1name = N'FinishPickUpHeader',
                                    @level2type = N'COLUMN',
                                    @level2name = N'StationId'
    END
    ELSE
    BEGIN
        PRINT 'columna StationId ya tiene descripcion'
    END

-- AGREGAR LLAVE FORANEA
    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_FinishPickUpHeader_CatStation'
    )
    BEGIN
        ALTER TABLE DeliveryBackOffice.dbo.FinishPickUpHeader
        ADD CONSTRAINT FK_FinishPickUpHeader_CatStation
            FOREIGN KEY (StationId)
            REFERENCES DeliveryBackOffice.dbo.CatStation (IdStation);
    
        PRINT 'Llave foránea creada: FK_FinishPickUpHeader_CatStation';
    END
    ELSE
    BEGIN
        PRINT 'La llave foránea ya existe: FK_FinishPickUpHeader_CatStation';
    END;

    COMMIT TRANSACTION
    PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    PRINT 'Ocurrió un error al ejecutar la actualización.'
    PRINT ERROR_MESSAGE()
END CATCH