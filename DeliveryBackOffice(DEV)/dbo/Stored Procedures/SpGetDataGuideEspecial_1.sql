
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

	SELECT
			RPH.IDTSERoutePreparationHeader,
			RPH.IdCatRoute,
			SR.First_Name +' '+ SR.Last_Name [Curierman],
			SR.ID IdCurierman,
			CV.UnitNumber+'-'+CV.Plate Plate,
			CV.IdVehicle,
			CRC.ClusterName,
			CRC.IdCatRouteCluster,
			SR1.First_Name +' '+ SR1.Last_Name [Name],
			SR1.ID IdSupervisor,
			SR2.First_Name +' '+ SR2.Last_Name [Leader],
			SR2.ID IdLeader,
	
			RPD.IDTSERoutePreparationDetail,
			RPD.TSERoutePreparationHeaderID,
			RPD.GuideSerie,
			RPD.GuideNumber


	FROM [dbo].[TSERoutePreparationHeader] RPH WITH (NOLOCK)
		 INNER JOIN
		 [dbo].[TSERoutePreparationDetail] RPD WITH (NOLOCK)
		 ON 	RPH.IDTSERoutePreparationHeader = RPD.TSERoutePreparationHeaderID
		 INNER JOIN 
		 [dbo].[SenderReceiver] SR WITH (NOLOCK)
		 ON RPH.SenderReceiverId = SR.ID
		 INNER JOIN 
		 [dbo].[SenderReceiver] SR1 WITH (NOLOCK)
		 ON RPH.IdRouteSupervisor = SR1.ID
		 INNER JOIN 
		 [dbo].[SenderReceiver] SR2 WITH (NOLOCK)
		 ON  RPH.IdRouteLeader  = SR2.ID
		 INNER JOIN
		 [dbo].[CatRouteCluster] CRC WITH (NOLOCK)
		 ON   RPH.IdCatRouteCluster = CRC.IdCatRouteCluster
		 INNER JOIN 
		 [dbo].[CatVehicle] CV  WITH (NOLOCK)
		 ON RPH.IdCatVehicle = CV.IdVehicle 

	WHERE  RPH.RowStatus = 1 AND RPD.RowStatus=1 AND
	       RPH.IdCatRoute = @IdCatRoute
 
END