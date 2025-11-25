-- Insertar registros de información adicional para CodeOfReference @codeOfReferenceNew - Seller
-- SCRIPT PARA DESARROLLO
BEGIN TRY
    BEGIN TRANSACTION;
    
    USE DeliveryBackOffice;
    
    DECLARE @codeOfReferenceNew BIGINT =  1666234;  --Nuevo CodeOfReference para configurar

    INSERT INTO AddInfoByCodeOfReference (
        CodeOfReference,
        [Node],
        [Name],
        [Data],
        [Value],
        EntityTypeByBillingSVId,
        DateCreated,
        TokenCreated,
        RowStatus
    ) VALUES
    (@codeOfReferenceNew, 'Seller'                       , 'NRC'                      , NULL                , '3111898'            ,  1                   , GETDATE(), 'JRAMIREZ-SYS',1),
    (@codeOfReferenceNew, 'Seller'                       , 'CodigoActividad'          , NULL                , '52219'              , 1, GETDATE(), 'JRAMIREZ-SYS',1),
    (@codeOfReferenceNew, 'Seller'                       , 'DescActividad'            , NULL                , 'Servicios para el transporte por vía terrestre n.c.p.', 1, GETDATE(), 'JRAMIREZ-SYS',1),
    (@codeOfReferenceNew, 'Seller'                       , 'NombreComercial'          , NULL                , 'DELIVERY EXPRESS EL SALVADOR S.A. DE C.V.', 1, GETDATE(), 'JRAMIREZ-SYS',1),
    (@codeOfReferenceNew, 'Seller'                       , 'TipoEstablecimiento'      , NULL                , '01'                 , 1, GETDATE(), 'JRAMIREZ-SYS',1),
    (@codeOfReferenceNew, 'Seller'                       , 'CodEstablecimientoMH'     , NULL                , 'B001'               , 1, GETDATE(), 'JRAMIREZ-SYS',1),  --Establecimiento
    (@codeOfReferenceNew, 'Seller'                       , 'CodEstablecimiento'       , NULL                , 'B001'               , 1, GETDATE(), 'JRAMIREZ-SYS',1),  --Establecimiento
    (@codeOfReferenceNew, 'Seller'                       , 'CodPuntoVentaMH'          , NULL                , 'P001'               , 1, GETDATE(), 'JRAMIREZ-SYS',1),  --Punto de Venta Digifact
    (@codeOfReferenceNew, 'Seller'                       , 'CodPuntoVenta'            , NULL                , 'P001'               , 1, GETDATE(), 'JRAMIREZ-SYS',1),  --Punto de Venta Digifact
    (@codeOfReferenceNew, 'Seller'                       , 'District'                 , NULL                , '20'                 , 1, GETDATE(), 'JRAMIREZ-SYS',1), 
    (@codeOfReferenceNew, 'Seller'                       , 'State'                    , NULL                , '06'                 , 1, GETDATE(), 'JRAMIREZ-SYS',1), 
    (@codeOfReferenceNew, 'Items'                        , 'UnitOfMeasure'           , NULL                 , '99'                 , 1 , GETDATE(), 'JRAMIREZ-SYS',1),
    (@codeOfReferenceNew, 'Items'                        , 'AdditionalInfo'          , 'PrecioSugeridoVenta', NULL                 , 1 , GETDATE(), 'JRAMIREZ-SYS',1),
    (@codeOfReferenceNew, 'Header.AdditionalIssueDocInfo', 'CodEstPuntoV'            , NULL                 , 'B001P001'           , 1 , GETDATE(), 'JRAMIREZ-SYS',1), --Establecimeinto + Punto de Venta 
    (@codeOfReferenceNew, 'Header.AdditionalIssueDocInfo', 'TipoModelo'              , NULL                 , '1'                  , 1 , GETDATE(), 'JRAMIREZ-SYS',1),
    (@codeOfReferenceNew, 'Header.AdditionalIssueDocInfo', 'TipoOperacion'           , NULL                 , '1'                  , 1 , GETDATE(), 'JRAMIREZ-SYS',1),
    (@codeOfReferenceNew, 'CancelDTE'                    , 'nombreResponsable'       , NULL                 , 'DELIVERY EXPRESS SV', 1 , GETDATE(), 'SYS-BPEDROZA', 1),
    (@codeOfReferenceNew, 'CancelDTE'                    , 'tipoDocumentoResponsable', NULL                 , '36'                 , 1 , GETDATE(), 'SYS-BPEDROZA', 1),
    (@codeOfReferenceNew, 'CancelDTE'                    , 'numDocumentoResponsable' , NULL                 , '06141501221044'     , 1 , GETDATE(), 'SYS-BPEDROZA', 1),
    (@codeOfReferenceNew, 'CancelDTE'                    , 'nombreSolicitante'       , NULL                 , 'DELIVERY EXPRESS SV', 1 , GETDATE(), 'SYS-BPEDROZA', 1),
    (@codeOfReferenceNew, 'CancelDTE'                    , 'tipoDocumentoSolicitante', NULL                 , '36'                 , 1 , GETDATE(), 'SYS-BPEDROZA', 1),
    (@codeOfReferenceNew, 'CancelDTE'                    , 'numDocumentoSolitante'   , NULL                 , '06141501221044'     , 1 , GETDATE(), 'SYS-BPEDROZA', 1);
    
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
