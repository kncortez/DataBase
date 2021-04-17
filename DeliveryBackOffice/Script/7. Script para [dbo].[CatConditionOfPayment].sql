USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatConditionOfPayment]
           ([ConditionOfPayment]
           ,[ConditionOfPaymenDescription]
           ,[ConditionOfPaymenAbbreviation]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('CONTADO'
           ,'Cancelación inmediata'
           ,'CONTADO'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO



INSERT INTO [dbo].[CatConditionOfPayment]
           ([ConditionOfPayment]
           ,[ConditionOfPaymenDescription]
           ,[ConditionOfPaymenAbbreviation]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('CREDITO 7 DIAS'
           ,'Crédito menor igual a 7 dias'
           ,'CREDITO7'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


INSERT INTO [dbo].[CatConditionOfPayment]
           ([ConditionOfPayment]
           ,[ConditionOfPaymenDescription]
           ,[ConditionOfPaymenAbbreviation]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('CREDITO 10 DIAS'
           ,'Crédito menor igual a 10 dias'
           ,'CREDITO10'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


INSERT INTO [dbo].[CatConditionOfPayment]
           ([ConditionOfPayment]
           ,[ConditionOfPaymenDescription]
           ,[ConditionOfPaymenAbbreviation]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('CREDITO 15 DIAS'
           ,'Crédito menor igual a 15 dias'
           ,'CREDITO15'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


INSERT INTO [dbo].[CatConditionOfPayment]
           ([ConditionOfPayment]
           ,[ConditionOfPaymenDescription]
           ,[ConditionOfPaymenAbbreviation]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('CREDITO 30 DIAS'
           ,'Crédito menor igual a 30 dias'
           ,'CREDITO30'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

select * from [dbo].[CatConditionOfPayment]
