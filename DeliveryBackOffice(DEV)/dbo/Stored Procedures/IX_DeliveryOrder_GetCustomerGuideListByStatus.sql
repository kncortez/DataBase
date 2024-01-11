--Delete index to prevent error
DROP INDEX IF EXISTS [IX_DeliveryOrder_GetCustomerGuideListByStatus] ON [DeliveryBackOffice].[dbo].[DeliveryOrder]
GO

--Index creation
CREATE NONCLUSTERED INDEX [IX_DeliveryOrder_GetCustomerGuideListByStatus] ON [DeliveryBackOffice].[dbo].[DeliveryOrder] 
(
	[IdCustomer] ASC,
	[DateCreated] ASC,
	[StatusOrderId] ASC
)
INCLUDE (
	[Sender_ID],
	[Sender_FirstName],
	[Sender_LastName],
	[Receiver_FirstName],
	[Receiver_LastName],
	[Receiver_Department]
)
GO