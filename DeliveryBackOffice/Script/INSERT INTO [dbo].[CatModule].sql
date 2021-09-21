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
           ('Confirmación de Entrega'
           ,NULL
           ,'Confirmación de Entrega'
           ,'Módulo en el que se confirma la entrega de guías'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)
GO