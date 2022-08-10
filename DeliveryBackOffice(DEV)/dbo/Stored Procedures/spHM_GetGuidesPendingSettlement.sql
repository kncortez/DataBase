-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-08-04>
-- Description:	<Obtiene el listado de guías pendientes de liquidación Linehaul>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetGuidesPendingSettlement]
	-- Add the parameters for the stored procedure here
	@LinehaulRoutePreparationId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT
	lrpcd.GuideSerie
   ,lrpcd.GuideNumber
   ,lrpcdp.PieceNumber
	FROM LinehaulRoutePreparationContainer lrpc
	INNER JOIN LinehaulRoutePreparationContainerDetail lrpcd
		ON lrpcd.LinehaulRoutePreparationContainerId = lrpc.IdLinehaulRoutePreparationContainer
	INNER JOIN LinehaulRoutePreparationContainerDetailPiece lrpcdp
		ON lrpcdp.LinehaulRoutePreparationContainerDetailId = lrpcd.IdLinehaulRoutePreparationContainerDetail
	WHERE lrpc.LinehaulRoutePreparationId = @LinehaulRoutePreparationId
		AND lrpcd.RowStatus = 1 AND lrpcdp.RowStatus = 1 AND lrpcdp.ActCode IS NULL
	EXCEPT
	SELECT
		lrscd.GuideSerie
	   ,lrscd.GuideNumber
	   ,lrscdp.PieceNumber
	FROM LinehaulRouteSettlement lrs
	INNER JOIN LinehaulRouteSettlementContainer lrsc
		ON lrsc.LinehaulRouteSettlementId = lrs.IdLinehaulRouteSettlement
	INNER JOIN LinehaulRouteSettlementContainerDetail lrscd
		ON lrscd.LinehaulRouteSettlementContainerId = lrsc.IdLinehaulRouteSettlementContainer
	INNER JOIN LinehaulRouteSettlementContainerDetailPiece lrscdp
		ON lrscdp.LinehaulRouteSettlementContainerDetailId = lrscd.IdLinehaulRouteSettlementContainerDetail
	WHERE lrs.LinehaulRoutePreparationId = @LinehaulRoutePreparationId
		AND lrscd.RowStatus = 1 AND lrscdp.RowStatus = 1 AND lrscdp.ActCode IS NULL

END