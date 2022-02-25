USE [DeliveryBackOffice]
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
           ('AccountBankFormatRule'
           ,23
           ,2
           ,'TRUE'
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)
GO