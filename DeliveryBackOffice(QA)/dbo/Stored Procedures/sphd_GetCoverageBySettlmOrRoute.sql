-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2021-11-16>
-- Description:	<Devuelve una tabla con los datos de la tabla DumpServiceCoverage>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-05-12>
-- Description:	< Adición de identificador si posee ubicación >
-- =============================================
CREATE PROCEDURE [dbo].[sphd_GetCoverageBySettlmOrRoute]
	@toSearch as nvarchar(50) = NULL
AS

BEGIN
		Declare @regexp NVARCHAR(55) ;
		Set @regexp = '%'+@toSearch+'%';
		SELECT Hub,IdDump as Id, RouteCode as Route,prov.ProvinceName as Province ,towns.TownshipName as Township,setl.Settlement as Settlement,Coverage,DeliveryTime,SDD,NDD,TDA, CAST(IIF(setl.SettlementLatitud IS NULL, 0, 1) AS BIT) 'IsLocated', CAST(setl.SettlementLatitud AS NVARCHAR) 'SettlementLatitud', CAST(setl.SettlementLongitud AS NVARCHAR) 'SettlementLongitud'
			FROM dbo.DumpServiceCoverage cov WITH(NOLOCK)
			INNER JOIN dbo.Settlement setl WITH(NOLOCK) ON setl.IdSettlement=cov.IdSettlement
			INNER JOIN dbo.Township towns WITH(NOLOCK) ON towns.IdTownship=setl.IdTownship 
			INNER JOIN dbo.Province prov WITH(NOLOCK) ON prov.IdProvince=towns.IdProvince
			WHERE  (cov.RowStatus=1) and ((@toSearch is NULL) or (Hub like @regexp or setl.Settlement like @regexp  or setl.Settlement like @regexp  or RouteCode like @regexp ))
END


