-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-12-19>
-- Description:	<Obtiene información para módulo Segmentos de Socios de Negocio Desktop>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_GetBusinessPartnerSegments]
	-- Add the parameters for the stored procedure here
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
	ORDER BY pO.ProvinceName

	SELECT
		IdProvince ProvinceId
	   ,ProvinceName ProvinceName
	FROM Province
	WHERE ProvinceStatus = 1

	SELECT
		IdTownship TownshipId
	   ,TownshipName TownshipName
	   ,IdProvince ProvinceId
	FROM Township
	WHERE TownshipStatus = 1

	SELECT
		CrsId SegmentId
	   ,CrsName SegmentName
	FROM CatRateSegment

END