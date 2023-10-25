
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-07-23>
-- Description:	<Obtiene el listado de todos los 
--               municipios de un departamento o 
--				 pais>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_list_townships]
	-- Add the parameters for the stored procedure here
	@IdTownship as int  = -1, --all
	@IdProvince as int = -1, --all
	@IdCountry as nvarchar(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select	mun.IdTownship     [IdTownship], 
			mun.TownshipName   [TownshipName], 
			mun.[HeaderCode]   [TownshipHeaderCode], 
			mun.IdProvince     [IdProvince],
			depto.ProvinceName [ProvinceName], 
			depto.IdCountry	   [IdCountry],
			ct.CNT_CountryName [CountryName]
	from DeliveryBackOffice.dbo.Township mun with(nolock)
			join DeliveryBackOffice.dbo.Province depto with(nolock) on mun.IdProvince = depto.IdProvince
			left join DenariusDesktop_Dev.dbo.prm_country ct with(nolock) on depto.IdCountry = ct.CNT_IdCountry
	where  mun.TownshipStatus = 'TRUE'
	and depto.IdCountry = @IdCountry
	and (@IdTownship = -1 or  mun.IdTownship = @IdTownship)
	and (@IdProvince = -1 or mun.IdProvince = @IdProvince)
END
