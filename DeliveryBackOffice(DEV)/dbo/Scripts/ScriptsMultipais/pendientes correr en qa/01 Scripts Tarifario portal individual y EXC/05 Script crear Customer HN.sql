
--CLIENTE A COPIAR PERO PARA HONDURAS YA QUE NOS SERVIRA PARA TARIFARIOS
--SELECT * FROM DeliveryBackOffice.dbo.Customer WITH(NOLOCK)
--WHERE Name = 'FD EXPRESS CENTER' AND (CountryID = 'GT' OR CountryID IS NULL)

DECLARE @IdSaleVisor INT;
DECLARE @IdCustomerType INT;
DECLARE @IdTypeOfBusiness INT;
DECLARE @IdBusinessSegment INT;
DECLARE @IdBusinessActivity INT;
DECLARE @IdCommercialSegment INT;
DECLARE @IdCatBillingVolume INT;

BEGIN TRY
    BEGIN TRANSACTION;

	SELECT @IdSaleVisor = IdSaleAdvisor FROM DeliveryBackOffice.dbo.CatSaleAdvisor WITH(NOLOCK)
	WHERE SaleAdvisorCode = 'EXP CENTER' AND CountryID = 'HN'

	SELECT @IdCustomerType = IdCustomerType FROM DeliveryBackOffice.dbo.CustomerType WITH(NOLOCK)
	WHERE Description = 'REDISTRIBUIDOR'

	SELECT @IdTypeOfBusiness = IdTypeOfBusiness FROM DeliveryBackOffice.dbo.CatTypeOfBusiness WITH(NOLOCK)
	WHERE TypeOfBusinessName = 'CANAL MODERNO' AND CountryID = 'HN'

	SELECT @IdBusinessSegment = IdBusinessSegment FROM DeliveryBackOffice.dbo.CatBusinessSegment WITH(NOLOCK)
	WHERE BusinessSegmentName = 'C2C' AND IdCountry = 'HN'

	SELECT @IdBusinessActivity = IdBusinessActivity FROM DeliveryBackOffice.dbo.CatBusinessActivity WITH(NOLOCK)
	WHERE BusinessActivityName = 'LOGISTICA'

	SELECT @IdCommercialSegment = IdCommercialSegment FROM DeliveryBackOffice.dbo.CatCommercialSegment WITH(NOLOCK)
	WHERE CommercialSegmentName = 'EXPRESS CENTER'

	SELECT @IdCatBillingVolume = IdCatBillingVolume FROM DeliveryBackOffice.dbo.CatBillingVolume
	WHERE NameBillingVolume = 'Completo'

	--INSERT
	INSERT INTO [dbo].[Customer]
			   ([Name]
			   ,[Description]
			   ,[Domain]
			   ,[RegexSubject]
			   ,[RegexEmail]
			   ,[RegexFilename]
			   ,[Abbreviation]
			   ,[IdCustomerType]
			   ,[ConditionOfPaymentID]
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
			   ,[CatTMSalesPersonId]
			   ,[CutOffDate]
			   ,[UpgradeDate]
			   ,[CustomerGoalQuantity]
			   ,[CatBillingTimeId]
			   ,[CatBillingVolumeId]
			   ,[BillingCut_offDate]
			   ,[NumImgEvidence]
			   ,[IsCOD])
		 VALUES
			   ('FD EXPRESS CENTER HN'
			   ,'FD EXPRESS CENTER HN'
			   ,''
			   ,''
			   ,'TMP-'
			   ,''
			   ,'FORZA DELIVERY EXC HN'
			   ,@IdCustomerType
			   ,NULL
			   ,'HN'
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,@IdSaleVisor
			   ,NULL
			   ,NULL
			   ,@IdTypeOfBusiness
			   ,@IdBusinessSegment
			   ,@IdBusinessActivity
			   ,@IdCommercialSegment
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,1
			   ,'SYS-ERAMIREZ'
			   ,'2024-08-12 16:40:00.000'
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,@IdCatBillingVolume
			   ,NULL
			   ,NULL
			   ,NULL)

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;