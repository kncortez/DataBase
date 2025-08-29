-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-19-04>
-- Description:	<Obtiene el listado de los clientes>
-- =============================================

-- =============================================
-- Author:		<Oscar,Rodriguez>
-- Update date: <2024-04-23>
-- Description:	<Se agrego obtencion de campo isCOD>
-- =============================================

-- =============================================
-- Author:		<Brandon, Pedroza>
-- Update date: <2024-06-03>
-- Description:	<Se agrega parametro para filtrar por pais>
-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Update date: <2024-06-26>
-- Description:	<Se agrega validacion para obtener campo isCOD sin valor null>
-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Update date: <2024-06-26>
-- Description:	<Se agrega validacion para obtener campo isCOD sin valor null>
-- =============================================
-- Modified:	<Tito Garcia>
-- Update date: <2024-10-21>
-- Description:	<Se agrega nuevo campo IsVoucherRequired>
-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Update date: <2025-06-12>
-- Description:	<Facturación SV - Obtiene campos de direccion de clientes para facturar de El Salvador>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetCustomer]
    -- Add the parameters for the stored procedure here
    @IdCustomer AS INT = -1
  , @Option AS INT = 0
  , @IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    IF (@Option = 0)
    BEGIN
        --First Catalog UI MgtCustomer
        SELECT CAST(cst.IdCustomer AS NVARCHAR)                                                                [IdValue]
             , IIF(cst.RowSatus = 0, '[INACTIVO] ', '') + UPPER(cst.Name) + ' ' + '[' + cst.Abbreviation + ']' [NameValue]
             , cst.CountryID                                                                                   [IdFilter]
        FROM Customer cst WITH(NOLOCK)
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              --AND cst.RowSatus = 'TRUE'
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              )
			  AND IIF(cst.CountryID IS NULL,'GT',cst.CountryID) = @IdCountry
        ORDER BY cst.Name;

        --Second Catalog UI MgtCustomer
        SELECT cst.SAPCardCode                                                                          [IdValue]
             , IIF(cst.RowSatus = 0, '[INACTIVO] ', '') + cst.Name + ' ' + '[' + cst.Abbreviation + ']' [NameValue]
             , cst.CountryID                                                                            [IdFilter]
        FROM Customer cst WITH(NOLOCK)
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              --AND cst.RowSatus = 'TRUE'
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              )
			  AND IIF(cst.CountryID IS NULL,'GT',cst.CountryID) = @IdCountry;

        --Third Data UI MgtCustomer
        SELECT cst.[IdCustomer]
             , cst.[Name]
             , cst.[Description]
             , cst.[Domain]
             , cst.[RegexSubject]
             , cst.[RegexEmail]
             , cst.[RegexFilename]
             , cst.[Abbreviation]
             , cst.[IdCustomerType]
             , cst.[CountryID]                             IdFilter
             , cst.[CommercialName]
             , cst.[CustomerPhone]
             , cst.[WebsiteURI]
             , cst.[ContactName]
             , cst.[ContactEmail]
             , cst.[NotificationAddress]
             , cst.[SaleAdvisorID]
             , cst.[DateUpService]
             , cst.[DateDownService]
             , cst.[TypeOfBusinessID]
             , cst.[BusinessSegmentID]
             , cst.[BusinessActivityID]
             , cst.[CommercialSegmentID]
             , cst.[OperationContactName]
             , cst.[OperationContactPhone]
             , cst.[OperationContactEmail]
             , cst.[LegalSponsorName]
             , cst.[LegalSponsorLastName]
             , cst.[LegalSponsorDPI]
             , cst.[HasAgreement]
             , cst.[AgreementNumber]
             , cst.[AgreementDateStart]
             , cst.[AgreementDateEnd]
             , cst.[InvoiceName]
             , cst.[TaxIdentificationNumber]
             , cst.[FiscalAddress]
             , cst.[InvoiceEmail]
             , cst.[ConditionOfPaymentID]
             , cst.[InvoiceContactName]
             , cst.[InvoiceContactPhone]
             , cst.[InvoiceContactEmail]
             , cst.[CODAccountBankID]
             , cst.[CODAccountNumber]
             , cst.[CODAccountName]
             , cst.[CODAccountTypeID]
             , cst.[CODCurrencyID]
             , cst.[CODContactName]
             , cst.[CODContactPhone]
             , cst.[CODContactEmail]
             , cst.[RowSatus]
             , cst.[SAPCardCode]
             , cst.[ExcludePriceShippingCOD]
             , cst.[ExcludeCommissionCOD]
             , ISNULL(cst.[CatBillingTimeId], -1)          AS CatBillingTimeId
             , ISNULL(cst.[CatBillingVolumeId], -1)        AS CatBillingVolumeId
             , ISNULL(cst.[BillingCut_offDate], GETDATE()) AS BillingCut_offDate
             , ISNULL(cst.[NumImgEvidence], 1)             AS NumImgEvidence
			 , ISNULL(cst.[IsCOD],0) IsCOD
			 , cst.[IsVoucherRequired]
        FROM Customer cst    WITH(NOLOCK)
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              --AND cst.RowSatus = 'TRUE'
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              )
			  AND IIF(cst.CountryID IS NULL,'GT',cst.CountryID) = @IdCountry
        ORDER BY cst.Name;
    END;

    IF (@Option = 1)
    BEGIN
        --First Catalog UI MgtCustomer
        SELECT CAST(cst.IdCustomer AS NVARCHAR)                                                                [IdValue]
             , IIF(cst.RowSatus = 0, '[INACTIVO] ', '') + UPPER(cst.Name) + ' ' + '[' + cst.Abbreviation + ']' [NameValue]
             , cst.CountryID                                                                                   [IdFilter]
        FROM Customer cst WITH(NOLOCK)
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              )
			  AND IIF(cst.CountryID IS NULL,'GT',cst.CountryID) = @IdCountry
        ORDER BY cst.Name;

        --Second Catalog UI MgtCustomer
        SELECT cst.SAPCardCode                                                                          [IdValue]
             , IIF(cst.RowSatus = 0, '[INACTIVO] ', '') + cst.Name + ' ' + '[' + cst.Abbreviation + ']' [NameValue]
             , cst.CountryID                                                                            [IdFilter]
        FROM Customer cst WITH(NOLOCK)
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              )
			  AND IIF(cst.CountryID IS NULL,'GT',cst.CountryID) = @IdCountry;

        --Third Data UI MgtCustomer
        SELECT cst.[IdCustomer]
             , cst.[Name]
             , cst.[Description]
             , cst.[Domain]
             , cst.[RegexSubject]
             , cst.[RegexEmail]
             , cst.[RegexFilename]
             , cst.[Abbreviation]
             , cst.[IdCustomerType]
             , cst.[CountryID]                             IdFilter
             , cst.[CommercialName]
             , cst.[CustomerPhone]
             , cst.[WebsiteURI]
             , cst.[ContactName]
             , cst.[ContactEmail]
             , cst.[NotificationAddress]
             , cst.[SaleAdvisorID]
             , cst.[DateUpService]
             , cst.[DateDownService]
             , cst.[TypeOfBusinessID]
             , cst.[BusinessSegmentID]
             , cst.[BusinessActivityID]
             , cst.[CommercialSegmentID]
             , cst.[OperationContactName]
             , cst.[OperationContactPhone]
             , cst.[OperationContactEmail]
             , cst.[LegalSponsorName]
             , cst.[LegalSponsorLastName]
             , cst.[LegalSponsorDPI]
             , cst.[HasAgreement]
             , cst.[AgreementNumber]
             , cst.[AgreementDateStart]
             , cst.[AgreementDateEnd]
             , cst.[InvoiceName]
             , cst.[TaxIdentificationNumber]
             , cst.[FiscalAddress]
             , cst.[InvoiceEmail]
             , cst.[ConditionOfPaymentID]
             , cst.[InvoiceContactName]
             , cst.[InvoiceContactPhone]
             , cst.[InvoiceContactEmail]
             , cst.[CODAccountBankID]
             , cst.[CODAccountNumber]
             , cst.[CODAccountName]
             , cst.[CODAccountTypeID]
             , cst.[CODCurrencyID]
             , cst.[CODContactName]
             , cst.[CODContactPhone]
             , cst.[CODContactEmail]
             , cst.[RowSatus]
             , cst.[SAPCardCode]
             , cst.[ExcludePriceShippingCOD]
             , cst.[ExcludeCommissionCOD]
             , cst.[CatBatchTypeCODId]
             , cst.[CatBatchFrequencyCODId]
             , ISNULL(cst.[CatBillingTimeId], -1)          AS CatBillingTimeId
             , ISNULL(cst.[CatBillingVolumeId], -1)        AS CatBillingVolumeId
             , ISNULL(cst.[BillingCut_offDate], GETDATE()) AS BillingCut_offDate
             , ISNULL(cst.[NumImgEvidence], 1)             AS NumImgEvidence
			 , ISNULL(cst.[IsCOD],0) IsCOD
			 , cst.[IsVoucherRequired]
        FROM Customer cst WITH(NOLOCK)
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              )
              AND IIF(cst.CountryID IS NULL,'GT',cst.CountryID) = @IdCountry
        ORDER BY cst.Name;

    END;

    IF (@Option = 3) --First Load Socios de negocio
    BEGIN

		--First Catalog UI MgtCustomer
        SELECT CAST(cst.IdCustomer AS NVARCHAR)                                                                [IdValue]
             , IIF(cst.RowSatus = 0, '[INACTIVO] ', '') + UPPER(cst.Name) + ' ' + '[' + cst.Abbreviation + ']' [NameValue]
             , cst.CountryID                                                                                   [IdFilter]
        FROM Customer cst WITH(NOLOCK)
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              )
			  AND IIF(cst.CountryID IS NULL,'GT',cst.CountryID) = @IdCountry
        ORDER BY cst.Name;

        --Second Catalog UI MgtCustomer
        SELECT cst.SAPCardCode                                                                          [IdValue]
             , IIF(cst.RowSatus = 0, '[INACTIVO] ', '') + cst.Name + ' ' + '[' + cst.Abbreviation + ']' [NameValue]
             , cst.CountryID                                                                            [IdFilter]
        FROM Customer cst WITH(NOLOCK)
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              )
			  AND IIF(cst.CountryID IS NULL,'GT',cst.CountryID) = @IdCountry;

        --Third Data UI MgtCustomer
        SELECT cst.[IdCustomer]
             , cst.[Name]
        FROM Customer cst WITH(NOLOCK)
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              )
			  AND IIF(cst.CountryID IS NULL,'GT',cst.CountryID) = @IdCountry
        ORDER BY cst.Name;
	END;

    IF (@Option = 4) --First Load Punto de visita
    BEGIN

		--First Catalog UI MgtCustomer
        SELECT CAST(cst.IdCustomer AS NVARCHAR)                                                                [IdValue]
             , IIF(cst.RowSatus = 0, '[INACTIVO] ', '') + UPPER(cst.Name) + ' ' + '[' + cst.Abbreviation + ']' [NameValue]
             , cst.CountryID                                                                                   [IdFilter]
        FROM Customer cst WITH(NOLOCK)
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              )
			  AND IIF(cst.CountryID IS NULL,'GT',cst.CountryID) = @IdCountry
        ORDER BY cst.Name;

        --Second Catalog UI MgtCustomer
        SELECT cst.SAPCardCode                                                                          [IdValue]
             , IIF(cst.RowSatus = 0, '[INACTIVO] ', '') + cst.Name + ' ' + '[' + cst.Abbreviation + ']' [NameValue]
             , cst.CountryID                                                                            [IdFilter]
        FROM Customer cst WITH(NOLOCK)
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              )
              AND IIF(cst.CountryID IS NULL,'GT',cst.CountryID) = @IdCountry;

        --Third Data UI MgtCustomer
        SELECT cst.[IdCustomer]
             , cst.[Name]
			 , cst.[SaleAdvisorID]
        FROM Customer cst WITH(NOLOCK)
        WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
              AND
              (
                  @IdCustomer = -1
                  OR cst.IdCustomer = @IdCustomer
              )
			 AND IIF(cst.CountryID IS NULL,'GT',cst.CountryID) = @IdCountry
        ORDER BY cst.Name;
	END;
    -- Facturacion El Salvador
	SELECT
		BL.Id,
		BL.IdCustomer,
        BL.IdTownship,
        BL.IdProvince,
		BL.ActivityId AS CodeActivity,
		BL.NRC,
		BL.Nirphone,
		BL.Phone
    FROM dbo.BillingCustomerBySV BL WITH(NOLOCK)
    LEFT JOIN dbo.DistrictByBillingSV DIS WITH(NOLOCK)
       ON DistrictId = DIS.Id
    WHERE BL.IdCustomer = @IdCustomer
        AND BL.RowStatus = 1;

END;
