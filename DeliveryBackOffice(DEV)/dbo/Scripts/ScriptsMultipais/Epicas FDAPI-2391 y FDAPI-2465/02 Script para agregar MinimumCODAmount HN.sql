--SCRIPT PARA INSERTAR EL VALOR DE MinimumCODAmount DE HN EN ConfigParams

INSERT INTO [dbo].[ConfigParams]
    ([Name]
    ,[Description]
    ,[Value]
    ,[Status]
    ,[CreateDate]
    ,[IdCountry]
    ,[IdCurrencyCOD])
VALUES
    ('MinimumCODAmount'
    ,'Monto minimo de COD permitido en la generación de una guía'
    ,'90'
    ,1
    ,GETDATE()
    ,'HN'
    ,NULL)
