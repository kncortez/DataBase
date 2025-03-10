/*
En el campo Value ingresar el valor según el ambiente:
Desarrollo:       https://develop.apicore.forzadelivery.io/comprobantes/
QA:               https://sandbox.apicore.forzadelivery.io/comprobantes/
Staging:          https://staging.apicore.forzadelivery.io/Comprobantes/
Producción:       https://apicore.forzadelivery.io/comprobantes/
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
           ,'https://apicore.forzadelivery.io/comprobantes/'
           ,1
           ,GETDATE()
           ,NULL
           ,NULL)