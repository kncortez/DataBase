USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Emisión de Facturas' 
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Facturación' AND ModDescription = 'Menu')
           ,'FrmBilling'
           ,'Módulo de facturación'
           ,1
           ,null
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,null
           ,null)
GO


