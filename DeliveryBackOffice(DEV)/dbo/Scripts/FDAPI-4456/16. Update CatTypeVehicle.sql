/***
-- ACTUALIZACION DESCRIPCION
-- CATALOGO DE PRODUCTOS
***/

BEGIN TRANSACTION;
BEGIN TRY
    
    UPDATE CatTypeVehicle SET [Description] = 'Panel ' WHERE IdCountry = 'SV' and Name = 'Panel'

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH