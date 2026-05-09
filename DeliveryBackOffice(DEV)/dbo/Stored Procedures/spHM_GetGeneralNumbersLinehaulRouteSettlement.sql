/* =================================================
   SP:        spHM_GetGeneralNumbersLinehaulRouteSettlement
   Propósito: Obtener métricas generales de Linehaul Route Settlement
   Autor:     Jerson Ochoa
   Historia:  ---
   Fecha:     2022-09-14

=== CHANGELOG ============================

2026-05-08 | Historia/épica: FDAPI-6096        | Autor: Brandon Pedroza      | Se obtiene numero de contenedores en escala

=========================================== */
CREATE PROCEDURE [dbo].[spHM_GetGeneralNumbersLinehaulRouteSettlement]
	@LinehaulRouteSettlementId AS INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @LRP_ID AS INT;
	DECLARE @TOTAL_PIECES AS INT;
	DECLARE @CONTAINER_IN_STOPOVER AS INT = 0;
	DECLARE @STATUS_STOPOVER AS INT = 4;


	SET @LRP_ID = (SELECT	[LRS].[LinehaulRoutePreparationId]
					FROM	[dbo].[LinehaulRouteSettlement] LRS WITH (NOLOCK)
					WHERE	[LRS].[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId);


	SELECT
		@TOTAL_PIECES         = TOTAL_PIECES,
		@CONTAINER_IN_STOPOVER = CONTAINER_IN_STOPOVER
	FROM (
		SELECT
			(
				SELECT      COUNT([LRPCD].[GuideSerie])
				FROM        [dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP WITH (NOLOCK)
				INNER JOIN  [dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
					ON      [LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
				INNER JOIN  [dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
					ON      [LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
				INNER JOIN  [dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
					ON      [LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
				WHERE       [LRPCDP].[ActCode] IS NULL
					AND     [LRPCDP].[RowStatus] = 1
					AND     [LRP].[IdLinehaulRoutePreparation] = @LRP_ID
					AND     [LRPCD].[RowStatus] = 1
			) AS TOTAL_PIECES,
			(
				SELECT  COUNT(1)
				FROM    [dbo].[LinehaulRoutePreparationContainer] WITH (NOLOCK)
				WHERE   [LinehaulRoutePreparationId] = @LRP_ID
					AND [CatLinehaulStatusId] = @STATUS_STOPOVER
			) AS CONTAINER_IN_STOPOVER
	) RESULTS;



    SELECT	[LRS].[GuidesReceived],
			[LRS].[ContainersReceived],
			[LRS].[GuidePiecesReceived],
			[LRS].[GuidePiecesMissing],
			@TOTAL_PIECES [TotalPieces],
			@CONTAINER_IN_STOPOVER [ContainersInStopOver]
	FROM	[dbo].[LinehaulRouteSettlement] LRS
	WHERE	[LRS].[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId;
END
