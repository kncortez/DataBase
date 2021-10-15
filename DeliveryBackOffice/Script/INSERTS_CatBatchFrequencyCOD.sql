USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatBatchFrequencyCOD]
           ([Name]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Inmediata'
           ,1
           ,'MJIMENEZ-SYS'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatBatchFrequencyCOD]
           ([Name]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Diaria'
           ,1
           ,'MJIMENEZ-SYS'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


