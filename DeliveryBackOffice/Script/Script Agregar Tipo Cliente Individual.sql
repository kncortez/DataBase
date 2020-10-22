USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CustomerType]
           ([Description]
           ,[CustomerTypeStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdated])
     VALUES
           ('INDIVIDUAL'
           ,'true'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


