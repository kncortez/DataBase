IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsName = 'Estandar' COLLATE Latin1_General_CI_AI) )
BEGIN
	INSERT INTO
		[DeliveryBackOffice].[dbo].[CatTypeService]
		(CtsName, CtsShortName, CtsDescription, CtsRowStatus, CtsTokenCreated, CtsDateCreated, RateGroup)
	VALUES
		('Estandar', 'EST', 'Servicio de entrega estandar', 1, 'SYS-ARUIZ', GETDATE(), 1)
END

IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsName = 'Estandar CoD' COLLATE Latin1_General_CI_AI) )
BEGIN
	INSERT INTO
		[DeliveryBackOffice].[dbo].[CatTypeService]
		(CtsName, CtsShortName, CtsDescription, CtsRowStatus, CtsTokenCreated, CtsDateCreated, RateGroup)
	VALUES
		('Estandar CoD', 'ECOD', 'Servicio de entrega estandar con CoD', 1, 'SYS-ARUIZ', GETDATE(), 1)
END

--SELECT * FROM [DeliveryBackOffice].[dbo].[CatTypeService]