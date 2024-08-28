-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-12-19>
-- Description:	<Obtiene información para módulo Segmentos de Socios de Negocio Desktop>
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-06-28>
-- Description:	<Se agrega parametro para filtra por pais>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_GetBusinessPartnerSegments]
	-- Add the parameters for the stored procedure here
		@IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	SELECT
		ctc.IdCorporateTownshipCoverage Id
	   ,pO.IdProvince ProvinceOriginId
	   ,pO.ProvinceName ProvinceOriginName
	   ,twnO.IdTownship TownshipOriginId
	   ,twnO.TownshipName TownshipOriginName
	   ,pD.IdProvince ProvinceDestinyId
	   ,pD.ProvinceName ProvinceDestinyName
	   ,twnD.IdTownship TownshipDestinyId
	   ,twnD.TownshipName TownshipDestinyName
	   ,crs.CrsId SegmentId
	   ,crs.CrsName SegmentName
	FROM CorporateTownshipCoverage ctc
	INNER JOIN Township twnO
		ON ctc.TownshipSourceId = twnO.IdTownship
	INNER JOIN Province pO
		ON twnO.IdProvince = pO.IdProvince
	INNER JOIN Township twnD
		ON ctc.TownshipDestinyId = twnD.IdTownship
	INNER JOIN Province pD
		ON twnD.IdProvince = pD.IdProvince
	INNER JOIN CatRateSegment crs
		ON ctc.SegmentTypeId = crs.CrsId
	WHERE ctc.RowStatus = 1
		AND ISNULL(pO.IdCountry,'GT') = @IdCountry AND ISNULL(pD.IdCountry,'GT') = @IdCountry
	ORDER BY pO.ProvinceName

	SELECT
		IdProvince ProvinceId
	   ,ProvinceName ProvinceName
	FROM Province
	WHERE ProvinceStatus = 1
		AND ISNULL(IdCountry,'GT') = @IdCountry

	SELECT
		Tw.IdTownship TownshipId
	   ,Tw.TownshipName TownshipName
	   ,Tw.IdProvince ProvinceId
	FROM Township Tw
		INNER JOIN Province Pr
		ON Tw.IdProvince = Pr.IdProvince
	WHERE TownshipStatus = 1
		AND ISNULL(Pr.IdCountry,'GT') = @IdCountry

	SELECT
		CrsId SegmentId
	   ,CrsName SegmentName
	FROM CatRateSegment

END