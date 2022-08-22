IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsName = 'Estándar' COLLATE Latin1_General_CI_AI) )
BEGIN
	INSERT INTO
		[DeliveryBackOffice].[dbo].[CatTypeService]
		(CtsName, CtsShortName, CtsDescription, CtsRowStatus, CtsTokenCreated, CtsDateCreated, RateGroup)
	VALUES
		('Estándar', 'EST', 'Servicio de entrega estándar', 1, 'SYS-ARUIZ', GETDATE(), 1)
END

IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsName = 'Estándar CoD' COLLATE Latin1_General_CI_AI) )
BEGIN
	INSERT INTO
		[DeliveryBackOffice].[dbo].[CatTypeService]
		(CtsName, CtsShortName, CtsDescription, CtsRowStatus, CtsTokenCreated, CtsDateCreated, RateGroup)
	VALUES
		('Estándar CoD', 'ECOD', 'Servicio de entrega estándar con CoD', 1, 'SYS-ARUIZ', GETDATE(), 1)
END

--SELECT * FROM [DeliveryBackOffice].[dbo].[CatTypeService]