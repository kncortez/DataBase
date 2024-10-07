USE [DeliveryBackOffice]
GO

-- INSERT INTO [dbo].[CatManagementLevel]  Rango jerárquico para desbloqueo de rutas según su valor

INSERT INTO [dbo].[CatManagementLevel] ([ManagementLevelName],[MinAmount],[MaxAmount],[RowStatus],[DateCreated],[TokenCreated],[DateUpdated],[TokenUpdated]) VALUES (N'Supervisor', 0.00, 300.00, 1, GETDATE(), N'SYS-TGARCIA',NULL,NULL)
INSERT INTO [dbo].[CatManagementLevel] ([ManagementLevelName],[MinAmount],[MaxAmount],[RowStatus],[DateCreated],[TokenCreated],[DateUpdated],[TokenUpdated]) VALUES (N'Jefe', 301.00, 800.00, 1, GETDATE(), N'SYS-TGARCIA',NULL,NULL)
INSERT INTO [dbo].[CatManagementLevel] ([ManagementLevelName],[MinAmount],[MaxAmount],[RowStatus],[DateCreated],[TokenCreated],[DateUpdated],[TokenUpdated]) VALUES (N'Subgerente', 801.00, 3000.00, 1, GETDATE(), N'SYS-TGARCIA',NULL,NULL)
INSERT INTO [dbo].[CatManagementLevel] ([ManagementLevelName],[MinAmount],[MaxAmount],[RowStatus],[DateCreated],[TokenCreated],[DateUpdated],[TokenUpdated]) VALUES (N'Gerente', 3001.00, 100000.00, 1, GETDATE(), N'SYS-TGARCIA',NULL,NULL)

-- INSERT INTO [dbo].[CatTypeIncidence] Incidencias registradas en el proceso de liquidación

INSERT INTO [dbo].[CatTypeIncidence] ([NameIncidence],[DescriptionIncidence],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ServiceType],[OrderId],[Code],[IncidenceClasificationId],[IsForcedIncidence],[ValidatesLocation]
           ,[HasConfirmationProcess],[NotifiesOrigin],[NameIncidencePublic],[EvidenceRequirement],[CourierInstructions],[CountryId])
     VALUES ( N'Paquete extraviado', N'Paquete extraviado',1,N'SYS-TGARCIA',GETDATE(),NULL,NULl,N'LAST MILE SETTLEMENT',1,NULL,3,0,0,0,0,NULL,NULL,NULL,N'GT')
INSERT INTO [dbo].[CatTypeIncidence] ([NameIncidence],[DescriptionIncidence],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ServiceType],[OrderId],[Code],[IncidenceClasificationId],[IsForcedIncidence],[ValidatesLocation]
           ,[HasConfirmationProcess],[NotifiesOrigin],[NameIncidencePublic],[EvidenceRequirement],[CourierInstructions],[CountryId])
     VALUES ( N'Asalto o robo', N'Asalto o robo',1,N'SYS-TGARCIA',GETDATE(),NULL,NULl,N'COD SETTLEMENT',1,NULL,3,0,0,0,0,NULL,NULL,NULL,N'GT')
INSERT INTO [dbo].[CatTypeIncidence] ([NameIncidence],[DescriptionIncidence],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ServiceType],[OrderId],[Code],[IncidenceClasificationId],[IsForcedIncidence],[ValidatesLocation]
           ,[HasConfirmationProcess],[NotifiesOrigin],[NameIncidencePublic],[EvidenceRequirement],[CourierInstructions],[CountryId])
     VALUES ( N'Estafa', N'Estafa',1,N'SYS-TGARCIA',GETDATE(),NULL,NULl,N'COD SETTLEMENT',1,NULL,3,0,0,0,0,NULL,NULL,NULL,N'GT')
INSERT INTO [dbo].[CatTypeIncidence] ([NameIncidence],[DescriptionIncidence],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ServiceType],[OrderId],[Code],[IncidenceClasificationId],[IsForcedIncidence],[ValidatesLocation]
           ,[HasConfirmationProcess],[NotifiesOrigin],[NameIncidencePublic],[EvidenceRequirement],[CourierInstructions],[CountryId])
     VALUES ( N'Extravio de dinero', N'Extravio de dinero',1,N'SYS-TGARCIA',GETDATE(),NULL,NULl,N'COD SETTLEMENT',1,NULL,3,0,0,0,0,NULL,NULL,NULL,N'GT')
INSERT INTO [dbo].[CatTypeIncidence] ([NameIncidence],[DescriptionIncidence],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ServiceType],[OrderId],[Code],[IncidenceClasificationId],[IsForcedIncidence],[ValidatesLocation]
           ,[HasConfirmationProcess],[NotifiesOrigin],[NameIncidencePublic],[EvidenceRequirement],[CourierInstructions],[CountryId])
     VALUES ( N'Paquete extraviado', N'Paquete extraviado para honduras',1,N'SYS-TGARCIA',GETDATE(),NULL,NULl,N'LAST MILE SETTLEMENT',1,NULL,3,0,0,0,0,NULL,NULL,NULL,N'HN')
INSERT INTO [dbo].[CatTypeIncidence] ([NameIncidence],[DescriptionIncidence],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ServiceType],[OrderId],[Code],[IncidenceClasificationId],[IsForcedIncidence],[ValidatesLocation]
           ,[HasConfirmationProcess],[NotifiesOrigin],[NameIncidencePublic],[EvidenceRequirement],[CourierInstructions],[CountryId])
     VALUES ( N'Asalto o robo', N'Asalto o robo para honduras',1,N'SYS-TGARCIA',GETDATE(),NULL,NULl,N'COD SETTLEMENT',1,NULL,3,0,0,0,0,NULL,NULL,NULL,N'HN')
INSERT INTO [dbo].[CatTypeIncidence] ([NameIncidence],[DescriptionIncidence],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ServiceType],[OrderId],[Code],[IncidenceClasificationId],[IsForcedIncidence],[ValidatesLocation]
           ,[HasConfirmationProcess],[NotifiesOrigin],[NameIncidencePublic],[EvidenceRequirement],[CourierInstructions],[CountryId])
     VALUES ( N'Estafa', N'Estafa para honduras',1,N'SYS-TGARCIA',GETDATE(),NULL,NULl,N'COD SETTLEMENT',1,NULL,3,0,0,0,0,NULL,NULL,NULL,N'HN')
INSERT INTO [dbo].[CatTypeIncidence] ([NameIncidence],[DescriptionIncidence],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ServiceType],[OrderId],[Code],[IncidenceClasificationId],[IsForcedIncidence],[ValidatesLocation]
           ,[HasConfirmationProcess],[NotifiesOrigin],[NameIncidencePublic],[EvidenceRequirement],[CourierInstructions],[CountryId])
     VALUES ( N'Extravio de dinero', N'Extravio de dinero para honduras',1,N'SYS-TGARCIA',GETDATE(),NULL,NULl,N'COD SETTLEMENT',1,NULL,3,0,0,0,0,NULL,NULL,NULL,N'HN')

-- INSERT INTO [dbo].[ManagementLevelByUser] Usuario con su nivel jerárquico para desbloquear rutas

-------- NOTA IMPORTANTE. se tiene que llenar el ID del usuario que va a validar en el campo [RegisterUserId] según el ambiente en que se utilice. -----------------------------------------------

INSERT INTO [dbo].[ManagementLevelByUser]([RegisterUserId],[CatManagementLevelId],[RowStatus],[DateCreated],[TokenCreated],[DateUpdated],[TokenUpdated]) VALUES (123,1,1,GETDATE(), N'SYS-TGARCIA', NULL, NULL)