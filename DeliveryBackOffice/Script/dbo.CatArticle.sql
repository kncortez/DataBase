
DECLARE @SmallPackageId INT = (SELECT TOP 1 CTA.TarId FROM [DeliveryBackOffice].[dbo].[CatTypeArticle] CTA WITH(NOLOCK) WHERE CTA.TarName = 'Paquete pequeño' COLLATE Latin1_General_CI_AI);
DECLARE @MediumPackageId INT = (SELECT TOP 1 CTA.TarId FROM [DeliveryBackOffice].[dbo].[CatTypeArticle] CTA WITH(NOLOCK) WHERE CTA.TarName = 'Paquete mediano' COLLATE Latin1_General_CI_AI);
DECLARE @BigPackageId INT = (SELECT TOP 1 CTA.TarId FROM [DeliveryBackOffice].[dbo].[CatTypeArticle] CTA WITH(NOLOCK) WHERE CTA.TarName = 'Paquete grande' COLLATE Latin1_General_CI_AI);
	
INSERT INTO	[DeliveryBackOffice].[dbo].[CatArticle]
	(ArtIdTypeArticle,ArtName, ArtShowDefault, ArtRowStatus, ArtTokenCreated, ArtDateCreated, ArtHeight, ArtWidth, ArtLength, ArtMassWeight)
VALUES
	(@SmallPackageId,'Paquete pequeño',0,1,'SYS-ARUIZ',GETDATE()	,10,20,30,10),
	(@MediumPackageId,'Paquete mediano',0,1,'SYS-ARUIZ',GETDATE()	,20,30,40,20),
	(@BigPackageId,'Paquete grande',0,1,'SYS-ARUIZ',GETDATE()		,30,40,50,40)