INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           ,[CreateDate]
           ,[IdCountry]
           ,[IdCurrencyCOD])
     VALUES
           ('PathSignatureImage'
           ,'Carpeta para Almacenar las firmas que se mostraran en los comprobantes digitales del modulo de reimpresión de comprobantes'
           ,'develop.apicore.forzadelivery.io/images/comprobantes/'
           ,1
           ,GETDATE()
           ,NULL
           ,NULL)