USE [DeliveryBackOffice]
GO
SET IDENTITY_INSERT [dbo].[CatValueType] ON 
GO
INSERT [dbo].[CatValueType] ([IdCatValueType], [ValueTypeName], [ValueTypeDescription], [RowStatus], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated]) VALUES (1, N'Porcentaje', N'%', 1, CAST(N'2022-05-25T10:29:00.000' AS DateTime), N'SYS-ARUIZ', NULL, NULL)
GO
INSERT [dbo].[CatValueType] ([IdCatValueType], [ValueTypeName], [ValueTypeDescription], [RowStatus], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated]) VALUES (2, N'Monto', N'Q', 1, CAST(N'2022-05-25T10:29:00.000' AS DateTime), N'SYS-ARUIZ', NULL, NULL)
GO
INSERT [dbo].[CatValueType] ([IdCatValueType], [ValueTypeName], [ValueTypeDescription], [RowStatus], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated]) VALUES (3, N'Servicio', N'Guia', 1, CAST(N'2022-05-25T10:30:00.000' AS DateTime), N'SYS-ARUIZ', NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[CatValueType] OFF
GO
