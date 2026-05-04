-- Capturar timestamp antes de la transacción para usarlo en el rollback
DECLARE @FechaEjecucion DATETIME2 = GETDATE();

BEGIN TRANSACTION;

BEGIN TRY

    INSERT INTO CatSubscriptionDiscountRange
        (CatSubscriptionId, DiscountLowServiceRange, DiscountTopServiceRange,
         ValueTypeId, DiscountValue, RowStatus, TokenCreated, DateCreated)
    SELECT 
        cs.IdCatSubscription,
        cs.SubscriptionMaxServiceFixedValue,
        NULL,
        1,
        0.00,
        1,
        'SYS-BMORATAYA',
        @FechaEjecucion
    FROM CatSubscription cs
    WHERE cs.IdCountry = 'SV';

    SELECT 'CatSubscriptionDiscountRange insertados' AS Accion, @@ROWCOUNT AS Filas;

    COMMIT;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
END CATCH;

-- =============================================
-- PLAN DE ROLLBACK
-- Ejecutar solo si se necesita revertir después del COMMIT.
-- Reemplazar el valor de @FechaEjecucion con el timestamp exacto
-- que se imprimió al correr el script original.
-- =============================================
/*
DECLARE @FechaEjecucion DATETIME2 = '2026-04-28 HH:MM:SS.nnnnnnn'; -- <-- ajustar

BEGIN TRANSACTION;

BEGIN TRY

    DELETE csdr
    FROM CatSubscriptionDiscountRange csdr
    INNER JOIN CatSubscription cs ON cs.IdCatSubscription = csdr.CatSubscriptionId
    WHERE cs.IdCountry = 'SV'
      AND csdr.DateCreated = @FechaEjecucion;

    SELECT 'CatSubscriptionDiscountRange eliminados (rollback)' AS Accion, @@ROWCOUNT AS Filas;

    COMMIT;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
END CATCH;
*/