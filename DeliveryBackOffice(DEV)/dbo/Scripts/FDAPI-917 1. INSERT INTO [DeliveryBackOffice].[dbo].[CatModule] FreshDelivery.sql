
IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Fresh Delivery App' COLLATE Latin1_General_CI_AI AND CM.ModRowStatus = 1))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
		(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated)
	VALUES
		('Fresh Delivery App', NULL, '', 'Módulo de app de cliente para Fresh Delivery', 1, '', 0, 1, 'SYS-ARUIZ', GETDATE())

END