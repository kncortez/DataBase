
CREATE PROCEDURE [dbo].[DeliveryManifestDetailTSE]  
	@IdRoute INT
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
			Upper(CONCAT([SR].[First_Name],' ', [SR].[Last_Name])) [Courierman],
			[DO].[Pieces_Dry] + [DO].[Pieces_Cold] TotalPieces,
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
		INNER JOIN
			[DeliveryBackOffice].[dbo].[SenderReceiver] SR  WITH(NOLOCK) 
			ON
				[SR].[ID] = [TRPH].[SenderReceiverId]
	WHERE 
		--[DO].[Pieces_Dry] > 1
		--AND
		[TRPH].[IdCatRoute] = @IdRoute 
		AND 
		[TRPD].[RowStatus] = 1
		AND   TRPH.HasLastDeliveryProccess =1
	ORDER BY
		[TRPD].[GuideNumber] ASC

END;