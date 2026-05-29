-- ===============================================================
-- UPDATE IdCountry en MarketplaceCart (registros sin país asignado)
-- ===============================================================
PRINT '>>> Iniciando UPDATE en MarketplaceCart...'

BEGIN TRANSACTION
BEGIN TRY

    UPDATE MarketplaceCart
    SET IdCountry = 'GT'
    WHERE IdCountry IS NULL;

    IF @@ROWCOUNT = 0
        THROW 50100, 'UPDATE no afectó ninguna fila. No existen registros con IdCountry IS NULL en MarketplaceCart.', 1;

    COMMIT TRANSACTION
    PRINT '    [OK] MarketplaceCart actualizado correctamente. Filas afectadas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló UPDATE en MarketplaceCart.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH

-- Verificación: no deben quedar registros con IdCountry NULL
SELECT COUNT(*) AS RegistrosNullPendientes
FROM MarketplaceCart
WHERE IdCountry IS NULL;
GO