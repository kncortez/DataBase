-- =============================================
-- Author:		<Edwin,,Ramirez>
-- Create date: <2021-05-13>
-- Description:	<Get VisitPoints Clients from Hermes by ID>
-- =============================================
-- =============================================
-- Author:		<Oscar,,Rodriguez>
-- Update date: <2024-05-26>
-- Description:	<Add Value isCOD from Customer Table for VisitPoints in Hermes>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_GetVisitPointById]
    -- Add the parameters for the stored procedure here
    @IdVisitPoint AS INT = -1
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT vpc.[IdVisitPointClient],
           vpc.[CodeOfReference] [IdVisitPoint],
           vpc.[DescriptionOfClient] [VPName],
           '[ ' + CAST(vpc.[CodeOfReference] AS VARCHAR) + ' ]' + ' - ' + vpc.[DescriptionOfClient] [VPDisplayName],
           vpc.[ContactName],
           vpc.[Phone],
           vpc.[Email],
           vpc.[Address],
           vpc.[BranchCode],
           vcf.[AveragePackageDaily],
           vcf.[DateStartOperation],
           vpc.[Latitude],
           vpc.[Longitude],
		   vpc.Accuracy,
           vpc.[Zone],
           vpc.[Town],
           vpc.[Department],
           vpc.[CountryId],
           vpc.[StatusClient],
           vpc.[CustomerID],
           vpc.[IdKindOfVPClient],
           vpc.[IdKindOfVPBusiness],
           vpc.[IdSettlement],
           vpc.[IdTownship],
		   twn.[TownshipName],
           twn.[IdProvince],
		   prv.[ProvinceName],
           vpc.[VisitPointId] [VPDenariusCode],
           vcf.IdVPConfiguration,
		   vcf.HubLogisticID,
           vcf.TransportCompanyID,
           vcf.CODAccountBankID,
           vcf.CODAccountName,
           vcf.CODAccountNumber,
           vcf.CODAccountBankTypeID,
           vcf.CODAccountCurrencyID,
		   vpf.IdVPFrequency,
		   vpc.SaleChannelId,
		   IIF(vpc.ExcludePriceShippingCOD = 'TRUE', vpc.ExcludePriceShippingCOD, 'FALSE') CODExcludedPriceShipping,
		   IIF(vpc.ExcludeCommissionCOD = 'TRUE', vpc.ExcludeCommissionCOD, 'FALSE') CODExcludedCommission,
			ISNULL(vpc.AllowScheduledPickups, 1) 'AllowScheduledPickups',
			ISNULL(vpc.CatBusinessSegmentId, 0) CatBusinessSegmentId,
			ISNULL(vcf.[CatBillingTimeId],-1)  AS CatBillingTimeId,
			ISNULL(vcf.[CatBillingVolumeId],-1) AS CatBillingVolumeId,
			vcf.[BillingCut_offDate] AS  BillingCut_offDate,
			cs.isCOD
    FROM DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK)
		INNER JOIN dbo.Customer cs WITH(NOLOCK)
			ON vpc.CustomerID = cs.IdCustomer
        LEFT JOIN dbo.Township twn  WITH(NOLOCK)
            ON twn.IdTownship = vpc.IdTownship
		LEFT JOIN dbo.Province prv  WITH(NOLOCK)
			ON prv.IdProvince = twn.IdProvince
        LEFT JOIN dbo.VisitPointConfiguration vcf WITH(NOLOCK)
            ON vpc.CodeOfReference = vcf.VisitPointID
			AND vcf.RowStatus = 'TRUE'
		LEFT JOIN dbo.VisitPointFrequency vpf WITH(NOLOCK)
			ON vpf.VPConfigurationID = vcf.IdVPConfiguration
			AND vpf.RowStatus = 'TRUE'
    WHERE (
              @IdVisitPoint = -1
              OR vpc.CodeOfReference = @IdVisitPoint
          );


END;
