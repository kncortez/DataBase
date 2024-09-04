
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-07-23>
-- Description:	<Obtiene el listado de todos los 
--               municipios de un departamento o 
--				 pais>
-- =============================================
-- =============================================
-- Author:		<Tito García>
-- Create date: <2024-07-04>
-- Description:	<se mejora el filtro para obtener destino según país de Origen en el cotizador>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_list_townships_by_header_code]
	-- Add the parameters for the stored procedure here
	@IdHeaderCodeTownship as nvarchar(10)  = '-1', --all
	@IdHeaderCode as  nvarchar(2) = '-1', --all
	@IdCountry as nvarchar(2) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		ISNULL(mun.HeaderCode, '0101') AS HeaderCodeTownship,
		ISNULL(depto.LocalCode, '01') AS HeaderCode,
		ISNULL(depto.ProvinceName, '') AS ProvinceName,
		ISNULL(depto.IdCountry, 'GT') AS Country,
		ISNULL(mun.TownshipName, '') AS TownshipName,
		ISNULL((SELECT TOP 1 IIF(ISNULL(COV.TDA, 0) = 0, 'false', 'true') 
		 FROM DBO.DumpServiceCoverage COV
		 WHERE COV.HeaderCode = mun.HeaderCode
		   AND COV.RowStatus = 1
		 ORDER BY TDA DESC), 'false') AS IsTDA,
		CONVERT(varchar, ISNULL(mun.IdTownship, 0)) AS IdTownship
	FROM 
		DeliveryBackOffice.dbo.Township mun WITH (NOLOCK)
	INNER JOIN 
		DeliveryBackOffice.dbo.Province depto 
		ON mun.IdProvince = depto.IdProvince 
	WHERE 
		mun.TownshipStatus = 'TRUE'
		AND depto.ProvinceStatus = 1
		AND ISNULL(NULLIF(@IdCountry,''), depto.IdCountry) = depto.IdCountry
		AND (@IdHeaderCodeTownship = '-1' OR mun.HeaderCode = @IdHeaderCodeTownship)
		AND (@IdHeaderCode = '-1' OR depto.LocalCode = @IdHeaderCode)
   
END
