-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-05-11>
-- Description:	<Obtiene información de Departamentos y Municipios para el Parser>
-- =============================================
CREATE PROCEDURE [dbo].[GetGeographicalData]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT p.ProvinceName, t.TownshipName
	FROM Province p WITH(NOLOCK)
	INNER JOIN Township t WITH(NOLOCK)
	ON p.IdProvince = t.IdProvince
	WHERE p.ProvinceStatus = 1
	AND t.TownshipStatus = 1
	ORDER BY p.ProvinceName

END