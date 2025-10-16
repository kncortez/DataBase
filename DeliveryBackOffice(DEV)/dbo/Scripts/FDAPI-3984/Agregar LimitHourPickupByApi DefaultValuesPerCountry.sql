-- =============================================
-- Author:      <Juan, Ramirez>
-- Create date: <2025-06-01>
-- Description: <Se altera tabla para agregar horario limite para recolecciones via API>
-- =============================================
BEGIN TRY
    BEGIN TRANSACTION;

    ALTER TABLE DeliveryBackOffice.dbo.DefaultValuesPerCountry
      ADD LimitHourPickupByApi NVARCHAR(5) NULL

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;


