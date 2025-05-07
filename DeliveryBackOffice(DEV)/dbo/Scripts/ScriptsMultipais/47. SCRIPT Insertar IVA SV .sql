/***
INSERTAR IVA PARA FACTURAR A TRAVES DE API 
***/

BEGIN TRANSACTION;
BEGIN TRY
    -- Inserciones de datos
insert into ConfigParams (Name,Description,Value,Status,CreateDate,IdCountry)
VALUES('TaxPercentage','Porcentaje para el calculo de IVA',1.13,1,GETDATE(),'SV');
    
    -- Si llegamos aquí sin errores, confirmamos la transacción
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
