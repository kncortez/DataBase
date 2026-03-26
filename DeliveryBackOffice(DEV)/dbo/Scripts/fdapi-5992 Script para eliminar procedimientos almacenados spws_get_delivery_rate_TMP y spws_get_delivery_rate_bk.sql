/* =================================================
   SCRIPT:     
   Propósito:  Eliminación controlada de SPs sin uso identificado
   Autor:      Brenda Echeverría
   Historia:   FDAPI-5992
   Fecha:      2026-03-25
   ================================================= */

/* === CHANGELOG =============================
   
   =========================================== */

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    --------------------------------------------------
    -- DROP: spws_get_delivery_rate_TMP
    --------------------------------------------------
    IF OBJECT_ID('dbo.spws_get_delivery_rate_TMP', 'P') IS NOT NULL
    BEGIN
        PRINT 'Eliminando procedimiento: dbo.spws_get_delivery_rate_TMP';
        DROP PROCEDURE dbo.spws_get_delivery_rate_TMP;
        PRINT 'Procedimiento eliminado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'Procedimiento dbo.spws_get_delivery_rate_TMP no existe.';
    END

    --------------------------------------------------
    -- DROP: spws_get_delivery_rate_bk
    --------------------------------------------------
    IF OBJECT_ID('dbo.spws_get_delivery_rate_bk', 'P') IS NOT NULL
    BEGIN
        PRINT 'Eliminando procedimiento: dbo.spws_get_delivery_rate_bk';
        DROP PROCEDURE dbo.spws_get_delivery_rate_bk;
        PRINT 'Procedimiento eliminado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'Procedimiento dbo.spws_get_delivery_rate_bk no existe.';
    END

    --------------------------------------------------
    -- FIN
    --------------------------------------------------
    PRINT '===== SCRIPT FINALIZADO CON ÉXITO =====';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    PRINT '***** ERROR EN LA EJECUCIÓN *****';
    PRINT ERROR_MESSAGE();

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Se realizó ROLLBACK de la transacción.';
END CATCH;