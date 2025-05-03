-- Clonar todos los registros de HN a SV, generando nuevos IDs automáticamente si es identity
-- Registro valido pero NO proporcionado por producto.
BEGIN TRY
    BEGIN TRANSACTION;
    
INSERT INTO [CatTransportCompany] (
    TransportCompanyName,
    TransportCompanyDescription,
    TansportCompanyAbbreviation,
    CountryID,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DataUpdated
)
SELECT
    TransportCompanyName,
    TransportCompanyDescription,
    TansportCompanyAbbreviation,
    'SV', -- Cambiamos el país
    RowStatus,
    'SYS-JRAMIREZ',
    GETDATE(),
    NULL,
    NULL
FROM [CatTransportCompany]
WHERE CountryID = 'HN'
  AND NOT EXISTS (SELECT TransportCompanyName,
                         TransportCompanyDescription,
                         TansportCompanyAbbreviation,
                         'SV', -- Cambiamos el paises
                         RowStatus,
                         'SYS-JRAMIREZ',
                         GETDATE(),
                         NULL,
                         NULL
                    FROM [CatTransportCompany]
                   WHERE CountryID = 'SV');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
