/*  Nuevas Suscripciones */
  -- PAQUETE MICRO
  -- PAQUETE FLEXI

INSERT [dbo].[CatSubscription] ( [SubscriptionName], [SubscriptionDescription], [SubscriptionCost], [SubscriptionFixedValue], [SubscriptionMaxServiceFixedValue], [SubscriptionValidity], [SubscriptionWeight], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [Icon], [NextSalesPackageBanner], [RateHeaderId], [AlternativeRateHeaderId], [IncludedMembershipId], [CatTypeSubscriptionId], [CatProductCategoryId], [Tag], [Position], [IdCountry], [IdCatCurrencyCOD]) VALUES ( N'Paquete MICRO', N'15 envíos Q36.00 c/u', CAST(540.00 AS Decimal(18, 2)), 0, 15, 6, 5, 1, N'SYS-EVASQUEZ', CAST(N'2025-01-31T20:03:00.337' AS DateTime), NULL, NULL, N'hwa-planProIcon', N'bannerSubsPlan4.png', NULL, NULL, NULL, 2, 2, N'NOVEDADES', 1, N'GT', 1)



INSERT [dbo].[CatSubscription] ( [SubscriptionName], [SubscriptionDescription], [SubscriptionCost], [SubscriptionFixedValue], [SubscriptionMaxServiceFixedValue], [SubscriptionValidity], [SubscriptionWeight], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [Icon], [NextSalesPackageBanner], [RateHeaderId], [AlternativeRateHeaderId], [IncludedMembershipId], [CatTypeSubscriptionId], [CatProductCategoryId], [Tag], [Position], [IdCountry], [IdCatCurrencyCOD]) VALUES ( N'Paquete FLEXI', N'300 envíos Q26.00 c/u', CAST(7800.00 AS Decimal(18, 2)), 0, 300, 6, 5, 1, N'SYS-EVASQUEZ', CAST(N'2025-01-31T20:03:00.337' AS DateTime), NULL, NULL, N'hwa-planProIcon', N'bannerSubsPlan4.png', NULL, NULL, NULL, 2, 2, N'NOVEDADES', 1, N'GT', 1)