USE [DeliveryBackOffice]
GO
SET IDENTITY_INSERT [dbo].[CatStatusType] ON 
GO
INSERT [dbo].[CatStatusType] ([IdCatStatusType], [StatusType], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated]) VALUES (1, N'Interno', 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL)
GO
INSERT [dbo].[CatStatusType] ([IdCatStatusType], [StatusType], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated]) VALUES (2, N'Externo', 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[CatStatusType] OFF
GO
