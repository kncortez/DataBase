USE [DeliveryBackOffice]
GO

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
           ('http://forzadelivery.com/'
           ,'Sitio Web Ecommerce Forza Delivery '
           ,'TRUE'
           ,'GT'
           ,'sandbox.forza.systems'
           ,'40467'
           ,''
           ,''
           ,''
           ,'SIFDCAPIECOM300720201459'
           ,''
           ,'quHvvZWgP5UQ0ZCHvRwYUNSaF+8YKP7cQr57cv8xSgFowxH6z37nX46t47Ktjykf'
           ,''
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL
           ,6
		   )
GO
