INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           ,[CreateDate]
           ,[IdCountry]
           ,[IdCurrencyCOD])
     VALUES
           ('CreateUser'
           ,'Nombre del archivo html'
           ,'EstablecerContrasena.html'
           ,1
           ,GETDATE()
           ,NULL
           ,NULL)
GO