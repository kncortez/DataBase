


-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-31>
-- Description:	<Description, Detalle de manifiesto  global DE Entrega de rutas especiales>
-- =============================================
CREATE PROCEDURE [dbo].[SPHDManifestDeliveryGlobalDetailTSE]  
	
AS
BEGIN

	SELECT 
		DISTINCT 
		    TRPD.GuideSerie + CONVERT(NVARCHAR(50),TRPD.GuideNumber) Guide,
			TRPD.GuideNumber,
			TRPD.IDTSERoutePreparationDetail,
			[DO].[Receiver_FirstName] [VoteCenter],
			[DO].[Receiver_Address] [Adress],
			UPPER([DO].[Receiver_Alternant_FullName]) [Coordinador],
			SR.First_Name +' '+ SR.Last_Name [Curierman],
			CV.UnitNumber+'-'+CV.Plate Plate,
			UPPER(CRC.ClusterName) ClusterName,
			FORMAT(GETDATE(),'dd-MM-yyyyy hh:mm:ss') [DateExec],
		    CR.CodeRoute ,
			(ISNULL([DO].[Pieces_Dry], 0) + ISNULL([DO].[Pieces_Cold], 0)) TotalPieces,
			'' Pieces
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
				INNER JOIN 
		 [dbo].[SenderReceiver] SR WITH (NOLOCK)
		 ON TRPH.SenderReceiverId = SR.ID
		 INNER JOIN 
		 [dbo].[SenderReceiver] SR1 WITH (NOLOCK)
		 ON TRPH.IdRouteSupervisor = SR1.ID
		 INNER JOIN 
		 [dbo].[SenderReceiver] SR2 WITH (NOLOCK)
		 ON  TRPH.IdRouteLeader  = SR2.ID
		 INNER JOIN
		 [dbo].[CatRouteCluster] CRC WITH (NOLOCK)
		 ON   TRPH.IdCatRouteCluster = CRC.IdCatRouteCluster
		 INNER JOIN 
		 [dbo].[CatVehicle] CV  WITH (NOLOCK)
		 ON TRPH.IdCatVehicle = CV.IdVehicle 
		 INNER JOIN [dbo].[CatRoute] CR
		 ON TRPH.IdCatRoute = CR.IdRoute
	WHERE 
		--[DO].[Pieces_Dry] > 1
		--AND
		[TRPD].[RowStatus] = 1
		AND
		TRPH.HasLastDeliveryProccess  =1 
	ORDER BY
		[TRPD].[GuideNumber] ASC

END;