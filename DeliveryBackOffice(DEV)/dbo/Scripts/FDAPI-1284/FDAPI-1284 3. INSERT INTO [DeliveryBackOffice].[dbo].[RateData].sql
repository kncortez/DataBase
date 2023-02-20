BEGIN TRANSACTION
BEGIN TRY
	-- Tarifarios
	DECLARE @TarifarioBasePorAplicar INT;

	DECLARE @TarifaPlanBasico INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Básico' COLLATE Latin1_General_CI_AI);
	DECLARE @TarifaPlanBasicoPlus INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Básico Plus' COLLATE Latin1_General_CI_AI);
	DECLARE @TarifaPlanGold INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Gold' COLLATE Latin1_General_CI_AI);
	DECLARE @TarifaPlanCorporativo INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Corporativo' COLLATE Latin1_General_CI_AI);
	
	DECLARE @TarifarioAlternoPorAplicar INT;

	DECLARE @TarifaPlanBasicoAlt INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Básico destinos express center' COLLATE Latin1_General_CI_AI);
	DECLARE @TarifaPlanBasicoPlusAlt INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Básico Plus destinos express center' COLLATE Latin1_General_CI_AI);
	DECLARE @TarifaPlanGoldAlt INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Gold destinos express center' COLLATE Latin1_General_CI_AI);
	DECLARE @TarifaPlanCorporativoAlt INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Corporativo destinos express center' COLLATE Latin1_General_CI_AI);
	
	-- Configuración
	--------------------------------------------------------------------------

	SET @TarifarioBasePorAplicar = @TarifaPlanBasico
	SET @TarifarioAlternoPorAplicar = @TarifaPlanBasicoAlt
	
	DECLARE @ExpressCenterDiscount DECIMAL(14,2) = 5.00;
	
	DECLARE @BaseLocSTDPrice DECIMAL(14,2) = 30.00;
	DECLARE @BaseMetSTDPrice DECIMAL(14,2) = 39.00;
	DECLARE @BaseForSTDPrice DECIMAL(14,2) = 40.00;
	DECLARE @BaseEspSTDPrice DECIMAL(14,2) = 55.00;
	
	DECLARE @BaseLocCODPrice DECIMAL(14,2) = 25.00;
	DECLARE @BaseMetCODPrice DECIMAL(14,2) = 29.00;
	DECLARE @BaseForCODPrice DECIMAL(14,2) = 35.00;
	DECLARE @BaseEspCODPrice DECIMAL(14,2) = 45.00;

	--------------------------------------------------------------------------
	
	IF(@TarifarioBasePorAplicar IS NULL OR @TarifarioAlternoPorAplicar IS NULL OR @TarifarioBasePorAplicar = @TarifarioAlternoPorAplicar)
	BEGIN
		
		;THROW 50001, 'VERIFICAR TARIFARIOS POR INGRESAR', 1;

	END
	-- Limpieza de tarifarios
	DELETE
		FROM
			[DeliveryBackOffice].[dbo].[RateData]
	WHERE
		RateId = @TarifarioBasePorAplicar

	DELETE
		FROM
			[DeliveryBackOffice].[dbo].[RateData]
	WHERE
		RateId = @TarifarioAlternoPorAplicar

	-- Tipo de servicio	
	DECLARE @STDTypeId INT = (SELECT TOP 1 CTS.CtsId FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsShortName = 'STD' COLLATE Latin1_General_CI_AI)
	DECLARE @CODTypeId INT = (SELECT TOP 1 CTS.CtsId FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsShortName = 'COD' COLLATE Latin1_General_CI_AI)

	-- Tipo de segmento
	DECLARE @LocTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'LOC' COLLATE Latin1_General_CI_AI)
	DECLARE @MetTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'MET' COLLATE Latin1_General_CI_AI)
	DECLARE @ForTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'FOR' COLLATE Latin1_General_CI_AI)
	DECLARE @EspTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'ESP' COLLATE Latin1_General_CI_AI)

	-- Artículo a ignorar
	DECLARE @FilePackageId INT =	(SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) ON CA.ArtId = ABC.AbcIdArticle WHERE CA.ArtName = 'Sobre' COLLATE Latin1_General_CI_AI AND ABC.Code = 'EXP075' COLLATE Latin1_General_CI_AI);
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
	
	-- Insertar información de tarifario a principal
	INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
		(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
	VALUES
		-- ARTÍCULOS NUEVOS
		-- ESTANDAR
		(@TarifarioBasePorAplicar, @STDTypeId, @LocTypeId, @SmallPackageId,			@BaseLocSTDPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @LocTypeId, @MediumPackageId,		@BaseLocSTDPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @LocTypeId, @BigPackageId,			@BaseLocSTDPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @LocTypeId, @ExtraBigPackageId,		@BaseLocSTDPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @LocTypeId, @OversizedPackageId,		@BaseLocSTDPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),

		(@TarifarioBasePorAplicar, @STDTypeId, @MetTypeId, @SmallPackageId,			@BaseMetSTDPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @MetTypeId, @MediumPackageId,		@BaseMetSTDPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @MetTypeId, @BigPackageId,			@BaseMetSTDPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @MetTypeId, @ExtraBigPackageId,		@BaseMetSTDPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @MetTypeId, @OversizedPackageId,		@BaseMetSTDPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),

		(@TarifarioBasePorAplicar, @STDTypeId, @ForTypeId, @SmallPackageId,			@BaseForSTDPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @ForTypeId, @MediumPackageId,		@BaseForSTDPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @ForTypeId, @BigPackageId,			@BaseForSTDPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @ForTypeId, @ExtraBigPackageId,		@BaseForSTDPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @ForTypeId, @OversizedPackageId,		@BaseForSTDPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		
		(@TarifarioBasePorAplicar, @STDTypeId, @EspTypeId, @SmallPackageId,		@BaseEspSTDPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @EspTypeId, @MediumPackageId,		@BaseEspSTDPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @EspTypeId, @BigPackageId,			@BaseEspSTDPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @EspTypeId, @ExtraBigPackageId,		@BaseEspSTDPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @STDTypeId, @EspTypeId, @OversizedPackageId,	@BaseEspSTDPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),

		-- COD
		(@TarifarioBasePorAplicar, @CODTypeId, @LocTypeId, @SmallPackageId,		@BaseLocCODPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @LocTypeId, @MediumPackageId,		@BaseLocCODPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @LocTypeId, @BigPackageId,			@BaseLocCODPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @LocTypeId, @ExtraBigPackageId,		@BaseLocCODPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @LocTypeId, @OversizedPackageId,	@BaseLocCODPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),

		(@TarifarioBasePorAplicar, @CODTypeId, @MetTypeId, @SmallPackageId,		@BaseMetCODPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @MetTypeId, @MediumPackageId,		@BaseMetCODPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @MetTypeId, @BigPackageId,			@BaseMetCODPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @MetTypeId, @ExtraBigPackageId,		@BaseMetCODPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @MetTypeId, @OversizedPackageId,	@BaseMetCODPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),

		(@TarifarioBasePorAplicar, @CODTypeId, @ForTypeId, @SmallPackageId,		@BaseForCODPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @ForTypeId, @MediumPackageId,		@BaseForCODPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @ForTypeId, @BigPackageId,			@BaseForCODPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @ForTypeId, @ExtraBigPackageId,		@BaseForCODPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @ForTypeId, @OversizedPackageId,	@BaseForCODPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		
		(@TarifarioBasePorAplicar, @CODTypeId, @EspTypeId, @SmallPackageId,		@BaseEspCODPrice + (@SmallPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @EspTypeId, @MediumPackageId,		@BaseEspCODPrice + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @EspTypeId, @BigPackageId,			@BaseEspCODPrice + (@BigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @EspTypeId, @ExtraBigPackageId,		@BaseEspCODPrice + (@ExtraBigPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioBasePorAplicar, @CODTypeId, @EspTypeId, @OversizedPackageId,	@BaseEspCODPrice + (@OversizedPackageWeight - @SmallPackageWeight)	, 1, 'SYS-ARUIZ', GETDATE())

		-- ARTÍCULOS VIEJOS
		-- LOCAL
		INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
			(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
		SELECT
			@TarifarioBasePorAplicar, NULL, @LocTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
		WHERE
			ABC.Code LIKE 'EXP%'
			AND
			ABC.AbcId NOT IN (
				@FilePackageId
				,@SmallPackageId
				,@MediumPackageId
				,@BigPackageId
				,@ExtraBigPackageId
				,@OversizedPackageId
			)

		-- METRO
		INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
			(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
		SELECT
			@TarifarioBasePorAplicar, NULL, @MetTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
		WHERE
			ABC.Code LIKE 'EXP%'
			AND
			ABC.AbcId NOT IN (
				@FilePackageId
				,@SmallPackageId
				,@MediumPackageId
				,@BigPackageId
				,@ExtraBigPackageId
				,@OversizedPackageId
			)

		--FORANEO
		INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
			(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
		SELECT
			@TarifarioBasePorAplicar, NULL, @ForTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
		WHERE
			ABC.Code LIKE 'EXP%'
			AND
			ABC.AbcId NOT IN (
				@FilePackageId
				,@SmallPackageId
				,@MediumPackageId
				,@BigPackageId
				,@ExtraBigPackageId
				,@OversizedPackageId
			)

		--ESPECIAL
		INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
			(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
		SELECT
			@TarifarioBasePorAplicar, NULL, @EspTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
		WHERE
			ABC.Code LIKE 'EXP%'
			AND
			ABC.AbcId NOT IN (
				@FilePackageId
				,@SmallPackageId
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
		(@TarifarioAlternoPorAplicar, @STDTypeId, @LocTypeId, @SmallPackageId,			@BaseLocSTDPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @LocTypeId, @MediumPackageId,		@BaseLocSTDPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @LocTypeId, @BigPackageId,			@BaseLocSTDPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @LocTypeId, @ExtraBigPackageId,		@BaseLocSTDPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @LocTypeId, @OversizedPackageId,		@BaseLocSTDPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),

		(@TarifarioAlternoPorAplicar, @STDTypeId, @MetTypeId, @SmallPackageId,			@BaseMetSTDPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @MetTypeId, @MediumPackageId,		@BaseMetSTDPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @MetTypeId, @BigPackageId,			@BaseMetSTDPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @MetTypeId, @ExtraBigPackageId,		@BaseMetSTDPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @MetTypeId, @OversizedPackageId,		@BaseMetSTDPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),

		(@TarifarioAlternoPorAplicar, @STDTypeId, @ForTypeId, @SmallPackageId,			@BaseForSTDPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @ForTypeId, @MediumPackageId,		@BaseForSTDPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @ForTypeId, @BigPackageId,			@BaseForSTDPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @ForTypeId, @ExtraBigPackageId,		@BaseForSTDPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @ForTypeId, @OversizedPackageId,		@BaseForSTDPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		
		(@TarifarioAlternoPorAplicar, @STDTypeId, @EspTypeId, @SmallPackageId,			@BaseEspSTDPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @EspTypeId, @MediumPackageId,		@BaseEspSTDPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @EspTypeId, @BigPackageId,			@BaseEspSTDPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @EspTypeId, @ExtraBigPackageId,		@BaseEspSTDPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @STDTypeId, @EspTypeId, @OversizedPackageId,		@BaseEspSTDPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),

		-- COD
		(@TarifarioAlternoPorAplicar, @CODTypeId, @LocTypeId, @SmallPackageId,			@BaseLocCODPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @LocTypeId, @MediumPackageId,		@BaseLocCODPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @LocTypeId, @BigPackageId,			@BaseLocCODPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @LocTypeId, @ExtraBigPackageId,		@BaseLocCODPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @LocTypeId, @OversizedPackageId,		@BaseLocCODPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),

		(@TarifarioAlternoPorAplicar, @CODTypeId, @MetTypeId, @SmallPackageId,			@BaseMetCODPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @MetTypeId, @MediumPackageId,		@BaseMetCODPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @MetTypeId, @BigPackageId,			@BaseMetCODPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @MetTypeId, @ExtraBigPackageId,		@BaseMetCODPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @MetTypeId, @OversizedPackageId,		@BaseMetCODPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),

		(@TarifarioAlternoPorAplicar, @CODTypeId, @ForTypeId, @SmallPackageId,			@BaseForCODPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @ForTypeId, @MediumPackageId,		@BaseForCODPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @ForTypeId, @BigPackageId,			@BaseForCODPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @ForTypeId, @ExtraBigPackageId,		@BaseForCODPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @ForTypeId, @OversizedPackageId,		@BaseForCODPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		
		(@TarifarioAlternoPorAplicar, @CODTypeId, @EspTypeId, @SmallPackageId,			@BaseEspCODPrice - @ExpressCenterDiscount + (@SmallPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @EspTypeId, @MediumPackageId,		@BaseEspCODPrice - @ExpressCenterDiscount + (@MediumPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @EspTypeId, @BigPackageId,			@BaseEspCODPrice - @ExpressCenterDiscount + (@BigPackageWeight - @SmallPackageWeight)			, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @EspTypeId, @ExtraBigPackageId,		@BaseEspCODPrice - @ExpressCenterDiscount + (@ExtraBigPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE()),
		(@TarifarioAlternoPorAplicar, @CODTypeId, @EspTypeId, @OversizedPackageId,		@BaseEspCODPrice - @ExpressCenterDiscount + (@OversizedPackageWeight - @SmallPackageWeight)		, 1, 'SYS-ARUIZ', GETDATE())
	
		-- ARTÍCULOS VIEJOS
		-- LOCAL
		INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
			(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
		SELECT
			@TarifarioAlternoPorAplicar, NULL, @LocTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
		WHERE
			ABC.Code LIKE 'EXP%'
			AND
			ABC.AbcId NOT IN (
				@FilePackageId
				,@SmallPackageId
				,@MediumPackageId
				,@BigPackageId
				,@ExtraBigPackageId
				,@OversizedPackageId
			)

		-- METRO
		INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
			(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
		SELECT
			@TarifarioAlternoPorAplicar, NULL, @MetTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
		WHERE
			ABC.Code LIKE 'EXP%'
			AND
			ABC.AbcId NOT IN (
				@FilePackageId
				,@SmallPackageId
				,@MediumPackageId
				,@BigPackageId
				,@ExtraBigPackageId
				,@OversizedPackageId
			)

		--FORANEO
		INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
			(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
		SELECT
			@TarifarioAlternoPorAplicar, NULL, @ForTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
		WHERE
			ABC.Code LIKE 'EXP%'
			AND
			ABC.AbcId NOT IN (
				@FilePackageId
				,@SmallPackageId
				,@MediumPackageId
				,@BigPackageId
				,@ExtraBigPackageId
				,@OversizedPackageId
			)

		--ESPECIAL
		INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
			(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
		SELECT
			@TarifarioAlternoPorAplicar, NULL, @EspTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
		WHERE
			ABC.Code LIKE 'EXP%'
			AND
			ABC.AbcId NOT IN (
				@FilePackageId
				,@SmallPackageId
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
	--	RD.RateId = @TarifarioBasePorAplicar
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
	--	RD.RateId = @TarifarioAlternoPorAplicar
	--ORDER BY
	--	CRS.CrsId ASC,
	--	CTS.CtsId DESC,
	--	ABC.Code ASC

	-- Limpiar coberturas
	DELETE
		FROM
			[DeliveryBackOffice].[dbo].[RateTownshipCoverage]
	WHERE
		RateId = @TarifarioBasePorAplicar

	DELETE
		FROM
			[DeliveryBackOffice].[dbo].[RateTownshipCoverage]
	WHERE
		RateId = @TarifarioAlternoPorAplicar

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
		@TarifarioBasePorAplicar, TwnOrig.IdTownship, TwnDest.IdTownship, @LocTypeId, 1, 'SYS-ARUIZ', GETDATE()
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
				RTCCheck.RateId = @TarifarioBasePorAplicar
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
		@TarifarioAlternoPorAplicar, TwnOrig.IdTownship, TwnDest.IdTownship, @LocTypeId, 1, 'SYS-ARUIZ', GETDATE()
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
				RTCCheck.RateId = @TarifarioAlternoPorAplicar
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
		@TarifarioBasePorAplicar
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
				RTCCheck.RateId = @TarifarioBasePorAplicar
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
		@TarifarioAlternoPorAplicar
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
				RTCCheck.RateId = @TarifarioAlternoPorAplicar
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
		@TarifarioBasePorAplicar
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
				RTCCheck.RateId = @TarifarioBasePorAplicar
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
		@TarifarioAlternoPorAplicar
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
				RTCCheck.RateId = @TarifarioAlternoPorAplicar
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
	--	RTC.RateId = @TarifarioBasePorAplicar
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
	--	RTC.RateId = @TarifarioAlternoPorAplicar
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