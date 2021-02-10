USE [DeliveryBackOffice]
GO

CREATE TABLE [dbo].[CreditCardTransactionByCustomerDetail](
	[OrderNumber] [varchar](50) NULL,
	[ProductNumber] [int] NULL,
	[SerieNumber] [varchar](2) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NC_CreditCardTransactionByCustomerDetail] ON [dbo].[CreditCardTransactionByCustomerDetail]
(
	[OrderNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NC2_CreditCardTransactionByCustomerDetail] ON [dbo].[CreditCardTransactionByCustomerDetail]
(
	[ProductNumber] ASC
	,[SerieNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO