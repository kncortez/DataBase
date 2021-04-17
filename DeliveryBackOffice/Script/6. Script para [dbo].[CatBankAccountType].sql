USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatBankAccountType]
           ([BankAccountType]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('AHORRO'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


INSERT INTO [dbo].[CatBankAccountType]
           ([BankAccountType]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('MONETARIA'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


SELECT * FROM [dbo].[CatBankAccountType]