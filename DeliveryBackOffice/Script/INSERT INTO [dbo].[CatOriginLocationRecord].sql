USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatOriginLocationRecord]
           ([OriginDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Ubicación por plataforma externa'
           ,1
           ,'SYS-ARUIZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO
INSERT INTO [dbo].[CatOriginLocationRecord]
           ([OriginDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Ubicación por SMS'
           ,1
           ,'SYS-ARUIZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO
INSERT INTO [dbo].[CatOriginLocationRecord]
           ([OriginDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Ubicación por historico de número de seguridad social'
           ,1
           ,'SYS-ARUIZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO
INSERT INTO [dbo].[CatOriginLocationRecord]
           ([OriginDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Ubicación por historico de teléfono'
           ,1
           ,'SYS-ARUIZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO