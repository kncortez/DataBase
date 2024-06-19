-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-06-07>
-- Description:	<Crear Guias - Crear método nuevo en lugar de Catalog/GetDynamicCatalog para Carga de Express Centers por país.>
-- =============================================

CREATE PROCEDURE [dbo].[spGetCatalogExcMC]
    -- Add the parameters for the stored procedure here
    @pToken VARCHAR(100) = '0BE2F8F3BD53652635746ACD069954B5',
    @pCountryId NVARCHAR(3)
AS
BEGIN

SELECT
	VPC.DescriptionOfClient										'Name',
	ISNULL(VPC.ContactName, '')									'ContactName',
	ISNULL(VPC.Phone, '')										'Phone',
	ISNULL(VPC.Email, '')										'Email',
	ISNULL(CONVERT(VARCHAR, TWS.IdTownship), '')				'IdTownship',
	ISNULL(TWS.TownshipDescription, '')							'TownshipName',
	ISNULL(CONVERT(VARCHAR, PRV.IdProvince), '')				'IdProvince',
	ISNULL(PRV.ProvinceDescription, '')							'ProvinceName',
	ISNULL(VPC.Address, '')										'Address',
	ISNULL(TWS.HeaderCode, '')									'HeaderCode',
	ISNULL( STL.Settlement, '')									'SettlementDescription',
	ISNULL(CONVERT(NVARCHAR, STL.IdSettlement), '')				'IdSettlement',
	ISNULL(CONVERT(NVARCHAR, VPC.CodeOfReference), '')			'CodeOfReference'
FROM DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
INNER JOIN DeliveryBackOffice.dbo.Settlement STL WITH(NOLOCK)
	ON VPC.IdSettlement = STL.IdSettlement 
INNER JOIN DeliveryBackOffice.dbo.Township TWS WITH(NOLOCK)
	ON TWS.IdTownship = STL.IdTownship
INNER JOIN DeliveryBackOffice.dbo.Province PRV WITH(NOLOCK)
	ON PRV.IdProvince = TWS.IdProvince
WHERE VPC.IdKindOfVPClient = 1 AND VPC.CountryId = @pCountryId
	AND VPC.StatusClient = 1
ORDER BY VPC.DescriptionOfClient

END;