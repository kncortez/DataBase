USE [DeliveryBackOffice]
GO

/****** Object:  Index [idx_sendertown]    Script Date: 25/08/2021 17:54:51 ******/
CREATE NONCLUSTERED INDEX [idx_sendertown] ON [dbo].[DeliveryOrder]
(
	[Sender_Town] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO


