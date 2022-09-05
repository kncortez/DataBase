USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatTypeService]
           ([CtsName]
           ,[CtsShortName]
           ,[CtsDescription]
           ,[CtsRowStatus]
           ,[CtsTokenCreated]
           ,[CtsDateCreated]
           ,[CtsTokenUpdated]
           ,[CtsDateUpdated]
           ,[RateGroup]
           ,[LimitHourDelivery]
           ,[LimitHourPickup])
     VALUES
           ('Fresh Delivery'
           ,'FDD'
           ,'Servicio de entrega refrigerado'
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL
           ,1
           ,NULL
           ,NULL)