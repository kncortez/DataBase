USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetDailyCodPayment]    Script Date: 5/07/2021 17:37:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-29>
-- Description:	<Guias por pagar COD>
-- =============================================
CREATE PROCEDURE [dbo].[GetDailyCodPayment]
-- Add the parameters for the stored procedure here
AS
BEGIN
   SELECT  DISTINCT cu.IdCustomer, cu.RegexEmail, dc.DCBA_Bank_Id
 FROM [dbo].[BatchDetailCOD] AS btd
        INNER JOIN [dbo].[ProcessedGuideCOD] AS pg
            ON btd.[GuideSerie] = pg.[GuideSerie]
               AND btd.[GuideNumber] = pg.[GuideNumber]
        INNER JOIN [dbo].[DeliveryOrder] AS do
            ON btd.[GuideSerie] = do.[Guide_Serie]
               AND btd.[GuideNumber] = do.[Guide_Number]
        LEFT JOIN dbo.Township twn
            ON twn.IdTownship = do.ReceiverIdTownship
        LEFT JOIN dbo.Township tw
            ON tw.TownshipName = do.Receiver_Town
        LEFT JOIN dbo.Province prv
            ON prv.IdProvince = twn.IdProvince
        LEFT JOIN dbo.Province pr
            ON pr.IdProvince = tw.IdProvince
        LEFT JOIN dbo.VisitPointClient vpc
            ON vpc.CodeOfReference = do.Sender_ID
        LEFT JOIN dbo.Customer cu
            ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
		LEFT JOIN dbo.DeliveryCustomerBankAccount dc ON dc.DCBA_Id = do.DCBA_ID
    WHERE pg.[Notificated] = 0
          AND btd.[AuthorizationNumber] IS NOT NULL;
END;