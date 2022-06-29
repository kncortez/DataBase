
DECLARE @ExtraBigPackageId INT =		(SELECT TOP 1 CA.ArtId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) WHERE CA.ArtName = 'Paquete extra grande' COLLATE Latin1_General_CI_AI);
DECLARE @OversizedPackageId INT =		(SELECT TOP 1 CA.ArtId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) WHERE CA.ArtName = 'Paquete sobredimensionado' COLLATE Latin1_General_CI_AI);

INSERT INTO [DeliveryBackOffice].[dbo].[ArticleByCustomer]
	(AbcIdArticle, AbcRowStatus, AbcDateCreated, AbcTokenCreated, Code, PriceDefault, Height, Width, Length, MassWeight)
VALUES
	(@ExtraBigPackageId, 1, GETDATE(), 'SYS-ARUIZ', 'EXP079', 0, 30, 40, 50, 50),
	(@OversizedPackageId, 1, GETDATE(), 'SYS-ARUIZ', 'EXP080', 0, 30, 40, 50, 60)