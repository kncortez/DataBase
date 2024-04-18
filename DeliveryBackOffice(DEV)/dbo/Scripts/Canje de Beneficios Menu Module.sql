-----Modulo

GO
INSERT [dbo].[CatModule] ( [ModName], [ModIdModuleParent], [ModPath], [ModDescription], [ModOrder], [ModMetadata], [ModVisible], [ModRowStatus], [ModTokenCreated], [ModDateCreated], [ModTokenUpdated], [ModDateUpdated], [ModGroup]) VALUES (N'Canje de Beneficios', NULL, N'/individual/centro-canje', N'Canje de Beneficios', 100, N'fa bi bi-shop-window fa-1x', 1, 1, N'evasquez', CAST(N'2022-12-22T13:23:21.510' AS DateTime), NULL, NULL, 0)
GO
INSERT [dbo].[CatModule] ( [ModName], [ModIdModuleParent], [ModPath], [ModDescription], [ModOrder], [ModMetadata], [ModVisible], [ModRowStatus], [ModTokenCreated], [ModDateCreated], [ModTokenUpdated], [ModDateUpdated], [ModGroup]) VALUES (N'Canje de Beneficios', NULL, N'/express/centro-canje', N'Canje de Beneficios express center ', 45, N'fa bi bi-shop-window fa-1x', 1, 1, N'evasquez', CAST(N'2024-01-06T00:39:59.723' AS DateTime), NULL, NULL, 1)
GO


--- rol aquí tiene que ir en este campo: [RmsIdModule] que se insertan  en la tabla CatModulo

DECLARE @IDMODULE INT =(select * from dbo.catmodule WHERE ModDescription='Canje de Beneficios' and ModPath='/individual/centro-canje');
DECLARE @IDMODULEEXC INT =(select modidmodule from  dbo.catmodule WHERE ModDescription='Canje de Beneficios express center ' and ModPath='/express/centro-canje');

INSERT [dbo].[RolByModuleBySystem] ([RmsIdRol], [RmsIdSystem], [RmsIdModule], [RmsRowStatus], [RmsTokenCreated], [RmsDateCreated], [RmsTokenUpdated], [RmsDateUpdated], [RmsModuleMenu], [RmsHasNewFunction]) VALUES (5, 1,@IDMODULEEXC, 1, N'evasquez', CAST(N'2024-01-05T19:01:07.360' AS DateTime), NULL, NULL, NULL, NULL)

INSERT [dbo].[RolByModuleBySystem] ([RmsIdRol], [RmsIdSystem], [RmsIdModule], [RmsRowStatus], [RmsTokenCreated], [RmsDateCreated], [RmsTokenUpdated], [RmsDateUpdated], [RmsModuleMenu], [RmsHasNewFunction]) VALUES (28, 1, @IDMODULE, 1, N'evasquez', CAST(N'2024-01-31T00:00:00.000' AS DateTime), NULL, NULL, 1, NULL)
