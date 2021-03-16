
USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[RatebyCustomer]
           ([RbcIdRate]
           ,[RbcIdCustomer]
           ,[RbcRowStatus]
           ,[RbcTokenCreated]
           ,[RbcDateCreated]
			)
     VALUES
           (3
           ,81
           ,1
           ,'SYS-CAQUINO'
           ,GETDATE()
			)
GO



select * from dbo.RatebyCustomer 