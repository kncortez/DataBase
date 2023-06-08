
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPHDManifestHeaderTSE] 
@IdRoute AS INT
AS
BEGIN
	
	SET NOCOUNT ON;

		SELECT TOP 1 
			RPH.IDTSERoutePreparationHeader,
			UPPER(CR.CodeRoute) CodeRoute,
			SR.First_Name +' '+ SR.Last_Name [Curierman],
			CV.UnitNumber+'-'+CV.Plate Plate,
			UPPER(CRC.ClusterName) ClusterName,
			SR1.First_Name +' '+ SR1.Last_Name [Name],
			SR2.First_Name +' '+ SR2.Last_Name [Leader]
		


	FROM [dbo].[TSERoutePreparationHeader] RPH WITH (NOLOCK)
		 INNER JOIN
		 [dbo].[CatRoute] CR WITH (NOLOCK)
		 ON 	RPH.IdCatRoute = CR.IdRoute
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

	WHERE  RPH.RowStatus = 1 AND 
	       RPH.IdCatRoute = @IdRoute
 
   
END