

-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-31>
-- Description:	<Description, Detalle de manifiesto global>
-- =============================================
CREATE PROCEDURE [dbo].[SPHDManifestPickUpGlobalDetailTSE]  
	
AS
BEGIN

	SELECT 
		DISTINCT 
		    TRPD.GuideSerie + Convert(NVARCHAR(50),TRPD.GuideNumber) Guide,
			TRPD.GuideNumber,
			TRPD.IDTSERoutePreparationDetail,
			[DO].[Receiver_FirstName] [VoteCenter],
			[DO].[Receiver_Address] [Adress],
			Upper([DO].[Receiver_Alternant_FullName]) [Coordinador],
			SR.First_Name +' '+ SR.Last_Name [Curierman],
			CV.UnitNumber+'-'+CV.Plate Plate,
			Upper(CRC.ClusterName) ClusterName,
			FORMAT(GETDATE(),'dd-MM-yyyyy hh:mm:ss') [DateExec],
		    CR.CodeRoute [CodeRoute],
			COUNT([DOP].[NoPiece]) TotalPieces
	FROM
		[DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] TRPD  WITH(NOLOCK) 
		INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
			ON
				[DO].[Guide_Serie] = [TRPD].[GuideSerie]
				AND
				[DO].[Guide_Number] = [TRPD].[GuideNumber]
		INNER JOIN
			[DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] TRPH  WITH(NOLOCK) 
			ON 
				TRPH.IdTSERoutePreparationHeader = TRPD.TSERoutePreparationHeaderID
				---Agregar campos de cabecera
				Inner Join 
		 [dbo].[SenderReceiver] SR WITH (NOLOCK)
		 ON TRPH.SenderReceiverId = SR.ID
		 Inner Join 
		 [dbo].[SenderReceiver] SR1 WITH (NOLOCK)
		 ON TRPH.IdRouteSupervisor = SR1.ID
		 Inner Join 
		 [dbo].[SenderReceiver] SR2 WITH (NOLOCK)
		 ON  TRPH.IdRouteLeader  = SR2.ID
		 Inner Join
		 [dbo].[CatRouteCluster] CRC WITH (NOLOCK)
		 ON   TRPH.IdCatRouteCluster = CRC.IdCatRouteCluster
		 Inner Join 
		 [dbo].[CatVehicle] CV  WITH (NOLOCK)
		 ON TRPH.IdCatVehicle = CV.IdVehicle 
		 Inner Join [dbo].[CatRoute] CR
		 On TRPH.IdCatRoute = CR.IdRoute
		 INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP  WITH(NOLOCK) 
		 ON [DO].[Guide_Serie] = [DOP].[GuideSerie] AND [DO].[Guide_Number]=[DOP].[GuideNumber]
	WHERE 
		[TRPD].[RowStatus] = 1
		AND
		TRPH.HasFirstPickupProcess =1 
		AND	
		[DO].[Pieces_Dry] > 1
	GROUP BY
		TRPD.GuideSerie + Convert(NVARCHAR(50),TRPD.GuideNumber),
		[TRPD].[GuideNumber]
		,[TRPD].[IDTSERoutePreparationDetail]
		,[DO].[Receiver_FirstName]
		,[DO].[Receiver_Address]
		,Upper([DO].[Receiver_Alternant_FullName])
		,SR.First_Name +' '+ SR.Last_Name
		,CV.UnitNumber+'-'+CV.Plate
		,Upper(CRC.ClusterName)
		,[CR].[CodeRoute]
	ORDER BY
		[TRPD].[GuideNumber] ASC

END;