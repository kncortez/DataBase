-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <19-01-2023>
-- Description:	<Create account for Telemarketing Customer>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_CreateTMCustomerAccount] 
	@FirstName NVARCHAR(100),
	@LastName NVARCHAR(100),
	@NickName NVARCHAR(100),
	@Password NVARCHAR(200),
	@Gender VARCHAR(100),
	@Birthdate DATE,
	@Identification VARCHAR(100),
	@Nationality VARCHAR(100),
	@Email  VARCHAR(200),
	@DeviceType NVARCHAR(20),
	@Currency NVARCHAR(20),
	@Phone NVARCHAR(30),
	@SystemId INT = 1,
	@RegisterUserId INT = 0

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @NewMainRates INT =	0;
	DECLARE @NewAlternativeRates INT = 0;
	DECLARE @NewMainUserRol INT = 0;
	DECLARE @EmailExisting INT;
	DECLARE @TypeAccountId INT;
	DECLARE @PersonId BIGINT = 0;
	DECLARE @PasswordExpirationDate DATETIME = (SELECT DATEADD(DAY, 90, SYSDATETIME()));
	DECLARE @CutOffDate DATE = EOMONTH( SYSDATETIME(), 1 ); -- Último día del mes siguiente
	DECLARE @UserId BIGINT = 0;
	DECLARE @CustomerTypeId INT = 0;
	DECLARE @CatBusinessSegmentId INT = 0;
	DECLARE @SaleAdvisorId INT = 0;
	DECLARE @CatTypeOfBusiness INT = 0;
	DECLARE @CatBusinessActivityId INT = 0;
	DECLARE @CatCommercialSegmentId INT = 0;
	DECLARE @CustomerId INT = 0;
	DECLARE @AccountId INT = 0;
	DECLARE @TacId INT = 0;
	DECLARE @RolId INT = 0;
	DECLARE @PackagesGoal INT = 0;
	DECLARE @CatTMSalesPersonId INT = 0;
	DECLARE @TMSalesPersonName NVARCHAR(600) = '';
	DECLARE @TMSalesPersonPhone NVARCHAR(200) = '';
	DECLARE @TMSalesPersonEmail NVARCHAR(200) = '';
	DECLARE @CatSaleAdvisorId INT = 0;

	SET @NewMainRates = (SELECT TOP 1 RH.RheId 
						FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) 
						WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI);

	SET @NewAlternativeRates = (SELECT TOP 1 RH.RheId 
								FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) 
								WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI);

	SET @NewMainUserRol =	(SELECT TOP 1 [CR].[RolIdRol]
							FROM [dbo].[CatRol] CR
							WHERE [CR].[RolName] = 'Nuevo estándar' COLLATE Latin1_General_CI_AI );

	SET @EmailExisting =	(SELECT [RU].[UsrIdUser]
							FROM	[dbo].[RegisterUser] RU 
							WHERE	[RU].[UsrEmail] = @Email);

	SET @CustomerTypeId =	(SELECT TOP 1 [CT].[IdCustomerType]
							FROM	[dbo].[CustomerType] CT
							WHERE	[CT].[Description] = 'INDIVIDUAL');

	SET @CatBusinessSegmentId = (SELECT TOP 1 [CBS].[IdBusinessSegment]
								FROM	[dbo].[CatBusinessSegment] CBS
								WHERE	[CBS].[BusinessSegmentName] = 'C2C - CUSTOMER TO CUSTOMER');

	--SET @SaleAdvisorId =	(SELECT [CSA].[IdSaleAdvisor]
	--						FROM	[dbo].[CatSaleAdvisor] CSA
	--						WHERE	[CSA].[SaleAdvisorCode] = 'BACKOFFICE01');

	SET @CatTypeOfBusiness =	(SELECT	TOP 1 [CTB].[IdTypeOfBusiness]
								FROM	[dbo].[CatTypeOfBusiness] CTB
								WHERE	[CTB].[TypeOfBusinessName] = 'PYMES');

	SET @CatBusinessActivityId =	(SELECT TOP 1 [CBA].[IdBusinessActivity]
									FROM	[dbo].[CatBusinessActivity] CBA
									WHERE	[CBA].[BusinessActivityName] = 'LOGÍSTICA');

	SET @CatCommercialSegmentId =	(SELECT TOP 1 [CCS].[IdCommercialSegment]
									FROM	[dbo].[CatCommercialSegment] CCS
									WHERE	[CCS].[CommercialSegmentName] = 'MARKETPLACE');

	SET @TypeAccountId =	(SELECT TOP 1 [CTA].[TacIdTypeAccount]
							FROM	[dbo].[CatTypeAccount] CTA
							WHERE	[CTA].[TacShortName] = 'IND');

	SET @TacId =	(SELECT TOP 1 [TAC].[IdTAC]
					FROM	[dbo].[TermsAndConditions] TAC
					WHERE	[TAC].[Name] = 'New Termns And Conditions');

	SET @RolId =	(SELECT TOP 1 [CR].[RolIdRol]
					FROM	[dbo].[CatRol] CR
					WHERE	[CR].[RolIdSystem] = @SystemId
						AND [CR].[RolName] = 'Estandar');

	SET @PackagesGoal = (SELECT TOP 1 [CP].[Value]
						FROM	[dbo].[ConfigParams] CP
						WHERE	[CP].[Name] = 'PymesPackagesGoal');

	SET @CatTMSalesPersonId = ( SELECT	[CTSP].[IdCatTMSalesPerson]
								FROM	[dbo].[CatTMSalesPerson] CTSP
								WHERE	[CTSP].[RegisterUserId] = @RegisterUserId);

	SET @TMSalesPersonName  = ( SELECT	CONCAT([CTSP].[FirstName], ' ', [CTSP].[LastName])
								FROM	[dbo].[CatTMSalesPerson] CTSP
								WHERE	[CTSP].[RegisterUserId] = @RegisterUserId);

	SET @TMSalesPersonPhone = ( SELECT [RU].[Phone]
								FROM [dbo].[RegisterUser] RU WITH(NOLOCK)
								WHERE RU.UsrIdUser = @RegisterUserId);

	SET @TMSalesPersonEmail = ( SELECT [RU].[UsrEmail]
								FROM [dbo].[RegisterUser] RU WITH(NOLOCK)
								WHERE RU.UsrIdUser = @RegisterUserId);

	SET @CatSaleAdvisorId = ( SELECT	[CTSP].[CatSaleAdvisorId]
								FROM	[dbo].[CatTMSalesPerson] CTSP
								WHERE	[CTSP].[RegisterUserId] = @RegisterUserId);

	-- Validación de correo
	IF (@EmailExisting > 0)
		BEGIN 
			SELECT 0 [spResult], 'Este correo ya fue registrado' [spMessage];
			RETURN;
		END

	BEGIN TRANSACTION
	BEGIN TRY

		-- TABLE PERSON
		INSERT INTO [dbo].[Person] ([PerFirstName],
									[PerLastName],
									[PerGender],
									[PerBirthdate],
									[PerIdentification],
									[PerNationality],
									[PerRowStatus],
									[PerTokenCreated],
									[PerDateCreated])
		VALUES						(@FirstName,
									@LastName,
									@Gender,
									@Birthdate,
									@Identification,
									@Nationality,
									1,			-- RowStatus
									'spHW_CreateTMCustomerAccount', 
									SYSDATETIME());

		SET @PersonId = SCOPE_IDENTITY();

		-- Table RegisterUser
		INSERT INTO [dbo].[RegisterUser]	([UsrIdPerson],
											[UsrNickName],
											[UsrEmail],
											[UsrAvatar],
											[UsrLastPassword],
											[UsrPasswordExpiration],
											[UsrLang],
											[UsrDeviceType],
											[UsrCurrency],
											[UsrEnable2FA],
											[UsrRestrictionAddressIp],
											[UsrRowStatus],
											[UsrTokenCreated],
											[UsrDateCreated],
											[Phone], 
											[ChangePassword])
		VALUES								(@PersonId,
											@NickName,
											@Email,
											NULL,	-- AVATAR
											@Password,
											@PasswordExpirationDate, 
											'ES',
											@DeviceType,
											@Currency,
											NULL,	-- ENABLE2FA
											NULL,	-- RESTRICTION ADDRESS IP
											1,		-- ROWSTATUS
											'spHW_CreateTMCustomerAccount',
											SYSDATETIME(),
											@Phone, 
											1);

		SET @UserId = SCOPE_IDENTITY();

		-- Table UserSystemRestriction
		INSERT INTO [dbo].[UserSystemRestriction]	([UstIdUser],
													[UstIdSystem],
													[UstAccessRetries],
													[UstRetries],
													[UstStatus],
													[UstRowStatus],
													[UstTokenCreated],
													[UstDateCreated],
													[UstOperationDate])
		VALUES										(@UserId,
													@SystemId,
													10,			-- Valor por defecto para reintentos
													0,			-- Contador de reintentos
													'ACTIVE',
													1,			-- RowStatus
													'spHW_CreateTMCustomerAccount',
													SYSDATETIME(),
													SYSDATETIME());

		-- Table Customer
		INSERT INTO [dbo].[Customer]	([Name],
										[Description],
										[Domain],
										[RegexSubject],
										[RegexEmail],
										[RegexFilename],
										[Abbreviation],
										[IdCustomerType],
										[BusinessSegmentID],
										[SaleAdvisorID],
										[TypeOfBusinessID],
										[BusinessActivityID],
										[CommercialSegmentID],
										[CatTMSalesPersonId],
										[CutOffDate],
										[CustomerGoalQuantity] )
		VALUES							(CONCAT(@FirstName, ' ', @LastName),													-- Name
										CONCAT(@FirstName, ' ', @LastName),														-- Description
										CAST(SUBSTRING (@Email, CHARINDEX( '@', @Email ), LEN(@Email)  ) AS nvarchar(50)),		-- Domain
										'^.*solicitud.*$',																		-- RegexSubject
										CAST(('^' + @Email + '$') AS NVARCHAR(100)),											-- RegexEmail
										'^envios_.*\.xls$',																		-- RegexFileName
										CAST((@FirstName + ' ' + @LastName) AS NVARCHAR(25)),									-- Abbreviation
										@CustomerTypeId,																		-- IdCustomerType
										@CatBusinessSegmentId,																	-- BusinessSegmentId
										@CatSaleAdvisorId,																					-- SaleAdvisorID
										@CatTypeOfBusiness,																		-- TypeOfBusinessID
										@CatBusinessActivityId,																	-- BusinessActivityID
										@CatCommercialSegmentId,																-- CommercialSegmentID
										@CatTMSalesPersonId,																	-- CatTMSalesPersonID
										@CutOffDate,																			-- CutOffDate												
										@PackagesGoal);																			-- CustomerGoalQuantity
										
		SET @CustomerId = SCOPE_IDENTITY();

		-- Asignación de tarifario principal para cliente individual
		INSERT INTO [dbo].[RatebyCustomer] ([RbcIdRate],
											[RbcIdCustomer],
											[RbcRowStatus],
											[RbcTokenCreated],
											[RbcDateCreated])
		VALUES								(@NewMainRates,
											@CustomerId,
											1, 
											'spHW_CreateTMCustomerAccount', 
											SYSDATETIME());

		-- Asignación de tarifario alterno para cliente individual
		INSERT INTO [dbo].[AlternativeRateByCustomer]	([RateId],
														[CustomerId],
														[RowStatus],
														[TokenCreated],
														[DateCreated])
		VALUES											(@NewAlternativeRates,
														@CustomerId,
														1, 
														'spHW_CreateTMCustomerAccount', 
														SYSDATETIME());

		-- Creación de cuenta para cliente de tipo individual
		INSERT INTO [dbo].[Account] ([AccName],
									[AccIdTypeAccount],
									[AccRowStatus],
									[AccTokenCreated],
									[AccDateCreated],
									[IdCustomer],
									[AccConfirm])
		VALUES						(CAST(concat('Envíos de ',@FirstName) AS VARCHAR(100)),
									@TypeAccountId, 
									1, 
									'',
									SYSDATETIME(),
									@CustomerId,
									'C');

		SET @AccountId = SCOPE_IDENTITY();

		-- Asignación de terminos y condiciones
		INSERT INTO [dbo].[TermsAndConditionsByUser]	([TACId],
														[IdAccount],
														[TAC],
														[RowStatus],
														[TokenCreated],
														[DateCreated])
		VALUES											(@TacId,
														@AccountId,
														1,				-- TAC
														1,				-- RowStatus
														'spHW_CreateTMCustomerAccount',
														SYSDATETIME());

		-- Asignación de rol por cuenta
		INSERT INTO [dbo].[RolByUserByAccount] ([RuaIdRol],
												[RuaIdUser],
												[RuaIdAccount],
												[RuaRowStatus],
												[RuaTokenCreated],
												[RuaDateCreated])
		VALUES									(@NewMainUserRol,
												@UserId,
												@AccountId,
												1, 
												'spHW_CreateTMCustomerAccount',
												SYSDATETIME());

		-- Asignación de wizards por defecto
		INSERT INTO [dbo].[DeliveryWizardAccount]	([AccIdAccount],
													[IdWiz],
													[StatusAccountWiz],
													[DateCreate], 
													[TokenCreate])
		VALUES										(CAST(@AccountId AS INT), 
													1,
													1, 
													SYSDATETIME(),
													'spHW_CreateTMCustomerAccount');

		INSERT INTO [dbo].[DeliveryWizardAccount]	([AccIdAccount],
													[IdWiz],
													[StatusAccountWiz],
													[DateCreate], 
													[TokenCreate])
		VALUES										(CAST(@AccountId AS INT), 
													2,
													1, 
													SYSDATETIME(),
													'spHW_CreateTMCustomerAccount');

		INSERT INTO [dbo].[DeliveryWizardAccount]	([AccIdAccount],
													[IdWiz],
													[StatusAccountWiz],
													[DateCreate], 
													[TokenCreate])
		VALUES										(CAST(@AccountId AS INT), 
													3,
													1, 
													SYSDATETIME(),
													'spHW_CreateTMCustomerAccount');

		-- Asignación de rol por sistema
		INSERT INTO [dbo].[RolByUserBySystem]	([RusIdRol],
												[RusIdSystem],
												[RusIdUser],
												[RusRowStatus],
												[RusTokenCreated],
												[RusDateCreated])
		VALUES									(@NewMainUserRol,
												@SystemId,
												@UserId,
												1, 
												'spHW_CreateTMCustomerAccount',
												SYSDATETIME());

		-- Asignación de tutoriales
		INSERT INTO [dbo].[TutorialByAccount]	([TutorialId],
												[AccountId],
												[ToDisplay],
												[RowStatus],
												[DateCreated],
												[TokenCreated])
		SELECT									T.IdTutorial,
												@AccountId,
												1,
												1,
												SYSDATETIME(),
												'spHW_CreateTMCustomerAccount'
		FROM		[dbo].[Tutorial] T
		WHERE		[T].[RowStatus] = 1;

		IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;

		SELECT 
			1 [spResult]
			, 'Cuenta creada exitósamente.' [spMessage]
			,@TMSalesPersonName [spTMSPName]
			,@TMSalesPersonPhone [spTMSPPhone]
			,@TMSalesPersonEmail [spTMSPEmail]
			,@AccountId [spIdAccount];
	END TRY
	BEGIN CATCH
		SELECT 0 [spResult],
				ERROR_NUMBER() AS [ErrorNumber],
				ERROR_SEVERITY() AS [ErrorSeverity],
				ERROR_STATE() AS [ErrorState],
				ERROR_PROCEDURE() AS [ErrorProcedure],
				ERROR_LINE() AS [ErrorLine],
				ERROR_MESSAGE() AS [spMessage];

		ROLLBACK TRANSACTION
	END CATCH
END