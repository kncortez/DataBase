USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatBatchTypeCOD]
           ([Name]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Acumulado'
           ,1
           ,'MJIMENEZ-SYS'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatBatchTypeCOD]
           ([Name]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Detallado'
           ,1
           ,'MJIMENEZ-SYS'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


