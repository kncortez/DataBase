/* =================================================
   SP:        [dbo].[ValidGuideReview]
   Propósito: Valida si una guía puede pasar al estado "En Inventario"
   Autor:     Cristian Suazo
   Historia:  FDAPI-4610
   Fecha:     2025-10-23
   === CHANGELOG ============================
   2026-06-01 | Historia/épica: FDAPI-6153   | Autor: Mario Herrarte | Bloqueo de guías preparadas para devolución.
=========================================== */
CREATE PROCEDURE [dbo].[ValidGuideReview]
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
        @ExistsFlag        BIT,   -- Indica si la guía existe
        @IsLastMileReturn  INT;   -- Indica si la guia esta definida para devolucion

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
        @StatusCurrent = MAX(StatusOrderId),
        @IsLastMileReturn = MAX(CAST(IsLastMileReturn AS INT))
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

    IF @IsLastMileReturn = 1
    BEGIN
        SELECT 0 AS StatusCode, 'Guía declarada para devolución, no procede' AS Message;
        RETURN;
    END; 

    SELECT 1 AS StatusCode, 'Procede: la guía no está en estado de Revisión.' AS Message;
END;