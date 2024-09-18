USE [DeliveryBackOffice]
GO

DECLARE @idcustomer int = (SELECT IdCustomer FROM dbo.Customer WHERE name ='FD EXPRESS CENTER HN')


INSERT INTO [dbo].[Ecommerce]
           ([EcomerceName]
           ,[EcommerceDescription]
           ,[IsPaymentGateway]
           ,[IdCountry]
           ,[ApiWSEndPoint]
           ,[ApiWSPort]
           ,[ApiWSResource]
           ,[ApiWSController]
           ,[ApiWSMethod]
           ,[UserKey]
           ,[Passkey]
           ,[SecretKey]
           ,[CertSourceKey]
           ,[EcommerceStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdated]
           ,[IdCustomer])
     VALUES
           (N'http://forzadelivery.com/'
           ,N'Sitio Web Ecommerce Forza Delivery Honduras '
           ,1
           ,N'HN'
           ,N'https://apicore.forzadelivery.io/'
           ,N''
           ,N''
           ,N''
           ,N''
           ,N'SIFDCAPIECOM090720241050'
           ,N''
           ,N'AnvMc+t/0RswIrob9EiU6IjoK6j2wzrr1zpeXAuY80c='
           ,N''
           ,1
           ,N'SYS-TGARCIA'
           ,GETDATE()
           ,NULL
           ,NULL
           ,@idcustomer)
GO
