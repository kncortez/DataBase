IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH(NOLOCK) WHERE CP.[Name] = 'DelayTracking' COLLATE Latin1_General_CI_AI))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           ,[CreateDate]
           ,[IdCountry]
           ,[IdCurrencyCOD])
     VALUES
           ('DelayTracking'
           ,'Duración de retardo en minutos para Tracking'
           ,5
           ,1
           ,GETDATE()
           ,'GT'
           ,NULL);

END
