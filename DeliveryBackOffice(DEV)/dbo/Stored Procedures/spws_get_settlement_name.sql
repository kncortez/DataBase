
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-07-23>
-- Description:	<Devuelve el nombre de un poblado
--				basado en coincidencia de  nombre>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_settlement_name]
	-- Add the parameters for the stored procedure here
	@ValName as nvarchar(100),
	@IdCountry as nvarchar(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select pob.IdSettlement   [IdSettlement],
		   pob.Settlement     [SettlementName],
		   pob.IdTownship     [IdTownship],
		   mun.TownshipName   [TownshipName],
		   mun.IdProvince     [IdProvince],
		   depto.ProvinceName [ProvinceName],
		   depto.IdCountry    [IdCountry],
		   ct.CNT_CountryName [CountryName],
		   isnull(cov.HeaderCode,'0101')	  [HeaderCode]
	from DeliveryBackOffice.dbo.Settlement pob with (nolock)
	join DeliveryBackOffice.dbo.Township mun with(nolock) on pob.IdTownship = mun.IdTownship
	join DeliveryBackOffice.dbo.Province depto with (nolock) on depto.IdProvince = mun.IdProvince
	left join DenariusDesktop_Dev.dbo.PRM_Country ct with(nolock) on ct.CNT_IdCountry = depto.IdCountry
	left join DeliveryBackOffice.dbo.DumpServiceCoverage cov on cov.IdSettlement = pob.IdSettlement
	and COV.RowStatus = 1
	where pob.SettlementSatus = 'TRUE'
	and pob.Settlement like '%' + @ValName + '%'
	and pob.IdCountry = @IdCountry

END
