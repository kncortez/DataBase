USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[WebhookRestrinctionByUser]
           ([IdCustomer]
           ,[WebhookTypeId]
           ,[Name]
           ,[Description]
           ,[StatusOrderId]
           ,[StatusInternalName]
           ,[StatusExternalName]
           ,[StatusRow]
           ,[CreatedToken]
           ,[CreatedDate]
          )
     VALUES
           (312
           ,1
           ,'Status'
           ,'se limitan los estados'
           ,5
           ,'Entregado'
           ,'Entregado al Cliente'
           ,1
           ,'SYS-MJIMENEZ'
           ,GETDATE()
          )
GO


