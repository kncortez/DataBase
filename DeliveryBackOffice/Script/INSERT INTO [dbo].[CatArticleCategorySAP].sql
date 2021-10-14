USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatArticleCategorySAP]
           ([Name]
           ,[Description]
           ,[RowSatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('GUÍA'
           ,'TRANSPORTE DE PAQUETES'
           ,1
           ,'SYS-ADMIN'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatArticleCategorySAP]
           ([Name]
           ,[Description]
           ,[RowSatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('OTROS'
           ,'OTROS'
           ,1
           ,'SYS-ADMIN'
           ,GETDATE()
           ,NULL
           ,NULL)
        
GO