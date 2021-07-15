USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetGuidesToPayCOD]    Script Date: 15/07/2021 10:25:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-22>
-- Description:	<Guias por pagar COD>
-- =============================================

CREATE PROCEDURE [dbo].[GetGuidesToPayCOD] 
-- Add the parameters for the stored procedure here
	@Date DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT bt.IdBatchCOD,bt.Name, bt.BatchNumber, db.[Acronym] AS Bank, bt.TotalAmountIncluded, btd.AuthorizationNumber, btd.AuthorizationDate, 
	btd.IdBatchDetailCOD, btd.GuideSerie, btd.GuideNumber, ISNULL(do.Receiver_FirstName,'')+' '+ISNULL(do.Receiver_LastName, '') AS Receiver, 
	cu.Name As Client, (SELECT TOP 1 dsc.[Hub] FROM [dbo].[DumpServiceCoverage] AS dsc WHERE twn.[HeaderCode] = dsc.[HeaderCode]) AS Hub, btd.[Commission], 
	do.[Collect_OnDelivery], btd.[Amount], ISNULL(sr.First_Name,'')+' '+ISNULL(sr.Last_Name,'') AS Courier, btd.[Excluded]
	FROM [dbo].[BatchDetailCOD] btd
	INNER JOIN [dbo].[BatchCOD] bt ON btd.[BatchCODId] = bt.[IdBatchCOD]
	INNER JOIN [dbo].[DeliveryBank] db ON btd.[BankId] = db.[Id_bank]
	INNER JOIN [dbo].[DeliveryOrder] do ON btd.[GuideSerie] = do.[Guide_Serie] AND btd.[GuideNumber] = do.[Guide_Number]
	INNER JOIN [dbo].[Customer] cu ON do.[IdCustomer] = cu.[IdCustomer]
	INNER JOIN [dbo].[Township] twn ON do.[ReceiverIdTownship] = twn.[IdTownship]
	INNER JOIN [dbo].[ProcessedGuideCOD] pg ON btd.[GuideSerie] = pg.[GuideSerie] AND btd.[GuideNumber] = pg.[GuideNumber]
	INNER JOIN [dbo].[SenderReceiver] sr ON pg.[CourierManId] = sr.[ID]
	WHERE db.[Id_bank] IN (5,33) --Banrural y BI
		AND CONVERT(DATE,bt.[Date]) = @Date

	SET NOCOUNT OFF;
END