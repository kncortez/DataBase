CREATE PROCEDURE [dbo].[sphd_getSettlements]
	@ID AS INT
AS
BEGIN
	SELECT IdSettlement, Settlement
	FROM [dbo].[Settlement]
	WHERE SettlementSatus = 1
	AND IdTownship = @ID
END
