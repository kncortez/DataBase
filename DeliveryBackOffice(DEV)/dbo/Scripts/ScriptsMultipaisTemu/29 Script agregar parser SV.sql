/*
-- CONFIGURACION PARA CORREO DE PARSER SV
*/

BEGIN TRANSACTION
BEGIN TRY

    insert into ConfigParams([Name],[Description],[Value],[Status],[CreateDate],[IdCountry])
    values('EmailByParser','Correo Parser de Salvador','solicitudes.sv@forza.delivery',1,GETDATE(),'SV')

    insert into ConfigParams([Name],[Description],[Value],[Status],[CreateDate],[IdCountry])
    values('EmailByParser','Correo Parser de Salvador','test.sv@forza.delivery',1,GETDATE(),'SV')

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- Si hay cualquier error, revertimos todo
    ROLLBACK TRANSACTION;
    
    -- Capturamos y mostramos el error
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
