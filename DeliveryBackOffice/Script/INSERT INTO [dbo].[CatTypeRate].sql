USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatTypeRate]
           ([Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Por Peso'
           ,'Tarifas por peso'
           ,'TRUE'
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)