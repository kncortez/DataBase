-- =============================================
-- Author:		<Andrés, Ruíz>
-- Create date: <16-02-2023>
-- Description:	< Comprar suscripción que posee membresía incluida >
-- =============================================
CREATE PROCEDURE [dbo].[spHW_TMBuySubscriptionWithMembership]
	@CatSubscriptionId AS INT,
	@AccountId AS BIGINT,
	@Voucher AS NVARCHAR(50) = NULL,
	@ModuleId AS INT = NULL,
	@SystemId AS INT ,
 	@Token AS NVARCHAR(50),
	@TaxId NVARCHAR(50) = 'CF',
	@FiscalAddress NVARCHAR(200) = 'Ciudad',
	@TaxName NVARCHAR(100) = 'CONSUMIDOR FINAL',
	@InvoiceEmail NVARCHAR(50) = '',
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
	DECLARE @SubscriptionId INT = 0;
	DECLARE @ActiveSuscription INT = 0;
	
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

     SET @ActiveSuscription =(SELECT COUNT(IdCatSubscription) 
	                            FROM [dbo].[CatSubscription] where IdCatSubscription = @CatSubscriptionId And RowStatus=1)

	--IF (@ActiveMembership > 0 OR (SELECT TOP 1 CS.IncludedMembershipId FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH(NOLOCK) WHERE CS.IdCatSubscription = @CatSubscriptionId) IS NULL) 
	--BEGIN
	--	SELECT 
	--		204 'ResultCode'
	--		,'No se ha podido realizar la compra debido a que el usuario ya tiene una membresía activa.' 'ResultMessage';
	--	RETURN;
	--END

  ---- Adquisición de membresia​
	BEGIN TRANSACTION
	BEGIN TRY

		--------------------------------------------- MEMBRESÍA ---------------------------------------------
		--INSERT INTO [dbo].[Membership] ([CatMembershipId], 
		--								[CatMembershipStatusId], 
		--								[MembershipCost], 
		--								[CustomerId], 
		--								[AccountId], 
		--								[MembershipCode], 
		--								[CustomerPaymentId], 
		--								[IsAutoRenewable], 
		--								[MembershipFixedValue], 
		--								[MembershipMaxServiceFixedValue], 
		--								[ActualServiceCount], 
		--								[ExpirationDate], 
		--								[RowStatus], 
		--								[TokenCreated], 
		--								[DateCreated], 
		--								[TaxIdNumber], 
		--								[InvoiceName], 
		--								[InvoiceEmail], 
		--								[FiscalAddress])
		--SELECT							[CM].[IdCatMembership],								-- CatMembershipId
		--								@StartingStatus,									-- CatMembershipStatusId
		--								[CM].[MembershipCost],								-- MembershipCost
		--								@CustomerId,										-- CustomerId
		--								@AccountId,											-- AccountId
		--								NULL,												-- MembershipCode
		--								@TypeOfInOutMoney,									-- CustomerPaymentId
		--								0,													-- IsAutoRenewable
		--								0,													-- MembershipFixedValue
		--								0,													-- MembershipMaxServiceFixedValue
		--								0,													-- ActualServiceCount
		--								DATEADD(DAY,[CM].[MembershipValidity], GETDATE()),	-- ExpirationDate
		--								1,													-- RowStatus
		--								@Token,												-- TokenCreated
		--								SYSDATETIME(),										-- DateCreated
		--								@TaxId,												-- TaxIdNumber
		--								@TaxName,											-- InvoiceName
		--								@InvoiceEmail,										-- InvoiceEmail
		--								@FiscalAddress										-- FiscalAddress
		--FROM							[dbo].[CatMembership] CM WITH (NOLOCK)
		--WHERE							[CM].[IdCatMembership] = (SELECT TOP 1 CS.IncludedMembershipId FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH(NOLOCK) WHERE CS.IdCatSubscription = @CatSubscriptionId);

		--SET @MembershipId = SCOPE_IDENTITY();



	IF(@ActiveMembership > 0 And @ActiveSuscription > 0)
	BEGIN

		SET @MembershipId =(SELECT TOP 1 IdMembership FROM dbo.Membership WHERE CustomerId = @CustomerId AND RowStatus = 1 ) 


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
														0,									-- DiscountValue
														0,									-- DiscountLowServiceRange
														NULL,								-- DiscountTopServiceRange
														1,									-- RowStatus 
														@Token,								-- TokenCreated
														SYSDATETIME()						-- DateCreated
		FROM											[dbo].[CatMembershipDiscountRange] CMDR WITH (NOLOCK)
		WHERE											[CMDR].[CatMembershipId] = (SELECT TOP 1 CS.IncludedMembershipId FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH(NOLOCK) WHERE CS.IdCatSubscription = @CatSubscriptionId);

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
													
		--------------------------------------------- SUSCRIPCIÓN ---------------------------------------------
		INSERT INTO [dbo].[Subscription]([CatSubscriptionId], 
										[MembershipId],
										[CatSubscriptionStatusId], 
										[SubscriptionCost], 
										[CustomerId], 
										[AccountId], 
										[SubscriptionCode], 
										[CustomerPaymentId], 
										[IsAutoRenewable], 
										[SubscriptionFixedValue], 
										[SubscriptionMaxServiceFixedValue], 
										[ActualServiceCount], 
										[ExpirationDate], 
										[RowStatus], 
										[TokenCreated], 
										[DateCreated],
										[CatTypeSubscriptionId])

		SELECT							[CS].[IdCatSubscription],							-- CatSubscriptionId
										@MembershipId,										-- MembershpiId
										@StartingStatus,									-- CatSubscriptionStatusId
										[CS].[SubscriptionCost],							-- SubscriptionCost
										@CustomerId,										-- CustomerId
										@AccountId,											-- AccountId
										NULL,												-- MembershipCode
										@TypeOfInOutMoney,									-- CustomerPaymentId
										0,													-- IsAutoRenewable
										[CS].[SubscriptionFixedValue],						-- SubscriptionFixedValue
										[CS].[SubscriptionMaxServiceFixedValue],			-- SubscriptionMaxServiceFixedValue
										0,													-- ActualServiceCount
										DATEADD(DAY,[CS].[SubscriptionValidity], GETDATE()),-- ExpirationDate
										1,													-- RowStatus
										@Token,												-- TokenCreated
										SYSDATETIME(),										-- DateCreated
										CS.IdCatSubscription                                --CatTypeSubscriptionId
		FROM							[dbo].[CatSubscription] CS WITH (NOLOCK)
		                                
		WHERE							[CS].Rowstatus=1 And [CS].[IdCatSubscription] = @CatSubscriptionId;

		SET @SubscriptionId = SCOPE_IDENTITY();

		​---------- Rango de descuento
		INSERT INTO [dbo].[SubscriptionDiscountRange] (	[SubscriptionId], 
														[ValueTypeId], 
														[DiscountValue], 
														[DiscountLowServiceRange], 
														[DiscountTopServiceRange], 
														[RowStatus], 
														[TokenCreated], 
														[DateCreated])

		SELECT											@SubscriptionId,					-- MembershipId
														[CSDR].[ValueTypeId],				-- ValueType
														[CSDR].[DiscountValue],				-- DiscountValue
														[CSDR].[DiscountLowServiceRange],	-- DiscountLowServiceRange
														[CSDR].[DiscountTopServiceRange],	-- DiscountTopServiceRange
														1,									-- RowStatus 
														@Token,								-- TokenCreated
														SYSDATETIME()						-- DateCreated
		FROM											[dbo].[CatSubscriptionDiscountRange] CSDR WITH (NOLOCK)
		WHERE											[CSDR].[CatSubscriptionId] = @CatSubscriptionId;

		​---- Log de pago de membresia
		INSERT INTO [dbo].[SubscriptionPaymentLog] ([SubscriptionId], 
													[TypeOfInOutOfMoneyId], 
													[TransactionOrder], 
													[RowStatus], 
													[TokenCreated], 
													[DateCreated],
													[PaymentImageURL])

		VALUES										(@SubscriptionId,
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
														@AccountId,
														1,				-- TAC
														1,				-- RowStatus
														'SPHWPBuyMembershipsandSubscriptions',
														SYSDATETIME());




END



		IF(@MembershipId >0 AND @SubscriptionId>0)
		BEGIN
		
			SELECT 
				200 'ResultCode'
				,'Suscripción ha sido asociada con éxito.' 'ResultMessage'
				--,'Membresía y suscripción ha sido asociada con éxito.' 'ResultMessage'


				 SELECT Top 1 CM.IdCatMembership  'MembershipIncludedId' from dbo.Membership M with(NOLOCK)
					Inner Join CatMembership CM with(NOLOCK)
					On M.CatMembershipId = CM.IdCatMembership
				 Where M.AccountId=@AccountId
				   And M.RowStatus=1
				 Order By M.DateCreated Desc;
             

			COMMIT TRANSACTION;
		
		END
		ELSE 
		BEGIN

			ROLLBACK TRANSACTION;
		
			SELECT 
				204 'ResultCode'
				,'No se ha podido realizar la compra.' 'ResultMessage'

		END

	END TRY
	BEGIN CATCH

		SELECT 
			500 'ResultCode'
			,ERROR_MESSAGE() 'ResultMessage'

		ROLLBACK TRANSACTION
	END CATCH
END
