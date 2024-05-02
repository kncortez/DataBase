
-- =============================================
-- Author:		<Edelman>
-- Create date: <30-04-2024>
-- Description:	<Datos de reporte de pago COD para sistema de  tracking (WebPage)>
-- =============================================
CREATE PROCEDURE [dbo].[SpwPaymentsCodReportsRpt] 
@Manifest_Serie NVARCHAR(5)='PC',
@Manifest_Number INT

AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT  	
			 Ctm.[Name],
			 Serv.Guide_Serie + CONVERT(VARCHAR,Serv.Guide_Number) Guide,
			 Serv.Receiver_Town Town,
			 Serv.Receiver_Department,
			 Serv.Receiver_Zone,
			 Serv.Receiver_Phone,
			 Serv.Receiver_FirstName + ' ' + Serv.Receiver_LastName ReceiverName,
			 ISNULL(Settlement_Collect_OnDelivery,0) CollectOnDelivery,
			 CASE
			      WHEN Serv.IsCollect = 1 THEN 'Destino' 
				  WHEN Serv.IsCollect = 0 THEN 'Origen' 
				  ELSE '' END IsCollected,
			 ISNULL(Serv.PriceShippment,0) PriceShippment
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpclient WITH (NOLOCK)
			ON serv.Sender_ID = vpclient.CodeOfReference		
		INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det WITH (NOLOCK)
		    ON serv.Guide_Serie = Det.Guide_Serie
		   AND serv.Guide_Number = Det.Guide_Number
		INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] Head WITH (NOLOCK)
            ON   Det.ID_DeliveryOrderBySettlement = Head.ID
		INNER JOIN DeliveryBackOffice.dbo.Customer Ctm  WITH (NOLOCK)
		    ON Ctm.IdCustomer = vpclient.CustomerID
		INNER JOIN DeliveryBackOffice.DBO.DeliveryOrderPaid paidguide WITH (NOLOCK)
			ON paidguide.Guide_Serie = serv.Guide_Serie
			AND paidguide.Guide_Number = serv.Guide_Number   		
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaidHeader oph  WITH (NOLOCK)
		    ON oph.IdDeliveryOrderPaid=paidguide.IdDeliveryOrderPaidHeader
		WHERE 
		serv.StatusOrderId <> 7 --No esté anulada la guía
		AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0
		AND serv.Dispatched_Date IS NOT NULL --La guía debe haber sido despachada
		AND oph.Manifest_Serie  =  @Manifest_Serie
		AND oph.Manifest_Number =  @Manifest_Number


   
END
GO




