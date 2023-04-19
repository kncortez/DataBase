USE [DeliveryBackOffice];
GO

CREATE PROCEDURE [dbo].[SPHAW_GetDashboardData]

	@AffiliateFilter BIGINT = NULL,
	@AffiliateUserFilter BIGINT = NULL,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL

AS
BEGIN
	-- Manejo de fechas
	IF(@EndDate IS NULL)
	BEGIN

		SET @EndDate = DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(GETDATE() AS DATE) AS DATETIME)))

	END
	ELSE 
	BEGIN

		SET @EndDate = DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(@EndDate AS DATE) AS DATETIME)))

	END

	IF(@StartDate IS NULL)
	BEGIN

		SET @StartDate = CAST(CAST(DATEADD(DAY,-7,@EndDate) AS DATE) AS DATETIME)

	END
	ELSE
	BEGIN

		SET @StartDate = CAST(CAST(@StartDate AS DATE) AS DATETIME)

	END

	IF(DATEDIFF(DAY,@StartDate, @EndDate) > 30)
	BEGIN

		SET @StartDate = CAST(CAST(DATEADD(DAY,-30,@EndDate) AS DATE) AS DATETIME)

	END

	DECLARE @MembershipUsageByAffiliateData TABLE (
		CustomerId INT,
		CustomerName NVARCHAR(600),
		CustomerMembership INT,

		RegisterUserId BIGINT,
		RegisterUserName NVARCHAR(600),

		TransactionDatetime DATETIME,
		TransactionDate DATE,
		IdMembershipUsageByAffiliate BIGINT,

		FinalAmount DECIMAL(18,2),
		DiscountGiven DECIMAL(18,2)
	);

	BEGIN TRY


	IF (
		-- Busqueda de datos especificando usuario de afiliado
		(@AffiliateFilter IS NULL AND @AffiliateUserFilter IS NOT NULL)
		OR
		(@AffiliateFilter IS NOT NULL AND @AffiliateUserFilter IS NOT NULL)
	)
	BEGIN

		SET @AffiliateFilter = (SELECT TOP 1 RUBA.AffiliateId FROM [DeliveryBackOffice].[dbo].[RegisterUserByAffiliate] RUBA WITH(NOLOCK) WHERE RUBA.RegisterUserId = @AffiliateUserFilter AND RUBA.RowStatus = 1)

		INSERT INTO @MembershipUsageByAffiliateData
			(
				CustomerId,
				CustomerName,
				CustomerMembership,

				TransactionDatetime,
				TransactionDate,
				IdMembershipUsageByAffiliate,

				FinalAmount,
				DiscountGiven
			)
		SELECT
			Cu.IdCustomer,
			Cu.[Name],
			MMBSHP.IdMembership,

			MUBA.DateCreated,
			CAST(MUBA.DateCreated AS DATE),
			MUBA.IdMembershipUsageByAffiliate,

			MUBA.FinalAmount,
			MUBA.DiscountApplied
		FROM
			[DeliveryBackOffice].[dbo].[MembershipUsageByAffiliate] MUBA WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Membership] MMBSHP WITH(NOLOCK)
				ON
					MUBA.MembershipId = MMBSHP.IdMembership
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
				ON
					MMBSHP.CustomerId = Cu.IdCustomer
		WHERE
			MUBA.AffiliateId = @AffiliateFilter
			AND
			MUBA.RegisterUserId = @AffiliateUserFilter
			AND
			MUBA.DateCreated BETWEEN @StartDate AND @EndDate
			AND
			MUBA.RowStatus = 1;

		IF(EXISTS(SELECT TOP 1 1 FROM @MembershipUsageByAffiliateData))
		BEGIN
	
			SELECT
				200 'responseCode',
				'Exito recuperando datos' 'responseMessage'
			
			SELECT
				COUNT(DISTINCT MUBAD.CustomerId) 'UniqueCustomers'
			FROM
				@MembershipUsageByAffiliateData MUBAD

			SELECT
				DISTINCT
					MUBAD.CustomerId,
					MUBAD.CustomerName
			FROM
				@MembershipUsageByAffiliateData MUBAD

			SELECT
				MUBAD.TransactionDate,
				COUNT(DISTINCT MUBAD.IdMembershipUsageByAffiliate) 'TotalTransactions'
			FROM
				@MembershipUsageByAffiliateData MUBAD
			GROUP BY
				MUBAD.TransactionDate

			SELECT
				SUM(MUBAD.FinalAmount) 'TotalFinalAmount',
				SUM(MUBAD.DiscountGiven) 'TotalDisountGiven'
			FROM
				@MembershipUsageByAffiliateData MUBAD

			SELECT
				MUBAD.IdMembershipUsageByAffiliate,
				MUBAD.TransactionDate,
				MUBAD.CustomerName,
				MUBAD.FinalAmount,
				MUBAD.DiscountGiven
			FROM
				@MembershipUsageByAffiliateData MUBAD

		END
		ELSE
		BEGIN

			SELECT
				204 'responseCode',
				'No existen datos para filtros indicados' 'responseMessage'

		END

	END
	ELSE IF (
		-- Busqueda de datos para administrador, buscar por todos los usuarios del afiliado
		(@AffiliateFilter IS NOT NULL AND @AffiliateUserFilter IS NULL)
	)
	BEGIN

		INSERT INTO @MembershipUsageByAffiliateData
			(
				CustomerId,
				CustomerName,
				CustomerMembership,

				RegisterUserId,
				RegisterUserName,

				TransactionDatetime,
				TransactionDate,
				IdMembershipUsageByAffiliate,

				FinalAmount,
				DiscountGiven
			)
		SELECT
			Cu.IdCustomer,
			Cu.[Name],
			MMBSHP.IdMembership,

			MUBA.RegisterUserId,
			RU.UsrNickName,

			MUBA.DateCreated,
			CAST(MUBA.DateCreated AS DATE),
			MUBA.IdMembershipUsageByAffiliate,

			MUBA.FinalAmount,
			MUBA.DiscountApplied
		FROM
			[DeliveryBackOffice].[dbo].[RegisterUserByAffiliate] RUBA WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[RegisterUser] RU WITH(NOLOCK)
				ON
					RUBA.RegisterUserId = RU.UsrIdUser
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[MembershipUsageByAffiliate] MUBA WITH(NOLOCK)
				ON
					RUBA.RegisterUserId = MUBA.RegisterUserId
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Membership] MMBSHP WITH(NOLOCK)
				ON
					MUBA.MembershipId = MMBSHP.IdMembership
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
				ON
					MMBSHP.CustomerId = Cu.IdCustomer
		WHERE
			RUBA.AffiliateId = @AffiliateFilter
			AND
			MUBA.DateCreated BETWEEN @StartDate AND @EndDate
			AND
			MUBA.RowStatus = 1;

		IF(EXISTS(SELECT TOP 1 1 FROM @MembershipUsageByAffiliateData))
		BEGIN
	
			SELECT
				200 'responseCode',
				'Exito recuperando datos' 'responseMessage'
			
			SELECT
				COUNT(DISTINCT MUBAD.CustomerId) 'UniqueCustomers'
			FROM
				@MembershipUsageByAffiliateData MUBAD

			SELECT
				DISTINCT
					MUBAD.CustomerId,
					MUBAD.CustomerName
			FROM
				@MembershipUsageByAffiliateData MUBAD
			
			SELECT
				MUBAD.TransactionDate,
				COUNT(DISTINCT MUBAD.IdMembershipUsageByAffiliate) 'TotalTransactions'
			FROM
				@MembershipUsageByAffiliateData MUBAD
			GROUP BY
				MUBAD.TransactionDate

			SELECT
				MUBAD.TransactionDate,
				MUBAD.RegisterUserName,
				COUNT(DISTINCT MUBAD.IdMembershipUsageByAffiliate) 'TotalTransactions'
			FROM
				@MembershipUsageByAffiliateData MUBAD
			GROUP BY
				MUBAD.TransactionDate,
				MUBAD.RegisterUserName
			
			SELECT
				SUM(MUBAD.FinalAmount) 'TotalFinalAmount',
				SUM(MUBAD.DiscountGiven) 'TotalDisountGiven'
			FROM
				@MembershipUsageByAffiliateData MUBAD

			SELECT
				MUBAD.RegisterUserName,
				SUM(MUBAD.FinalAmount) 'TotalFinalAmount',
				SUM(MUBAD.DiscountGiven) 'TotalDisountGiven'
			FROM
				@MembershipUsageByAffiliateData MUBAD
			GROUP BY
				MUBAD.RegisterUserName

			SELECT
				MUBAD.IdMembershipUsageByAffiliate,
				MUBAD.RegisterUserName,
				MUBAD.TransactionDate,
				MUBAD.CustomerName,
				MUBAD.FinalAmount,
				MUBAD.DiscountGiven
			FROM
				@MembershipUsageByAffiliateData MUBAD

		END
		ELSE
		BEGIN

			SELECT
				204 'responseCode',
				'No existen datos para filtros indicados' 'responseMessage'

		END

	END
	ELSE
	BEGIN

		SELECT
			204 'responseCode',
			'No existen datos para filtros indicados' 'responseMessage'

	END

	END TRY
	BEGIN CATCH

		SELECT
			500 'responseCode',
			ERROR_MESSAGE() 'responseMessage'

	END CATCH

END