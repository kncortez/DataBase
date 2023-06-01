-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-31>
-- Description:	<Description,Cabecera de reporte de manifiiesto recolección de rutas especiales>
-- =============================================
CREATE PROCEDURE [dbo].[SPHDManifestHeaderTSE] 
@IdRoute AS INT
AS
BEGIN
	
	SET NOCOUNT ON;

		Select Top 1 
			RPH.IDTSERoutePreparationHeader,
			UPPER(CR.CodeRoute) CodeRoute,
			SR.First_Name +' '+ SR.Last_Name [Curierman],
			CV.UnitNumber+'-'+CV.Plate Plate,
			UPPER(CRC.ClusterName) ClusterName,
			SR1.First_Name +' '+ SR1.Last_Name [Name],
			SR2.First_Name +' '+ SR2.Last_Name [Leader]
		


	From [dbo].[TSERoutePreparationHeader] RPH WITH (NOLOCK)
		 Inner Join
		 [dbo].[CatRoute] CR WITH (NOLOCK)
		 ON 	RPH.IdCatRoute = CR.IdRoute
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
	       RPH.IdCatRoute = @IdRoute
 
   
END