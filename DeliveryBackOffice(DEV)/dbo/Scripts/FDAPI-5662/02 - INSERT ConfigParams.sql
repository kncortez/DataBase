use DeliveryBackOffice

BEGIN TRY

    IF NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.ConfigParams WITH (NOLOCK)
        WHERE [Name] = 'EmailByPickupGT'
    )
    BEGIN
        INSERT INTO DeliveryBackOffice.dbo.ConfigParams
        (
            [Name],
            [Description],
            [Value],
            [Status],
            CreateDate,
            IdCountry
        )
        VALUES
        ('EmailByPickupGT',
         'Correo Recoleccion Generico Guatemala',
         'recolecionesgt@forzadelivery.com',
         1  ,
         GETDATE(),
         'GT'
        )
    END
    ELSE
    BEGIN
         PRINT 'El correo para GT ya fue creado'
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.ConfigParams WITH (NOLOCK)
        WHERE [Name] = 'EmailByPickupHN'
    )
    BEGIN
        INSERT INTO DeliveryBackOffice.dbo.ConfigParams
        (
            [Name],
            [Description],
            [Value],
            [Status],
            CreateDate,
            IdCountry
        )
        VALUES
        ('EmailByPickupHN',
         'Correo Recoleccion Generico Honduras',
         'recoleccioneshn@forzadelivery.com',
         1  ,
         GETDATE(),
         'HN'
        )
    END
    ELSE
    BEGIN
         PRINT 'El correo para HN ya fue creado'
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.ConfigParams WITH (NOLOCK)
        WHERE [Name] = 'EmailByPickupSV'
    )
    BEGIN
        INSERT INTO DeliveryBackOffice.dbo.ConfigParams
        (
            [Name],
            [Description],
            [Value],
            [Status],
            CreateDate,
            IdCountry
        )
        VALUES
        ('EmailByPickupSV',
         'Correo Recoleccion Generico El Salvador',
         'recoleccionessv@forzadlievery.com',
         1  ,
         GETDATE(),
         'SV'
        )
    END
    ELSE
    BEGIN
         PRINT 'El correo para SV ya fue creado'
    END

END TRY
BEGIN CATCH

    PRINT 'Error: ' + ERROR_MESSAGE();
    THROW;

END CATCH;