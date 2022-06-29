
-- Tarifarios
DECLARE @NewMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI);
DECLARE @NewAlternativeRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI);

-- Tipo de servicio	
DECLARE @SDDTypeId INT = (SELECT TOP 1 CTS.CtsId FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsShortName = 'SDD' COLLATE Latin1_General_CI_AI)
DECLARE @NDDTypeId INT = (SELECT TOP 1 CTS.CtsId FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsShortName = 'NDD' COLLATE Latin1_General_CI_AI)
DECLARE @TDATypeId INT = (SELECT TOP 1 CTS.CtsId FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsShortName = 'TDA' COLLATE Latin1_General_CI_AI)

-- Tipo de segmento
DECLARE @LocTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'LOC' COLLATE Latin1_General_CI_AI)
DECLARE @MetTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'MET' COLLATE Latin1_General_CI_AI)
DECLARE @ForTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'FOR' COLLATE Latin1_General_CI_AI)

-- Artículos
DECLARE @ExtraBigPackageId INT =		(SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete extra grande' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP079' COLLATE Latin1_General_CI_AI);
DECLARE @OversizedPackageId INT =		(SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete sobredimensionado' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP080' COLLATE Latin1_General_CI_AI);

-- Insertar información de tarifario a principal
INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
	(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
VALUES
	-- ARTÍCULOS NUEVOS
	-- SAME DAY
	--(@NewMainRates, @SDDTypeId, @LocTypeId, @SmallPackageId,	29.99, 1, 'SYS-ARUIZ', GETDATE()), Precio base de paquete pequeño
	(@NewMainRates, @SDDTypeId, @LocTypeId, @ExtraBigPackageId,	41.99, 1, 'SYS-ARUIZ', GETDATE()), -- +12
	(@NewMainRates, @SDDTypeId, @LocTypeId, @OversizedPackageId,44.99, 1, 'SYS-ARUIZ', GETDATE()), -- +15

	-- NEXT DAY
	--(@NewMainRates, @NDDTypeId, @LocTypeId, @SmallPackageId,	29.99, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @NDDTypeId, @LocTypeId, @ExtraBigPackageId,	41.99, 1, 'SYS-ARUIZ', GETDATE()), -- +12
	(@NewMainRates, @NDDTypeId, @LocTypeId, @OversizedPackageId,44.99, 1, 'SYS-ARUIZ', GETDATE()), -- +15

	--(@NewMainRates, @NDDTypeId, @MetTypeId, @SmallPackageId,	29.99, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @NDDTypeId, @MetTypeId, @ExtraBigPackageId,	41.99, 1, 'SYS-ARUIZ', GETDATE()), -- +12
	(@NewMainRates, @NDDTypeId, @MetTypeId, @OversizedPackageId,44.99, 1, 'SYS-ARUIZ', GETDATE()), -- +15

	--(@NewMainRates, @NDDTypeId, @ForTypeId, @SmallPackageId,	39.99, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @NDDTypeId, @ForTypeId, @ExtraBigPackageId,	51.99, 1, 'SYS-ARUIZ', GETDATE()), -- +12
	(@NewMainRates, @NDDTypeId, @ForTypeId, @OversizedPackageId,54.99, 1, 'SYS-ARUIZ', GETDATE()), -- +15

	-- TOTAL DELIVERY ACCESS
	--(@NewMainRates, @TDATypeId, @LocTypeId, @SmallPackageId,	29.99, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @TDATypeId, @LocTypeId, @ExtraBigPackageId,	41.99, 1, 'SYS-ARUIZ', GETDATE()), -- +12
	(@NewMainRates, @TDATypeId, @LocTypeId, @OversizedPackageId,44.99, 1, 'SYS-ARUIZ', GETDATE()), -- +15

	--(@NewMainRates, @TDATypeId, @MetTypeId, @SmallPackageId,	29.99, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @TDATypeId, @MetTypeId, @ExtraBigPackageId,	41.99, 1, 'SYS-ARUIZ', GETDATE()), -- +12
	(@NewMainRates, @TDATypeId, @MetTypeId, @OversizedPackageId,44.99, 1, 'SYS-ARUIZ', GETDATE()), -- +15

	--(@NewMainRates, @TDATypeId, @ForTypeId, @SmallPackageId,	39.99, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @TDATypeId, @ForTypeId, @ExtraBigPackageId,	51.99, 1, 'SYS-ARUIZ', GETDATE()), -- +12
	(@NewMainRates, @TDATypeId, @ForTypeId, @OversizedPackageId,54.99, 1, 'SYS-ARUIZ', GETDATE())  -- +15
	
-- Insertar información de tarifario a alterno
INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
	(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
VALUES
	-- ARTÍCULOS NUEVOS
	-- SAME DAY
	--(@NewAlternativeRates, @SDDTypeId, @LocTypeId, @SmallPackageId,	24.99, 1, 'SYS-ARUIZ', GETDATE()), Precio base de paquete pequeño
	(@NewAlternativeRates, @SDDTypeId, @LocTypeId, @ExtraBigPackageId,	36.99, 1, 'SYS-ARUIZ', GETDATE()), -- +12
	(@NewAlternativeRates, @SDDTypeId, @LocTypeId, @OversizedPackageId,	39.99, 1, 'SYS-ARUIZ', GETDATE()), -- +15

	-- NEXT DAY
	--(@NewAlternativeRates, @NDDTypeId, @LocTypeId, @SmallPackageId,	24.99, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @NDDTypeId, @LocTypeId, @ExtraBigPackageId,	36.99, 1, 'SYS-ARUIZ', GETDATE()), -- +12
	(@NewAlternativeRates, @NDDTypeId, @LocTypeId, @OversizedPackageId,	39.99, 1, 'SYS-ARUIZ', GETDATE()), -- +15

	--(@NewAlternativeRates, @NDDTypeId, @MetTypeId, @SmallPackageId,	24.99, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @NDDTypeId, @MetTypeId, @ExtraBigPackageId,	36.99, 1, 'SYS-ARUIZ', GETDATE()), -- +12
	(@NewAlternativeRates, @NDDTypeId, @MetTypeId, @OversizedPackageId,	39.99, 1, 'SYS-ARUIZ', GETDATE()), -- +15

	--(@NewAlternativeRates, @NDDTypeId, @ForTypeId, @SmallPackageId,	34.99, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @NDDTypeId, @ForTypeId, @ExtraBigPackageId,	46.99, 1, 'SYS-ARUIZ', GETDATE()), -- +12
	(@NewAlternativeRates, @NDDTypeId, @ForTypeId, @OversizedPackageId,	49.99, 1, 'SYS-ARUIZ', GETDATE()), -- +15

	-- TOTAL DELIVERY ACCESS
	--(@NewAlternativeRates, @TDATypeId, @LocTypeId, @SmallPackageId,	24.99, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @TDATypeId, @LocTypeId, @ExtraBigPackageId,	36.99, 1, 'SYS-ARUIZ', GETDATE()), -- +12
	(@NewAlternativeRates, @TDATypeId, @LocTypeId, @OversizedPackageId,	39.99, 1, 'SYS-ARUIZ', GETDATE()), -- +15

	--(@NewAlternativeRates, @TDATypeId, @MetTypeId, @SmallPackageId,	24.99, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @TDATypeId, @MetTypeId, @ExtraBigPackageId,	36.99, 1, 'SYS-ARUIZ', GETDATE()), -- +12
	(@NewAlternativeRates, @TDATypeId, @MetTypeId, @OversizedPackageId,	39.99, 1, 'SYS-ARUIZ', GETDATE()), -- +15

	--(@NewAlternativeRates, @TDATypeId, @ForTypeId, @SmallPackageId,	34.99, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @TDATypeId, @ForTypeId, @ExtraBigPackageId,	46.99, 1, 'SYS-ARUIZ', GETDATE()), -- +12
	(@NewAlternativeRates, @TDATypeId, @ForTypeId, @OversizedPackageId,	49.99, 1, 'SYS-ARUIZ', GETDATE())  -- +15
	