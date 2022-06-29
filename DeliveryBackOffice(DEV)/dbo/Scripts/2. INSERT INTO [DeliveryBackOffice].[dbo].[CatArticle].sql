
DECLARE @ExtraBigPackageId INT = (SELECT TOP 1 CTA.TarId FROM [DeliveryBackOffice].[dbo].[CatTypeArticle] CTA WITH(NOLOCK) WHERE CTA.TarName = 'Paquete extra grande' COLLATE Latin1_General_CI_AI);
DECLARE @OversizedPackageId INT = (SELECT TOP 1 CTA.TarId FROM [DeliveryBackOffice].[dbo].[CatTypeArticle] CTA WITH(NOLOCK) WHERE CTA.TarName = 'Paquete sobredimensionado' COLLATE Latin1_General_CI_AI);
	
INSERT INTO	[DeliveryBackOffice].[dbo].[CatArticle]
	(ArtIdTypeArticle,ArtName, ArtShowDefault, ArtRowStatus, ArtTokenCreated, ArtDateCreated, ArtHeight, ArtWidth, ArtLength, ArtMassWeight)
VALUES
	(@ExtraBigPackageId,'Paquete extra grande',0,1,'SYS-ARUIZ',GETDATE()	,30,40,50,50),
	(@OversizedPackageId,'Paquete sobredimensionado',0,1,'SYS-ARUIZ',GETDATE()	,30,40,50,60)