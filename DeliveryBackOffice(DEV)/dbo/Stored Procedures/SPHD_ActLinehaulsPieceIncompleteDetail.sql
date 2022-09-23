-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-11>
-- Description:	<detalle de actas por justificacion de piezas incompletas>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ActLinehaulsPieceIncompleteDetail] 
	
@IdAct AS INT
	
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT  DISTINCT A.IdAct, 
	  CASE WHEN AD.RowStatus=1 
	       THEN 'ACTIVA'
	  ELSE 'INACTIVA' END Estado,
			AD.GuideSerie + CAST(AD.GuideNumber AS nvarchar) +'-' + CAST(ADP.PieceNumber AS nvarchar) Guide,
			DO.Sender_FirstName,
			DO.Receiver_FirstName,
			HL.HubName AS Hubdestiny,
			HubOrigin='N/D'
	 FROM dbo.ACT A WITH (NOLOCK)
	 LEFT JOIN dbo.ActDetail AD WITH (NOLOCK)
		ON A.IdAct = AD.ActId
	 LEFT JOIN dbo.DeliveryOrder DO WITH (NOLOCK) 
	    ON  AD.GuideSerie  = DO.Guide_Serie and
		    AD.GuideNumber = DO.Guide_Number
	 LEFT JOIN  dbo.LinehaulRoutePreparationContainerDetail LC WITH (NOLOCK) 
	    ON  DO.Guide_Serie = LC.GuideSerie AND DO.Guide_Number = LC.GuideNumber 
	 LEFT JOIN LinehaulRoutePreparationContainer LC2 WITH (NOLOCK) 
	    ON  LC.LinehaulRoutePreparationContainerId = LC2.IdLinehaulRoutePreparationContainer
	 LEFT JOIN HubLogistics HL WITH (NOLOCK) 
	    ON   LC2.HubDestinyId = HL.IdHubLogistic
	 LEFT JOIN ActDetailPiece ADP WITH (NOLOCK) 
	    ON AD.IdActDetail = ADP.ActDetailId
	WHERE AD.ActId= @IdAct  
		AND AD.RowStatus=1


	
	 
	 


END