CREATE PROCEDURE [dbo].[CreateCouponData]  
  @TokenUser NVARCHAR(50) = 'SYS-BHERRERA'
 ,@CouponPrefix NVARCHAR(5) = 'RCR'
 ,@CouponQuantity INT = 0
 ,@TargetCustomer INT = NULL
 ,@TargetCustomerVisitPoint INT = NULL
 ,@TargetCustomerVisitPointPortfolio INT = NULL
 ,@DiscountType NVARCHAR(50) = 'Guías a 2x1'
 ,@StartDate DATE = NULL
 ,@DaysToAdd INT = NULL
 ,@EndDate DATE = '2023-12-31'
AS
BEGIN

--DECLARE @TokenUser NVARCHAR(50) = 'SYS-BHERRERA'
--DECLARE @CouponPrefix NVARCHAR(5) = 'RCR'
--DECLARE @CouponQuantity INT = 20;
--DECLARE @TargetCustomer INT = 163;
--DECLARE @TargetCustomerVisitPoint INT = NULL;
--DECLARE @TargetCustomerVisitPointPortfolio INT = NULL;
--DECLARE @DiscountType NVARCHAR(50) = 'Guías a 2x1';

--DECLARE @StartDate DATE = NULL;
--DECLARE @DaysToAdd INT = NULL;
--DECLARE @EndDate DATE = '2023-12-31';



BEGIN TRANSACTION
BEGIN TRY

	DECLARE @PromoId INT = (SELECT TOP 1 CP.IdPromo FROM [DeliveryBackOffice].[dbo].[CatPromo] CP WITH(NOLOCK) WHERE CP.PromoDescription = @DiscountType COLLATE Latin1_General_CI_AI AND CP.RowStatus = 1);
	DECLARE @SystemId INT = (SELECT TOP 1 CS.SysIdSystem FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysNameSystem = 'Hermes Desktop' COLLATE Latin1_General_CI_AI);

	DECLARE @StartDatetime DATETIME = CAST(@StartDate AS DATETIME);
	DECLARE @EndDatetime DATETIME = CAST(@EndDate AS DATETIME);
	
	-- Fecha de inicio del cupon
	IF(@StartDatetime IS NULL)
	BEGIN
		SET @StartDatetime = CAST(GETDATE() AS DATE);
	END
	ELSE
	BEGIN

		SET @StartDatetime = CAST(CAST(@StartDatetime AS DATE) AS DATETIME)

	END

	IF(@EndDatetime IS NULL AND @DaysToAdd IS NULL)
	BEGIN
		SET @EndDatetime = DATEADD(SECOND, -1, DATEADD(DAY, 1, @StartDatetime));
	END
	ELSE IF (@EndDatetime IS NULL AND @DaysToAdd IS NOT NULL)
	BEGIN
		IF (@DaysToAdd < 0)
		BEGIN
			;THROW 50001, 'Días por adicionar no deben ser menores a 0', 1;
		END

		SET @EndDatetime = DATEADD(SECOND, -1, DATEADD(DAY, @DaysToAdd, @StartDatetime))
	END
	ELSE IF(@EndDatetime IS NOT NULL AND @DaysToAdd IS NULL)
	BEGIN
	
		SET @EndDatetime = DATEADD(SECOND, -1, DATEADD(DAY, 1, @EndDatetime))

	END

	IF (@StartDatetime > @EndDatetime)
	BEGIN
	
		;THROW 50001, 'Fecha de fin de cupon es mayor a fecha de inicio', 1;

	END

	-- Generación de cupones
	IF (@PromoId IS NOT NULL AND @TargetCustomer IS NOT NULL AND @TokenUser IS NOT NULL)
	BEGIN

		DECLARE @CouponTable TABLE (
			RowNumber INT,
			CouponCode NVARCHAR(50)
		)

		-- Expresión de tabla comun
		;WITH CouponCodeTable (RowNumber, CouponCode) AS (
			SELECT
				1												AS 'RowNumber',
				CONCAT(@CouponPrefix,RIGHT(CONCAT('00000',RAND(CHECKSUM(NEWID()))),5))	AS 'CouponCode'
			UNION ALL
			SELECT
				(CCT.RowNumber + 1)								AS 'RowNumber',
				CONCAT(@CouponPrefix,RIGHT(CONCAT('00000',RAND(CHECKSUM(NEWID()))),5))	AS 'CouponCode'
			FROM
				CouponCodeTable CCT
			WHERE
				CCT.RowNumber < @CouponQuantity
		)

		INSERT INTO
			@CouponTable
			(RowNumber, CouponCode)
		SELECT
			RowNumber
			,CouponCode
		FROM
			CouponCodeTable
			
		INSERT INTO [DeliveryBackOffice].[dbo].[PromoCoupon]
			(
				CatPromoId,
				PromoCouponSerie,

				GuideSerieOrigin,
				GuideNumberOrigin,
				ServiceManagementOrigin,

				SystemOrigin,

				CustomerOrigin,
				VisitPointClientOrigin,
				VisitPointClientPortfolioOrigin,

				CatDiscountTypeId,
				CatValueTypeId,
				CouponValue,

				StartActiveDate,
				FinalActiveDate,
				RowStatus,
				DateCreated,
				TokenCreated
			)
		SELECT
			@PromoId 'CatPromoId',
			CT.CouponCode 'PromoCouponSerie',

			NULL 'GuideSerieOrigin',
			NULL 'GuideNumberOrigin',
			NULL 'ServiceManagementOrigin',

			@SystemId 'SystemOrigin',

			@TargetCustomer 'CustomerOrigin',
			@TargetCustomerVisitPoint 'VisitPointClientOrigin',
			@TargetCustomerVisitPointPortfolio 'VisitPointClientPortfolioOrigin',

			CP.CatDiscountTypeId 'CatDiscountTypeId',
			CP.CatValueTypeId 'CatValueTypeId',
			CP.PromoValue 'CouponValue',

			@StartDatetime 'StartActiveDate',
			@EndDatetime 'FinalActiveDate',
			1 'RowStatus',
			GETDATE() 'DateCreated',
			@TokenUser 'TokenCreated'
		FROM
			@CouponTable CT
			OUTER APPLY (
				SELECT
					*
				FROM
					[DeliveryBackOffice].[dbo].[CatPromo] CP WITH(NOLOCK)
				WHERE
					CP.IdPromo = @PromoId
			) CP
			
		COMMIT TRANSACTION
	
		SELECT
			200 'ResultCode',
			'Cupones generados' 'ResultMessage'

	END
	ELSE
	BEGIN
	
		;THROW 50001, 'Error con usuario objetivo o promoción elegida', 1;

	END
	
END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION

	SELECT
		500 'ResultCode',
		ERROR_MESSAGE() 'ResultMessage'

END CATCH
END