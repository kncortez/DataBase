CREATE NONCLUSTERED INDEX [IX_NC_IdCustomersByGuideDeliveryOrder] ON [dbo].[DeliveryOrder]
		(
			[IdCustomer] ,
			[Guide_Serie] ,
			[Guide_Number] 
		)
		
go
CREATE NONCLUSTERED INDEX [IX_NC_TypeServiceDeliveryOrder] ON [dbo].[DeliveryOrder]
		(
			TypeService 
		)
	go
