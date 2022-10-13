IF( EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsName = 'Estándar' COLLATE Latin1_General_CI_AI) )
BEGIN

	UPDATE
		[DeliveryBackOffice].[dbo].[CatTypeService]
	SET
		CtsShortName = 'STD',
		CtsTokenUpdated = 'SYS-ARUIZ',
		CtsDateUpdated = GETDATE()
	WHERE
		CtsName = 'Estándar'
		AND
		CtsShortName = 'EST'
		AND
		CtsTokenCreated = 'SYS-ARUIZ'
	
END

IF( EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsName = 'Estándar CoD' COLLATE Latin1_General_CI_AI) )
BEGIN

	UPDATE
		[DeliveryBackOffice].[dbo].[CatTypeService]
	SET
		CtsName = 'Estándar COD',
		CtsShortName = 'COD',
		CtsTokenUpdated = 'SYS-ARUIZ',
		CtsDateUpdated = GETDATE()
	WHERE
		CtsName = 'Estándar CoD'
		AND
		CtsShortName = 'ECOD'
		AND
		CtsTokenCreated = 'SYS-ARUIZ'
END

--SELECT * FROM [DeliveryBackOffice].[dbo].[CatTypeService]