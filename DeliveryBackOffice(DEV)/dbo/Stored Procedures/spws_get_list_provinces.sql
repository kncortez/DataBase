
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-07-23>
-- Description:	<Devuelve una lista de departamentos asociados a un pais>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_list_provinces]
	-- Add the parameters for the stored procedure here
	@IdProvince as int = -1,
	@IdCountry as nvarchar(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select depto.IdProvince   [IdProvince],
		   depto.ProvinceName [ProvinceName],
		   depto.IdCountry    [IdCountry],
		   depto.LocalCode    [HeaderCode],
		   ct.CNT_CountryName [CountryName]
	from DeliveryBackOffice.dbo.Province depto with(nolock) left join
	 DenariusDesktop_Dev.dbo.prm_country ct on depto.IdCountry = ct.CNT_IdCountry
	where depto.ProvinceStatus = 'TRUE'
	and  (@IdProvince = -1 or depto.IdProvince = @IdProvince)
	and depto.IdCountry = @IdCountry

END
