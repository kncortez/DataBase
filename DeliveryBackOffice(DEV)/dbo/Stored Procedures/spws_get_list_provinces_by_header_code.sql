
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-12-11>
-- Description:	<Devuelve una lista de departamentos asociados a un pais>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_list_provinces_by_header_code]
	-- Add the parameters for the stored procedure here
	@IdHeaderCode as nvarchar(2) = '-1',
	@IdCountry as nvarchar(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  
		depto.LocalCode		'HeaderCode',
		depto.ProvinceName	'ProvinceName',
		depto.IdCountry		'IdCountry'
	FROM DeliveryBackOffice.dbo.Province depto WITH (NOLOCK) 
	WHERE depto.ProvinceStatus = 'TRUE'
		AND  (@IdHeaderCode = '-1' OR depto.LocalCode = @IdHeaderCode)
		AND depto.IdCountry = @IdCountry
	ORDER BY depto.LocalCode

END
