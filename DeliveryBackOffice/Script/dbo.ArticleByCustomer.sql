
DECLARE @SmallPackageId INT =	(SELECT TOP 1 CA.ArtId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) WHERE CA.ArtName = 'Paquete pequeño' COLLATE Latin1_General_CI_AI);
DECLARE @MediumPackageId INT =	(SELECT TOP 1 CA.ArtId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) WHERE CA.ArtName = 'Paquete mediano' COLLATE Latin1_General_CI_AI);
DECLARE @BigPackageId INT =		(SELECT TOP 1 CA.ArtId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) WHERE CA.ArtName = 'Paquete grande' COLLATE Latin1_General_CI_AI);
	
INSERT INTO [DeliveryBackOffice].[dbo].[ArticleByCustomer]
	(AbcIdArticle, AbcRowStatus, AbcDateCreated, AbcTokenCreated, Code, PriceDefault, Height, Width, Length)
VALUES
	(@SmallPackageId, 1, GETDATE(), 'SYS-ARUIZ', 'EXP076', 0, 30, 20, 10),
	(@MediumPackageId, 1, GETDATE(), 'SYS-ARUIZ', 'EXP077', 0, 40, 30, 20),
	(@BigPackageId, 1, GETDATE(), 'SYS-ARUIZ', 'EXP078', 0, 50, 40, 30)