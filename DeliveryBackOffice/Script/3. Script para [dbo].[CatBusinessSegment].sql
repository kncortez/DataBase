USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatBusinessSegment]
           ([BusinessSegmentName]
           ,[BusinessSegmentDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('EMPRENDIMIENTO'
           ,'Hasta 4 personas'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatBusinessSegment]
           ([BusinessSegmentName]
           ,[BusinessSegmentDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('MICRO EMPRESA'
           ,'Hasta 10 Personas'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


INSERT INTO [dbo].[CatBusinessSegment]
           ([BusinessSegmentName]
           ,[BusinessSegmentDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('PEQUEÑA EMPRESA'
           ,'Entre 11 Y 50 Personas'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


INSERT INTO [dbo].[CatBusinessSegment]
           ([BusinessSegmentName]
           ,[BusinessSegmentDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('MEDIANA EMPRESA'
           ,'Entre 51 Y 200 Personas'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO



INSERT INTO [dbo].[CatBusinessSegment]
           ([BusinessSegmentName]
           ,[BusinessSegmentDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('GRANDE EMPRESA'
           ,'Mas de 201 Personas'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO



INSERT INTO [dbo].[CatBusinessSegment]
           ([BusinessSegmentName]
           ,[BusinessSegmentDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('CORPORACION'
           ,'Mas de 250 Personas'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

SELECT * FROM  [dbo].[CatBusinessSegment]

