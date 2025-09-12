BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS(SELECT TOP 1 1 FROM Customer WITH(NOLOCK) WHERE CountryID IS NULL)
    BEGIN
        UPDATE Customer
        SET CountryID = 'GT',
            TokenUpdated = 'SYS-BPEDROZA',
            DateUpdated = GETDATE()
        WHERE CountryID IS NULL;
    END;

    IF EXISTS(SELECT TOP 1 1 FROM CatBusinessSegment WITH(NOLOCK) WHERE IdCountry IS NULL)
    BEGIN
        UPDATE CatBusinessSegment
        SET IdCountry = 'GT',
            TokenUpdated = 'SYS-BPEDROZA',
            DateUpdated = GETDATE()
        WHERE IdCountry IS NULL;
    END;

    IF EXISTS(SELECT TOP 1 1 FROM CatBankAccountType WITH(NOLOCK) WHERE IdCountry IS NULL)
    BEGIN
        UPDATE CatBankAccountType
        SET IdCountry = 'GT',
            TokenUpdated = 'SYS-BPEDROZA',
            DateUpdated = GETDATE()
        WHERE IdCountry IS NULL;
    END;

    IF EXISTS(SELECT TOP 1 1 FROM RateHeader WITH(NOLOCK) WHERE CountryId IS NULL)
    BEGIN
        UPDATE RateHeader
        SET CountryId = 'GT',
            RheTokenUpdated = 'SYS-BPEDROZA',
            RheCreateUpdated = GETDATE()
        WHERE CountryId IS NULL;
    END;

    IF EXISTS(SELECT TOP 1 1 FROM KindOfVPBusiness WITH(NOLOCK) WHERE IdCountry IS NULL)
    BEGIN
        UPDATE KindOfVPBusiness
        SET IdCountry = 'GT',
            TokenUpdate = 'SYS-BPEDROZA',
            DateUpdated = GETDATE()
        WHERE IdCountry IS NULL;
    END;

    IF EXISTS(SELECT TOP 1 1 FROM KindOfVPClient WITH(NOLOCK) WHERE IdCountry IS NULL)
    BEGIN
        UPDATE KindOfVPClient
        SET IdCountry = 'GT',
            TokenUpdate = 'SYS-BPEDROZA',
            DateUpdated = GETDATE()
        WHERE IdCountry IS NULL;
    END;

    IF EXISTS(SELECT TOP 1 1 FROM Province WITH(NOLOCK) WHERE IdCountry IS NULL)
    BEGIN
        UPDATE Province
        SET IdCountry = 'GT',
            TokenUpdated = 'SYS-BPEDROZA',
            DateUpdated = GETDATE()
        WHERE IdCountry IS NULL;
    END;

    IF EXISTS(SELECT TOP 1 1 FROM CatArticle WITH(NOLOCK) WHERE IdCountry IS NULL)
    BEGIN
        UPDATE CatArticle
        SET IdCountry = 'GT',
            ArtTokenUpdated = 'SYS-BPEDROZA',
            ArtDateUpdated = GETDATE()
        WHERE IdCountry IS NULL;
    END;

    IF EXISTS(SELECT TOP 1 1 FROM invoiceHeader WITH(NOLOCK) WHERE IdCountry IS NULL)
    BEGIN
        UPDATE invoiceHeader
        SET IdCountry = 'GT',
            inv_tokenUpdate = 'SYS-BPEDROZA',
            inv_dateUpdate = GETDATE()
        WHERE IdCountry IS NULL;
    END;

    COMMIT TRANSACTION;
    PRINT 'Actualización completada exitosamente.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Se produjo un error en la ejecución.';
    PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Severidad: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
    PRINT 'Estado: ' + CAST(ERROR_STATE() AS VARCHAR(10));
    PRINT 'Procedimiento: ' + ISNULL(ERROR_PROCEDURE(), '-');
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH;
