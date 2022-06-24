
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
DECLARE @SmallPackageId INT =	(SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete pequeño' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP076' COLLATE Latin1_General_CI_AI);
DECLARE @MediumPackageId INT =	(SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete mediano' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP077' COLLATE Latin1_General_CI_AI);
DECLARE @BigPackageId INT =		(SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete grande' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP078' COLLATE Latin1_General_CI_AI);

-- Insertar información de tarifario a principal
INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
	(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
VALUES
	-- ARTÍCULOS NUEVOS
	-- SAME DAY
	(@NewMainRates, @SDDTypeId, @LocTypeId, @SmallPackageId,	25, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @SDDTypeId, @LocTypeId, @MediumPackageId,	28, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @SDDTypeId, @LocTypeId, @BigPackageId,		32, 1, 'SYS-ARUIZ', GETDATE()),

	(@NewMainRates, @SDDTypeId, @MetTypeId, @SmallPackageId,	27, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @SDDTypeId, @MetTypeId, @MediumPackageId,	30, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @SDDTypeId, @MetTypeId, @BigPackageId,		34, 1, 'SYS-ARUIZ', GETDATE()),

	(@NewMainRates, @SDDTypeId, @ForTypeId, @SmallPackageId,	30, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @SDDTypeId, @ForTypeId, @MediumPackageId,	32, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @SDDTypeId, @ForTypeId, @BigPackageId,		35, 1, 'SYS-ARUIZ', GETDATE()),

	-- NEXT DAY
	(@NewMainRates, @NDDTypeId, @LocTypeId, @SmallPackageId,	23, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @NDDTypeId, @LocTypeId, @MediumPackageId,	26, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @NDDTypeId, @LocTypeId, @BigPackageId,		30, 1, 'SYS-ARUIZ', GETDATE()),

	(@NewMainRates, @NDDTypeId, @MetTypeId, @SmallPackageId,	26, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @NDDTypeId, @MetTypeId, @MediumPackageId,	29, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @NDDTypeId, @MetTypeId, @BigPackageId,		33, 1, 'SYS-ARUIZ', GETDATE()),

	(@NewMainRates, @NDDTypeId, @ForTypeId, @SmallPackageId,	29, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @NDDTypeId, @ForTypeId, @MediumPackageId,	31, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @NDDTypeId, @ForTypeId, @BigPackageId,		34, 1, 'SYS-ARUIZ', GETDATE()),

	-- TOTAL DELIVERY ACCESS
	(@NewMainRates, @TDATypeId, @LocTypeId, @SmallPackageId,	27, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @TDATypeId, @LocTypeId, @MediumPackageId,	30, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @TDATypeId, @LocTypeId, @BigPackageId,		34, 1, 'SYS-ARUIZ', GETDATE()),

	(@NewMainRates, @TDATypeId, @MetTypeId, @SmallPackageId,	29, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @TDATypeId, @MetTypeId, @MediumPackageId,	32, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @TDATypeId, @MetTypeId, @BigPackageId,		36, 1, 'SYS-ARUIZ', GETDATE()),

	(@NewMainRates, @TDATypeId, @ForTypeId, @SmallPackageId,	32, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @TDATypeId, @ForTypeId, @MediumPackageId,	34, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewMainRates, @TDATypeId, @ForTypeId, @BigPackageId,		37, 1, 'SYS-ARUIZ', GETDATE())
	
	-- ARTÍCULOS VIEJOS
	-- LOCAL
	INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
		(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
	SELECT
		@NewMainRates, NULL, @LocTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
	WHERE
		ABC.Code LIKE 'EXP%'
		AND
		ABC.AbcId NOT IN (
			SELECT
				RD.ArticleId
			FROM
				[DeliveryBackOffice].[dbo].[RateData] RD WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC2 WITH(NOLOCK)
					ON
						RD.ArticleId = ABC2.AbcIdArticle
			WHERE
				ABC2.Code LIKE 'EXP%'
				AND
				RD.TypeServiceId IS NOT NULL
				AND
				RD.TypeSegmentId IS NOT NULL
				AND
				RD.RateId = @NewMainRates
		)

	-- METRO
	INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
		(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
	SELECT
		@NewMainRates, NULL, @MetTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
	WHERE
		ABC.Code LIKE 'EXP%'
		AND
		ABC.AbcId NOT IN (
			SELECT
				RD.ArticleId
			FROM
				[DeliveryBackOffice].[dbo].[RateData] RD WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC2 WITH(NOLOCK)
					ON
						RD.ArticleId = ABC2.AbcIdArticle
			WHERE
				ABC2.Code LIKE 'EXP%'
				AND
				RD.TypeServiceId IS NOT NULL
				AND
				RD.TypeSegmentId IS NOT NULL
				AND
				RD.RateId = @NewMainRates
		)

	--FORANEO
	INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
		(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
	SELECT
		@NewMainRates, NULL, @ForTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
	WHERE
		ABC.Code LIKE 'EXP%'
		AND
		ABC.AbcId NOT IN (
			SELECT
				RD.ArticleId
			FROM
				[DeliveryBackOffice].[dbo].[RateData] RD WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC2 WITH(NOLOCK)
					ON
						RD.ArticleId = ABC2.AbcIdArticle
			WHERE
				ABC2.Code LIKE 'EXP%'
				AND
				RD.TypeServiceId IS NOT NULL
				AND
				RD.TypeSegmentId IS NOT NULL
				AND
				RD.RateId = @NewMainRates
		)
-- Insertar información de tarifario a alterno
INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
	(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
VALUES
	-- ARTÍCULOS NUEVOS
	-- SAME DAY
	(@NewAlternativeRates, @SDDTypeId, @LocTypeId, @SmallPackageId,		15, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @SDDTypeId, @LocTypeId, @MediumPackageId,	18, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @SDDTypeId, @LocTypeId, @BigPackageId,		22, 1, 'SYS-ARUIZ', GETDATE()),

	(@NewAlternativeRates, @SDDTypeId, @MetTypeId, @SmallPackageId,		17, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @SDDTypeId, @MetTypeId, @MediumPackageId,	20, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @SDDTypeId, @MetTypeId, @BigPackageId,		24, 1, 'SYS-ARUIZ', GETDATE()),

	(@NewAlternativeRates, @SDDTypeId, @ForTypeId, @SmallPackageId,		20, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @SDDTypeId, @ForTypeId, @MediumPackageId,	22, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @SDDTypeId, @ForTypeId, @BigPackageId,		25, 1, 'SYS-ARUIZ', GETDATE()),

	-- NEXT DAY
	(@NewAlternativeRates, @NDDTypeId, @LocTypeId, @SmallPackageId,		13, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @NDDTypeId, @LocTypeId, @MediumPackageId,	16, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @NDDTypeId, @LocTypeId, @BigPackageId,		20, 1, 'SYS-ARUIZ', GETDATE()),

	(@NewAlternativeRates, @NDDTypeId, @MetTypeId, @SmallPackageId,		16, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @NDDTypeId, @MetTypeId, @MediumPackageId,	19, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @NDDTypeId, @MetTypeId, @BigPackageId,		23, 1, 'SYS-ARUIZ', GETDATE()),

	(@NewAlternativeRates, @NDDTypeId, @ForTypeId, @SmallPackageId,		19, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @NDDTypeId, @ForTypeId, @MediumPackageId,	21, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @NDDTypeId, @ForTypeId, @BigPackageId,		24, 1, 'SYS-ARUIZ', GETDATE()),

	-- TOTAL DELIVERY ACCESS
	(@NewAlternativeRates, @TDATypeId, @LocTypeId, @SmallPackageId,		17, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @TDATypeId, @LocTypeId, @MediumPackageId,	20, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @TDATypeId, @LocTypeId, @BigPackageId,		24, 1, 'SYS-ARUIZ', GETDATE()),

	(@NewAlternativeRates, @TDATypeId, @MetTypeId, @SmallPackageId,		19, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @TDATypeId, @MetTypeId, @MediumPackageId,	22, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @TDATypeId, @MetTypeId, @BigPackageId,		26, 1, 'SYS-ARUIZ', GETDATE()),

	(@NewAlternativeRates, @TDATypeId, @ForTypeId, @SmallPackageId,		22, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @TDATypeId, @ForTypeId, @MediumPackageId,	24, 1, 'SYS-ARUIZ', GETDATE()),
	(@NewAlternativeRates, @TDATypeId, @ForTypeId, @BigPackageId,		27, 1, 'SYS-ARUIZ', GETDATE())
	
	-- ARTÍCULOS VIEJOS
	-- LOCAL
	INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
		(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
	SELECT
		@NewAlternativeRates, NULL, @LocTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
	WHERE
		ABC.Code LIKE 'EXP%'
		AND
		ABC.AbcId NOT IN (
			SELECT
				RD.ArticleId
			FROM
				[DeliveryBackOffice].[dbo].[RateData] RD WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC2 WITH(NOLOCK)
					ON
						RD.ArticleId = ABC2.AbcIdArticle
			WHERE
				ABC2.Code LIKE 'EXP%'
				AND
				RD.TypeServiceId IS NOT NULL
				AND
				RD.TypeSegmentId IS NOT NULL
				AND
				RD.RateId = @NewAlternativeRates
		)

	-- METRO
	INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
		(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
	SELECT
		@NewAlternativeRates, NULL, @MetTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
	WHERE
		ABC.Code LIKE 'EXP%'
		AND
		ABC.AbcId NOT IN (
			SELECT
				RD.ArticleId
			FROM
				[DeliveryBackOffice].[dbo].[RateData] RD WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC2 WITH(NOLOCK)
					ON
						RD.ArticleId = ABC2.AbcIdArticle
			WHERE
				ABC2.Code LIKE 'EXP%'
				AND
				RD.TypeServiceId IS NOT NULL
				AND
				RD.TypeSegmentId IS NOT NULL
				AND
				RD.RateId = @NewAlternativeRates
		)

	--FORANEO
	INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
		(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
	SELECT
		@NewAlternativeRates, NULL, @ForTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
	WHERE
		ABC.Code LIKE 'EXP%'
		AND
		ABC.AbcId NOT IN (
			SELECT
				RD.ArticleId
			FROM
				[DeliveryBackOffice].[dbo].[RateData] RD WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC2 WITH(NOLOCK)
					ON
						RD.ArticleId = ABC2.AbcIdArticle
			WHERE
				ABC2.Code LIKE 'EXP%'
				AND
				RD.TypeServiceId IS NOT NULL
				AND
				RD.TypeSegmentId IS NOT NULL
				AND
				RD.RateId = @NewAlternativeRates
		)