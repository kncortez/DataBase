USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatServiceStatus]
           ([Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Cancelado'
           ,NULL
           ,1
           ,'SYS-OSCAR'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

