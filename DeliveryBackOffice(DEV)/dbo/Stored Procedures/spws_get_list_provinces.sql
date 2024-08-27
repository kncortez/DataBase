
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-07-23>
-- Description:	<Devuelve una lista de departamentos asociados a un pais>
-- =============================================
-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2024-07-03>
-- Description:	<Validación si se muestra la información de varios paises o uno en especifico>
-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2024-08-26>
-- Description:	<Se cambia tabla prm_country de base Denarius por tabla catcountry en base DeliveryBackOffice>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_list_provinces]
	-- Add the parameters for the stored procedure here
	@IdProvince as int = -1,
	@IdCountry as nvarchar(2) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT depto.IdProvince [IdProvince],
		   depto.ProvinceName [ProvinceName],
		   depto.IdCountry [IdCountry],
		   depto.LocalCode [HeaderCode],
		   cc.CountryNameES [CountryName]
	FROM DeliveryBackOffice.dbo.Province depto WITH(NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.CatCountry cc WITH(NOLOCK) 
			ON depto.IdCountry = cc.IdCountry
	WHERE depto.ProvinceStatus = 'TRUE'
	  AND depto.IdProvince = IIF(@IdProvince != -1, @IdProvince, depto.IdProvince)
	  AND ISNULL(NULLIF(@IdCountry,''), depto.IdCountry) = depto.IdCountry

END
