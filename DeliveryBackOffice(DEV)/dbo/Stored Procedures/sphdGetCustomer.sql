-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-19-04>
-- Description:	<Obtiene el listado de los clientes>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetCustomer]
    -- Add the parameters for the stored procedure here
    @IdCustomer AS INT = -1,
    @Option AS INT = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    IF (@Option = 0)
    BEGIN
        --First Catalog UI MgtCustomer
        SELECT CAST(cst.IdCustomer AS NVARCHAR) [IdValue],
               IIF(cst.RowSatus = 0, '[INACTIVO] ', '') + UPPER(cst.Name) + ' ' + '[' + cst.Abbreviation + ']' [NameValue],
               cst.CountryID [IdFilter]
        FROM Customer cst
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              --AND cst.RowSatus = 'TRUE'
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              )
        ORDER BY cst.Name;

        --Second Catalog UI MgtCustomer
        SELECT cst.SAPCardCode [IdValue],
               IIF(cst.RowSatus = 0, '[INACTIVO] ', '') + cst.Name + ' ' + '[' + cst.Abbreviation + ']' [NameValue],
               cst.CountryID [IdFilter]
        FROM Customer cst
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              --AND cst.RowSatus = 'TRUE'
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              );

        --Third Data UI MgtCustomer
        SELECT cst.[IdCustomer],
               cst.[Name],
               cst.[Description],
               cst.[Domain],
               cst.[RegexSubject],
               cst.[RegexEmail],
               cst.[RegexFilename],
               cst.[Abbreviation],
               cst.[IdCustomerType],
               cst.[CountryID] IdFilter,
               cst.[CommercialName],
               cst.[CustomerPhone],
               cst.[WebsiteURI],
               cst.[ContactName],
               cst.[ContactEmail],
               cst.[NotificationAddress],
               cst.[SaleAdvisorID],
               cst.[DateUpService],
               cst.[DateDownService],
               cst.[TypeOfBusinessID],
               cst.[BusinessSegmentID],
               cst.[BusinessActivityID],
               cst.[CommercialSegmentID],
               cst.[OperationContactName],
               cst.[OperationContactPhone],
               cst.[OperationContactEmail],
               cst.[LegalSponsorName],
               cst.[LegalSponsorLastName],
               cst.[LegalSponsorDPI],
               cst.[HasAgreement],
               cst.[AgreementNumber],
               cst.[AgreementDateStart],
               cst.[AgreementDateEnd],
               cst.[InvoiceName],
               cst.[TaxIdentificationNumber],
               cst.[FiscalAddress],
               cst.[InvoiceEmail],
               cst.[ConditionOfPaymentID],
               cst.[InvoiceContactName],
               cst.[InvoiceContactPhone],
               cst.[InvoiceContactEmail],
               cst.[CODAccountBankID],
               cst.[CODAccountNumber],
               cst.[CODAccountName],
               cst.[CODAccountTypeID],
               cst.[CODCurrencyID],
               cst.[CODContactName],
               cst.[CODContactPhone],
               cst.[CODContactEmail],
               cst.[RowSatus],
               cst.[SAPCardCode],
			   cst.[ExcludePriceShippingCOD],
			   cst.[ExcludeCommissionCOD],
			   ISNULL(cst.[CatBillingTimeId],-1)  AS CatBillingTimeId,
			   ISNULL(cst.[CatBillingVolumeId],-1) AS CatBillingVolumeId,
			   ISNULL(cst.[BillingCut_offDate],GETDATE()) AS BillingCut_offDate
        FROM Customer cst
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              --AND cst.RowSatus = 'TRUE'
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              )
        ORDER BY cst.Name;
    END;

	IF (@Option = 1)
    BEGIN
	--First Catalog UI MgtCustomer
        SELECT CAST(cst.IdCustomer AS NVARCHAR) [IdValue],
               IIF(cst.RowSatus = 0, '[INACTIVO] ', '') + UPPER(cst.Name) + ' ' + '[' + cst.Abbreviation + ']' [NameValue],
               cst.CountryID [IdFilter]
        FROM Customer cst
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
		AND (@IdCustomer = -1 OR cst.IdCustomer = @IdCustomer)
        ORDER BY cst.Name;

        --Second Catalog UI MgtCustomer
        SELECT cst.SAPCardCode [IdValue],
               IIF(cst.RowSatus = 0, '[INACTIVO] ', '') + cst.Name + ' ' + '[' + cst.Abbreviation + ']' [NameValue],
               cst.CountryID [IdFilter]
        FROM Customer cst
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
		AND (@IdCustomer = -1 OR cst.IdCustomer = @IdCustomer);

        --Third Data UI MgtCustomer
        SELECT cst.[IdCustomer],
               cst.[Name],
               cst.[Description],
               cst.[Domain],
               cst.[RegexSubject],
               cst.[RegexEmail],
               cst.[RegexFilename],
               cst.[Abbreviation],
               cst.[IdCustomerType],
               cst.[CountryID] IdFilter,
               cst.[CommercialName],
               cst.[CustomerPhone],
               cst.[WebsiteURI],
               cst.[ContactName],
               cst.[ContactEmail],
               cst.[NotificationAddress],
               cst.[SaleAdvisorID],
               cst.[DateUpService],
               cst.[DateDownService],
               cst.[TypeOfBusinessID],
               cst.[BusinessSegmentID],
               cst.[BusinessActivityID],
               cst.[CommercialSegmentID],
               cst.[OperationContactName],
               cst.[OperationContactPhone],
               cst.[OperationContactEmail],
               cst.[LegalSponsorName],
               cst.[LegalSponsorLastName],
               cst.[LegalSponsorDPI],
               cst.[HasAgreement],
               cst.[AgreementNumber],
               cst.[AgreementDateStart],
               cst.[AgreementDateEnd],
               cst.[InvoiceName],
               cst.[TaxIdentificationNumber],
               cst.[FiscalAddress],
               cst.[InvoiceEmail],
               cst.[ConditionOfPaymentID],
               cst.[InvoiceContactName],
               cst.[InvoiceContactPhone],
               cst.[InvoiceContactEmail],
               cst.[CODAccountBankID],
               cst.[CODAccountNumber],
               cst.[CODAccountName],
               cst.[CODAccountTypeID],
               cst.[CODCurrencyID],
               cst.[CODContactName],
               cst.[CODContactPhone],
               cst.[CODContactEmail],
               cst.[RowSatus],
               cst.[SAPCardCode],
			   cst.[ExcludePriceShippingCOD],
			   cst.[ExcludeCommissionCOD],
			   cst.[CatBatchTypeCODId],
			   cst.[CatBatchFrequencyCODId],
			    ISNULL(cst.[CatBillingTimeId],-1)  AS CatBillingTimeId,
			   ISNULL(cst.[CatBillingVolumeId],-1) AS CatBillingVolumeId,
			   ISNULL(cst.[BillingCut_offDate],GETDATE()) AS BillingCut_offDate
        FROM Customer cst
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
		AND ( @IdCustomer = -1 OR cst.IdCustomer = @IdCustomer)
        ORDER BY cst.Name;

	END

END;
