USE [DeliveryBackOffice]
GO

declare @IdEpa as int 
set @IdEpa = (select top 1 cliente.IdCustomer  from Customer cliente where cliente.Name = 'EPA GUATEMALA')

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
           (
		   'https://gt.epaenlinea.com'
           ,'EPA Sitio Web E-Commerce Guatemala'
           ,0 --si vamos a cobrar en línea
           ,'GT'
           ,''
           ,''
           ,''
           ,''
           ,''
           ,'SIEPAECOM220720202223'
           ,''
           ,'PRqNU78ln8xp1Ndp58iYQk7TwOWIhTkACUMz4phx6xO4eS3WN+QgcyXErZjFVOKc'
           ,''
           ,1
           ,'SYS-BHERRERA'
           ,getdate()
           ,null
           ,null
           ,@IdEpa )
GO

--DBCC CHECKIDENT ('dbo.Ecommerce', RESEED, 0)
--delete from Ecommerce
--select * from Ecommerce

