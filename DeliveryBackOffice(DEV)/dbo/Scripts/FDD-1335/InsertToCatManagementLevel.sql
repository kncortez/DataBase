USE [DeliveryBackOffice]
GO

-- INSERT INTO [dbo].[CatManagementLevel]  Rango jerárquico para desbloqueo de rutas según su valor

INSERT INTO [dbo].[CatManagementLevel] ([ManagementLevelName],[MinAmount],[MaxAmount],[RowStatus],[DateCreated],[TokenCreated],[DateUpdated],[TokenUpdated]) VALUES (N'Supervisor', 0.00, 300.00, 1, GETDATE(), N'SYS-TGARCIA',NULL,NULL)
INSERT INTO [dbo].[CatManagementLevel] ([ManagementLevelName],[MinAmount],[MaxAmount],[RowStatus],[DateCreated],[TokenCreated],[DateUpdated],[TokenUpdated]) VALUES (N'Jefe', 301.00, 800.00, 1, GETDATE(), N'SYS-TGARCIA',NULL,NULL)
INSERT INTO [dbo].[CatManagementLevel] ([ManagementLevelName],[MinAmount],[MaxAmount],[RowStatus],[DateCreated],[TokenCreated],[DateUpdated],[TokenUpdated]) VALUES (N'Subgerente', 801.00, 3000.00, 1, GETDATE(), N'SYS-TGARCIA',NULL,NULL)
INSERT INTO [dbo].[CatManagementLevel] ([ManagementLevelName],[MinAmount],[MaxAmount],[RowStatus],[DateCreated],[TokenCreated],[DateUpdated],[TokenUpdated]) VALUES (N'Subgerente', 3001.00, NULL, 1, GETDATE(), N'SYS-TGARCIA',NULL,NULL)

-- INSERT INTO [dbo].[CatManifestSettlementIncidenceType] Incidencias registradas en el proceso de liquidación

INSERT INTO [dbo].[CatManifestSettlementIncidenceType]([Category],[Type],[RowStatus],[DateCreated],[TokenCreated],[DateUpdated],[TokenUpdated]) VALUES (N'Liquidación de ruta de despacho de última milla', N'Paquete extraviado',1, GETDATE(), N'SYS-TGARCIA',NULL,NULL)
INSERT INTO [dbo].[CatManifestSettlementIncidenceType]([Category],[Type],[RowStatus],[DateCreated],[TokenCreated],[DateUpdated],[TokenUpdated]) VALUES (N'Liquidación de COD', N'Asalto o robo',1, GETDATE(), N'SYS-TGARCIA',NULL,NULL)
INSERT INTO [dbo].[CatManifestSettlementIncidenceType]([Category],[Type],[RowStatus],[DateCreated],[TokenCreated],[DateUpdated],[TokenUpdated]) VALUES (N'Liquidación de COD', N'Estafa',1, GETDATE(), N'SYS-TGARCIA',NULL,NULL)
INSERT INTO [dbo].[CatManifestSettlementIncidenceType]([Category],[Type],[RowStatus],[DateCreated],[TokenCreated],[DateUpdated],[TokenUpdated]) VALUES (N'Liquidación de COD', N'Extravio de dinero',1, GETDATE(), N'SYS-TGARCIA',NULL,NULL)

-- INSERT INTO [dbo].[ManagementLevelByUser] Usuario con su nivel jerárquico para desbloquear rutas

-------- NOTA IMPORTANTE. se tiene que llenar el token del usuario que va a validar en el campo TokenValidator según el ambiente en que se utilice. -----------------------------------------------

INSERT INTO [dbo].[ManagementLevelByUser]([TokenValidator],[CatManagementLevelId],[RowStatus],[DateCreated],[TokenCreated],[DateUpdated],[TokenUpdated]) VALUES (N'',1,1,GETDATE(), N'SYS-TGARCIA', NULL, NULL)