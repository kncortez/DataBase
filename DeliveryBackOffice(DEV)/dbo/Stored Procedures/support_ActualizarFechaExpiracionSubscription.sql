/* =================================================
   SP:        [dbo].[support_ActualizarFechaExpiracionSubscription]
   Propósito: Actualizar la fecha de expiración de una suscripción.
   Autor:     Cristian De Leon
   Historia:  FDAPI-5287
   Fecha:     2026-02-16
============================================
=== CHANGELOG ================================
2026-02-16 | Historia/épica: FDAPI-5287 | Autor: Cristian De Leon |
-----
=========================================== */
CREATE OR ALTER PROCEDURE dbo.support_ActualizarFechaExpiracionSubscription
(
    @IdSubscription INT,
    @NuevaFecha     DATE,
    @Usuario        NVARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    /* Validación */
    IF NOT EXISTS (
        SELECT 1
        FROM DeliveryBackOffice.dbo.Subscription WITH (NOLOCK)
        WHERE IdSubscription = @IdSubscription
    )
    BEGIN
        RAISERROR('La suscripción no existe.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;

        UPDATE DeliveryBackOffice.dbo.Subscription
        SET
            ExpirationDate = @NuevaFecha,
            TokenUpdated   = @Usuario,
            DateUpdated    = GETDATE()
        WHERE IdSubscription = @IdSubscription;

        COMMIT TRAN;

        PRINT 'Fecha de expiración actualizada correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
