-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-12-11>
-- Description:	<Devuelve una lista de departamentos asociados a un pais>
-- =============================================
-- =============================================
-- Author:		<Cristian, Suazo>
-- Create date: <2024-06-28>
-- Description:	<Se agrega el IdProvince en la respuesta de la consulta>
-- =============================================
-- =============================================
-- Author:		<Garcia, Tito>
-- Create date: <2024-07-04>
-- Description:	<Se mejora el filtro por pais para tomar en cuenta el string vacio>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_list_provinces_by_header_code]
	-- Add the parameters for the stored procedure here
	@IdHeaderCode as nvarchar(2) = '-1',
	@IdCountry as nvarchar(2) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  
		depto.LocalCode		'HeaderCode',
		depto.ProvinceName	'ProvinceName',
		depto.IdProvince AS 'IdProvince',
		depto.IdCountry		'IdCountry'
	FROM DeliveryBackOffice.dbo.Province depto WITH (NOLOCK) 
	WHERE depto.ProvinceStatus = 'TRUE'
		AND depto.IdProvince = IIF(@IdHeaderCode != -1, @IdHeaderCode, depto.IdProvince)
		AND ISNULL(NULLIF(@IdCountry,''), depto.idCountry) = depto.idCountry
	ORDER BY depto.LocalCode

END
