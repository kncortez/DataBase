BEGIN TRY
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.indexes 
        WHERE name = 'IX_invoiceHeader_IdCountry_inv_numberFEL' 
          AND object_id = OBJECT_ID('dbo.invoiceHeader')
    )
    BEGIN
        CREATE NONCLUSTERED INDEX IX_invoiceHeader_IdCountry_inv_numberFEL
        ON dbo.invoiceHeader (IdCountry, inv_numberFEL ASC);

        PRINT 'Índice creado exitosamente.';
    END
    ELSE
    BEGIN
        PRINT 'El índice ya existe.';
    END
END TRY
BEGIN CATCH
    PRINT 'Ocurrió un error al crear el índice:';
    PRINT ERROR_MESSAGE();
END CATCH;
