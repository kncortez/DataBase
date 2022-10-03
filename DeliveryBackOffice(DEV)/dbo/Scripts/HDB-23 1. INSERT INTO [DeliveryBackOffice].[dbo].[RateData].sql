
BEGIN TRANSACTION
BEGIN TRY
	-- Tarifarios
	DECLARE @NewMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI);
	DECLARE @NewAlternativeRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI);

	-- Limpieza de tarifarios
	DELETE
		FROM
			[DeliveryBackOffice].[dbo].[RateData]
	WHERE
		RateId = @NewMainRates

	DELETE
		FROM
			[DeliveryBackOffice].[dbo].[RateData]
	WHERE
		RateId = @NewAlternativeRates

	-- Tipo de servicio	
	DECLARE @STDTypeId INT = (SELECT TOP 1 CTS.CtsId FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsShortName = 'STD' COLLATE Latin1_General_CI_AI)
	DECLARE @CODTypeId INT = (SELECT TOP 1 CTS.CtsId FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsShortName = 'COD' COLLATE Latin1_General_CI_AI)

	-- Tipo de segmento
	DECLARE @LocTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'LOC' COLLATE Latin1_General_CI_AI)
	DECLARE @MetTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'MET' COLLATE Latin1_General_CI_AI)
	DECLARE @ForTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'FOR' COLLATE Latin1_General_CI_AI)
	DECLARE @EspTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'ESP' COLLATE Latin1_General_CI_AI)

	-- Artículos
	DECLARE @SmallPackageId INT =	(SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete pequeño' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP076' COLLATE Latin1_General_CI_AI);
	DECLARE @MediumPackageId INT =	(SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete mediano' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP077' COLLATE Latin1_General_CI_AI);
	DECLARE @BigPackageId INT =		(SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete grande' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP078' COLLATE Latin1_General_CI_AI);
	DECLARE @ExtraBigPackageId INT =		(SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete extra grande' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP079' COLLATE Latin1_General_CI_AI);
	DECLARE @OversizedPackageId INT =		(SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete sobredimensionado' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP080' COLLATE Latin1_General_CI_AI);

	-- Base weight
	DECLARE @SmallPackageWeight DECIMAL(14,2) = (SELECT TOP 1 CA.ArtMassWeight FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete pequeño' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP076' COLLATE Latin1_General_CI_AI);
	DECLARE @MediumPackageWeight DECIMAL(14,2) = (SELECT TOP 1 CA.ArtMassWeight FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete mediano' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP077' COLLATE Latin1_General_CI_AI);
	DECLARE @BigPackageWeight DECIMAL(14,2) = (SELECT TOP 1 CA.ArtMassWeight FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete grande' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP078' COLLATE Latin1_General_CI_AI);
	DECLARE @ExtraBigPackageWeight DECIMAL(14,2) = (SELECT TOP 1 CA.ArtMassWeight FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete extra grande' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP079' COLLATE Latin1_General_CI_AI);
	DECLARE @OversizedPackageWeight DECIMAL(14,2) = (SELECT TOP 1 CA.ArtMassWeight FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Paquete sobredimensionado' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP080' COLLATE Latin1_General_CI_AI);
	
	-- Configuración de precios
	DECLARE @ExpressCenterDiscount DECIMAL(14,2) = 5.00;

	DECLARE @BaseLocSTDPrice DECIMAL(14,2) = 24.00;
	DECLARE @BaseMetSTDPrice DECIMAL(14,2) = 28.00;
	DECLARE @BaseForSTDPrice DECIMAL(14,2) = 35.00;
	DECLARE @BaseEspSTDPrice DECIMAL(14,2) = 42.00;
	
	/* BLOQUE PENDIENTE DE CONFIRMAR */
	DECLARE @BaseLocCODPrice DECIMAL(14,2) = 23.00;
	DECLARE @BaseMetCODPrice DECIMAL(14,2) = 26.00;
	DECLARE @BaseForCODPrice DECIMAL(14,2) = 33.00;
	DECLARE @BaseEspCODPrice DECIMAL(14,2) = 40.00;
	/* BLOQUE PENDIENTE DE CONFIRMAR */

	-- Insertar información de tarifario a principal
	INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
		(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
	VALUES
		-- ARTÍCULOS NUEVOS
		-- ESTANDAR
		(@NewMainRates, @STDTypeId, @LocTypeId, @SmallPackageId,		@BaseLocSTDPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @LocTypeId, @MediumPackageId,		@BaseLocSTDPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @LocTypeId, @BigPackageId,			@BaseLocSTDPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @LocTypeId, @ExtraBigPackageId,		@BaseLocSTDPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @LocTypeId, @OversizedPackageId,	@BaseLocSTDPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),

		(@NewMainRates, @STDTypeId, @MetTypeId, @SmallPackageId,		@BaseMetSTDPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @MetTypeId, @MediumPackageId,		@BaseMetSTDPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @MetTypeId, @BigPackageId,			@BaseMetSTDPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @MetTypeId, @ExtraBigPackageId,		@BaseMetSTDPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @MetTypeId, @OversizedPackageId,	@BaseMetSTDPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),

		(@NewMainRates, @STDTypeId, @ForTypeId, @SmallPackageId,		@BaseForSTDPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @ForTypeId, @MediumPackageId,		@BaseForSTDPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @ForTypeId, @BigPackageId,			@BaseForSTDPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @ForTypeId, @ExtraBigPackageId,		@BaseForSTDPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @ForTypeId, @OversizedPackageId,	@BaseForSTDPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		
		(@NewMainRates, @STDTypeId, @EspTypeId, @SmallPackageId,		@BaseEspSTDPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @EspTypeId, @MediumPackageId,		@BaseEspSTDPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @EspTypeId, @BigPackageId,			@BaseEspSTDPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @EspTypeId, @ExtraBigPackageId,		@BaseEspSTDPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @STDTypeId, @EspTypeId, @OversizedPackageId,	@BaseEspSTDPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),

		-- COD
		(@NewMainRates, @CODTypeId, @LocTypeId, @SmallPackageId,		@BaseLocCODPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @LocTypeId, @MediumPackageId,		@BaseLocCODPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @LocTypeId, @BigPackageId,			@BaseLocCODPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @LocTypeId, @ExtraBigPackageId,		@BaseLocCODPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @LocTypeId, @OversizedPackageId,	@BaseLocCODPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),

		(@NewMainRates, @CODTypeId, @MetTypeId, @SmallPackageId,		@BaseMetCODPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @MetTypeId, @MediumPackageId,		@BaseMetCODPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @MetTypeId, @BigPackageId,			@BaseMetCODPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @MetTypeId, @ExtraBigPackageId,		@BaseMetCODPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @MetTypeId, @OversizedPackageId,	@BaseMetCODPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),

		(@NewMainRates, @CODTypeId, @ForTypeId, @SmallPackageId,		@BaseForCODPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @ForTypeId, @MediumPackageId,		@BaseForCODPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @ForTypeId, @BigPackageId,			@BaseForCODPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @ForTypeId, @ExtraBigPackageId,		@BaseForCODPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @ForTypeId, @OversizedPackageId,	@BaseForCODPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		
		(@NewMainRates, @CODTypeId, @EspTypeId, @SmallPackageId,		@BaseEspCODPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @EspTypeId, @MediumPackageId,		@BaseEspCODPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @EspTypeId, @BigPackageId,			@BaseEspCODPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @EspTypeId, @ExtraBigPackageId,		@BaseEspCODPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewMainRates, @CODTypeId, @EspTypeId, @OversizedPackageId,	@BaseEspCODPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE())

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
				@SmallPackageId
				,@MediumPackageId
				,@BigPackageId
				,@ExtraBigPackageId
				,@OversizedPackageId
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
				@SmallPackageId
				,@MediumPackageId
				,@BigPackageId
				,@ExtraBigPackageId
				,@OversizedPackageId
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
				@SmallPackageId
				,@MediumPackageId
				,@BigPackageId
				,@ExtraBigPackageId
				,@OversizedPackageId
			)

		--ESPECIAL
		INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
			(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
		SELECT
			@NewMainRates, NULL, @EspTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
		WHERE
			ABC.Code LIKE 'EXP%'
			AND
			ABC.AbcId NOT IN (
				@SmallPackageId
				,@MediumPackageId
				,@BigPackageId
				,@ExtraBigPackageId
				,@OversizedPackageId
			)

	-- Insertar información de tarifario a alterno
	INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
		(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
	VALUES
		-- ARTÍCULOS NUEVOS
		-- ESTANDAR
		(@NewAlternativeRates, @STDTypeId, @LocTypeId, @SmallPackageId,			@BaseLocSTDPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @LocTypeId, @MediumPackageId,		@BaseLocSTDPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @LocTypeId, @BigPackageId,			@BaseLocSTDPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @LocTypeId, @ExtraBigPackageId,		@BaseLocSTDPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @LocTypeId, @OversizedPackageId,		@BaseLocSTDPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),

		(@NewAlternativeRates, @STDTypeId, @MetTypeId, @SmallPackageId,			@BaseMetSTDPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @MetTypeId, @MediumPackageId,		@BaseMetSTDPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @MetTypeId, @BigPackageId,			@BaseMetSTDPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @MetTypeId, @ExtraBigPackageId,		@BaseMetSTDPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @MetTypeId, @OversizedPackageId,		@BaseMetSTDPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),

		(@NewAlternativeRates, @STDTypeId, @ForTypeId, @SmallPackageId,			@BaseForSTDPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @ForTypeId, @MediumPackageId,		@BaseForSTDPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @ForTypeId, @BigPackageId,			@BaseForSTDPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @ForTypeId, @ExtraBigPackageId,		@BaseForSTDPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @ForTypeId, @OversizedPackageId,		@BaseForSTDPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		
		(@NewAlternativeRates, @STDTypeId, @EspTypeId, @SmallPackageId,			@BaseEspSTDPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @EspTypeId, @MediumPackageId,		@BaseEspSTDPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @EspTypeId, @BigPackageId,			@BaseEspSTDPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @EspTypeId, @ExtraBigPackageId,		@BaseEspSTDPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @STDTypeId, @EspTypeId, @OversizedPackageId,		@BaseEspSTDPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),

		-- COD
		(@NewAlternativeRates, @CODTypeId, @LocTypeId, @SmallPackageId,			@BaseLocCODPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @LocTypeId, @MediumPackageId,		@BaseLocCODPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @LocTypeId, @BigPackageId,			@BaseLocCODPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @LocTypeId, @ExtraBigPackageId,		@BaseLocCODPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @LocTypeId, @OversizedPackageId,		@BaseLocCODPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),

		(@NewAlternativeRates, @CODTypeId, @MetTypeId, @SmallPackageId,			@BaseMetCODPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @MetTypeId, @MediumPackageId,		@BaseMetCODPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @MetTypeId, @BigPackageId,			@BaseMetCODPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @MetTypeId, @ExtraBigPackageId,		@BaseMetCODPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @MetTypeId, @OversizedPackageId,		@BaseMetCODPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),

		(@NewAlternativeRates, @CODTypeId, @ForTypeId, @SmallPackageId,			@BaseForCODPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @ForTypeId, @MediumPackageId,		@BaseForCODPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @ForTypeId, @BigPackageId,			@BaseForCODPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @ForTypeId, @ExtraBigPackageId,		@BaseForCODPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @ForTypeId, @OversizedPackageId,		@BaseForCODPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		
		(@NewAlternativeRates, @CODTypeId, @EspTypeId, @SmallPackageId,			@BaseEspCODPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @EspTypeId, @MediumPackageId,		@BaseEspCODPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @EspTypeId, @BigPackageId,			@BaseEspCODPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @EspTypeId, @ExtraBigPackageId,		@BaseEspCODPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@NewAlternativeRates, @CODTypeId, @EspTypeId, @OversizedPackageId,		@BaseEspCODPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE())
	
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
				@SmallPackageId
				,@MediumPackageId
				,@BigPackageId
				,@ExtraBigPackageId
				,@OversizedPackageId
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
				@SmallPackageId
				,@MediumPackageId
				,@BigPackageId
				,@ExtraBigPackageId
				,@OversizedPackageId
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
				@SmallPackageId
				,@MediumPackageId
				,@BigPackageId
				,@ExtraBigPackageId
				,@OversizedPackageId
			)

		--ESPECIAL
		INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
			(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
		SELECT
			@NewAlternativeRates, NULL, @EspTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
		WHERE
			ABC.Code LIKE 'EXP%'
			AND
			ABC.AbcId NOT IN (
				@SmallPackageId
				,@MediumPackageId
				,@BigPackageId
				,@ExtraBigPackageId
				,@OversizedPackageId
			)

	--SELECT
	--	CRS.CrsShortName, CTS.CtsShortName, ABC.Code, CA.ArtName, RD.RateValue
	--FROM
	--	[DeliveryBackOffice].[dbo].[RateData] RD WITH(NOLOCK)
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK)
	--		ON
	--			RD.TypeSegmentId = CRS.CrsId
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK)
	--		ON
	--			RD.TypeServiceId = CTS.CtsId
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
	--		ON
	--			RD.ArticleId = ABC.AbcId
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK)
	--		ON
	--			ABC.AbcIdArticle = CA.ArtId
	--WHERE
	--	RD.RateId = @NewMainRates
	--ORDER BY
	--	CRS.CrsId ASC,
	--	CTS.CtsId DESC,
	--	ABC.Code ASC
		

	--SELECT
	--	CRS.CrsShortName, CTS.CtsShortName, ABC.Code, CA.ArtName, RD.RateValue
	--FROM
	--	[DeliveryBackOffice].[dbo].[RateData] RD WITH(NOLOCK)
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK)
	--		ON
	--			RD.TypeSegmentId = CRS.CrsId
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK)
	--		ON
	--			RD.TypeServiceId = CTS.CtsId
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
	--		ON
	--			RD.ArticleId = ABC.AbcId
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK)
	--		ON
	--			ABC.AbcIdArticle = CA.ArtId
	--WHERE
	--	RD.RateId = @NewAlternativeRates
	--ORDER BY
	--	CRS.CrsId ASC,
	--	CTS.CtsId DESC,
	--	ABC.Code ASC

	-- Limpiar coberturas
	DELETE
		FROM
			[DeliveryBackOffice].[dbo].[RateTownshipCoverage]

	-- LOCALES
	-- GUATEMALA
	DECLARE @IdAmatitlan INT = (SELECT TOP 1 Twn.IdTownship FROM [DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK) WHERE Twn.TownshipName = 'Amatitlán' COLLATE Latin1_General_CI_AI);
	DECLARE @IdFraijanes INT = (SELECT TOP 1 Twn.IdTownship FROM [DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK) WHERE Twn.TownshipName = 'Fraijanes' COLLATE Latin1_General_CI_AI);
	DECLARE @IdGuatemala INT = (SELECT TOP 1 Twn.IdTownship FROM [DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK) WHERE Twn.TownshipName = 'Guatemala' COLLATE Latin1_General_CI_AI);
	DECLARE @IdMixco INT = (SELECT TOP 1 Twn.IdTownship FROM [DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK) WHERE Twn.TownshipName = 'Mixco' COLLATE Latin1_General_CI_AI);
	DECLARE @IdSanJosePinula INT = (SELECT TOP 1 Twn.IdTownship FROM [DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK) WHERE Twn.TownshipName = 'San José Pinula' COLLATE Latin1_General_CI_AI);
	DECLARE @IdSanMiguelPetapa INT = (SELECT TOP 1 Twn.IdTownship FROM [DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK) WHERE Twn.TownshipName = 'San Miguel Petapa' COLLATE Latin1_General_CI_AI);
	DECLARE @IdSantaCatarinaPinula INT = (SELECT TOP 1 Twn.IdTownship FROM [DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK) WHERE Twn.TownshipName = 'Santa Catarina Pinula' COLLATE Latin1_General_CI_AI);
	DECLARE @IdVillaNueva INT = (SELECT TOP 1 Twn.IdTownship FROM [DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK) WHERE Twn.TownshipName = 'Villa Nueva' COLLATE Latin1_General_CI_AI);

	-- Tarifa normal
	INSERT INTO [DeliveryBackOffice].[dbo].[RateTownshipCoverage]
		(RateId, TownshipSourceId, TownshipDestinyId, SegmentTypeId, RowStatus, TokenCreated, DateCreated)
	SELECT
		@NewMainRates, TwnOrig.IdTownship, TwnDest.IdTownship, @LocTypeId, 1, 'SYS-ARUIZ', GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[Township] TwnOrig WITH(NOLOCK)
		CROSS JOIN
			[DeliveryBackOffice].[dbo].[Township] TwnDest WITH(NOLOCK)
	WHERE
		TwnOrig.IdTownship IN (@IdAmatitlan,@IdFraijanes,@IdGuatemala,@IdMixco,@IdSanJosePinula,@IdSanMiguelPetapa,@IdSantaCatarinaPinula,@IdVillaNueva)
		AND
		TwnDest.IdTownship IN (@IdAmatitlan,@IdFraijanes,@IdGuatemala,@IdMixco,@IdSanJosePinula,@IdSanMiguelPetapa,@IdSantaCatarinaPinula,@IdVillaNueva)
		AND
		TwnOrig.IdTownship != TwnDest.IdTownship
		AND
		NOT EXISTS(
			SELECT
				TOP 1
					1
			FROM
				[DeliveryBackOffice].[dbo].[RateTownshipCoverage] RTCCheck WITH(NOLOCK)
			WHERE
				RTCCheck.RateId = @NewMainRates
				AND
				RTCCheck.TownshipSourceId = TwnOrig.IdTownship
				AND
				RTCCheck.TownshipDestinyId = TwnDest.IdTownship
				AND
				RTCCheck.RowStatus = 1
		)

	-- Tarifa express center
	INSERT INTO [DeliveryBackOffice].[dbo].[RateTownshipCoverage]
		(RateId, TownshipSourceId, TownshipDestinyId, SegmentTypeId, RowStatus, TokenCreated, DateCreated)
	SELECT
		@NewAlternativeRates, TwnOrig.IdTownship, TwnDest.IdTownship, @LocTypeId, 1, 'SYS-ARUIZ', GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[Township] TwnOrig WITH(NOLOCK)
		CROSS JOIN
			[DeliveryBackOffice].[dbo].[Township] TwnDest WITH(NOLOCK)
	WHERE
		TwnOrig.IdTownship IN (@IdAmatitlan,@IdFraijanes,@IdGuatemala,@IdMixco,@IdSanJosePinula,@IdSanMiguelPetapa,@IdSantaCatarinaPinula,@IdVillaNueva)
		AND
		TwnDest.IdTownship IN (@IdAmatitlan,@IdFraijanes,@IdGuatemala,@IdMixco,@IdSanJosePinula,@IdSanMiguelPetapa,@IdSantaCatarinaPinula,@IdVillaNueva)
		AND
		TwnOrig.IdTownship != TwnDest.IdTownship
		AND
		NOT EXISTS(
			SELECT
				TOP 1
					1
			FROM
				[DeliveryBackOffice].[dbo].[RateTownshipCoverage] RTCCheck WITH(NOLOCK)
			WHERE
				RTCCheck.RateId = @NewAlternativeRates
				AND
				RTCCheck.TownshipSourceId = TwnOrig.IdTownship
				AND
				RTCCheck.TownshipDestinyId = TwnDest.IdTownship
				AND
				RTCCheck.RowStatus = 1
		)

	-- CABECERAS /// METROPOLITANO
	-- TODA CABECERA
	-- Tarifa normal
	INSERT INTO [DeliveryBackOffice].[dbo].[RateTownshipCoverage]
		(RateId, TownshipSourceId, TownshipDestinyId, SegmentTypeId, RowStatus, TokenCreated, DateCreated)
	SELECT
		@NewMainRates
		,TwnOrig.IdTownship
		,TwnDest.IdTownship
		,@MetTypeId
		,1
		,'SYS-ARUIZ'
		,GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[Township] TwnOrig WITH(NOLOCK)
		CROSS JOIN
			(
				SELECT
					TwnDest.IdTownship
				FROM
					[DeliveryBackOffice].[dbo].[Township] TwnDest WITH(NOLOCK)
					INNER JOIN
						[DeliveryBackOffice].[dbo].[Province] Prov WITH(NOLOCK)
						ON
							TwnDest.IdProvince = Prov.IdProvince
							AND
							TwnDest.HeaderCode = CONCAT(Prov.LocalCode, '01')
			) TwnDest
	WHERE
		TwnOrig.IdTownship != TwnDest.IdTownship
		AND
		NOT EXISTS(
			SELECT
				TOP 1
					1
			FROM
				[DeliveryBackOffice].[dbo].[RateTownshipCoverage] RTCCheck WITH(NOLOCK)
			WHERE
				RTCCheck.RateId = @NewMainRates
				AND
				RTCCheck.TownshipSourceId = TwnOrig.IdTownship
				AND
				RTCCheck.TownshipDestinyId = TwnDest.IdTownship
				AND
				RTCCheck.RowStatus = 1
		)

	-- Destino express center
	INSERT INTO [DeliveryBackOffice].[dbo].[RateTownshipCoverage]
		(RateId, TownshipSourceId, TownshipDestinyId, SegmentTypeId, RowStatus, TokenCreated, DateCreated)
	SELECT
		@NewAlternativeRates
		,TwnOrig.IdTownship
		,TwnDest.IdTownship
		,@MetTypeId
		,1
		,'SYS-ARUIZ'
		,GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[Township] TwnOrig WITH(NOLOCK)
		CROSS JOIN
			(
				SELECT
					TwnDest.IdTownship
				FROM
					[DeliveryBackOffice].[dbo].[Township] TwnDest WITH(NOLOCK)
					INNER JOIN
						[DeliveryBackOffice].[dbo].[Province] Prov WITH(NOLOCK)
						ON
							TwnDest.IdProvince = Prov.IdProvince
							AND
							TwnDest.HeaderCode = CONCAT(Prov.LocalCode, '01')
			) TwnDest
	WHERE
		TwnOrig.IdTownship != TwnDest.IdTownship
		AND
		NOT EXISTS(
			SELECT
				TOP 1
					1
			FROM
				[DeliveryBackOffice].[dbo].[RateTownshipCoverage] RTCCheck WITH(NOLOCK)
			WHERE
				RTCCheck.RateId = @NewAlternativeRates
				AND
				RTCCheck.TownshipSourceId = TwnOrig.IdTownship
				AND
				RTCCheck.TownshipDestinyId = TwnDest.IdTownship
				AND
				RTCCheck.RowStatus = 1
		)

	-- ESPECIAL
	DECLARE @EspecialDestination AS TABLE (
		IdTownship INT
	);
	INSERT INTO @EspecialDestination
		(IdTownship)
	SELECT
		IdTownship
	FROM
		[DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK)
	WHERE
		Twn.TownshipName COLLATE Latin1_General_CI_AI IN (
			'Aguacatán',
			'Alotenango', --- NO ESTA
			'Cabricán',
			'Canillá',
			'Catarina',
			'Chahal',
			'Chajul',
			'Champerico',
			'Chicamán',
			'Chinique',
			'Chisec',
			'Chuarrancho',
			'Colotenango',
			'Comitancillo',
			'Concepción Huista',
			'Concepción Tutuapa',
			'Cubulco',
			'Cuilco',
			'Cunén',
			'Dolores',
			'El Estor',
			'El Quetzal',
			'Esquipulas Palo Gordo',
			'Fray Bartolomé de las Casas',
			'Granados',
			'Guanagazapa',
			'Ixcán',
			'Ixchiguán',
			'Jacaltenango',
			'Jalpatagua',
			'La Blanca',
			'La Democracia Huehuetenango',
			'La Libertad Huehuetenango', 
			'La Reforma',
			'La Tinta', --- NO ESTA
			'La Unión',
			'Las Cruces',
			'Livingston',
			'Malacatancito',
			'Mataquescuintla',
			'Melchor de Mencos',
			'Morazán',
			'Moyuta',
			'Nahualá',
			'Nebaj',
			'Nentón',
			'Nuevo Progreso',
			'Nuevo San Carlos',
			'Ocós',
			'Olintepeque',
			'Pachalum',
			'Panzós',
			'Pastores',
			'Purulhá',
			'Rabinal',
			'Raxruhá',
			'Sacapulas',
			'Samayac',
			'San Andrés Sajcabajá',
			'San Andrés Xecul',
			'San Antonio Aguas Calientes',
			'San Antonio Huista',
			'San Antonio Palopó',
			'San Carlos Alzatate',
			'San Carlos Sija',
			'San Cristóbal Cucho',
			'San Francisco',
			'San Gaspar Ixchil',
			'San Ildefonso Ixtaguacán',
			'San Jose Acatempa',
			'San Jose Ojetenam',
			'San Jose Poaquil',
			'San Juan Atitán',
			'San Juan Cotzal',
			'San Juan Ixcoy',
			'San Juan La Laguna',
			'San Lorenzo',
			'San Marcos',
			'San Lucas Tolimán',
			'San Marcos La Laguna',
			'San Martín Jilotepeque',
			'San Mateo Ixtatán',
			'San Miguel Acatán',
			'San Miguel Dueñas',
			'San Miguel Ixtahuacán',
			'San Miguel Sigüilá',
			'San Pablo',
			'San Pablo La Laguna',
			'San Pedro La Laguna',
			'San Pedro Necta',
			'San Pedro Pinula',
			'San Pedro Soloma',
			'San Rafael Pétzal',
			'San Rafael Pie de la Cuesta',
			'San Raymundo',
			'San Sebastián Coatán',
			'Santa Ana Huista',
			'Santa Apolonia',
			'Santa Bárbara Huehuetenango',
			'Santa Catarina Ixtahuacán',
			'Santa Catarina Palopó',
			'Santa Clara La Laguna',
			'Santa Cruz Barillas',
			'Santa Cruz el Chol',
			'Santa Eulalia',
			'Santa Lucía Utatlán',
			'Santa María Cahabón',
			'Santa María Chiquimula',
			'Santiago Atitlán',
			'Santiago Chimaltenango',
			'Santo Domingo Suchitepéquez',
			'Santo Domingo Xenacoj',
			'Santo Tomás La Unión',
			'Sayaxché',
			'Senahú',
			'Sipacapa',
			'Tacaná',
			'Tajumulco',
			'Tamahú',
			'Tectitán',
			'Tejutla',
			'Todos Santos Cuchumatán', -- NO ESTA
			'Tucurú',
			'Unión Cantinil',
			'Uspantán',
			'Yupiltepeque'
		)
	ORDER BY
		Twn.TownshipName ASC
		
	-- Tarifa normal
	INSERT INTO [DeliveryBackOffice].[dbo].[RateTownshipCoverage]
		(RateId, TownshipSourceId, TownshipDestinyId, SegmentTypeId, RowStatus, TokenCreated, DateCreated)
	SELECT
		@NewMainRates
		,TwnOrig.IdTownship
		,TwnDest.IdTownship
		,@EspTypeId
		,1
		,'SYS-ARUIZ'
		,GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[Township] TwnOrig WITH(NOLOCK)
		CROSS JOIN
			@EspecialDestination TwnDest
	WHERE
		TwnOrig.IdTownship != TwnDest.IdTownship
		AND
		NOT EXISTS(
			SELECT
				TOP 1
					1
			FROM
				[DeliveryBackOffice].[dbo].[RateTownshipCoverage] RTCCheck WITH(NOLOCK)
			WHERE
				RTCCheck.RateId = @NewMainRates
				AND
				RTCCheck.TownshipSourceId = TwnOrig.IdTownship
				AND
				RTCCheck.TownshipDestinyId = TwnDest.IdTownship
				AND
				RTCCheck.RowStatus = 1
		)

	-- Destino express center
	INSERT INTO [DeliveryBackOffice].[dbo].[RateTownshipCoverage]
		(RateId, TownshipSourceId, TownshipDestinyId, SegmentTypeId, RowStatus, TokenCreated, DateCreated)
	SELECT
		@NewAlternativeRates
		,TwnOrig.IdTownship
		,TwnDest.IdTownship
		,@EspTypeId
		,1
		,'SYS-ARUIZ'
		,GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[Township] TwnOrig WITH(NOLOCK)
		CROSS JOIN
			@EspecialDestination TwnDest
	WHERE
		TwnOrig.IdTownship != TwnDest.IdTownship
		AND
		NOT EXISTS(
			SELECT
				TOP 1
					1
			FROM
				[DeliveryBackOffice].[dbo].[RateTownshipCoverage] RTCCheck WITH(NOLOCK)
			WHERE
				RTCCheck.RateId = @NewAlternativeRates
				AND
				RTCCheck.TownshipSourceId = TwnOrig.IdTownship
				AND
				RTCCheck.TownshipDestinyId = TwnDest.IdTownship
				AND
				RTCCheck.RowStatus = 1
		)

	--SELECT
	--	RTC.RateId
	--	,TwnOri.TownshipName
	--	,TwnDes.TownshipName
	--	,CRS.CrsShortName
	--FROM
	--	[DeliveryBackOffice].[dbo].[RateTownshipCoverage] RTC WITH(NOLOCK)
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[Township] TwnOri WITH(NOLOCK)
	--		ON
	--			RTC.TownshipSourceId = TwnOri.IdTownship
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[Township] TwnDes WITH(NOLOCK)
	--		ON
	--			RTC.TownshipDestinyId = TwnDes.IdTownship
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK)
	--		ON
	--			CRS.CrsId = RTC.SegmentTypeId
	--WHERE
	--	RTC.RateId = @NewMainRates
	--ORDER BY
	--	RTC.TownshipSourceId ASC,
	--	RTC.TownshipDestinyId ASC

	--SELECT
	--	RTC.RateId
	--	,TwnOri.TownshipName
	--	,TwnDes.TownshipName
	--	,CRS.CrsShortName
	--FROM
	--	[DeliveryBackOffice].[dbo].[RateTownshipCoverage] RTC WITH(NOLOCK)
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[Township] TwnOri WITH(NOLOCK)
	--		ON
	--			RTC.TownshipSourceId = TwnOri.IdTownship
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[Township] TwnDes WITH(NOLOCK)
	--		ON
	--			RTC.TownshipDestinyId = TwnDes.IdTownship
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK)
	--		ON
	--			CRS.CrsId = RTC.SegmentTypeId
	--WHERE
	--	RTC.RateId = @NewAlternativeRates
	--ORDER BY
	--	RTC.TownshipSourceId ASC,
	--	RTC.TownshipDestinyId ASC
		
	--;THROW 50005, '', 1;

	COMMIT TRANSACTION;

	SELECT
		1 [blnResult]

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION;

	SELECT
		0 [blnResult]

END CATCH