-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-04-27>
-- Description:	<inserta o actualiza registros a clientes en base a flag @option 1 insert 2 update>
-- =============================================
 CREATE PROCEDURE [dbo].[sphdSetCustomer]
	-- Add the parameters for the stored procedure here
	@IdCustomer int,
	@NameCustomer nvarchar(100),
	@Description  nvarchar(100) = '',
	@Domain nvarchar(50)='',
	@RegexSubject nvarchar(100) = '',
	@RegexEmail nvarchar(100) = '',
	@RegexFilename nvarchar(100) = '',
	@Abbreviation nvarchar(25) = '',
	@IdCustomerType int = 1,    -- 1	CORPORATIVO; 2	REDISTRIBUIDOR;  3	INDIVIDUAL
	@CountryID varchar(2) =  'GT',
	@CommercialName nvarchar(50),
	@CustomerPhone nvarchar(50),
	@WebsiteURI nvarchar(50) = '',
	@ContactName nvarchar(50), 
	@ContactEmail nvarchar(50),
	@NotificationAddress nvarchar(200),
	@SaleAdvisorID int = -1,
	@DateUpService datetime = NULL,
	@DateDownService datetime = NULL,
	@TypeOfBusinessID int,
	@BusinessSegmentID int,
	@BusinessActivityID int,
	@CommercialSegmentID int,
	@OperationContactName nvarchar(50) = '',
	@OperationContactPhone nvarchar(50) = '',
	@OperationContactEmail nvarchar(50) = '',
	@LegalSponsorName nvarchar(50) = '',
	@LegalSponsorLastName nvarchar(50) = '', 
	@LegalSponsorDPI nvarchar(50) = '',
	@HasAgreement bit  = 'FALSE', 
	@AgreementNumber nvarchar(50) = '', 
	@AgreementDateStart datetime = NULL,
	@AgreementDateEnd datetime = NULL,
	@InvoiceName nvarchar(100) = '',
	@TaxIdentificationNumber nvarchar(50) = '',
	@FiscalAddress  nvarchar(200)  = '',
	@InvoiceEmail nvarchar(50) = '',
	@ConditionOfPaymentID int  = 1,
	@InvoiceContactName nvarchar(50) = '',
	@InvoiceContactPhone nvarchar(50) = '',
	@InvoiceContactEmail nvarchar(50) = '',
	@CODAccountBankID int = NULL,
	@CODAccountNumber nvarchar(50) = '',
	@CODAccountName nvarchar(50) = '',
	@CODAccountTypeID int = NULL,
	@CODCurrencyID int = NULL,
	@CODContactName nvarchar(50) = '',
	@CODContactPhone nvarchar(50) = '',
	@CODContactEmail nvarchar(50) = '',
	@RowSatus bit = 'TRUE',
	@Token nvarchar(50) = 'SYS-FDADMIN',
	@Option as int,  -- 1 create record, 2 update record
	@ExcludePriceShippingCOD bit = 'FALSE',
	@ExcludeCommissionCOD bit = 'FALSE',
	@CatBatchTypeCODId BIGINT,
	@CatBatchFrequencyCODId BIGINT,
	@BillingTimeId int = 3,
	@BillingVolumeId int = 2,
	@BillingCut_offDate Date = NULL,
	-----------------------------------------------------
	@CardCode nvarchar(50) =NULL
	-----------------------------------------------------
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY

		DECLARE @msgerror NVARCHAR(MAX)='';		
				SELECT @msgerror=
				STUFF((SELECT CHAR(10) + Name
				FROM DBO.Customer C WITH(NOLOCK)
				  WHERE C.TaxIdentificationNumber= @TaxIdentificationNumber AND LEN(TaxIdentificationNumber)>0 and RowSatus=1 AND (@Option=1 OR(@Option=2 AND IdCustomer<>@IdCustomer))
				  FOR XML PATH('')), 1, 1, '');
		IF(LEN(@msgerror)>0)
		BEGIN				
				SET @msgerror='Los siguientes clientes ya estan registrados con el NIT '+ @TaxIdentificationNumber+': '+CHAR(10)+ @msgerror;
				RAISERROR (@msgerror, 16,1);
			--END
		END

		-----------
		DECLARE @SAPCARDCODEUSEREXIST NVARCHAR(50);
		SELECT @SAPCARDCODEUSEREXIST=Name FROM DBO.Customer WHERE SAPCardCode=@CardCode and IdCustomer<>@IdCustomer;
		IF (@SAPCARDCODEUSEREXIST IS NOT NULL)
		--BEGIN
				BEGIN
					 SELECT	'FALSE'	[blnResult]
							,'-1' [IdResult]
							,'' AS [ErrorNumber]
							,'' AS [ErrorSeverity]  
							,'' AS [ErrorState]
							,'' AS [ErrorProcedure]  
							,'' AS [ErrorLine]
							,CONCAT('El usuario ',@SAPCARDCODEUSEREXIST,'  ya posee el codigo SAP: ',@CardCode) AS [Message];  
				END
		--END		
		ELSE 
		-----------

		
		IF (@Option = 1)
		BEGIN 
			print 'insert record'
			IF NOT EXISTS ( SELECT cli.IdCustomer FROM Customer cli where cli.Name = @NameCustomer ) 
			BEGIN

			INSERT INTO [DeliveryBackOffice].[dbo].[Customer]
				   ([Name]
				   ,[Description]
				   ,[Domain]
				   ,[RegexSubject]
				   ,[RegexEmail]
				   ,[RegexFilename]
				   ,[Abbreviation]
				   ,[IdCustomerType]
				   ,[CountryID]
				   ,[CommercialName]
				   ,[CustomerPhone]
				   ,[WebsiteURI]
				   ,[ContactName]
				   ,[ContactEmail]
				   ,[NotificationAddress]
				   ,[SaleAdvisorID]
				   ,[DateUpService]
				   ,[DateDownService]
				   ,[TypeOfBusinessID]
				   ,[BusinessSegmentID]
				   ,[BusinessActivityID]
				   ,[CommercialSegmentID]
				   ,[OperationContactName]
				   ,[OperationContactPhone]
				   ,[OperationContactEmail]
				   ,[LegalSponsorName]
				   ,[LegalSponsorLastName]
				   ,[LegalSponsorDPI]
				   ,[HasAgreement]
				   ,[AgreementNumber]
				   ,[AgreementDateStart]
				   ,[AgreementDateEnd]
				   ,[InvoiceName]
				   ,[TaxIdentificationNumber]
				   ,[FiscalAddress]
				   ,[InvoiceEmail]
				   ,[ConditionOfPaymentID]
				   ,[InvoiceContactName]
				   ,[InvoiceContactPhone]
				   ,[InvoiceContactEmail]
				   ,[CODAccountBankID]
				   ,[CODAccountNumber]
				   ,[CODAccountName]
				   ,[CODAccountTypeID]
				   ,[CODCurrencyID]
				   ,[CODContactName]
				   ,[CODContactPhone]
				   ,[CODContactEmail]
				   ,[RowSatus]
				   ,[TokenCreated]
				   ,[DateCreated]
				   ,[TokenUpdated]
				   ,[DateUpdated]
				   ,[SAPCardCode]
				   ,[ExcludePriceShippingCOD]
				   ,[ExcludeCommissionCOD]
				   ,[CatBatchTypeCODId]
				   ,[CatBatchFrequencyCODId]
				   ,[DCBAID]
				   ,[CatBillingTimeId]
				   ,[CatBillingVolumeId]
				   ,[BillingCut_offDate]
				   )
			 VALUES
				   (@NameCustomer
				   ,@Description
				   ,@Domain
				   ,@RegexSubject
				   ,@RegexEmail
				   ,@RegexFilename
				   ,@Abbreviation
				   ,@IdCustomerType
				   ,@CountryID
				   ,@CommercialName
				   ,@CustomerPhone
				   ,@WebsiteURI
				   ,@ContactName
				   ,@ContactEmail
				   ,@NotificationAddress
				   ,@SaleAdvisorID
				   ,@DateUpService
				   ,@DateDownService
				   ,@TypeOfBusinessID
				   ,@BusinessSegmentID
				   ,@BusinessActivityID
				   ,@CommercialSegmentID
				   ,@OperationContactName
				   ,@OperationContactPhone
				   ,@OperationContactEmail
				   ,@LegalSponsorName
				   ,@LegalSponsorLastName
				   ,@LegalSponsorDPI
				   ,@HasAgreement
				   ,@AgreementNumber
				   ,@AgreementDateStart
				   ,@AgreementDateEnd
				   ,@InvoiceName
				   ,@TaxIdentificationNumber
				   ,@FiscalAddress
				   ,@InvoiceEmail
				   ,@ConditionOfPaymentID
				   ,@InvoiceContactName
				   ,@InvoiceContactPhone
				   ,@InvoiceContactEmail
				   ,@CODAccountBankID
				   ,@CODAccountNumber
				   ,@CODAccountName
				   ,@CODAccountTypeID
				   ,@CODCurrencyID
				   ,@CODContactName
				   ,@CODContactPhone
				   ,@CODContactEmail
				   ,@RowSatus --'TRUE'
				   ,@Token
				   ,GETDATE()
				   ,NULL
				   ,NULL
				   -------------------------
				   --,NULL				   
				   ,@CardCode
				   -------------------------
				   ,@ExcludePriceShippingCOD
				   ,@ExcludeCommissionCOD
				   ,@CatBatchTypeCODId
				   ,@CatBatchFrequencyCODId
				   ,@DCBAID
				   ,@BillingTimeId
				   ,@BillingVolumeId
				   ,@BillingCut_offDate
				   )

				   SELECT	'TRUE'	[blnResult]
							,CAST(SCOPE_IDENTITY() AS VARCHAR) [IdResult]
							,'' AS [ErrorNumber]
							,'' AS [ErrorSeverity]  
							,'' AS [ErrorState]
							,'' AS [ErrorProcedure]  
							,'' AS [ErrorLine]
							,'Success' AS [Message];  
				END
			ELSE
				BEGIN
					 SELECT	'FALSE'	[blnResult]
							,'-1' [IdResult]
							,'' AS [ErrorNumber]
							,'' AS [ErrorSeverity]  
							,'' AS [ErrorState]
							,'' AS [ErrorProcedure]  
							,'' AS [ErrorLine]
							,'El cliente que intenta crear ya existe en base datos' AS [Message];  
				END

		END
		ELSE IF (@Option = 2)
		BEGIN
				print 'update record'
				 

				UPDATE [DeliveryBackOffice].[dbo].[Customer]
				   SET [Name] = @NameCustomer
					  ,[Description] = @Description
					  --,[Domain] = <Domain, nvarchar(50),>
					  --,[RegexSubject] = <RegexSubject, nvarchar(100),>
					  --,[RegexEmail] = <RegexEmail, nvarchar(100),>
					  --,[RegexFilename] = <RegexFilename, nvarchar(100),>
					  --,[Abbreviation] = <Abbreviation, nvarchar(25),>
					  --,[IdCustomerType] = <IdCustomerType, int,>
					  ,[CountryID] = @CountryID
					  ,[CommercialName] = @CommercialName
					  ,[CustomerPhone] = @CustomerPhone
					  ,[WebsiteURI] = @WebsiteURI
					  ,[ContactName] = @ContactName
					  ,[ContactEmail] = @ContactEmail
					  ,[NotificationAddress] = @NotificationAddress
					  ,[SaleAdvisorID] = @SaleAdvisorID
					  ,[DateUpService] = @DateUpService
					  ,[DateDownService] = @DateDownService
					  ,[TypeOfBusinessID] = @TypeOfBusinessID
					  ,[BusinessSegmentID] = @BusinessSegmentID
					  ,[BusinessActivityID] = @BusinessActivityID
					  ,[CommercialSegmentID] = @CommercialSegmentID
					  ,[OperationContactName] = @OperationContactName
					  ,[OperationContactPhone] = @OperationContactPhone
					  ,[OperationContactEmail] = @OperationContactEmail
					  ,[LegalSponsorName] = @LegalSponsorName
					  ,[LegalSponsorLastName] = @LegalSponsorLastName
					  ,[LegalSponsorDPI] = @LegalSponsorDPI
					  ,[HasAgreement] = @HasAgreement
					  ,[AgreementNumber] = @AgreementNumber
					  ,[AgreementDateStart] = @AgreementDateStart
					  ,[AgreementDateEnd] = @AgreementDateEnd
					  ,[InvoiceName] = @InvoiceName
					  ,[TaxIdentificationNumber] = @TaxIdentificationNumber
					  ,[FiscalAddress] = @FiscalAddress
					  ,[InvoiceEmail] = @InvoiceEmail
					  ,[ConditionOfPaymentID] = @ConditionOfPaymentID
					  ,[InvoiceContactName] = @InvoiceContactName
					  ,[InvoiceContactPhone] = @InvoiceContactPhone
					  ,[InvoiceContactEmail] = @InvoiceContactEmail
					  ,[CODAccountBankID] = @CODAccountBankID
					  ,[CODAccountNumber] = @CODAccountNumber
					  ,[CODAccountName] = @CODAccountName
					  ,[CODAccountTypeID] = @CODAccountTypeID
					  ,[CODCurrencyID] = @CODCurrencyID
					  ,[CODContactName] = @CODContactName
					  ,[CODContactPhone] = @CODContactPhone
					  ,[CODContactEmail] = @CODContactEmail
					  ,[RowSatus] = @RowSatus
					  ,[TokenUpdated] = @Token
					  ,[DateUpdated] = GETDATE()
					  --[SAPCardCode] = [SAPCardCode]
					  ,[ExcludePriceShippingCOD] = @ExcludePriceShippingCOD
					  ,[ExcludeCommissionCOD] = @ExcludeCommissionCOD
					  ,[CatBatchTypeCODId] = @CatBatchTypeCODId
					  ,[CatBatchFrequencyCODId] = @CatBatchFrequencyCODId
					  -------------------------
					  ,[SAPCardCode]=@CardCode
					  -------------------------
					  ,[DCBAID] = @DCBAID
					  ,[CatBillingTimeId] = @BillingTimeId
					  ,[CatBillingVolumeId] = @BillingVolumeId
				      ,[BillingCut_offDate] = @BillingCut_offDate
					  
				 WHERE IdCustomer = @IdCustomer

				  SELECT	'TRUE'	[blnResult]
							,CAST(@IdCustomer AS VARCHAR) [IdResult]
							,'' AS [ErrorNumber]
							,'' AS [ErrorSeverity]  
							,'' AS [ErrorState]
							,'' AS [ErrorProcedure]  
							,'' AS [ErrorLine]
							,'Success' AS [Message];  

		END

		COMMIT TRANSACTION;  

	END TRY
	BEGIN CATCH  
			SELECT 'FALSE'	[blnResult]
				,CAST(ERROR_NUMBER() AS VARCHAR) AS [ErrorNumber]
				,CAST(ERROR_SEVERITY() AS VARCHAR) AS [ErrorSeverity]
				,CAST(ERROR_STATE() AS VARCHAR) AS [ErrorState]
				,CAST(ERROR_PROCEDURE() AS VARCHAR) AS [ErrorProcedure]
				,CAST(ERROR_LINE() AS VARCHAR) AS [ErrorLine]  
				,CAST(ERROR_MESSAGE() AS NVARCHAR(MAX)) AS [Message];  
			ROLLBACK TRANSACTION;  
	END CATCH;  
END
