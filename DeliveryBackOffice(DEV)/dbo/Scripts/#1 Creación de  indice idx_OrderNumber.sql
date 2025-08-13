
/****** Object:  Index [idx_OrderNumber]    Script Date: 31/07/2025 12:31:51 ******/
CREATE NONCLUSTERED INDEX [idx_OrderNumber] ON [dbo].[RegistrationofTransactionProcessStates]
(
	[OrderNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]



