USE [DeliveryBackOffice]
GO

/****** Object:  Index [NonClusteredIndex-20241126]    Script Date: 26/11/2024 20:04:15 ******/
CREATE NONCLUSTERED INDEX [IDX_IdLinehaulRoutePreparation] ON [dbo].[LinehaulRoutePreparation]
(
	[IdLinehaulRoutePreparation] ASC,
	[CatLinehaulStatusId] ASC,
	[RowStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


