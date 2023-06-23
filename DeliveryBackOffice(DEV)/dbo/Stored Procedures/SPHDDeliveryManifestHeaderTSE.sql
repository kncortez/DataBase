
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-31>
-- Description:	<Description,Cabecera de reporte de manifiiestoentrega de rutas especiales>
-- =============================================
CREATE PROCEDURE [dbo].[SPHDDeliveryManifestHeaderTSE] 
@IdRoute AS INT,
@NameUser AS NVARCHAR(50)=''
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
			SR2.First_Name +' '+ SR2.Last_Name [Leader],
			UPPER(@NameUser) [User],
		    FORMAT(GETDATE(),'dd-MM-yyyy hh:mm:ss') DateExec,
			ISNULL([RouteSignature].[Signature], '') [Signature],
			ISNULL([RPH].[TSECustomsMark],'') [CustomsMark]


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
		 OUTER APPLY 
		 (
			SELECT 
				TOP (1) 
					[DP].[Path_Dry] [Signature]
			FROM 
				[DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] TSED  WITH(NOLOCK) 
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA  WITH(NOLOCK) 
					ON
						[TSED].[GuideSerie] = [DA].[Guide_Serie]
						AND
						[TSED].[GuideNumber] = [DA].[Guide_Number]
						AND
						ISNULL([DA].[IsLastMileReturn], 0) = 1
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryProof] DP  WITH(NOLOCK) 
					ON
						[DP].[ID] = [DA].[ID_Proof]
			WHERE
				[TSED].[TSERoutePreparationHeaderID] = [RPH].[IDTSERoutePreparationHeader]
				AND
				[TSED].[RowStatus] = 1
				AND
				[DP].[Path_Dry] IS NOT NULL
			ORDER BY
				[DA].[Date_Created] DESC
		 ) RouteSignature

	WHERE  RPH.RowStatus = 1 AND 
	       RPH.IdCatRoute = @IdRoute
		   AND RPH.HasLastDeliveryProccess =1
 
   
END