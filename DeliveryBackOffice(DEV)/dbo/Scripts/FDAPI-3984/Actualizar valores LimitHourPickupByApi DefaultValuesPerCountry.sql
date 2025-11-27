-- =============================================
-- Author:      <Juan, Ramirez>
-- Create date: <2025-06-01>
-- Description: <Se agrega valor horario limite para recolecciones via API>
-- =============================================
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry
       SET LimitHourPickupByApi = '17:00'
     WHERE IdCountry = 'GT'

    UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry
       SET LimitHourPickupByApi = '17:00'
     WHERE IdCountry = 'HN'

    UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry
       SET LimitHourPickupByApi = '17:00'
     WHERE IdCountry = 'SV'

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
