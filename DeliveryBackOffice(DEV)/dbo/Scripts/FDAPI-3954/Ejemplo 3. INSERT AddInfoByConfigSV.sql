-- Insertar registros de información adicional para CodeOfReference 1162393 - Seller
BEGIN TRY
    BEGIN TRANSACTION;
    
    USE DeliveryBackOffice;

    INSERT INTO AddInfoByConfigSV ([Node], [Name], [Data], [Value], RowStatus, DateCreated, TokenCreated)
    VALUES 
    ('Items', 'UnitOfMeasure'                                    , NULL, '99', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Items', 'AdditionalInfo'                                   , 'PrecioSugeridoVenta', NULL, 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Header','AdditionalIssueType'                              , NULL, '00', 1, GETDATE(), 'JRAMIREZ-SYS'),--Ambiente prod/dev
    ('Totals', 'TotalTaxes.TotalTax'                             , '20','Impuesto al valor Agregado 13%', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Version', 'TaxCredit'                                      , NULL,'3', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Version', 'CreditNote'                                      , NULL,'3', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Version', 'ElectronicInvoice'                              , NULL,'1', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Header.AdditionalIssueDocInfo', 'Secuencial'               , NULL,'00090004000110', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Header.AdditionalIssueDocInfo', 'CodEstPuntoV'             , NULL,'M001P001', 1, GETDATE(), 'JRAMIREZ-SYS'), --Proporcionado por Digifact
    ('Header.AdditionalIssueDocInfo', 'TipoModelo'               , NULL,'1', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Header.AdditionalIssueDocInfo', 'TipoOperacion'            , NULL,'1', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Taxes.Tax', 'Code'                                         , NULL,'20', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('CreateDTE', 'USERNAME'                                     , NULL,'TESTFORZADELI', 1, GETDATE(), 'JRAMIREZ-SYS'),--Proporcionado por Digifact
    ('CreateDTE', 'FORMAT'                                       , NULL,'PDF|JSON', 1, GETDATE(), 'JRAMIREZ-SYS');

    -- Consulta para verificar los datos
    SELECT * FROM AddInfoByConfigSV;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
