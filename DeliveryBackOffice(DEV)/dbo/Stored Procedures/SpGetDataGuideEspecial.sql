-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-22>
-- Description:	<Description, SP para obtener datos de preparación de guías Especiales>
-- =============================================
CREATE PROCEDURE [dbo].[SpGetDataGuideEspecial]
@IdCatRoute AS INT
AS
BEGIN
	
	SET NOCOUNT ON;

	Select
			RPH.IDTSERoutePreparationHeader,
			RPH.IdCatRoute,
			SR.First_Name +' '+ SR.Last_Name [Curierman],
			CV.UnitNumber+'-'+CV.Plate Plate,
			CRC.ClusterName,
			SR1.First_Name +' '+ SR1.Last_Name [Supervisor],
			SR2.First_Name +' '+ SR2.Last_Name [Leader],
			RPH.Coordinator,
	
			RPD.IDTSERoutePreparationDetail,
			RPD.TSERoutePreparationHeaderID,
			RPD.GuideSerie,
			RPD.GuideNumber


	From [dbo].[TSERoutePreparationHeader] RPH WITH (NOLOCK)
		 Inner Join
		 [dbo].[TSERoutePreparationDetail] RPD WITH (NOLOCK)
		 ON 	RPH.IDTSERoutePreparationHeader = RPD.TSERoutePreparationHeaderID
		 Inner Join 
		 [dbo].[SenderReceiver] SR WITH (NOLOCK)
		 ON RPH.SenderReceiverId = SR.ID
		 Inner Join 
		 [dbo].[SenderReceiver] SR1 WITH (NOLOCK)
		 ON RPH.IdRouteSupervisor = SR1.ID
		 Inner Join 
		 [dbo].[SenderReceiver] SR2 WITH (NOLOCK)
		 ON  RPH.IdRouteLeader  = SR2.ID
		 Inner Join
		 [dbo].[CatRouteCluster] CRC WITH (NOLOCK)
		 ON   RPH.IdCatRouteCluster = CRC.IdCatRouteCluster
		 Inner Join 
		 [dbo].[CatVehicle] CV  WITH (NOLOCK)
		 ON RPH.IdCatVehicle = CV.IdVehicle 

	WHERE  RPH.RowStatus = 1 And 
	       RPH.IdCatRoute = @IdCatRoute
 
END