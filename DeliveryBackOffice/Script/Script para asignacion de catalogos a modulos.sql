USE [DeliveryBackOffice]
GO

declare @IdModuleBP as int = (SELECT top 1 mdl.ModIdModule FROM CatModule MDL WHERE MDL.ModPath = 'FrmBusinessPartner')
declare @IdModuleRT as int = (SELECT top 1 mdl.ModIdModule FROM CatModule MDL WHERE MDL.ModPath = 'FrmRate')

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
           ('SaleAdvisor'
           ,@IdModuleBP 
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
           ('TypeOfBusiness'
           ,@IdModuleBP
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
           ('BusinessSegment'
           ,@IdModuleBP
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
           ('BusinessActivity'
           ,@IdModuleBP
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
           ('CommercialSegment'
           ,@IdModuleBP
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
           ('ConditionOfPayment'
           ,@IdModuleBP
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
           ('DeliveryBank'
           ,@IdModuleBP
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
           ('DeliveryCurrency'
           ,@IdModuleBP
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
           ('BankAccountType'
           ,@IdModuleBP
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
           ('RateType'
           ,@IdModuleRT
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
           ('RateCatalog'
           ,@IdModuleRT
           ,2
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)	


select * from [CatalogbyModule]