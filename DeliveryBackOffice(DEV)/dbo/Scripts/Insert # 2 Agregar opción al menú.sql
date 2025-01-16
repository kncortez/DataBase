
INSERT [dbo].[CatModule] ( [ModName], [ModIdModuleParent], [ModPath], [ModDescription], [ModOrder], [ModMetadata], [ModVisible], [ModRowStatus], [ModTokenCreated], [ModDateCreated], [ModTokenUpdated], [ModDateUpdated], [ModGroup]) VALUES ( N'Integraciones', 99, N'/individual/integraciones', N'Nuevo módulo individual de Integraciones', 1, N'bi bi-check2-circle', 1, 1, N'SYS-evasquez', CAST(N'2024-12-12T15:15:55.900' AS DateTime), NULL, NULL, 0)

INSERT [dbo].[CatModule] ( [ModName], [ModIdModuleParent], [ModPath], [ModDescription], [ModOrder], [ModMetadata], [ModVisible], [ModRowStatus], [ModTokenCreated], [ModDateCreated], [ModTokenUpdated], [ModDateUpdated], [ModGroup]) VALUES ( N'Integraciones', 63, N'/integraciones', N'Integraciones', 2, N'file.png', 1, 1, N'SYS-MESPINOZA', CAST(N'2022-05-24T22:39:46.200' AS DateTime), NULL, NULL, 0)

INSERT [dbo].[RolByModuleBySystem] ([RmsIdRol], [RmsIdSystem], [RmsIdModule], [RmsRowStatus], [RmsTokenCreated], [RmsDateCreated], [RmsTokenUpdated], [RmsDateUpdated], [RmsModuleMenu], [RmsHasNewFunction]) VALUES (7, 1, 133, 1, N'SYS-EVASQUEZ', CAST(N'2024-12-12T22:40:00.310' AS DateTime), NULL, NULL, NULL, NULL)
INSERT [dbo].[RolByModuleBySystem] ([RmsIdRol], [RmsIdSystem], [RmsIdModule], [RmsRowStatus], [RmsTokenCreated], [RmsDateCreated], [RmsTokenUpdated], [RmsDateUpdated], [RmsModuleMenu], [RmsHasNewFunction]) VALUES (28, 1, 132, 1, N'SYS-EVASQUEZ', CAST(N'2024-04-11T23:18:00.870' AS DateTime), NULL, NULL, NULL, NULL)


