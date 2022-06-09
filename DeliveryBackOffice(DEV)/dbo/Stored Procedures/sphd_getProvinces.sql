CREATE PROCEDURE [dbo].[sphd_getProvinces]
AS
BEGIN
	SELECT IdProvince, ProvinceName
	FROM DeliveryBackOffice.[dbo].[Province]
	WHERE ProvinceStatus = 1
END