

INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           ,[CreateDate])
     VALUES
           ('DaysToExpiration'
           ,'Días de vigencia de una guia de transporte'
           ,'45'
           ,1
           ,GETDATE())


select * from dbo.ConfigParams
order by ConfigParamsId

