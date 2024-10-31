/*
En el campo Value ingresar el valor según el ambiente:
Desarrollo:       develop.apicore.forzadelivery.io/images/comprobantes/
QA:               sandbox.apicore.forzadelivery.io/images/comprobantes/
Producción:       apicore.forzadelivery.io/images/comprobantes/
*/

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