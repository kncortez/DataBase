-- =============================================
-- Author:      <Edelman Vásquez>
-- Create date: <2026-05-29>
-- Description: Actualiza la columna CollectPaymentLinkRate de dbo.RateHeader
--              con el valor 5 (5%) para todos los tarifarios del país GT.
-- =============================================

BEGIN TRANSACTION;

BEGIN TRY

    UPDATE [dbo].[RateHeader]
    SET    [CollectPaymentLinkRate] = 5
    WHERE  [CountryId] = 'GT';

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;
    THROW;

END CATCH;
GO
