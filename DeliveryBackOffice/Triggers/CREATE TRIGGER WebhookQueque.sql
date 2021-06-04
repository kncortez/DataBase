CREATE TRIGGER WebhookQueque
ON DeliveryBackOffice.dbo.DeliveryOrderDetail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO DeliveryBackOffice.dbo.WebhookTrackingQueue(
		    [Guide_Serie]
           ,[Guide_Number]
           ,[IdCustomer]
           ,[Status]
           ,[WebhookEndpointId]
           ,[HasNotified]
           ,[ChangedDate]
    )
    SELECT
		 i.Guide_Serie
        ,i.Guide_Number
        ,do.IdCustomer
        ,i.StatusOrderId
        ,we.WebhookEndpointId
		,0
		,GETDATE()
    FROM
        inserted i
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do ON i.Guide_Serie = do.Guide_Serie AND i.Guide_Number = do.Guide_Number
		--INNER JOIN DeliveryBackOffice.dbo.Ecommerce e ON do.EcommerceId = e.IdEcommerce AND e.EcommerceStatus = 1
		INNER JOIN DeliveryBackOffice.dbo.WebhookEndpoint we ON do.IdEcommerce = we.IdEcommerce AND do.IdCustomer = we.IdCustomer AND we.RowStatus = 1
	
END