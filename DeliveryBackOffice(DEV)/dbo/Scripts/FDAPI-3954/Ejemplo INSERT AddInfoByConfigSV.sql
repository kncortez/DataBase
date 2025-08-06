-- Insertar registros de información adicional para CodeOfReference 1162393 - Seller
BEGIN TRY
    BEGIN TRANSACTION;
    
    USE DeliveryBackOffice;

    INSERT INTO AddInfoByConfigSV ([Node], [Name], [Data], [Value], RowStatus, DateCreated, TokenCreated)
    VALUES 
    ('Items', 'UnitOfMeasure'                                    , NULL, '99', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Items', 'AdditionalInfo'                                   , 'PrecioSugeridoVenta', NULL, 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Header','AdditionalIssueType'                              , NULL, '00', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Totals', 'TotalTaxes.TotalTax'                             , '20','Impuesto al valor Agregado 13%', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Version', 'Version'                                        , NULL,'3', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Header.AdditionalIssueDocInfo', 'Secuencial'               , NULL,'000900030000045', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Header.AdditionalIssueDocInfo', 'CodEstPuntoV'             , NULL,'1234M010', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Header.AdditionalIssueDocInfo', 'TipoModelo'               , NULL,'1', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Header.AdditionalIssueDocInfo', 'TipoOperacion'            , NULL,'1', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('Taxes.Tax', 'Code'                                         , NULL,'20', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('CreateDTE', 'USERNAME'                                     , NULL,'TESTFORZADELI', 1, GETDATE(), 'JRAMIREZ-SYS'),
    ('CreateDTE', 'FORMAT'                                       , NULL,'PDF', 1, GETDATE(), 'JRAMIREZ-SYS');

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
