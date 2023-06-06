IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP  WITH(NOLOCK) WHERE [CP].[Name] = 'CodeApp'  COLLATE Latin1_General_CI_AI  ) )
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigParams]
	(
		[Name],
		[Description],
		[Value],
		[Status],
		[CreateDate]
	)
	VALUES
	(	
		'CodeApp',     -- Name - varchar(500)
		'CodeApp registrado para uso de llamadas a API desde sistemas internos.',   -- Description - varchar(max)
		'SIFDCECOM300720201459',     -- Value - varchar(max)
		1,      -- Status - smallint
		GETDATE() -- CreateDate - datetime
	)
END
IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP  WITH(NOLOCK) WHERE [CP].[Name] = 'SecretKey'  COLLATE Latin1_General_CI_AI  ) )
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigParams]
	(
		[Name],
		[Description],
		[Value],
		[Status],
		[CreateDate]
	)
	VALUES
	(	
		'SecretKey',     -- Name - varchar(500)
		'Llave secreta a utilizar para llamadas a API desde sistemas internos.',   -- Description - varchar(max)
		'BmkDVQY3xHG88ChnZ9HKqSEafjNGWJ4p',     -- Value - varchar(max)
		1,      -- Status - smallint
		GETDATE() -- CreateDate - datetime
	)
END
IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP  WITH(NOLOCK) WHERE [CP].[Name] = 'APIUrl'  COLLATE Latin1_General_CI_AI  ) )
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigParams]
	(
		[Name],
		[Description],
		[Value],
		[Status],
		[CreateDate]
	)
	VALUES
	(	
		'APIUrl',     -- Name - varchar(500)
		'Dirección base de API Forza Delivery para uso de llamadas a API desde sistemas internos.',   -- Description - varchar(max)
		'https://develop.forza.systems:40466/api.forzadelivery/',     -- Value - varchar(max)
		1,      -- Status - smallint
		GETDATE() -- CreateDate - datetime
	)
END