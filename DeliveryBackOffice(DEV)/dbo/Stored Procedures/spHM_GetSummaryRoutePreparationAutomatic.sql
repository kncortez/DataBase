/* =================================================
   SP:        [dbo].[spHMGetSummaryRoutePreparationAutomatic]
   Propósito: Obtiene resumen de piezas para realizar preparacion de ruta automatica
   Autor:     Brandon Pedroza
   Historia:  FDAPI-6096
   Fecha:     2026-05-08
   === CHANGELOG ============================

=========================================== */

CREATE PROCEDURE [dbo].[spHM_GetSummaryRoutePreparationAutomatic]
    @LinehaulRouteSettlementId  INT
AS
BEGIN
    SET NOCOUNT ON;


    DECLARE @LRP_ID AS INT;
    DECLARE @STATUS_LIQUID AS INT = 3; -- Liquidado <- CatLinehaulStatus 

    SET @LRP_ID = (
        SELECT  [LRS].[LinehaulRoutePreparationId]
        FROM    [dbo].[LinehaulRouteSettlement] LRS WITH (NOLOCK)
        WHERE   [LRS].[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId
    );

    IF OBJECT_ID('tempdb..#GuidesTmp') IS NOT NULL
        DROP TABLE #GuidesTmp;

    CREATE TABLE #GuidesTmp (
        GuideSerie   NVARCHAR(2),
        GuideNumber  INT,
        GuidePiece   INT
    );

    INSERT INTO #GuidesTmp (GuideSerie, GuideNumber, GuidePiece)
    SELECT
        LRPCD.GuideSerie,
        LRPCD.GuideNumber,
        LRPCDP.PieceNumber
    FROM        [dbo].[LinehaulRoutePreparationContainerDetailPiece]    LRPCDP  WITH (NOLOCK)
    INNER JOIN  [dbo].[LinehaulRoutePreparationContainerDetail]         LRPCD   WITH (NOLOCK)
        ON      [LRPCDP].[LinehaulRoutePreparationContainerDetailId]    = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
    INNER JOIN  [dbo].[LinehaulRoutePreparationContainer]               LRPC    WITH (NOLOCK)
        ON      [LRPCD].[LinehaulRoutePreparationContainerId]           = [LRPC].[IdLinehaulRoutePreparationContainer]
    INNER JOIN  [dbo].[LinehaulRoutePreparation]                        LRP     WITH (NOLOCK)
        ON      [LRPC].[LinehaulRoutePreparationId]                     = [LRP].[IdLinehaulRoutePreparation]
    WHERE       [LRPCDP].[ActCode]                  IS NULL
        AND     [LRPCDP].[RowStatus]                = 1
        AND     [LRP].[IdLinehaulRoutePreparation]  = @LRP_ID
        AND     [LRPCD].[RowStatus]                 = 1
        AND     [LRPCDP].CatLinehaulStatusId        = @STATUS_LIQUID;

    SELECT
        COUNT(GT.GuideNumber)   AS [TotalPieces],
        DSC.Hub,
        DSC.RouteCode
    FROM        DeliveryOrder           DO WITH (NOLOCK)
    INNER JOIN  #GuidesTmp              GT
        ON      DO.Guide_Serie          = GT.GuideSerie
        AND     DO.Guide_Number         = GT.GuideNumber
    INNER JOIN  DumpServiceCoverage     DSC WITH (NOLOCK)
        ON      DO.ReceiverIdSettlement = DSC.IdSettlement
    GROUP BY    DSC.Hub, DSC.RouteCode;

    IF OBJECT_ID('tempdb..#GuidesTmp') IS NOT NULL
        DROP TABLE #GuidesTmp;

END;
