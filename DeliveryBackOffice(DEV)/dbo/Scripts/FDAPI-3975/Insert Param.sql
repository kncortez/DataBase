USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           ,[CreateDate]
           ,[IdCountry]
           ,[IdCurrencyCOD])
     VALUES
           ('BaseURL'
           ,'Base para URL que muestra el comprobante de entrega escaneado'
           ,'https://tracking.forzadelivery.com'
           ,1
           ,GETDATE()
           ,NULL
           ,NULL)
GO
