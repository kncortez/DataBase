-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-29>
-- Description:	<Guias por pagar COD>
-- =============================================
CREATE PROCEDURE [dbo].[spcod_get_customer_daily_delivery]
-- Add the parameters for the stored procedure here
AS
BEGIN

	DECLARE @Debug BIT	 = 'false'

    SELECT DISTINCT TOP 2 
           ISNULL(ord.IdCustomer, vpc.CustomerID) idcustomer,
           --IIF(@Debug ='true', 'envios.parser4@gmail.com', COALESCE(ord.Sender_Mail, cs.CODContactEmail,cs.RegexEmail))
           'juan.ramirez@forzadelivery.com' RegexEmail
    FROM dbo.DeliveryOrderDetail dt
        LEFT JOIN dbo.DeliveryOrder ord
            ON ord.Guide_Serie = dt.Guide_Serie
               AND ord.Guide_Number = dt.Guide_Number
        LEFT JOIN dbo.VisitPointClient vpc
            ON vpc.CodeOfReference = ord.Sender_ID
        LEFT JOIN dbo.Customer cs
            ON cs.IdCustomer = ISNULL(ord.IdCustomer, vpc.CustomerID)
		LEFT JOIN ProcessedGuideCOD PC ON dt.Guide_Number = pc.GuideNumber and dt.Guide_Serie = pc.GuideSerie and pc.Notificated = 0
    WHERE dt.StatusOrderId IN (5,22)
	      AND ord.StatusOrderId NOT IN (7,15)
          AND CONVERT(DATE, dt.DateCreated) = CONVERT(DATE, GETDATE())
		  AND PC.Notificated = 0
		  AND PC.BatchCODId IS NOT NULL
		 
END;




