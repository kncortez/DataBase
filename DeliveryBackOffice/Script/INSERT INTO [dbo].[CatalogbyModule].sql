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
           ,22
           ,2
           ,'TRUE'
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)
GO