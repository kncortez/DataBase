
-- Tarifarios
DECLARE @NewMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI);
DECLARE @NewAlternativeMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI);

-- Tipo de servicio	
DECLARE @StandardTypeId INT = (SELECT TOP 1 CTS.CtsId FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsName = 'Estandar' COLLATE Latin1_General_CI_AI)
DECLARE @StandardCoDTypeId INT = (SELECT TOP 1 CTS.CtsId FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsName = 'Estandar CoD' COLLATE Latin1_General_CI_AI)

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

-- Precios
DECLARE @BasePrice DECIMAL(5,2) = 25.99; -- Base 25.99
DECLARE @MetroBasePrice DECIMAL(5,2) = @BasePrice + 4; -- +4
DECLARE @ForeignBasePrice DECIMAL(5,2) = 39.99; -- Base 39.99
DECLARE @EspecialBasePrice DECIMAL(5,2) = @ForeignBasePrice + 4;

DECLARE @BasePriceCoD DECIMAL(5,2) = @BasePrice - 3; -- Base 25.99
DECLARE @MetroBasePriceCoD DECIMAL(5,2) = @BasePriceCoD + 4; -- +4
DECLARE @ForeignBasePriceCoD DECIMAL(5,2) = @ForeignBasePrice - 3; -- Base 39.99
DECLARE @EspecialBasePriceCoD DECIMAL(5,2) = @ForeignBasePriceCoD + 4;
-- Precios alternativos
DECLARE @AlternativeBasePrice DECIMAL(5,2) = 20.99; -- Base 20.99
DECLARE @MetroAlternativeBasePrice DECIMAL(5,2) = @AlternativeBasePrice + 4; -- +4
DECLARE @ForeignAlternativeBasePrice DECIMAL(5,2) = 34.99; -- Base 34.99
DECLARE @EspecialAlternativeBasePrice DECIMAL(5,2) = @ForeignAlternativeBasePrice + 4; -- Base 34.99

DECLARE @AlternativeBasePriceCoD DECIMAL(5,2) = @AlternativeBasePrice- 3; -- Base 20.99
DECLARE @MetroAlternativeBasePriceCoD DECIMAL(5,2) = @AlternativeBasePriceCoD + 4; -- +4
DECLARE @ForeignAlternativeBasePriceCoD DECIMAL(5,2) = @ForeignAlternativeBasePrice - 3; -- Base 34.99
DECLARE @EspecialAlternativeBasePriceCoD DECIMAL(5,2) = @ForeignAlternativeBasePriceCoD + 4; -- Base 34.99

DECLARE @CanContinue BIT = 0;

BEGIN TRANSACTION
BEGIN TRY
	-- Insertar información de tarifario a principal
	INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
		(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
	VALUES
		-- ARTÍCULOS NUEVOS
		-- STANDARD
		(@NewMainRates, @StandardTypeId, @LocTypeId, @SmallPackageId,		(@BasePrice), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewMainRates, @StandardTypeId, @LocTypeId, @MediumPackageId,		(@BasePrice+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewMainRates, @StandardTypeId, @LocTypeId, @BigPackageId,			(@BasePrice+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewMainRates, @StandardTypeId, @LocTypeId, @ExtraBigPackageId,	(@BasePrice+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewMainRates, @StandardTypeId, @LocTypeId, @OversizedPackageId,	(@BasePrice+15), 1, 'SYS-ARUIZ', GETDATE()), -- +15

		(@NewMainRates, @StandardTypeId, @MetTypeId, @SmallPackageId,		(@MetroBasePrice), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewMainRates, @StandardTypeId, @MetTypeId, @MediumPackageId,		(@MetroBasePrice+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewMainRates, @StandardTypeId, @MetTypeId, @BigPackageId,			(@MetroBasePrice+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewMainRates, @StandardTypeId, @MetTypeId, @ExtraBigPackageId,	(@MetroBasePrice+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewMainRates, @StandardTypeId, @MetTypeId, @OversizedPackageId,	(@MetroBasePrice+15), 1, 'SYS-ARUIZ', GETDATE()), -- +15

		(@NewMainRates, @StandardTypeId, @ForTypeId, @SmallPackageId,		(@ForeignBasePrice), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewMainRates, @StandardTypeId, @ForTypeId, @MediumPackageId,		(@ForeignBasePrice+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewMainRates, @StandardTypeId, @ForTypeId, @BigPackageId,			(@ForeignBasePrice+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewMainRates, @StandardTypeId, @ForTypeId, @ExtraBigPackageId,	(@ForeignBasePrice+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewMainRates, @StandardTypeId, @ForTypeId, @OversizedPackageId,	(@ForeignBasePrice+15), 1, 'SYS-ARUIZ', GETDATE()), -- +15

		(@NewMainRates, @StandardTypeId, @EspTypeId, @SmallPackageId,		(@EspecialBasePrice), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewMainRates, @StandardTypeId, @EspTypeId, @MediumPackageId,		(@EspecialBasePrice+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewMainRates, @StandardTypeId, @EspTypeId, @BigPackageId,			(@EspecialBasePrice+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewMainRates, @StandardTypeId, @EspTypeId, @ExtraBigPackageId,	(@EspecialBasePrice+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewMainRates, @StandardTypeId, @EspTypeId, @OversizedPackageId,	(@EspecialBasePrice+15), 1, 'SYS-ARUIZ', GETDATE()), -- +15

		-- STANDARD COD
		(@NewMainRates, @StandardCoDTypeId, @LocTypeId, @SmallPackageId,	(@BasePriceCoD), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewMainRates, @StandardCoDTypeId, @LocTypeId, @MediumPackageId,	(@BasePriceCoD+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewMainRates, @StandardCoDTypeId, @LocTypeId, @BigPackageId,		(@BasePriceCoD+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewMainRates, @StandardCoDTypeId, @LocTypeId, @ExtraBigPackageId,	(@BasePriceCoD+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewMainRates, @StandardCoDTypeId, @LocTypeId, @OversizedPackageId,(@BasePriceCoD+15), 1, 'SYS-ARUIZ', GETDATE()), -- +15

		(@NewMainRates, @StandardCoDTypeId, @MetTypeId, @SmallPackageId,	(@MetroBasePriceCoD), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewMainRates, @StandardCoDTypeId, @MetTypeId, @MediumPackageId,	(@MetroBasePriceCoD+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewMainRates, @StandardCoDTypeId, @MetTypeId, @BigPackageId,		(@MetroBasePriceCoD+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewMainRates, @StandardCoDTypeId, @MetTypeId, @ExtraBigPackageId,	(@MetroBasePriceCoD+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewMainRates, @StandardCoDTypeId, @MetTypeId, @OversizedPackageId,(@MetroBasePriceCoD+15), 1, 'SYS-ARUIZ', GETDATE()), -- +15

		(@NewMainRates, @StandardCoDTypeId, @ForTypeId, @SmallPackageId,	(@ForeignBasePriceCoD), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewMainRates, @StandardCoDTypeId, @ForTypeId, @MediumPackageId,	(@ForeignBasePriceCoD+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewMainRates, @StandardCoDTypeId, @ForTypeId, @BigPackageId,		(@ForeignBasePriceCoD+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewMainRates, @StandardCoDTypeId, @ForTypeId, @ExtraBigPackageId,	(@ForeignBasePriceCoD+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewMainRates, @StandardCoDTypeId, @ForTypeId, @OversizedPackageId,(@ForeignBasePriceCoD+15), 1, 'SYS-ARUIZ', GETDATE()),  -- +15

		(@NewMainRates, @StandardCoDTypeId, @EspTypeId, @SmallPackageId,	(@EspecialBasePriceCoD), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewMainRates, @StandardCoDTypeId, @EspTypeId, @MediumPackageId,	(@EspecialBasePriceCoD+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewMainRates, @StandardCoDTypeId, @EspTypeId, @BigPackageId,		(@EspecialBasePriceCoD+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewMainRates, @StandardCoDTypeId, @EspTypeId, @ExtraBigPackageId,	(@EspecialBasePriceCoD+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewMainRates, @StandardCoDTypeId, @EspTypeId, @OversizedPackageId,(@EspecialBasePriceCoD+15), 1, 'SYS-ARUIZ', GETDATE())  -- +15
	
	-- Insertar información de tarifario alternativo
	INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
		(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
	VALUES
		-- ARTÍCULOS NUEVOS
		-- STANDARD
		(@NewAlternativeMainRates, @StandardTypeId, @LocTypeId, @SmallPackageId,		(@AlternativeBasePrice), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewAlternativeMainRates, @StandardTypeId, @LocTypeId, @MediumPackageId,		(@AlternativeBasePrice+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewAlternativeMainRates, @StandardTypeId, @LocTypeId, @BigPackageId,			(@AlternativeBasePrice+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewAlternativeMainRates, @StandardTypeId, @LocTypeId, @ExtraBigPackageId,		(@AlternativeBasePrice+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewAlternativeMainRates, @StandardTypeId, @LocTypeId, @OversizedPackageId,	(@AlternativeBasePrice+15), 1, 'SYS-ARUIZ', GETDATE()), -- +15

		(@NewAlternativeMainRates, @StandardTypeId, @MetTypeId, @SmallPackageId,		(@MetroAlternativeBasePrice), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewAlternativeMainRates, @StandardTypeId, @MetTypeId, @MediumPackageId,		(@MetroAlternativeBasePrice+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewAlternativeMainRates, @StandardTypeId, @MetTypeId, @BigPackageId,			(@MetroAlternativeBasePrice+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewAlternativeMainRates, @StandardTypeId, @MetTypeId, @ExtraBigPackageId,		(@MetroAlternativeBasePrice+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewAlternativeMainRates, @StandardTypeId, @MetTypeId, @OversizedPackageId,	(@MetroAlternativeBasePrice+15), 1, 'SYS-ARUIZ', GETDATE()), -- +15

		(@NewAlternativeMainRates, @StandardTypeId, @ForTypeId, @SmallPackageId,		(@ForeignAlternativeBasePrice), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewAlternativeMainRates, @StandardTypeId, @ForTypeId, @MediumPackageId,		(@ForeignAlternativeBasePrice+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewAlternativeMainRates, @StandardTypeId, @ForTypeId, @BigPackageId,			(@ForeignAlternativeBasePrice+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewAlternativeMainRates, @StandardTypeId, @ForTypeId, @ExtraBigPackageId,		(@ForeignAlternativeBasePrice+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewAlternativeMainRates, @StandardTypeId, @ForTypeId, @OversizedPackageId,	(@ForeignAlternativeBasePrice+15), 1, 'SYS-ARUIZ', GETDATE()), -- +15
	
		(@NewAlternativeMainRates, @StandardTypeId, @EspTypeId, @SmallPackageId,		(@EspecialAlternativeBasePrice), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewAlternativeMainRates, @StandardTypeId, @EspTypeId, @MediumPackageId,		(@EspecialAlternativeBasePrice+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewAlternativeMainRates, @StandardTypeId, @EspTypeId, @BigPackageId,			(@EspecialAlternativeBasePrice+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewAlternativeMainRates, @StandardTypeId, @EspTypeId, @ExtraBigPackageId,		(@EspecialAlternativeBasePrice+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewAlternativeMainRates, @StandardTypeId, @EspTypeId, @OversizedPackageId,	(@EspecialAlternativeBasePrice+15), 1, 'SYS-ARUIZ', GETDATE()), -- +15

		-- STANDARD COD
		(@NewAlternativeMainRates, @StandardCoDTypeId, @LocTypeId, @SmallPackageId,		(@AlternativeBasePriceCoD), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewAlternativeMainRates, @StandardCoDTypeId, @LocTypeId, @MediumPackageId,	(@AlternativeBasePriceCoD+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewAlternativeMainRates, @StandardCoDTypeId, @LocTypeId, @BigPackageId,		(@AlternativeBasePriceCoD+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewAlternativeMainRates, @StandardCoDTypeId, @LocTypeId, @ExtraBigPackageId,	(@AlternativeBasePriceCoD+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewAlternativeMainRates, @StandardCoDTypeId, @LocTypeId, @OversizedPackageId,	(@AlternativeBasePriceCoD+15), 1, 'SYS-ARUIZ', GETDATE()), -- +15

		(@NewAlternativeMainRates, @StandardCoDTypeId, @MetTypeId, @SmallPackageId,		(@MetroAlternativeBasePriceCoD), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewAlternativeMainRates, @StandardCoDTypeId, @MetTypeId, @MediumPackageId,	(@MetroAlternativeBasePriceCoD+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewAlternativeMainRates, @StandardCoDTypeId, @MetTypeId, @BigPackageId,		(@MetroAlternativeBasePriceCoD+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewAlternativeMainRates, @StandardCoDTypeId, @MetTypeId, @ExtraBigPackageId,	(@MetroAlternativeBasePriceCoD+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewAlternativeMainRates, @StandardCoDTypeId, @MetTypeId, @OversizedPackageId,	(@MetroAlternativeBasePriceCoD+15), 1, 'SYS-ARUIZ', GETDATE()), -- +15

		(@NewAlternativeMainRates, @StandardCoDTypeId, @ForTypeId, @SmallPackageId,		(@ForeignAlternativeBasePriceCoD), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewAlternativeMainRates, @StandardCoDTypeId, @ForTypeId, @MediumPackageId,	(@ForeignAlternativeBasePriceCoD+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewAlternativeMainRates, @StandardCoDTypeId, @ForTypeId, @BigPackageId,		(@ForeignAlternativeBasePriceCoD+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewAlternativeMainRates, @StandardCoDTypeId, @ForTypeId, @ExtraBigPackageId,	(@ForeignAlternativeBasePriceCoD+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewAlternativeMainRates, @StandardCoDTypeId, @ForTypeId, @OversizedPackageId,	(@ForeignAlternativeBasePriceCoD+15), 1, 'SYS-ARUIZ', GETDATE()),  -- +15
	
		(@NewAlternativeMainRates, @StandardCoDTypeId, @EspTypeId, @SmallPackageId,		(@EspecialAlternativeBasePriceCoD), 1, 'SYS-ARUIZ', GETDATE()), -- Base
		(@NewAlternativeMainRates, @StandardCoDTypeId, @EspTypeId, @MediumPackageId,	(@EspecialAlternativeBasePriceCoD+3), 1, 'SYS-ARUIZ', GETDATE()), -- +3
		(@NewAlternativeMainRates, @StandardCoDTypeId, @EspTypeId, @BigPackageId,		(@EspecialAlternativeBasePriceCoD+8), 1, 'SYS-ARUIZ', GETDATE()), -- +8
		(@NewAlternativeMainRates, @StandardCoDTypeId, @EspTypeId, @ExtraBigPackageId,	(@EspecialAlternativeBasePriceCoD+12), 1, 'SYS-ARUIZ', GETDATE()), -- +12
		(@NewAlternativeMainRates, @StandardCoDTypeId, @EspTypeId, @OversizedPackageId,	(@EspecialAlternativeBasePriceCoD+15), 1, 'SYS-ARUIZ', GETDATE())  -- +15

	IF(@@TRANCOUNT > 0)
		COMMIT TRANSACTION;

	SET @CanContinue = 1;

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	SET @CanContinue = 0;
END CATCH

IF(@CanContinue = 1)
BEGIN

	BEGIN TRANSACTION
	BEGIN TRY
	---- ARTÍCULOS IRREGULARES
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
	
		-- ARTÍCULOS IRREGULARES
		INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
			(RateId, TypeServiceId, TypeSegmentId, ArticleId, RateValue, RowStatus, TokenCreated, DateCreated)
		SELECT
			@NewAlternativeMainRates, NULL, @EspTypeId, ABC.AbcId, ABC.PriceDefault, 1, 'SYS-ARUIZ', GETDATE()
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
					RD.RateId = @NewAlternativeMainRates
		)

		IF(@@TRANCOUNT > 0)
			COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
	END CATCH

END
