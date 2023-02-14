INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
	(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated, ModTokenUpdated, ModDateUpdated, ModGroup)
VALUES
	('Hermes Charge Service', NULL, 'Windows Service', 'Windows Service', 1, NULL, 0, 1, 'SYS-ARUIZ', GETDATE(), NULL, NULL, NULL)