-- Insertar registros de información adicional para CodeOfReference 1162393 - Seller
BEGIN TRY
    BEGIN TRANSACTION;
    
    USE DeliveryBackOffice;
    -- Insertar valores iniciales
    INSERT INTO AddInfoByCodeOfReference (
        CodeOfReference,
        [Node],
        [Name],
        [Value],
        EntityTypeByBillingSVId,
        DateCreated,
        TokenCreated,
        RowStatus
    ) VALUES
    (1378846, 'Seller','NRC', '3182701', 2, GETDATE(), 'JRAMIREZ-SYS',1),
    (1378846, 'Seller','CodigoActividad', '62090', 2, GETDATE(), 'JRAMIREZ-SYS',1),
    (1378846, 'Seller','DescActividad', 'Otras actividades de tecnología de información y servicios de computadora', 2, GETDATE(), 'JRAMIREZ-SYS',1),
    (1378846, 'Seller','NombreComercial', 'Digifact Servicios S.A', 2, GETDATE(), 'JRAMIREZ-SYS',1),
    (1378846, 'Seller','TipoEstablecimiento', '01', 2, GETDATE(), 'JRAMIREZ-SYS',1),
    (1378846, 'Seller','CodEstablecimientoMH', 'M001', 2, GETDATE(), 'JRAMIREZ-SYS',1),
    (1378846, 'Seller','CodEstablecimiento', 'M001', 2, GETDATE(), 'JRAMIREZ-SYS',1),
    (1378846, 'Seller','CodPuntoVentaMH', 'P001', 2, GETDATE(), 'JRAMIREZ-SYS',1),
    (1378846, 'Seller','CodPuntoVenta', 'P001', 2, GETDATE(), 'JRAMIREZ-SYS',1),
    (1378846, 'Seller','District', '20', 2, GETDATE(), 'JRAMIREZ-SYS',1),
    (1378846, 'Seller','State', '06', 2, GETDATE(), 'JRAMIREZ-SYS',1);

    -- Consulta para verificar los datos
    SELECT * FROM AddInfoByCodeOfReference;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
