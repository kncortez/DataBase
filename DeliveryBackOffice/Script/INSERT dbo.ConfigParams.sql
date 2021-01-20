USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           )
     VALUES
           ('HTML_ResetPassword','Nombre del archivo html','ResetPassword.html ',1)
GO

INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           )
     VALUES
           ('DEV','Desarrollo','https://develop.forzadelivery.com',1)
GO

INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           )
     VALUES
           ('STG','Staging','https://qa.forzadelivery.com',1)
GO

INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           )
     VALUES
           ('PROD','Producción','https://forzadelivery.com ',1)
GO



