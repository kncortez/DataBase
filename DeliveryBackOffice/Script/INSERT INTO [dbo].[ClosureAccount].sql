USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[ClosureAccount]
           ([AccountNumber]
		   ,[Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('066'
		   ,'Cuenta Express Center'
           ,'Cuenta Express Center'
           ,1
           ,'SYS-ORODRIGUEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[ClosureAccount]
           ([AccountNumber]
		   ,[Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('113'
		   ,'Cuenta Área COD'
           ,'Cuenta Área COD'
           ,1
           ,'SYS-ORODRIGUEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO