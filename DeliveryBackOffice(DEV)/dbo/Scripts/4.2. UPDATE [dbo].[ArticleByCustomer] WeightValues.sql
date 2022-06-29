
-- Artículos
DECLARE @SmallPackageId INT =	(SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete pequeño' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP076' COLLATE Latin1_General_CI_AI);
DECLARE @MediumPackageId INT =	(SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete mediano' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP077' COLLATE Latin1_General_CI_AI);
DECLARE @BigPackageId INT =		(SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete grande' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP078' COLLATE Latin1_General_CI_AI);
	
UPDATE
	ABC
SET
	ABC.MassWeight = 5
	,ABC.AbcTokenUpdated = 'SYS-ARUIZ'
	,ABC.AbcDateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
WHERE
	ABC.AbcId = @SmallPackageId

UPDATE
	ABC
SET
	ABC.MassWeight = 20
	,ABC.AbcTokenUpdated = 'SYS-ARUIZ'
	,ABC.AbcDateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
WHERE
	ABC.AbcId = @MediumPackageId

UPDATE
	ABC
SET
	ABC.MassWeight = 40
	,ABC.AbcTokenUpdated = 'SYS-ARUIZ'
	,ABC.AbcDateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
WHERE
	ABC.AbcId = @BigPackageId