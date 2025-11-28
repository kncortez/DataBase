BEGIN TRY
    BEGIN TRAN;

    -------------------------------------------------------------
    -- Eliminar SPs 
    -------------------------------------------------------------
    DROP PROCEDURE sps_headerInvoice
    DROP PROCEDURE sps_RegisterInvoiceForza
    DROP PROCEDURE sps_RegisterInvoiceForzaCorp
    DROP PROCEDURE sps_UpdateInvoiceForza

    -------------------------------------------------------------
    -- Eliminar el tipo si existe
    -------------------------------------------------------------
    DROP TYPE dbo.TblBuyerInfo;

    COMMIT TRAN;
    PRINT 'Proceso completado con éxito.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;

    DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
    PRINT 'ERROR: ' + @Err;
    THROW;
END CATCH;







