CREATE PROCEDURE [dbo].[sphd_getTownships]
	@ID AS INT
AS
BEGIN
	SELECT IdTownship, TownshipName
	FROM DeliveryBackOffice.[dbo].[Township]
	WHERE TownshipStatus = 1
	AND IdProvince = @ID
END