USE [DeliveryBackOffice]
GO

IF (NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[ConfigParams] CP WITH(NOLOCK) WHERE CP.[Name] = 'MundialPromo' COLLATE Latin1_General_CI_AI))
BEGIN
	INSERT INTO [dbo].[ConfigParams]
			   ([Name]
			   ,[Description]
			   ,[Value]
			   ,[Status]
			   ,[CreateDate])
		 VALUES
			   ('MundialPromo'
			   ,'Promo del mundial al crear usuarios'
			   ,'1'
			   ,1
			   ,GETDATE())


END