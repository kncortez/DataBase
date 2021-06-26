USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sphdSetCustomer]    Script Date: 6/25/2021 6:06:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-04-27>
-- Description:	<inserta o actualiza registros a clientes en base a flag @option 1 insert 2 update>
-- =============================================
CREATE PROCEDURE [dbo].[sphdSetCustomer]
	-- Add the parameters for the stored procedure here
	@IdCustomer INT,
	@NameCustomer NVARCHAR(100),
	@Description  NVARCHAR(100) = '',
	@Domain NVARCHAR(50)='',
	@RegexSubject NVARCHAR(100) = '',
	@RegexEmail NVARCHAR(100) = '',
	@RegexFilename NVARCHAR(100) = '',
	@Abbreviation NVARCHAR(25) = '',
	@IdCustomerType INT = 1,    -- 1	CORPORATIVO; 2	REDISTRIBUIDOR;  3	INDIVIDUAL
	@CountryID VARCHAR(2) =  'GT',
	@CommercialName NVARCHAR(50),
	@CustomerPhone NVARCHAR(50),
	@WebsiteURI NVARCHAR(50) = '',
	@ContactName NVARCHAR(50), 
	@ContactEmail NVARCHAR(50),
	@NotificationAddress NVARCHAR(200),
	@SaleAdvisorID INT = -1,
	@DateUpService DATETIME = NULL,
	@DateDownService DATETIME = NULL,
	@TypeOfBusinessID INT,
	@BusinessSegmentID INT,
	@BusinessActivityID INT,
	@CommercialSegmentID INT,
	@OperationContactName NVARCHAR(50) = '',
	@OperationContactPhone NVARCHAR(50) = '',
	@OperationContactEmail NVARCHAR(50) = '',
	@LegalSponsorName NVARCHAR(50) = '',
	@LegalSponsorLastName NVARCHAR(50) = '', 
	@LegalSponsorDPI NVARCHAR(50) = '',
	@HasAgreement BIT  = 'FALSE', 
	@AgreementNumber NVARCHAR(50) = '', 
	@AgreementDateStart DATETIME = NULL,
	@AgreementDateEnd DATETIME = NULL,
	@InvoiceName NVARCHAR(100) = '',
	@TaxIdentificationNumber NVARCHAR(50) = '',
	@FiscalAddress  NVARCHAR(200)  = '',
	@InvoiceEmail NVARCHAR(50) = '',
	@ConditionOfPaymentID INT  = 1,
	@InvoiceContactName NVARCHAR(50) = '',
	@InvoiceContactPhone NVARCHAR(50) = '',
	@InvoiceContactEmail NVARCHAR(50) = '',
	@CODAccountBankID INT = NULL,
	@CODAccountNumber NVARCHAR(50) = '',
	@CODAccountName NVARCHAR(50) = '',
	@CODAccountTypeID INT = NULL,
	@CODCurrencyID INT = NULL,
	@CODContactName NVARCHAR(50) = '',
	@CODContactPhone NVARCHAR(50) = '',
	@CODContactEmail NVARCHAR(50) = '',
	@RowSatus BIT = 'TRUE',
	@Token NVARCHAR(50) = 'SYS-FDADMIN',
	@Option AS INT  -- 1 create record, 2 update record
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY

		IF (@Option = 1)
		BEGIN 
			print 'insert record'
			IF NOT EXISTS ( SELECT cli.IdCustomer FROM Customer cli WHERE cli.Name = @NameCustomer) 
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
				   ,[SAPCardCode])
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
				   ,NULL)

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
		IF (@Option = 2)
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
					  --,[SAPCardCode] = @SAPCardCode
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
				,CAST(ERROR_MESSAGE() AS VARCHAR) AS [Message];  
			ROLLBACK TRANSACTION;  
	END CATCH;  
END
GO


