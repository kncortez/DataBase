CREATE PROCEDURE dbo.support_ActualizarFechaExpiracionSubscription
(
    @IdSubscription INT,
    @NuevaFecha     DATE,
    @Usuario        VARCHAR(50) 
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    /*  Validación */
    IF NOT EXISTS (
        SELECT 1
        FROM Subscription
        WHERE IdSubscription = @IdSubscription
    )
    BEGIN
        RAISERROR('La suscripción no existe.',16,1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;

        UPDATE Subscription
        SET
            ExpirationDate = CAST(@NuevaFecha AS DATE), -- solo fecha
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
        RAISERROR(@ErrorMessage,16,1);
    END CATCH
END;
GO
