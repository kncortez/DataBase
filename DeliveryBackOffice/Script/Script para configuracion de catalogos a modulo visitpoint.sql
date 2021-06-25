USE [DeliveryBackOffice]
GO
--select * from CatalogbyModule
--select * from CatSystem
--select * from CatModule

INSERT INTO [dbo].[CatalogbyModule]
           ([NameCatalog]
           ,[ModuleID]
           ,[SystemID]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('DeliveryBank'
           ,20
           ,2
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatalogbyModule]
           ([NameCatalog]
           ,[ModuleID]
           ,[SystemID]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('DeliveryCurrency'
           ,20
           ,2
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatalogbyModule]
           ([NameCatalog]
           ,[ModuleID]
           ,[SystemID]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('BankAccountType'
           ,20
           ,2
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


INSERT INTO [dbo].[CatalogbyModule]
           ([NameCatalog]
           ,[ModuleID]
           ,[SystemID]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('HubLogistics'
           ,20
           ,2
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


INSERT INTO [dbo].[CatalogbyModule]
           ([NameCatalog]
           ,[ModuleID]
           ,[SystemID]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('TransportCompany'
           ,20
           ,2
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)


INSERT INTO [dbo].[CatalogbyModule]
           ([NameCatalog]
           ,[ModuleID]
           ,[SystemID]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Province'
           ,20
           ,2
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)


INSERT INTO [dbo].[CatalogbyModule]
           ([NameCatalog]
           ,[ModuleID]
           ,[SystemID]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Township'
           ,20
           ,2
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)


INSERT INTO [dbo].[CatalogbyModule]
           ([NameCatalog]
           ,[ModuleID]
           ,[SystemID]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Settlement'
           ,20
           ,2
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)


INSERT INTO [dbo].[CatalogbyModule]
           ([NameCatalog]
           ,[ModuleID]
           ,[SystemID]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('KindOfVPBusiness'
           ,20
           ,2
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatalogbyModule]
           ([NameCatalog]
           ,[ModuleID]
           ,[SystemID]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('KindOfVPClient'
           ,20
           ,2
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)