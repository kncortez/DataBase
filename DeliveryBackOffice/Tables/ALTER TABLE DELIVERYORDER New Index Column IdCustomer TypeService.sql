CREATE NONCLUSTERED INDEX [IX_NC_IdCustomerDeliveryOrder] ON [dbo].[DeliveryOrder]
		(
			[IdCustomer] 
		)
		
go
CREATE NONCLUSTERED INDEX [IX_NC_TypeServiceDeliveryOrder] ON [dbo].[DeliveryOrder]
		(
			TypeService 
		)
	go
