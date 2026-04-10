use DeliveryBackOffice

BEGIN TRY

    IF NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.CatServiceStatus WITH (NOLOCK)
        WHERE [Name] = 'Incidencia Validada'
    )
    BEGIN
        INSERT INTO DeliveryBackOffice.dbo.CatServiceStatus
        ([Name], [Description], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated])
        VALUES('Incidencia Validada', NULL, 1, 'SYS-CAQUINO', GETDATE(), NULL, NULL);
    END
    ELSE
    BEGIN
         PRINT 'Estado Incidencia Validada ya existe'
    END

END TRY
BEGIN CATCH

    PRINT 'Error: ' + ERROR_MESSAGE();
    THROW;

END CATCH;