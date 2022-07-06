DECLARE @SmallPackageId INT =	(SELECT TOP 1 CA.ArtId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) WHERE CA.ArtName = 'Paquete pequeño' COLLATE Latin1_General_CI_AI);

UPDATE
	CA
SET
	CA.ArtHeight = 28
	,CA.ArtWidth = 28
	,CA.ArtLength = 28
	,CA.ArtMassWeight = 10
	,CA.ArtTokenUpdated = 'SYS-ARUIZ'
	,CA.ArtDateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK)
WHERE
	CA.ArtId = @SmallPackageId

UPDATE
	ABC
SET
	ABC.Height = 28
	,ABC.Width = 28
	,ABC.Length = 28
	,ABC.MassWeight = 10
	,ABC.AbcTokenUpdated = 'SYS-ARUIZ'
	,ABC.AbcDateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
WHERE
	ABC.AbcIdArticle = @SmallPackageId
	AND
	ABC.Code = 'EXP076' COLLATE Latin1_General_CI_AI