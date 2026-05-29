--EXEC [dbo].[GetRoutesAndGuidesFromDate] @IdManifest= 31202,@Date = '2021-07-28'

CREATE PROCEDURE [dbo].[GetRoutesAndGuidesFromDate]
	@IdManifest AS INT
	,@Date AS DATETIME
AS
BEGIN
		SELECT DAT.ID_Courier,
			   DOR.Receiver_FirstName,
			   DOR.Receiver_Address,
			   DOR.Courier_Route
			  ,DOR.Guide_Serie
			  ,DOR.Guide_Number
			  ,DOR.Pieces_Dry
			  ,DOR.PriceShippment
			  ,DOR.Collect_OnDelivery
			  ,DOR.IsCollect
		FROM
		(
			SELECT DISTINCT
				   Guide_Serie,
				   Guide_Number,
				   ID_Courier
			FROM dbo.DeliveryAttempt WITH (NOLOCK)
			WHERE CAST(Date_Created AS DATE) = CAST(@Date AS DATE)
		) DAT
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				ON DAT.Guide_Serie = DOR.Guide_Serie
				   AND DAT.Guide_Number = DOR.Guide_Number
			INNER JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail DSD
				ON DSD.Guide_Serie = DAT.Guide_Serie
				   AND DSD.Guide_Number = DAT.Guide_Number
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOS
				ON DOS.ID = DSD.ID_DeliveryOrderBySettlement
				   AND DOS.ID_Courier = DAT.ID_Courier
			LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
				ON VPC.CodeOfReference = DOR.Sender_ID
	
		WHERE DOS.ID = @IdManifest--31202
		AND DSD.RowStatus = 1
		GROUP BY DAT.ID_Courier,
				 DOR.Receiver_FirstName,
				 DOR.Receiver_Address,
				 DOR.Courier_Route
				 ,DOR.Guide_Serie
				 ,DOR.Guide_Number
				 ,DOR.Pieces_Dry
				 ,DOR.PriceShippment
				 ,DOR.Collect_OnDelivery
				 ,DOR.IsCollect
		ORDER BY DOR.Courier_Route;

	

END;