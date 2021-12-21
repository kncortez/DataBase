USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetRoutesAndGuidesFromDate]    Script Date: 20/12/2021 14:33:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC [dbo].[GetRoutesAndGuidesFromDate] @IdManifest= 31202,@Date = '2021-07-28'

ALTER PROCEDURE [dbo].[GetRoutesAndGuidesFromDate]
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
			FROM dbo.DeliveryAttempt
			WHERE CAST(Date_Created AS DATE) = CAST(@Date AS DATE)
		) DAT
			JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR
				ON DAT.Guide_Serie = DOR.Guide_Serie
				   AND DAT.Guide_Number = DOR.Guide_Number
				   --AND DOR.StatusOrderId IN ( 4, 5, 12 )
			JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail DSD
				ON DSD.Guide_Serie = DAT.Guide_Serie
				   AND DSD.Guide_Number = DAT.Guide_Number
				   AND DSD.RowStatus = 1
			JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOS
				ON DOS.ID = DSD.ID_DeliveryOrderBySettlement
				   AND DOS.ID_Courier = DAT.ID_Courier
			LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
				ON VPC.CodeOfReference = DOR.Sender_ID
			--WHERE DOR.Courier_Route IN (SELECT * FROM (VALUES ('UGUA007'),('UGUA077') )AS RouteValue(routeName)) -- DOR.Courier_Route LIKE'%UGUA%'
		WHERE DOS.ID = @IdManifest--31202
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