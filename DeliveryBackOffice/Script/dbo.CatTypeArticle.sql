
DECLARE @BoxPackageId INT = (SELECT TOP 1 CP.PckId FROM [DeliveryBackOffice].[dbo].[CatPackage] CP WITH(NOLOCK) WHERE CP.PckName = 'Caja' COLLATE Latin1_General_CI_AI);
DECLARE @FolderPackageId INT = (SELECT TOP 1 CP.PckId FROM [DeliveryBackOffice].[dbo].[CatPackage] CP WITH(NOLOCK) WHERE CP.PckName = 'Sobre' COLLATE Latin1_General_CI_AI);
	
INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeArticle]
	(TarIdPackage, TarName, TarRowStatus, TarTokenCreated, TarDateCreated)
VALUES
	(@BoxPackageId,'Paquete pequeño',1,'SYS-ARUIZ',GETDATE()),
	(@BoxPackageId,'Paquete mediano',1,'SYS-ARUIZ',GETDATE()),
	(@BoxPackageId,'Paquete grande',1,'SYS-ARUIZ',GETDATE())

UPDATE
	[DeliveryBackOffice].[dbo].[CatTypeArticle]
SET
	TarIdPackage = @BoxPackageId
	,TarTokenUpdated = 'SYS-ARUIZ'
	,TarDateUpdated = GETDATE()
WHERE
	TarName = 'Caja' COLLATE Latin1_General_CI_AI

UPDATE
	[DeliveryBackOffice].[dbo].[CatTypeArticle]
SET
	TarIdPackage = @FolderPackageId
	,TarTokenUpdated = 'SYS-ARUIZ'
	,TarDateUpdated = GETDATE()
WHERE
	TarName = 'Sobre' COLLATE Latin1_General_CI_AI