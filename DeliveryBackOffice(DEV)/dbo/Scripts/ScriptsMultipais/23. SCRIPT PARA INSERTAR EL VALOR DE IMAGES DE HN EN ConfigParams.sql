--SCRIPT PARA INSERTAR EL VALOR DE IMAGES DE HN EN ConfigParams

INSERT INTO [dbo].[ConfigParams]
    ([Name]
    ,[Description]
    ,[Value]
    ,[Status]
    ,[CreateDate]
    ,[IdCountry]
    ,[IdCurrencyCOD])
VALUES
    ('Images'
    ,'Ruta de portada login'
    ,'assets/images/loginHN.png'
    ,1
    ,GETDATE()
    ,'HN'
    ,NULL)

INSERT INTO [dbo].[ConfigParams]
    ([Name]
    ,[Description]
    ,[Value]
    ,[Status]
    ,[CreateDate]
    ,[IdCountry]
    ,[IdCurrencyCOD])
VALUES
    ('Images'
    ,'Ruta de banner'
    ,'assets/images/bannerHN.jpg'
    ,1
    ,GETDATE()
    ,'HN'
    ,NULL)

INSERT INTO [dbo].[ConfigParams]
    ([Name]
    ,[Description]
    ,[Value]
    ,[Status]
    ,[CreateDate]
    ,[IdCountry]
    ,[IdCurrencyCOD])
VALUES
    ('Images'
    ,'Ruta de portada login Corporativo'
    ,'assets/images/login-CorpHN.jpg'
    ,1
    ,GETDATE()
    ,'HN'
    ,NULL)