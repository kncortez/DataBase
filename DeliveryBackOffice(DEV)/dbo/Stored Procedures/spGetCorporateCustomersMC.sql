-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-06-26>
-- Description:	<Crear Guías - Método que devuelva un listado de clientes corporativos filtrado por país.>
-- =============================================

CREATE PROCEDURE [dbo].[spGetCorporateCustomersMC]
    -- Add the parameters for the stored procedure here
    @pOthers VARCHAR(100) = '',
    @pCountryId NVARCHAR(3) = 'GT'
AS
BEGIN

DECLARE @ActiveSalesPackageId INT = ( SELECT TOP 1 CSPS.IdCatSalesPackageStatus FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH(NOLOCK) WHERE CSPS.SalesPackageStatusName = 'Activa' COLLATE Latin1_General_CI_AI )

SELECT DISTINCT
    CONVERT(NVARCHAR, ISNULL(IdCustomer, 0)) AS [Id],
    REPLACE(ISNULL(cu.[Name], 'N/A'), '"', '') AS [Name],
    ISNULL(cu.[CustomerPhone], '') AS [Phone],
    ISNULL(cu.[ContactEmail], '') AS [Email],
    CONVERT(NVARCHAR, ISNULL(vpc.[CodeOfReference], '')) AS CodeOfReference,
    ISNULL(REPLACE(vpc.[DescriptionOfClient], '"', ''), '') AS Description,
    ISNULL(REPLACE(vpc.[Address], '"', ''), '') AS [Address],
    ISNULL(pr.ProvinceName, '') AS Province,
    ISNULL(TWS.TownshipName, '') AS Township,
    ISNULL(TWS.HeaderCode, '') AS HeaderCode,
    CONVERT(NVARCHAR, ISNULL((CASE WHEN mmbrshp.IdMembership IS NOT NULL THEN 1 ELSE 0 END), 0)) AS HasMembership,
    CONVERT(NVARCHAR, ISNULL(rc.[RbcRowStatus], '')) AS HasRate,
    CONVERT( NVARCHAR,
    ISNULL(
		IIF(ISNULL(ccp.ConditionOfPayment, 'Contado') = 'Contado',
    '0','1'),'' )) AS HasCredit,
    CONVERT(NVARCHAR,ISNULL(rh.InsuranceRate, 0)) AS InsuranceRate,
	CONVERT(NVARCHAR,ISNULL(rh.InsuranceExempt, 0)) AS InsuranceExempt,
    REPLACE(ISNULL(Cu.[InvoiceName], ''), '"', '') AS EntityName,
    ISNULL(Cu.[TaxIdentificationNumber], '') AS TaxId,
    REPLACE(ISNULL(Cu.[FiscalAddress], ''), '"', '') AS TaxAddress,
    REPLACE(ISNULL(Cu.[InvoiceEmail], ''), CHAR(31), '') AS TaxEmail,
    CONVERT(NVARCHAR, ISNULL([CODAccountBankID], '')) AS IdBank,
    REPLACE(CONVERT(NVARCHAR, ISNULL(dbk.[Name], '')), '"', '') AS BankDescription,
    REPLACE(CONVERT(NVARCHAR, ISNULL(dbk.[Acronym], '')), '"', '') AS Acronym,
    REPLACE(ISNULL([CODAccountName], ''), '"', '') AS NameAccount,
    CONVERT(NVARCHAR, ISNULL(cba.[BankAccountType], '')) AS TypeAccount,
    ISNULL([CODAccountNumber], '') AS NumberAcc
FROM DeliveryBackOffice.dbo.Customer cu WITH(NOLOCK)
LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank dbk WITH(NOLOCK)
    ON cu.CODAccountBankID = dbk.Id_bank
    AND (dbk.Id_country = @pCountryId OR (@pCountryId = 'GT' AND dbk.Id_country IS NULL))
    AND dbk.Id_status = 1
LEFT JOIN DeliveryBackOffice.dbo.CatBankAccountType cba WITH(NOLOCK)
    ON cu.CODAccountTypeID = cba.IdBankAccountType
    AND cba.RowStatus = 1
LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer rc WITH(NOLOCK)
    ON cu.IdCustomer = rc.RbcIdCustomer
    AND rc.RbcRowStatus = 1
LEFT JOIN DeliveryBackOffice.dbo.RateHeader rh WITH(NOLOCK)
	ON rc.RbcIdRate = rh.RheId AND rh.RheRowStatus = 1
LEFT JOIN DeliveryBackOffice.dbo.CatConditionOfPayment ccp WITH(NOLOCK)
    ON ccp.IdConditionOfPayment = cu.ConditionOfPaymentID
INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK)
    ON vpc.CustomerID = cu.IdCustomer
LEFT JOIN DeliveryBackOffice.dbo.Settlement STL WITH(NOLOCK)
    ON vpc.IdSettlement = STL.IdSettlement
LEFT JOIN DeliveryBackOffice.dbo.Township TWS WITH(NOLOCK)
    ON TWS.IdTownship = STL.IdTownship 
LEFT JOIN DeliveryBackOffice.dbo.Province pr WITH(NOLOCK)
    ON pr.IdProvince = TWS.IdProvince
LEFT JOIN DeliveryBackOffice.dbo.Membership mmbrshp WITH(NOLOCK)
    ON cu.IdCustomer = mmbrshp.CustomerId
    AND mmbrshp.RowStatus = 1
    AND mmbrshp.ExpirationDate >= GETDATE()
    AND mmbrshp.CatMembershipStatusId IN (@ActiveSalesPackageId)
WHERE IdCustomerType = 1 
    AND vpc.StatusClient = 1
    AND cu.RowSatus = 1
    AND (cu.IdCustomer = IIF(ISNUMERIC(@pOthers) = 1, @pOthers, 0)
         OR cu.Name LIKE CONCAT('%', @pOthers, '%')
         OR vpc.DescriptionOfClient LIKE CONCAT('%', @pOthers, '%'))
	AND (cu.CountryID = @pCountryId OR (@pCountryId = 'GT' AND cu.CountryID IS NULL))
    AND RowSatus = 1;
                               
END;