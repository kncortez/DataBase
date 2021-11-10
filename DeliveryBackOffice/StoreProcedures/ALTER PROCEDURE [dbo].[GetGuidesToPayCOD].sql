USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetGuidesToPayCOD]    Script Date: 9/11/2021 09:38:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-22>
-- Description:	<Guias por pagar COD>
-- =============================================

ALTER PROCEDURE [dbo].[GetGuidesToPayCOD]
    -- Add the parameters for the stored procedure here
    @Date DATE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    SELECT bt.IdBatchCOD,
           bt.Name,
           bt.BatchNumber,
           bt.BankId,
           db.[Acronym] AS Bank,
           bt.TotalAmountIncluded,
           bt.BatchTimeRange,
           bt.Date,
           btd.AuthorizationNumber,
           btd.AuthorizationDate,
           btd.IdBatchDetailCOD,
           btd.GuideSerie,
           btd.GuideNumber,
           CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName) AS Receiver,
           IIF(cu.Name = 'FD EXPRESS CENTER', do.Sender_FirstName, cu.Name) AS Client,
           (
               SELECT TOP 1
                      dsc.[Hub]
               FROM [dbo].[DumpServiceCoverage] AS dsc
               WHERE twn.[HeaderCode] = dsc.[HeaderCode]
           ) AS Hub,
           btd.[Commission],
           do.[Collect_OnDelivery],
           btd.[Amount],
           btd.AccountNumber AS NumAccount,
           btd.AccountName AS AccountName,
           btd.TypeAccountName AS TypeAccount,
           ISNULL(vp.DescriptionOfClient, '') AS Source,
           do.Sender_FirstName AS Sender,
           CONCAT(sr.First_Name, ' ', sr.Last_Name) AS Courier,
           ISNULL(do.PriceShippment, 0) AS Price,
           ISNULL(btd.DiscountPrice, 0) AS DiscountPrice,
           (
               SELECT COUNT(1)
               FROM DeliveryOrderPiece
               WHERE GuideSerie = btd.GuideSerie
                     AND GuideNumber = btd.GuideNumber
           ) AS Pieces,
           btd.[Excluded],
           btd.CatConceptCODId,
           btd.Comments
		   ,btc.Amount Profit
		   ,(CASE WHEN vp.IdKindOfVPClient IN (2,6,8) THEN ''
			ELSE vp.DescriptionOfClient 
			END) VisitPoint
    FROM [dbo].[BatchDetailCOD] btd
        LEFT JOIN [dbo].[BatchCOD] bt
            ON btd.[BatchCODId] = bt.[IdBatchCOD]
        LEFT JOIN [dbo].[DeliveryBank] db
            ON db.Id_bank = bt.BankId
        LEFT JOIN [dbo].[DeliveryOrder] do
            ON btd.[GuideSerie] = do.[Guide_Serie]
               AND btd.[GuideNumber] = do.[Guide_Number]
        LEFT JOIN [dbo].VisitPointClient vp
            ON vp.CodeOfReference = do.Sender_ID
        LEFT JOIN [dbo].[Customer] cu
            ON ISNULL(do.[IdCustomer], vp.CustomerID) = cu.[IdCustomer]
        LEFT JOIN [dbo].[Township] twn
            ON CASE
                   WHEN do.[ReceiverIdTownship] IS NULL THEN
                   (
                       SELECT TOP 1
                              [IdTownship]
                       FROM [dbo].[Township]
                       WHERE UPPER(do.[Receiver_Town])COLLATE Latin1_General_CI_AI = UPPER([TownshipName])COLLATE Latin1_General_CI_AI
                   )
                   ELSE
                       do.[ReceiverIdTownship]
               END = twn.[IdTownship]
        LEFT JOIN [dbo].[ProcessedGuideCOD] pg
            ON btd.[GuideSerie] = pg.[GuideSerie]
               AND btd.[GuideNumber] = pg.[GuideNumber]
        LEFT JOIN [dbo].[SenderReceiver] sr
            ON pg.CourierManId = sr.ID
        LEFT JOIN [dbo].[BatchDetailCOD] btc
            ON btc.GuideSerie = btd.GuideSerie
               AND btc.GuideNumber = btd.GuideNumber
               AND btc.CatConceptCODId = 1
    WHERE
        --AND db.[Id_bank] IN ( 5, 33,31,2 ) --Banrural y BI
        CONVERT(DATE, bt.[Date]) = @Date
        AND btd.CatConceptCODId = 2
    ORDER BY bt.IdBatchCOD,
             bt.Date;

    SELECT DISTINCT
           CommissionId,
           CommissionDate
    FROM [dbo].[BatchDetailCOD]
    WHERE CONVERT(DATE, CommissionDate) = @Date
    ORDER BY CommissionId;


    SET NOCOUNT OFF;
END;
