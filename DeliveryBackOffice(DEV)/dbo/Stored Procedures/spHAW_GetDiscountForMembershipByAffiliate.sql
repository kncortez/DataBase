
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-12-27>
-- Description:	< Obtener datos de descuento y vigencia de membresia para  >
-- =============================================

CREATE PROCEDURE [dbo].[spHAW_GetDiscountForMembershipByAffiliate]	
	@MembershipId INT
	,@UserId BIGINT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

		
	DECLARE @AffiliateId BIGINT
	DECLARE @VoidedMembership INT

	SET @AffiliateId = (SELECT TOP 1 RUBA.AffiliateId FROM [DeliveryBackOffice].[dbo].[RegisterUserByAffiliate] RUBA WITH(NOLOCK) WHERE RUBA.RegisterUserId = @UserId AND RUBA.RowStatus = 1)
	SET @VoidedMembership = (SELECT TOP 1 CSPS.IdCatSalesPackageStatus FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH(NOLOCK) WHERE CSPS.SalesPackageStatusName = 'Anulada' COLLATE Latin1_General_CI_AI)
	
	DECLARE @MembershipData TABLE (
		MembershipId INT,
		CatMembershipId INT,
		IsActive BIT
	);

	DECLARE @ResponseData TABLE (
		CustomerName NVARCHAR(500),
		MembershipName NVARCHAR(100),
		StatusName NVARCHAR(50),
		ExpirationDate DATETIME,
		DiscountType NVARCHAR(50),
		DiscountValue DECIMAL(5,2)
	);

	BEGIN TRY

		INSERT INTO @MembershipData
			(
				MembershipId
				, CatMembershipId
				, IsActive
			)
		SELECT
			Mmbrship.IdMembership
			,Mmbrship.CatMembershipId
			,(
				CASE
					WHEN Mmbrship.ExpirationDate >= GETDATE() AND Mmbrship.CatMembershipStatusId != @VoidedMembership AND Mmbrship.RowStatus != 0 THEN 1
					ELSE 0
				END
			)
		FROM
			[DeliveryBackOffice].[dbo].[Membership] Mmbrship WITH(NOLOCK)
		WHERE
			Mmbrship.IdMembership = @MembershipId

		-- Si se obtuvo información
		IF(EXISTS (SELECT TOP 1 1 FROM @MembershipData))
		BEGIN

			IF(ISNULL((SELECT TOP 1 MD.IsActive FROM @MembershipData MD),0) = 1)
			BEGIN

				INSERT INTO @ResponseData
					(
						CustomerName
						,MembershipName
						,StatusName
						,ExpirationDate
						,DiscountType
						,DiscountValue
					)
				SELECT
					Cu.[Name]
					,CMmbrship.MembershipName
					,(
						CASE
							WHEN MD.IsActive = 1 THEN 'Vigente'
							ELSE 'Inactivo'
						END
					) 'Status'
					,Mmbrship.ExpirationDate
					,ISNULL(CVT.ValueTypeDescription, 'N/A')
					,ISNULL(MAD.DiscountValue, 0)
				FROM
					@MembershipData MD
					INNER JOIN
						[DeliveryBackOffice].[dbo].[Membership] Mmbrship WITH(NOLOCK)
						ON
							MD.MembershipId = Mmbrship.IdMembership
					INNER JOIN
						[DeliveryBackOffice].[dbo].[CatMembership] CMmbrship WITH(NOLOCK)
						ON
							Mmbrship.CatMembershipId = CMmbrship.IdCatMembership
					INNER JOIN
						[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
						ON
							Mmbrship.CustomerId = Cu.IdCustomer
					LEFT JOIN
						[DeliveryBackOffice].[dbo].[MembershipAffiliateDiscount] MAD WITH(NOLOCK)
						ON
							Mmbrship.CatMembershipId = MAD.CatMembershipId
							AND
							MAD.AffiliateId = @AffiliateId
					LEFT JOIN
						[DeliveryBackOffice].[dbo].[CatValueType] CVT WITH(NOLOCK)
						ON
							MAD.DiscountValueType = CVT.IdCatValueType
						
				IF(EXISTS (SELECT TOP 1 1 FROM @ResponseData))
				BEGIN

					SELECT
						200 'ResultCode',
						'Datos de membresía y descuento obtenidos' 'ResultMessage'

					SELECT
						RD.CustomerName
						,RD.MembershipName
						,RD.StatusName
						,RD.ExpirationDate
						,RD.DiscountType
						,RD.DiscountValue
					FROM
						@ResponseData RD

				END
				ELSE
				BEGIN

					SELECT
						204 'ResultCode',
						'Sin datos de descuento' 'ResultMessage'

				END

			END
			ELSE
			BEGIN

				SELECT
					204 'ResultCode',
					'Membresia no vigente' 'ResultMessage'

			END

		END
		ELSE
		BEGIN

			SELECT
				204 'ResultCode',
				'Membresia no existe' 'ResultMessage'

		END

	END TRY
	BEGIN CATCH

		SELECT
			500 'ResultCode',
			ERROR_MESSAGE() 'ResultMessage'

	END CATCH

END;