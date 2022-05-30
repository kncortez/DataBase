USE [DeliveryBackOffice]
GO
SET IDENTITY_INSERT [dbo].[CatPromo] ON 
GO
INSERT [dbo].[CatPromo] ([IdPromo], [PromoDescription], [PromoWeight], [StartPromoDate], [FinishPromoDate], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday], [CatValueTypeId], [PromoValue], [CatDiscountTypeId], [RowStatus], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated], [LimitPromoTime]) VALUES (1, N'Guías a 2x1', 10, CAST(N'2022-05-01T00:00:00.000' AS DateTime), CAST(N'2022-05-31T23:59:59.000' AS DateTime), 0, 0, 0, 1, 0, 0, 1, 1, CAST(100.00 AS Decimal(5, 2)), 2, 1, CAST(N'2022-05-25T00:00:00.000' AS DateTime), N'SYS-ARUIZ', NULL, NULL, CAST(24.00 AS Decimal(6, 2)))
GO
INSERT [dbo].[CatPromo] ([IdPromo], [PromoDescription], [PromoWeight], [StartPromoDate], [FinishPromoDate], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday], [CatValueTypeId], [PromoValue], [CatDiscountTypeId], [RowStatus], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated], [LimitPromoTime]) VALUES (2, N'Segunda guía a mitad de precio', 10, CAST(N'2022-05-01T00:00:00.000' AS DateTime), CAST(N'2022-05-31T23:59:59.000' AS DateTime), 0, 0, 0, 0, 1, 0, 1, 1, CAST(50.00 AS Decimal(5, 2)), 2, 1, CAST(N'2022-05-25T00:00:00.000' AS DateTime), N'SYS-ARUIZ', NULL, NULL, CAST(24.00 AS Decimal(6, 2)))
GO
SET IDENTITY_INSERT [dbo].[CatPromo] OFF
GO
SET IDENTITY_INSERT [dbo].[PromoCoverage] ON 
GO
INSERT [dbo].[PromoCoverage] ([IdPromoCoverage], [CatPromoId], [CustomerId], [VisitPointClientId], [CustomerTypeId], [RowStatus], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated]) VALUES (1, 1, NULL, NULL, 2, 1, CAST(N'2022-05-25T00:00:00.000' AS DateTime), N'SYS-ARUIZ', NULL, NULL)
GO
INSERT [dbo].[PromoCoverage] ([IdPromoCoverage], [CatPromoId], [CustomerId], [VisitPointClientId], [CustomerTypeId], [RowStatus], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated]) VALUES (2, 2, NULL, NULL, 2, 1, CAST(N'2022-05-25T00:00:00.000' AS DateTime), N'SYS-ARUIZ', NULL, NULL)
GO
INSERT [dbo].[PromoCoverage] ([IdPromoCoverage], [CatPromoId], [CustomerId], [VisitPointClientId], [CustomerTypeId], [RowStatus], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated]) VALUES (3, 2, NULL, NULL, 3, 1, CAST(N'2022-05-25T00:00:00.000' AS DateTime), N'SYS-ARUIZ', NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[PromoCoverage] OFF
GO
