USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[SegmentArea]
           ([NameSegmentOfArea]
           ,[Abrevation]
           ,[SegmentDescription]
           ,[SegmentStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[IdTypeOfSegment])
     VALUES
           ('LOCAL'
           ,'LOCAL'
           ,'DE 1 A 20 KMS'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL
           ,2)
GO

INSERT INTO [dbo].[SegmentArea]
           ([NameSegmentOfArea]
           ,[Abrevation]
           ,[SegmentDescription]
           ,[SegmentStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[IdTypeOfSegment])
     VALUES
           ('ZONA A'
           ,'A'
           ,'DE 21 A 100 KMS'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL
           ,2)
GO

INSERT INTO [dbo].[SegmentArea]
           ([NameSegmentOfArea]
           ,[Abrevation]
           ,[SegmentDescription]
           ,[SegmentStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[IdTypeOfSegment])
     VALUES
           ('ZONA B'
           ,'B'
           ,'DE 101 A 200 KMS'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL
           ,2)
GO



INSERT INTO [dbo].[SegmentArea]
           ([NameSegmentOfArea]
           ,[Abrevation]
           ,[SegmentDescription]
           ,[SegmentStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[IdTypeOfSegment])
     VALUES
           ('ZONA C'
           ,'C'
           ,'DE 201 A 300 KMS'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL
           ,2)
GO

INSERT INTO [dbo].[SegmentArea]
           ([NameSegmentOfArea]
           ,[Abrevation]
           ,[SegmentDescription]
           ,[SegmentStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[IdTypeOfSegment])
     VALUES
           ('ZONA D'
           ,'D'
           ,'MAS DE 300 KMS'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL
           ,2)
GO


