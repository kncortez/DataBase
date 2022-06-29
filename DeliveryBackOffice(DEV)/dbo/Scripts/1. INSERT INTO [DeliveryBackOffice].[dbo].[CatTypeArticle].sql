
DECLARE @BoxPackageId INT = (SELECT TOP 1 CP.PckId FROM [DeliveryBackOffice].[dbo].[CatPackage] CP WITH(NOLOCK) WHERE CP.PckName = 'Caja' COLLATE Latin1_General_CI_AI);

INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeArticle]
	(TarIdPackage, TarName, TarRowStatus, TarTokenCreated, TarDateCreated)
VALUES
	(@BoxPackageId,'Paquete extra grande',1,'SYS-ARUIZ',GETDATE()),
	(@BoxPackageId,'Paquete sobredimensionado',1,'SYS-ARUIZ',GETDATE())
