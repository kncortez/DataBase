-- Se agregan los correos de información para los paises de Guatemala y Honduras

INSERT INTO [dbo].[ConfigParams] ([Name], [Description], [Value], [Status], [CreateDate], [IdCountry], [IdCurrencyCOD])
     VALUES
           ('SupportEmailByCountry'
           ,'Correo de información y soporte para Guatemala'
           ,'info.gt@forzadelivery.com'
           ,1
           ,GETDATE()
           ,'GT'
           ,NULL)
GO
INSERT INTO [dbo].[ConfigParams] ([Name], [Description], [Value], [Status], [CreateDate], [IdCountry], [IdCurrencyCOD])
     VALUES
           ('SupportEmailByCountry'
           ,'Correo de información y soporte para Honduras'
           ,'info.hn@forzadelivery.com'
           ,1
           ,GETDATE()
           ,'HN'
           ,NULL)
GO