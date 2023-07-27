-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-31>
-- Description:	<Description,Cabecera de reporte de manifiiesto recolección de rutas especiales>
-- =============================================
CREATE PROCEDURE [dbo].[SPHDPickUpManifestHeaderTSE] 
@IdRoute AS INT,
@NameUser AS NVARCHAR(50)=''
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
			SR2.First_Name +' '+ SR2.Last_Name [Leader],
			UPPER(@NameUser) [User],
			FORMAT(GETDATE(),'dd-MM-yyyy hh:mm:ss') DateExec,
			ISNULL([RouteSignature].[Signature], '') [Signature],
			ISNULL([RPH].[TSECustomsMark], '') [CustomsMark]
		


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
		 OUTER APPLY
		 (
			SELECT 
				TOP (1) 
					[SM].[PuSignaturePath] [Signature] 
			FROM 
				[DeliveryBackOffice].[dbo].[RouteAssigment] RA  WITH(NOLOCK) 
				INNER JOIN
					[DeliveryBackOffice].[dbo].[ServiceManagement] SM  WITH(NOLOCK) 
					ON
						[SM].[IdPuRouteAssigment] = [RA].[IdRouteAssigment]
			WHERE
				[RA].[RowStatus] = 1
				AND
				[RA].[IdVehicle] = [RPH].[IdCatVehicle]
				AND
				[RA].[IdRoute] = [RPH].[IdCatRoute]
				AND
				[SM].[PuSignaturePath] IS NOT NULL
		 ) RouteSignature

	WHERE  RPH.RowStatus = 1 And 
	       RPH.IdCatRoute = @IdRoute
		   And RPH.HasFirstPickupProcess =1
 
   
END