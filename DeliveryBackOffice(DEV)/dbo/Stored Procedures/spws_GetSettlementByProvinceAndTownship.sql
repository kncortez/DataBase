-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2025-01-03>
-- Description:	<Retorna listado de poblados desde su municipio y departamento>
-- =============================================
CREATE PROCEDURE [dbo].[spws_GetSettlementByProvinceAndTownship]
    @ProvinceId INT,
	@TownshipId INT
AS
BEGIN
    SET NOCOUNT ON;

	SELECT
		IdSettlement,
		Settlement
	FROM Settlement
	WHERE CHARINDEX(',', Settlement) > 0 
		AND SettlementSatus = 1
		AND IdProvince = @ProvinceId 
		AND IdTownship = @TownshipId;
END;