-- =============================================
-- Author:		<Eduardo, López>
-- Create date: <2022-09-23>
-- Description:	<Validar existencias de actas para linehauls con piezas incompletas>
-- =============================================
CREATE PROCEDURE [dbo].[ValidExistActs]
@LinehaulId INT

AS
	BEGIN

		SELECT COUNT(actdp.IdActDetailPiece) Acts
				FROM LinehaulRoutePreparation lrp WITH (NOLOCK)
				INNER JOIN LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
				ON lrp.IdLinehaulRoutePreparation = lrpc.LinehaulRoutePreparationId
				INNER JOIN LinehaulRoutePreparationContainerDetail lrpcd WITH (NOLOCK)
				ON lrpc.IdLinehaulRoutePreparationContainer = lrpcd.LinehaulRoutePreparationContainerId
				INNER JOIN ActDetail actd WITH (NOLOCK)
				ON lrpcd.GuideNumber = actd.GuideNumber
				INNER JOIN Act ac WITH (NOLOCK)
				ON ac.IdAct = actd.ActId
				INNER JOIN ActDetailPiece actdp WITH (NOLOCK)
				ON actd.IdActDetail = actdp.ActDetailId
					WHERE lrp.IdLinehaulRoutePreparation = @LinehaulId
					AND Ac.RowStatus= 1
					AND Actd.RowStatus = 1
					AND Actdp.RowStatus = 1
			
	END