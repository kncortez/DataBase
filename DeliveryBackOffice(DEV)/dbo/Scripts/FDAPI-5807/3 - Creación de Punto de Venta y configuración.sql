-- ===============================================================
-- [1/4] Insertar VisitPointClient
-- ===============================================================
PRINT '>>> [1/4] Iniciando INSERT en VisitPointClient...'

DECLARE @NewCodeOfReference INT;
DECLARE @IdCustomer         INT;

BEGIN TRANSACTION
BEGIN TRY

    -- Resolver variables
    SELECT @NewCodeOfReference = MAX(CodeOfReference) + 1 FROM dbo.VisitPointClient;
    SELECT @IdCustomer = IdCustomer FROM dbo.Customer WHERE Name = 'FD EXPRESS CENTER SV';

    -- Validar que se resolvieron correctamente
    IF @NewCodeOfReference IS NULL
        THROW 50100, 'No se pudo calcular el nuevo CodeOfReference. La tabla VisitPointClient podría estar vacía.', 1;
    IF @IdCustomer IS NULL
        THROW 50101, 'No se encontró el cliente "FD EXPRESS CENTER SV" en dbo.Customer.', 1;

    PRINT '    Nuevo CodeOfReference : ' + CAST(@NewCodeOfReference AS NVARCHAR(10));
    PRINT '    IdCustomer            : ' + CAST(@IdCustomer AS NVARCHAR(10));

    INSERT INTO dbo.VisitPointClient
    (
        CodeOfReference, DescriptionOfClient, StatusClient, CountryId, VisitPointId,
        TokenCreated, DateCreated, CustomerID, Address, Zone, Town, Department,
        Phone, ContactName, IdKindOfVPClient, Email, IdTownship, Latitude, Longitude,
        BranchCode, SaleChannelId, ExcludePriceShippingCOD, ExcludeCommissionCOD,
        IsOriginVisitPoint, LogLatitude, LogLongitude, DescriptionCC,
        CatBusinessSegmentId, AllowScheduledPickups, ParserGuideTypes
    )
    VALUES
    (
        @NewCodeOfReference, 'EXPRESS CENTER CLUBFORZA', 1, 'SV', NULL,
        'SYS-CAZURDIA', '2026-03-30 10:14:57', @IdCustomer, 'San Salvador', '0', 'San Salvador', 'San Salvador',
        '(1234568', 'FD EXC SV 1', 21, 'x_x_exc.sv1@forzadelivery.com', 664, '14.6386943', '-90.5229859',
        NULL, 2, 0, 0,
        1, '14.638701', '-90.5229899', 'Express Center SV 1',
        21, 1, 'Crédito'
    );

    COMMIT TRANSACTION
    PRINT '    [OK] VisitPointClient insertado correctamente. CodeOfReference: ' + CAST(@NewCodeOfReference AS NVARCHAR(10))

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló INSERT en VisitPointClient.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH

-- Verificación
SELECT * FROM dbo.VisitPointClient WHERE CodeOfReference = @NewCodeOfReference;
GO


-- ===============================================================
-- [2/4] INSERT en AddInfoByCodeOfReference
-- ===============================================================
PRINT '>>> [2/4] Iniciando INSERT en AddInfoByCodeOfReference...'

DECLARE @NewCodeOfReference INT;

BEGIN TRANSACTION
BEGIN TRY

    -- Recuperar el CodeOfReference recién insertado
    SELECT @NewCodeOfReference = MAX(CodeOfReference) FROM dbo.VisitPointClient
    WHERE DescriptionOfClient = 'EXPRESS CENTER CLUBFORZA'
      AND CountryId = 'SV';

    IF @NewCodeOfReference IS NULL
        THROW 50200, 'No se encontró el registro de VisitPointClient recién insertado. Verificar que el paso [1/2] fue exitoso.', 1;

    PRINT '    CodeOfReference recuperado: ' + CAST(@NewCodeOfReference AS NVARCHAR(10));

    INSERT INTO dbo.AddInfoByCodeOfReference
    (
        CodeOfReference, Node, Name, Data, Value,
        EntityTypeByBillingSVId, RowStatus, DateCreated, TokenCreated
    )
    VALUES
    -- Seller
    (@NewCodeOfReference, 'Seller', 'NRC',                  NULL, '3111898',                                                            1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    (@NewCodeOfReference, 'Seller', 'CodigoActividad',      NULL, '52219',                                                              1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    (@NewCodeOfReference, 'Seller', 'DescActividad',        NULL, 'Servicios para el transporte por vía terrestre n.c.p.',              1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    (@NewCodeOfReference, 'Seller', 'NombreComercial',      NULL, 'DELIVERY EXPRESS EL SALVADOR, SOCIEDAD ANONIMA DE CAPITAL VARIABLE', 1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    (@NewCodeOfReference, 'Seller', 'TipoEstablecimiento',  NULL, '01',                                                                 1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    (@NewCodeOfReference, 'Seller', 'CodEstablecimientoMH', NULL, 'M001',                                                               1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    (@NewCodeOfReference, 'Seller', 'CodEstablecimiento',   NULL, 'M001',                                                               1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    (@NewCodeOfReference, 'Seller', 'CodPuntoVentaMH',      NULL, 'P004',                                                               1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    (@NewCodeOfReference, 'Seller', 'CodPuntoVenta',        NULL, 'P004',                                                               1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    (@NewCodeOfReference, 'Seller', 'District',             NULL, '20',                                                                 1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    (@NewCodeOfReference, 'Seller', 'State',                NULL, '06',                                                                 1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    -- Items
    (@NewCodeOfReference, 'Items', 'UnitOfMeasure',         NULL,                   '99', 1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    (@NewCodeOfReference, 'Items', 'AdditionalInfo',        'PrecioSugeridoVenta',  NULL, 1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    -- Header
    (@NewCodeOfReference, 'Header.AdditionalIssueDocInfo', 'CodEstPuntoV',  NULL, 'M001P004', 1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    (@NewCodeOfReference, 'Header.AdditionalIssueDocInfo', 'TipoModelo',    NULL, '1',        1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    (@NewCodeOfReference, 'Header.AdditionalIssueDocInfo', 'TipoOperacion', NULL, '1',        1, 1, GETDATE(), 'JRAMIREZ-SYS'),
    -- CancelDTE
    (@NewCodeOfReference, 'CancelDTE', 'nombreResponsable',          NULL, 'DELIVERY EXPRESS SV',  1, 1, GETDATE(), 'SYS-BPEDROZA'),
    (@NewCodeOfReference, 'CancelDTE', 'tipoDocumentoResponsable',   NULL, '36',                   1, 1, GETDATE(), 'SYS-BPEDROZA'),
    (@NewCodeOfReference, 'CancelDTE', 'numDocumentoResponsable',    NULL, '06141501221044',        1, 1, GETDATE(), 'SYS-BPEDROZA'),
    (@NewCodeOfReference, 'CancelDTE', 'nombreSolicitante',          NULL, 'DELIVERY EXPRESS SV',  1, 1, GETDATE(), 'SYS-BPEDROZA'),
    (@NewCodeOfReference, 'CancelDTE', 'tipoDocumentoSolicitante',   NULL, '36',                   1, 1, GETDATE(), 'SYS-BPEDROZA'),
    (@NewCodeOfReference, 'CancelDTE', 'numDocumentoSolitante',      NULL, '06141501221044',        1, 1, GETDATE(), 'SYS-BPEDROZA');

    COMMIT TRANSACTION
    PRINT '    [OK] AddInfoByCodeOfReference insertado correctamente. Filas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló INSERT en AddInfoByCodeOfReference.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH

-- Verificación
SELECT * FROM dbo.AddInfoByCodeOfReference WHERE CodeOfReference = @NewCodeOfReference;
GO

-- ===============================================================
-- [3/4] INSERT en del_ParametrosFactura
-- ===============================================================
PRINT '>>> [3/4] Iniciando INSERT en del_ParametrosFactura ...'

DECLARE @NewCodeOfReference INT;

BEGIN TRANSACTION
BEGIN TRY

    -- Recuperar el CodeOfReference recién insertado
    SELECT @NewCodeOfReference = MAX(CodeOfReference) FROM dbo.VisitPointClient

    INSERT INTO dbo.del_ParametrosFactura 
    (dpf_VpCodeOfReference, dpf_FELRequestor, dpf_FELTransaction, dpf_FELCountry, dpf_FELEntity, dpf_FELUser, dpf_FELUserName, dpf_FELData1, dpf_FELData3, dpf_FELCorreo, dpf_FELAsuntoCorreoFactura, dpf_FELAsuntoCorreoNotaCredito, dpf_FELEstablecimiento, dpf_FELCorreoCCO, dpf_SAPServidorLicencias, dpf_SAPCompania, dpf_SAPUsuario, dpf_SAPContrasenia, dpf_SAPServidor, dpf_SAPUsuarioBD, dpf_SAPContraseniaBD, dpf_SAPserieFactura, dpf_SAPserieNC, dpf_SAPseriePago, dpf_SAPcardCode, dpf_SAParticulo, dpf_SAPvendor, dpf_SAPcreditCard, dpf_OcrCode, dpf_OcrCode2, dpf_StatusFACE, dpf_WarehouseCode, inv_cmp_name, inv_cmp_nameComercial, KioskCode)
    VALUES 
    (@NewCodeOfReference, 'Digifact23*', '', 'SV', '06141501221044', 'SV.06141501221044.TESTUSER', 'TEST', '', '', 'bidcar.herrera@forzalatam.com', 'Forza Delivery Factura', 'Forza Delivery', '', 'bidcar.herrera@forzalatam.com', 'WIN-QF1OUTS7TLC', 'DELIVERY_FORZA', 'manager', '12345', '192.168.130.107', 'evo', 'JSViESlacc+ErkN1QPBwUA==', '', '', '', '', '', '1', '97', NULL, NULL, 'A', NULL, 'Delivery Express El Salvador S.A. De C.V.', 'DELIVERY EXPRESS SV', NULL);

    COMMIT TRANSACTION
    PRINT '    [OK] del_ParametrosFactura  insertado correctamente. Filas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló INSERT en del_ParametrosFactura .'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH

-- Verificación
SELECT * FROM dbo.del_ParametrosFactura  WHERE dpf_vpCodeOfReference = @NewCodeOfReference;
GO

-- ===============================================================
-- [3/4] INSERT en del_ParametrosFactura
-- ===============================================================
PRINT '>>> [3/4] Iniciando INSERT en del_ParametrosFactura ...'

DECLARE @NewCodeOfReference INT;

BEGIN TRANSACTION
BEGIN TRY

    -- Recuperar el CodeOfReference recién insertado
    SELECT @NewCodeOfReference = MAX(CodeOfReference) FROM dbo.VisitPointClient

    INSERT INTO dbo.del_ParametrosFactura 
    (dpf_VpCodeOfReference, dpf_FELRequestor, dpf_FELTransaction, dpf_FELCountry, dpf_FELEntity, dpf_FELUser, dpf_FELUserName, dpf_FELData1, dpf_FELData3, dpf_FELCorreo, dpf_FELAsuntoCorreoFactura, dpf_FELAsuntoCorreoNotaCredito, dpf_FELEstablecimiento, dpf_FELCorreoCCO, dpf_SAPServidorLicencias, dpf_SAPCompania, dpf_SAPUsuario, dpf_SAPContrasenia, dpf_SAPServidor, dpf_SAPUsuarioBD, dpf_SAPContraseniaBD, dpf_SAPserieFactura, dpf_SAPserieNC, dpf_SAPseriePago, dpf_SAPcardCode, dpf_SAParticulo, dpf_SAPvendor, dpf_SAPcreditCard, dpf_OcrCode, dpf_OcrCode2, dpf_StatusFACE, dpf_WarehouseCode, inv_cmp_name, inv_cmp_nameComercial, KioskCode)
    VALUES 
    (@NewCodeOfReference, 'Digifact23*', '', 'SV', '06141501221044', 'SV.06141501221044.TESTUSER', 'TEST', '', '', 'bidcar.herrera@forzalatam.com', 'Forza Delivery Factura', 'Forza Delivery', '', 'bidcar.herrera@forzalatam.com', 'WIN-QF1OUTS7TLC', 'DELIVERY_FORZA', 'manager', '12345', '192.168.130.107', 'evo', 'JSViESlacc+ErkN1QPBwUA==', '', '', '', '', '', '1', '97', NULL, NULL, 'A', NULL, 'Delivery Express El Salvador S.A. De C.V.', 'DELIVERY EXPRESS SV', NULL);

    COMMIT TRANSACTION
    PRINT '    [OK] del_ParametrosFactura  insertado correctamente. Filas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló INSERT en del_ParametrosFactura .'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH

-- Verificación
SELECT * FROM dbo.del_ParametrosFactura  WHERE dpf_vpCodeOfReference = @NewCodeOfReference;
GO

-- ===============================================================
-- [4/4] INSERT en invoiceAuthorizationRelationships
-- ===============================================================
PRINT '>>> [4/4] Iniciando INSERT en invoiceAuthorizationRelationships ...'

DECLARE @NewCodeOfReference INT;
DECLARE @CURRENTAUTHORIZATION NVARCHAR(512);

BEGIN TRANSACTION
BEGIN TRY

    -- Recuperar el CodeOfReference recién insertado Y Autorización de Digifact
    SELECT @CURRENTAUTHORIZATION = [IdInvoiceAuthorizationHeader] FROM invoiceAuthorizationHeader WHERE RowStatus = 1
    SELECT @NewCodeOfReference = MAX(CodeOfReference) FROM dbo.VisitPointClient

    insert into invoiceAuthorizationRelationships (InvoiceAuthorizationHeaderId, CodeOfReference, RowStatus, DateCreated, TokenCreated) 
    values (@CURRENTAUTHORIZATION, @NewCodeOfReference, 1, GETDATE(), 'SYS-CAZURDIA')

    COMMIT TRANSACTION
    PRINT '    [OK] invoiceAuthorizationRelationships  insertado correctamente. Filas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló INSERT en invoiceAuthorizationRelationships.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH

-- Verificación
SELECT * FROM invoiceAuthorizationRelationships  WHERE RowStatus = 1;
GO