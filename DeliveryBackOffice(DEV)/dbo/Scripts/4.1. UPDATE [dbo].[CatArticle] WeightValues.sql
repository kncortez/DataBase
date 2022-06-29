
DECLARE @SmallPackageId INT =	(SELECT TOP 1 CA.ArtId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) WHERE CA.ArtName = 'Paquete pequeño' COLLATE Latin1_General_CI_AI);
DECLARE @MediumPackageId INT =	(SELECT TOP 1 CA.ArtId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) WHERE CA.ArtName = 'Paquete mediano' COLLATE Latin1_General_CI_AI);
DECLARE @BigPackageId INT =		(SELECT TOP 1 CA.ArtId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) WHERE CA.ArtName = 'Paquete grande' COLLATE Latin1_General_CI_AI);
	
UPDATE
	CA
SET
	CA.ArtMassWeight = 5
	,CA.ArtTokenUpdated = 'SYS-ARUIZ'
	,CA.ArtDateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[CatArticle] CA
WHERE
	CA.ArtId = @SmallPackageId
	
UPDATE
	CA
SET
	CA.ArtMassWeight = 20
	,CA.ArtTokenUpdated = 'SYS-ARUIZ'
	,CA.ArtDateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[CatArticle] CA
WHERE
	CA.ArtId = @MediumPackageId
	
UPDATE
	CA
SET
	CA.ArtMassWeight = 40
	,CA.ArtTokenUpdated = 'SYS-ARUIZ'
	,CA.ArtDateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[CatArticle] CA
WHERE
	CA.ArtId = @BigPackageId