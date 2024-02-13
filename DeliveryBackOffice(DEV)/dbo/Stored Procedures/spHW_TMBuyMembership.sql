
-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <23-01-2023>
-- Description:	<Buy a membership from Telemarketing Web module>
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2023-03-22>
-- Description:	<aceptar terminos y condiciones al momento de la adquisición de membresias y suscripciones>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_TMBuyMembership]
	@CatMembershipId AS INT,
	@AccountId AS BIGINT,
	@Voucher AS NVARCHAR(50) = NULL,
	@ModuleId AS INT = NULL,
	@SystemId AS INT ,
 	@Token AS NVARCHAR(50),
	@TaxId NVARCHAR(50) = 'CF',
	@FiscalAddress NVARCHAR(200) = 'Ciudad',
	@TaxName NVARCHAR(100) = 'CONSUMIDOR FINAL',
	@InvoiceEmail NVARCHAR(50) = '',
	@RegisterUserId INT,
	@IsAutoRenewable BIT = 0,
	@ImageURL NVARCHAR(600) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TransactionSuccess BIT = 0;
	DECLARE @ActiveMembership INT = 0;
	DECLARE @CustomerTypeId INT = 0; 
	DECLARE @CustomerId  AS INT;
	DECLARE @StartingStatus INT = 0;
	DECLARE @TypeOfInOutMoney INT = 0;
	DECLARE @MembershipId INT = 0;
	DECLARE @CatTMSalesPersonId INT = 0;
	DECLARE @AddedPointExpirationDate INT = 0;

	DECLARE @TacId INT = 0;

	SET @TacId =	(SELECT TOP 1 [TAC].[IdTAC]
					FROM	[dbo].[TermsAndConditions] TAC
					WHERE	[TAC].[Name] = 'Terms and conditions memberships and subscriptions');
	
	-- Variables estaticas "globales"
	SET @StartingStatus = (	SELECT TOP 1 [CSPS].[IdCatSalesPackageStatus] 
							FROM	[DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH (NOLOCK) 
							WHERE	[CSPS].[SalesPackageStatusName] = 'Activa' COLLATE Latin1_General_CI_AI);
	SET @CustomerTypeId = ( SELECT TOP 1 [CT].[IdCustomerType]
							FROM	[dbo].[CustomerType] CT
							WHERE	[CT].[Description] = 'INDIVIDUAL'
								AND [CT].[CustomerTypeStatus] = 1);
	SET @CustomerId = (	SELECT TOP 1 [A].[IdCustomer]
						FROM	[dbo].[Account] A
						WHERE	[A].[AccIdAccount] = @AccountId);
	SET @ActiveMembership = ( SELECT COUNT([M].[IdMembership])
								FROM	[DeliveryBackOffice].[dbo].[Membership] M 
								WHERE	[M].[AccountId] = @AccountId
									AND [M].[RowStatus] = 1);
	SET @TypeOfInOutMoney = (	SELECT TOP 1 [TIOM].[tio_pk_id]
								FROM	[dbo].[ctgTypeOfInOutOfMoney] TIOM
								WHERE	[TIOM].[tio_pk_name] = 'Datafono');
	SET @CatTMSalesPersonId = ( SELECT TOP 1 [CTSP].[IdCatTMSalesPerson]
								FROM	[dbo].[CatTMSalesPerson] CTSP
								WHERE	[CTSP].[RegisterUserId] = @RegisterUserId);

    SET @AddedPointExpirationDate
        = CAST(ISNULL(
               (
                   SELECT TOP 1
                          [CP].[Value]
                   FROM [DeliveryBackOffice].[dbo].[ConfigParams] [CP] WITH (NOLOCK)
                   WHERE [CP].[Name] = 'ForzaPointsExpirationDays' COLLATE Latin1_General_CI_AI
               ),
               0
            ) AS INT);


	IF (@ActiveMembership > 0) 
		BEGIN
			SELECT 0 [spResult], 'No se ha podido realizar la compra debido a que el usuario ya tiene una membresía activa.' [spMessage];
			RETURN;
		END

  ---- Adquisición de membresia​
	BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO [dbo].[Membership] ([CatMembershipId], 
										[CatMembershipStatusId], 
										[MembershipCost], 
										[CustomerId], 
										[AccountId], 
										[MembershipCode], 
										[CustomerPaymentId], 
										[IsAutoRenewable], 
										[MembershipFixedValue], 
										[MembershipMaxServiceFixedValue], 
										[ActualServiceCount], 
										[ExpirationDate], 
										[RowStatus], 
										[TokenCreated], 
										[DateCreated], 
										[TaxIdNumber], 
										[InvoiceName], 
										[InvoiceEmail], 
										[FiscalAddress],
										[CatTMSalesPersonId],
										[AvailablePoints],
										[AccumulatedPoints],
										[PointsExpirationDate]
										)
		SELECT							[CM].[IdCatMembership],								-- CatMembershipId
										@StartingStatus,									-- CatMembershipStatusId
										[CM].[MembershipCost],								-- MembershipCost
										@CustomerId,										-- CustomerId
										@AccountId,											-- AccountId
										NULL,												-- MembershipCode
										NULL,									-- CustomerPaymentId
										@IsAutoRenewable,									-- IsAutoRenewable
										[CM].[MembershipFixedValue],						-- MembershipFixedValue
										[CM].[MembershipMaxServiceFixedValue],				-- MembershipMaxServiceFixedValue
										0,													-- ActualServiceCount
										DATEADD(DAY,[CM].[MembershipValidity], GETDATE()),	-- ExpirationDate
										1,													-- RowStatus
										@Token,												-- TokenCreated
										SYSDATETIME(),										-- DateCreated
										@TaxId,												-- TaxIdNumber
										@TaxName,											-- InvoiceName
										@InvoiceEmail,										-- InvoiceEmail
										@FiscalAddress,										-- FiscalAddress
										@CatTMSalesPersonId,								-- CatTMSalesPersonId
										0,													-- AvailablePoints
										0,													-- AccumulatedPoints
										DATEADD(DAY, @AddedPointExpirationDate, DATEADD(DAY,[CM].[MembershipValidity], GETDATE())) -- PointsExpirationDate
		FROM							[dbo].[CatMembership] CM WITH (NOLOCK)
		WHERE							[CM].[IdCatMembership] = @CatMembershipId;

		SET @MembershipId = SCOPE_IDENTITY();

		​---------- Rango de descuento
		INSERT INTO [dbo].[MembershipDiscountRange] (	[MembershipId], 
														[ValueTypeId], 
														[DiscountValue], 
														[DiscountLowServiceRange], 
														[DiscountTopServiceRange], 
														[RowStatus], 
														[TokenCreated], 
														[DateCreated])
		SELECT											@MembershipId,						-- MembershipId
														[CMDR].[ValueTypeId],				-- ValueType
														[CMDR].[DiscountValue],				-- DiscountValue
														[CMDR].[DiscountLowServiceRange],	-- DiscountLowServiceRange
														[CMDR].[DiscountTopServiceRange],	-- DiscountTopServiceRange
														[CMDR].[RowStatus],					-- RowStatus 
														@Token,								-- TokenCreated
														SYSDATETIME()						-- DateCreated
		FROM											[dbo].[CatMembershipDiscountRange] CMDR WITH (NOLOCK)
		WHERE											[CMDR].[CatMembershipId] = @CatMembershipId;

		​---- Log de pago de membresia
		INSERT INTO [dbo].[MembershipPaymentLog] (	[MembershipId], 
													[TypeOfInOutOfMoneyId], 
													[TransactionOrder], 
													[RowStatus], 
													[TokenCreated], 
													[DateCreated],
													[PaymentImageURL])
		VALUES										(@MembershipId,
													@TypeOfInOutMoney,
													@Voucher,
													1,
													@Token,
													SYSDATETIME(),
													@ImageURL);


       -- Asignación de terminos y condiciones
		INSERT INTO [dbo].[TermsAndConditionsByUser]([TACId],
														[IdAccount],
														[TAC],
														[RowStatus],
														[TokenCreated],
														[DateCreated])
		                                     VALUES	 (@TacId,
														@AccountId ,
														1,				-- TAC
														1,				-- RowStatus
														'spHW_TMBuyMembership',
														SYSDATETIME());


		SELECT 1 [spResult], 'Membresía ha sido asociada con éxito' [spMessage];
		IF (@@TRANCOUNT > 0) 
			COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		SELECT 0 [spResult],
				ERROR_NUMBER() AS [ErrorNumber],
				ERROR_SEVERITY() AS [ErrorSeverity],
				ERROR_STATE() AS [ErrorState],
				ERROR_PROCEDURE() AS [ErrorProcedure],
				ERROR_LINE() AS [ErrorLine],
				ERROR_MESSAGE() AS [ErrorMessage],
				'No se pudo completar la transacción, intente nuevamente o comuníquese con soporte técnico.' [spMessage];
		ROLLBACK TRANSACTION
	END CATCH
END