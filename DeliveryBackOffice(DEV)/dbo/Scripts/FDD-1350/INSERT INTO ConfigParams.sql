/*
En el campo Value ingresar el valor según el ambiente:
Desarrollo:       develop.apicore.forzadelivery.io/comprobantes/
QA:               sandbox.apicore.forzadelivery.io/comprobantes/
Staging:          staging.apicore.forzadelivery.io/comprobantes/
Producción:       apicore.forzadelivery.io/comprobantes/
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
           ,'Carpeta para Almacenar las firmas que se mostraran en los comprobantes digitales del módulo de reimpresión de comprobantes'
           ,'develop.apicore.forzadelivery.io/comprobantes/'
           ,1
           ,GETDATE()
           ,NULL
           ,NULL)