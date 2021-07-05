USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spcod_get_customer_daily_delivery]    Script Date: 5/07/2021 17:41:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-29>
-- Description:	<Guias por pagar COD>
-- =============================================
CREATE PROCEDURE [dbo].[spcod_get_customer_daily_delivery]
-- Add the parameters for the stored procedure here
AS
BEGIN
    SELECT DISTINCT
           ISNULL(ord.IdCustomer, vpc.CustomerID) idcustomer,
           cs.RegexEmail
    FROM dbo.DeliveryOrderDetail dt
        LEFT JOIN dbo.DeliveryOrder ord
            ON ord.Guide_Serie = dt.Guide_Serie
               AND ord.Guide_Number = dt.Guide_Number
        LEFT JOIN dbo.VisitPointClient vpc
            ON vpc.CodeOfReference = ord.Sender_ID
        LEFT JOIN dbo.Customer cs
            ON cs.IdCustomer = ISNULL(ord.IdCustomer, vpc.CustomerID)
    WHERE dt.StatusOrderId = 5
	      AND ord.StatusOrderId NOT IN (7,15)
          AND CONVERT(DATE, dt.DateCreated) = CONVERT(DATE, GETDATE());
END;