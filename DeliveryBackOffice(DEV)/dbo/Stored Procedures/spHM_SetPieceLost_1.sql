
CREATE   PROCEDURE dbo.spHM_SetPieceLost
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
    @NoPiece INT,
    @Observations NVARCHAR(200) = NULL,
    @Token NVARCHAR(50),
    @UpdateGuideIfAllPiecesLost BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LostStatusId INT = (SELECT so.StatusOrderId FROM StatusOrder so WITH (NOLOCK) WHERE so.OrderDescription = 'Paquete Extraviado');

    IF NOT EXISTS (
        SELECT 1 FROM DeliveryOrderPiece WITH (NOLOCK)
        WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber AND NoPiece = @NoPiece
    )
    BEGIN
        SELECT 6 AS StatusCode, 'La pieza no existe para la guía indicada.' AS Description;
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE DeliveryOrderPiece
        SET StatusOrderId = @LostStatusId
        WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber AND NoPiece = @NoPiece;

        INSERT INTO DeliveryOrderDetail (Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations)
        VALUES (@GuideSerie, @GuideNumber, @LostStatusId, @Token, GETDATE(), GETDATE(), CONCAT('Pieza ', @NoPiece, ' extraviada. ', ISNULL(@Observations, '')));

        IF (@UpdateGuideIfAllPiecesLost = 1)
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM DeliveryOrderPiece WITH (NOLOCK)
                WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber AND StatusOrderId <> @LostStatusId
            )
            BEGIN
                UPDATE DeliveryOrder
                SET StatusOrderId = @LostStatusId
                WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber;
            END
        END

        COMMIT TRANSACTION;
        SELECT 1 AS StatusCode, 'Pieza marcada como extraviada correctamente.' AS Description;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS StatusCode, ERROR_MESSAGE() AS Description;
    END CATCH
END