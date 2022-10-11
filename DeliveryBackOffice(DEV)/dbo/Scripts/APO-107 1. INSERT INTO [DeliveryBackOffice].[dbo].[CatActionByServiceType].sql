IF (
	NOT EXISTS (
		SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatActionByServiceType] CABST WITH(NOLOCK) 
		WHERE 
			CABST.ActionName = 'Delivered' COLLATE Latin1_General_CI_AI 
			AND 
			CABST.ServiceType = 'DELIVERY' COLLATE Latin1_General_CI_AI
	)
)
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[CatActionByServiceType]
		(ActionName, ServiceType, DateCreatead, TokenCreated)
	VALUES
		('Delivered', 'DELIVERY', GETDATE(), 'SYS-ARUIZ')
END

IF (
	NOT EXISTS (
		SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatActionByServiceType] CABST WITH(NOLOCK) 
		WHERE 
			CABST.ActionName = 'Returned' COLLATE Latin1_General_CI_AI 
			AND 
			CABST.ServiceType = 'RETURN' COLLATE Latin1_General_CI_AI
	)
)
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[CatActionByServiceType]
		(ActionName, ServiceType, DateCreatead, TokenCreated)
	VALUES
		('Returned', 'RETURN', GETDATE(), 'SYS-ARUIZ')
END

IF (
	NOT EXISTS (
		SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatActionByServiceType] CABST WITH(NOLOCK) 
		WHERE 
			CABST.ActionName = 'MissingPackage' COLLATE Latin1_General_CI_AI 
			AND 
			CABST.ServiceType = 'DELIVERY' COLLATE Latin1_General_CI_AI
	)
)
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[CatActionByServiceType]
		(ActionName, ServiceType, DateCreatead, TokenCreated)
	VALUES
		('MissingPackage', 'DELIVERY', GETDATE(), 'SYS-ARUIZ')
END

IF (
	NOT EXISTS (
		SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatActionByServiceType] CABST WITH(NOLOCK) 
		WHERE 
			CABST.ActionName = 'MissingPackage' COLLATE Latin1_General_CI_AI 
			AND 
			CABST.ServiceType = 'RETURN' COLLATE Latin1_General_CI_AI
	)
)
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[CatActionByServiceType]
		(ActionName, ServiceType, DateCreatead, TokenCreated)
	VALUES
		('MissingPackage', 'RETURN', GETDATE(), 'SYS-ARUIZ')
END

IF (
	NOT EXISTS (
		SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatActionByServiceType] CABST WITH(NOLOCK) 
		WHERE 
			CABST.ActionName = 'TransferedEXC' COLLATE Latin1_General_CI_AI 
			AND 
			CABST.ServiceType = 'DELIVERY' COLLATE Latin1_General_CI_AI
	)
)
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[CatActionByServiceType]
		(ActionName, ServiceType, DateCreatead, TokenCreated)
	VALUES
		('TransferedEXC', 'DELIVERY', GETDATE(), 'SYS-ARUIZ')
END

IF (
	NOT EXISTS (
		SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatActionByServiceType] CABST WITH(NOLOCK) 
		WHERE 
			CABST.ActionName = 'TransferedEXC' COLLATE Latin1_General_CI_AI 
			AND 
			CABST.ServiceType = 'RETURN' COLLATE Latin1_General_CI_AI
	)
)
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[CatActionByServiceType]
		(ActionName, ServiceType, DateCreatead, TokenCreated)
	VALUES
		('TransferedEXC', 'RETURN', GETDATE(), 'SYS-ARUIZ')
END

IF (
	NOT EXISTS (
		SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatActionByServiceType] CABST WITH(NOLOCK) 
		WHERE 
			CABST.ActionName = 'Incidence' COLLATE Latin1_General_CI_AI 
			AND 
			CABST.ServiceType = 'DELIVERY' COLLATE Latin1_General_CI_AI
	)
)
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[CatActionByServiceType]
		(ActionName, ServiceType, DateCreatead, TokenCreated)
	VALUES
		('Incidence', 'DELIVERY', GETDATE(), 'SYS-ARUIZ')
END


IF (
	NOT EXISTS (
		SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatActionByServiceType] CABST WITH(NOLOCK) 
		WHERE 
			CABST.ActionName = 'Incidence' COLLATE Latin1_General_CI_AI 
			AND 
			CABST.ServiceType = 'RETURN' COLLATE Latin1_General_CI_AI
	)
)
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[CatActionByServiceType]
		(ActionName, ServiceType, DateCreatead, TokenCreated)
	VALUES
		('Incidence', 'RETURN', GETDATE(), 'SYS-ARUIZ')
END


IF (
	NOT EXISTS (
		SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatActionByServiceType] CABST WITH(NOLOCK) 
		WHERE 
			CABST.ActionName = 'Incidence' COLLATE Latin1_General_CI_AI 
			AND 
			CABST.ServiceType = 'PICKUP' COLLATE Latin1_General_CI_AI
	)
)
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[CatActionByServiceType]
		(ActionName, ServiceType, DateCreatead, TokenCreated)
	VALUES
		('Incidence', 'PICKUP', GETDATE(), 'SYS-ARUIZ')
END

