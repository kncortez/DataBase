-- =============================================
-- Author:        Cristian Suazo
-- Create date:   23-10-2025
-- Description:   Valida si una guía puede pasar al estado "En Inventario"
-- Historia:      FDAPI-4610
-- =============================================
CREATE PROCEDURE ValidGuideReview
    @GuideSerie   NVARCHAR(2) = 'FD',
    @GuideNumber  INT = NULL,
    @StatusId  INT 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @StatusRequested   INT,   -- Estado al que se quiere mover
        @StatusCurrent     INT,   -- Estado actual de la guía
        @StatusInventory   INT,   -- ID del estado "En Inventario"
        @StatusReview      INT,   -- ID del estado "En Revisión"
        @ExistsFlag        BIT;   -- Indica si la guía existe

    SELECT 
        @StatusInventory = so.StatusOrderId
    FROM StatusOrder so WITH (NOLOCK)
    WHERE so.OrderDescription = 'En Inventario';

    SELECT 
        @StatusReview = so.StatusOrderId
    FROM StatusOrder so WITH (NOLOCK)
    WHERE so.OrderDescription = 'En Revisión';

    SELECT 
        @ExistsFlag = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END,
        @StatusCurrent = MAX(StatusOrderId)
    FROM DeliveryOrder WITH (NOLOCK)
    WHERE Guide_Serie = @GuideSerie
      AND Guide_Number = @GuideNumber;

    IF @ExistsFlag = 0
    BEGIN
        SELECT 0 AS StatusCode, 'La guía no existe' AS Message;
        RETURN;
    END;

    IF @StatusCurrent = @StatusReview AND @StatusId = @StatusInventory
    BEGIN
        SELECT 1 AS StatusCode, 'Procede, pasará a estado En Inventario' AS Message;
        RETURN;
    END;

    IF @StatusCurrent = @StatusReview
    BEGIN
        SELECT 0 AS StatusCode, 'Guía en estado de Revisión, no procede' AS Message;
        RETURN;
    END;

    SELECT 1 AS StatusCode, 'Procede: la guía no está en estado de Revisión.' AS Message;
END;