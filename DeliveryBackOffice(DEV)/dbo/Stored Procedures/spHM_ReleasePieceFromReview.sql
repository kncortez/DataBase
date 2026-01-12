-- =============================================
-- Libera una pieza individual de una guía desde revisión
-- Si todas las piezas quedan liberadas, también libera la guía
-- =============================================
USE [DeliveryBackOffice]
GO

CREATE OR ALTER PROCEDURE dbo.spHM_ReleasePieceFromReview
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
    @NoPiece INT,
    @Observations NVARCHAR(200) = NULL,
    @Token NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ReleasedStatusId INT = 44; -- Trasladado a Hub
    DECLARE @RevisionStatusId INT = 13; -- En Revisión
    DECLARE @CurrentPieceStatus INT;

    -- Verificar que la pieza existe
    IF NOT EXISTS (
        SELECT 1 FROM DeliveryOrderPiece WITH (NOLOCK)
        WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber AND NoPiece = @NoPiece
    )
    BEGIN
        SELECT 6 AS StatusCode, 'La pieza no existe para la guía indicada.' AS Description;
        RETURN;
    END;

    -- Obtener estado actual de la pieza
    SELECT @CurrentPieceStatus = StatusOrderId
    FROM DeliveryOrderPiece WITH (NOLOCK)
    WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber AND NoPiece = @NoPiece;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Actualizar estado de la pieza a 44 (puede estar en cualquier estado previo)
        UPDATE DeliveryOrderPiece
        SET StatusOrderId = @ReleasedStatusId
        WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber AND NoPiece = @NoPiece;

        -- Registrar en histórico
        INSERT INTO DeliveryOrderDetail (
            Guide_Serie,
            Guide_Number,
            StatusOrderId,
            UserCreated,
            DateCreated,
            DateCreatedInSystem,
            Observations,
            RowStatus
        )
        VALUES (
            @GuideSerie,
            @GuideNumber,
            @ReleasedStatusId,
            @Token,
            GETDATE(),
            GETDATE(),
            CONCAT('Pieza ', @NoPiece, ' liberada. ', ISNULL(@Observations, '')),
            1
        );

        -- Verificar si todas las piezas están ahora en estado 44
        DECLARE @TotalPiezas INT;
        DECLARE @PiezasLiberadas INT;

        SELECT
            @TotalPiezas = COUNT(*),
            @PiezasLiberadas = SUM(CASE WHEN StatusOrderId = @ReleasedStatusId THEN 1 ELSE 0 END)
        FROM DeliveryOrderPiece WITH (NOLOCK)
        WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber;

        -- Si todas las piezas están liberadas, liberar también la guía
        IF (@TotalPiezas > 0 AND @PiezasLiberadas = @TotalPiezas)
        BEGIN
            UPDATE DeliveryOrder
            SET StatusOrderId = @ReleasedStatusId
            WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber;

            -- Registrar liberación de la guía en histórico
            INSERT INTO DeliveryOrderDetail (
                Guide_Serie,
                Guide_Number,
                StatusOrderId,
                UserCreated,
                DateCreated,
                DateCreatedInSystem,
                Observations,
                RowStatus
            )
            VALUES (
                @GuideSerie,
                @GuideNumber,
                @ReleasedStatusId,
                @Token,
                GETDATE(),
                GETDATE(),
                'Guía liberada automáticamente: todas las piezas liberadas.',
                1
            );

            SELECT
                1 AS StatusCode,
                'Pieza liberada. Todas las piezas están liberadas, guía también liberada.' AS Description,
                1 AS GuideReleased,
                @TotalPiezas AS TotalPiezas,
                @PiezasLiberadas AS PiezasLiberadas;
        END
        ELSE
        BEGIN
            SELECT
                1 AS StatusCode,
                'Pieza liberada correctamente.' AS Description,
                0 AS GuideReleased,
                @TotalPiezas AS TotalPiezas,
                @PiezasLiberadas AS PiezasLiberadas;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS StatusCode, ERROR_MESSAGE() AS Description;
    END CATCH
END
GO
