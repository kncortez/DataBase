DECLARE @MediumPackageId INT =	(SELECT TOP 1 CA.ArtId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) WHERE CA.ArtName = 'Paquete mediano' COLLATE Latin1_General_CI_AI);

UPDATE
	CA
SET
	CA.ArtHeight = 35
	,CA.ArtWidth = 35
	,CA.ArtLength = 35
	,CA.ArtTokenUpdated = 'SYS-ARUIZ'
	,CA.ArtDateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK)
WHERE
	CA.ArtId = @MediumPackageId

UPDATE
	ABC
SET
	ABC.Height = 35
	,ABC.Width = 35
	,ABC.Length = 35
	,ABC.AbcTokenUpdated = 'SYS-ARUIZ'
	,ABC.AbcDateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
WHERE
	ABC.AbcIdArticle = @MediumPackageId
	AND
	ABC.Code = 'EXP077' COLLATE Latin1_General_CI_AI