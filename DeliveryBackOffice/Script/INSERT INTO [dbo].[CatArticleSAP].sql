USE [DeliveryBackOffice]
GO
		   
DECLARE @CategoryGuide INT = (SELECT IdCatCategoryArticleSAP FROM CatArticleCategorySAP WHERE Name = 'GUÍA')
DECLARE @CategoryOther INT = (SELECT IdCatCategoryArticleSAP FROM CatArticleCategorySAP WHERE Name = 'OTROS')

INSERT INTO [dbo].[CatArticleSAP]
           ([CatCategoryArticleSAPId]
           ,[Name]
           ,[Description]
           ,[SAPCode]
           ,[RowSatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           (@CategoryGuide
           ,'NDD'
           ,'NextDay'
           ,'S04001'
           ,1
           ,'SYS-ADMIN'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatArticleSAP]
           ([CatCategoryArticleSAPId]
           ,[Name]
           ,[Description]
           ,[SAPCode]
           ,[RowSatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           (@CategoryGuide
           ,'SDD'
           ,'SameDay'
           ,'S04002'
           ,1
           ,'SYS-ADMIN'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatArticleSAP]
           ([CatCategoryArticleSAPId]
           ,[Name]
           ,[Description]
           ,[SAPCode]
           ,[RowSatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           (@CategoryGuide
           ,'TDA'
           ,'TDA'
           ,'S04003'
           ,1
           ,'SYS-ADMIN'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatArticleSAP]
           ([CatCategoryArticleSAPId]
           ,[Name]
           ,[Description]
           ,[SAPCode]
           ,[RowSatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           (@CategoryOther
           ,'SERVICIOS INTERNACIONALES'
           ,'SERVICIOS INTERNACIONALES'
           ,'S04004'
           ,1
           ,'SYS-ADMIN'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatArticleSAP]
           ([CatCategoryArticleSAPId]
           ,[Name]
           ,[Description]
           ,[SAPCode]
           ,[RowSatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           (@CategoryOther
           ,'OTROS'
           ,'OTROS'
           ,'S04005'
           ,1
           ,'SYS-ADMIN'
           ,GETDATE()
           ,NULL
           ,NULL)
GO
