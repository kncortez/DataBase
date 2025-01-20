BEGIN TRY
    BEGIN TRANSACTION
    DECLARE @ID INT,
            @Description1 NVARCHAR(50),
            @Inventary NVARCHAR(50),
            @NewLink NVARCHAR(50)

    SET @Description1 =
    (
        SELECT ModIdModule FROM CatModule WHERE ModName = 'Mis links'
    )

    SET @Inventary =
    (
        SELECT ModIdModule FROM CatModule WHERE ModName = 'Inventario'
    )

    SET @NewLink =
    (
        SELECT ModIdModule FROM CatModule WHERE ModName = 'Nuevo link'
    )

    INSERT INTO CatModule
    (
        ModName,
        ModPath,
        ModDescription,
        ModOrder,
        ModMetadata,
        ModVisible,
        ModRowStatus,
        ModTokenCreated,
        ModDateCreated
    )
    VALUES
    ('Link de entrega',
     '/individual/mis-links',
     'Agrupacion de opciones',
     35 ,
     'fa fa-link',
     1  ,
     1  ,
     'SYS-CSUAZO',
     GETDATE()
    )

    SET @ID = SCOPE_IDENTITY()

    UPDATE CatModule
    SET ModIdModuleParent = @ID
    WHERE ModIdModule IN ( @Description1, @Inventary, @NewLink )

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    SELECT ERROR_MESSAGE(),
           ERROR_LINE(),
           ERROR_NUMBER()
END CATCH