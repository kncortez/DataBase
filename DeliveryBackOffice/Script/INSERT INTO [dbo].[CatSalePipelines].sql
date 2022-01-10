USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatSalePipelines]
           ([Name]
           ,[ShortName]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Concesionario'
           ,'CNC'
           ,'Concesionario'
           ,1
           ,'SYS-FMONTERROSO'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


