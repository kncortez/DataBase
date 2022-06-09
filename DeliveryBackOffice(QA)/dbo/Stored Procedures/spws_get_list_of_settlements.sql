
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-07-23>
-- Description:	<Obtiene los nombres de las poblaciones en base a su Id>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_list_of_settlements]
	-- Add the parameters for the stored procedure here
	@IdSettlement as bigint = -1,
	@IdTownship as int = -1,
	@IdProvince  as int = -1,
	@IdCountry as NVARCHAR(2) = 'GT'

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select pob.IdSettlement   [IdSettlement],
		   pob.Settlement	  [SettlementName],
		   pob.IdTownship     [IdTownship],
		   mun.TownshipName   [TownshipName],
		   mun.IdProvince     [IdProvince],
		   depto.ProvinceName [ProvinceName],
		   depto.IdCountry    [IdCountry],
		   ct.CNT_CountryName [CountryName]
	from DeliveryBackOffice.dbo.Settlement pob with (nolock)
	join DeliveryBackOffice.dbo.Township mun with(nolock) on pob.IdTownship = mun.IdTownship
	join DeliveryBackOffice.dbo.Province depto with (nolock) on depto.IdProvince = mun.IdProvince
	left join DenariusDesktop_Dev.dbo.PRM_Country ct with(nolock) on ct.CNT_IdCountry = depto.IdCountry
	where pob.SettlementSatus = 'TRUE'
	and (@IdSettlement = -1 or pob.IdSettlement = @IdSettlement)
	and (@IdTownship = -1 or mun.IdTownship = @IdTownship)
	and (@IdProvince = -1 or depto.IdProvince = @IdProvince)
	and pob.IdCountry = @IdCountry
END
