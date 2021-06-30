USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetDeliveryExecutionReportCOD]     Script Date: 29/06/2021 17:18:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-29>
-- Description:	<Guias por pagar COD>
-- =============================================

CREATE PROCEDURE [dbo].[GetDeliveryExecutionReportCOD] 
-- Add the parameters for the stored procedure here

AS
BEGIN

	SELECT cu.[IdCustomer], cu.[Name], btd.[GuideSerie], btd.[GuideNumber], 
		(SELECT COUNT(dop.GuideNumber)
		FROM [dbo].[DeliveryOrderPiece] AS dop
		WHERE btd.[GuideSerie] = dop.[GuideSerie] AND btd.[GuideNumber] = dop.[GuideNumber]
		GROUP BY dop.[GuideNumber]
		HAVING COUNT(*) >= 1) AS Pieces,
		(SELECT SUM(dop.PieceWeight)
		FROM [dbo].[DeliveryOrderPiece] AS dop
		WHERE btd.[GuideSerie] = dop.[GuideSerie] AND btd.[GuideNumber] = dop.[GuideNumber]
		GROUP BY dop.[GuideNumber], dop.[PieceWeight]
		HAVING COUNT(*) >= 1) AS Weight,
		do.[Receiver_Department] AS Department, do.[Receiver_Town] AS Town, 
		CONCAT(do.[Receiver_FirstName], do.[Receiver_LastName]) AS Receiver, 
		do.[DateCreated], do.[Dispatched_Date], btd.[AuthorizationDate], btd.[AuthorizationNumber],
		do.[Collect_OnDelivery] AS CODAmount, do.[TypeService], do.[PriceShippment] AS ShippmentAmount, 
		btd.[Commission] AS CommissionAmount, btd.[Amount]+btd.[Commission] AS ChargedAmount,
		btd.[Amount] AS TotalAmount 
	FROM [dbo].[BatchDetailCOD] AS btd
	INNER JOIN [dbo].[ProcessedGuideCOD] AS pg 
		ON btd.[GuideSerie] = pg.[GuideSerie] AND btd.[GuideNumber] = pg.[GuideNumber]
	INNER JOIN [dbo].[DeliveryOrder] AS do 
		ON btd.[GuideSerie] = do.[Guide_Serie] AND btd.[GuideNumber] = do.[Guide_Number]
    INNER JOIN [dbo].[Customer] AS cu 
		ON do.[IdCustomer] = cu.[IdCustomer]
	WHERE MONTH(pg.[Date]) = MONTH(GETDATE())

END