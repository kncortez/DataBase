-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <14-09-2022>
-- Description:	<Get general numbers from Linehaul Route Settlement>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetGeneralNumbersLinehaulRouteSettlement]
	@LinehaulRouteSettlementId AS INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @LRP_ID AS INT;
	DECLARE @TOTAL_PIECES AS INT;

	SET @LRP_ID = (SELECT	[LRS].[LinehaulRoutePreparationId]
					FROM	[dbo].[LinehaulRouteSettlement] LRS
					WHERE	[LRS].[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId);

	SET @TOTAL_PIECES = (SELECT		COUNT([LRPCD].[GuideSerie]) AS TOTAL
						FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
						INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
							ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
						INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
							ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
						INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP
							ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
							AND		[LRP].[IdLinehaulRoutePreparation] = @LRP_ID
						WHERE		[LRPCDP].[ActCode] IS NULL
							AND		[LRPCDP].[RowStatus] = 1);

    SELECT	[LRS].[GuidesReceived],
			[LRS].[ContainersReceived],
			[LRS].[GuidePiecesReceived],
			[LRS].[GuidePiecesMissing],
			@TOTAL_PIECES [TotalPieces]
	FROM	[dbo].[LinehaulRouteSettlement] LRS
	WHERE	[LRS].[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId;
END