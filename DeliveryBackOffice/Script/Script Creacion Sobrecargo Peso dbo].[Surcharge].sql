USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[Surcharge]
           ([SurchargeName]
           ,[PercentValue]
           ,[SuchargeStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('SOBRECARGO PESO'
           ,'0'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


