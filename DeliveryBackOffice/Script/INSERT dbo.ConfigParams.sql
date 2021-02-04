USE [DeliveryBackOffice]
GO
/*
INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           )
     VALUES
           ('ResetPassword','Nombre del archivo html','ResetPassword.html ',1)
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
           ('PROD','Producción','https://forzadelivery.com',1)
GO

INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           )
     VALUES
           ('EmailFrom','Email del cual se enviarán los correos','bWFqaW1lbmV6bXRAZ21haWwuY29t',1)
GO

INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           )
     VALUES
           ('Host','Host del cual se enviarán los correos','c210cC5nbWFpbC5jb20=',1)
GO

INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           )
     VALUES
           ('Port','Puerto del cual se enviarán los correos','NTg3',1)
GO

INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           )
     VALUES
           ('Password','Password del usuario de email donde se enviarán los correos','YmRnc2EqKio=',1)
GO

INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           )
     VALUES
           ('SetNewPassword','Nombre del archivo html','UpdateNewPassword.html ',1)
GO
*/

INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           )
     VALUES
           ('SetConfirmationEmail','Nombre del archivo html','ValidarCorreo.html ',1)
GO

INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           )
     VALUES
           ('SetConfirmationAccount','Nombre del archivo html','CorreoConfirmado.html ',1)
GO


