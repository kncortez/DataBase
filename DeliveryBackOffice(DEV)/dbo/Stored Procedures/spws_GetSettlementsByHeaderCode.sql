-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2025-01-03>
-- Description:	<Retorna listado de poblados desde su codigo de cabecera del municipio>
-- =============================================
CREATE PROCEDURE [dbo].[spws_GetSettlementsByHeaderCode]
    @HeaderCode VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

	SELECT
		stl.IdSettlement,
		stl.Settlement
	FROM DeliveryBackOffice.dbo.Settlement stl WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.Township t WITH (NOLOCK)
            ON t.IdTownship = stl.IdTownship
	WHERE stl.SettlementSatus = 1
		AND t.TownshipStatus = 1
		AND t.HeaderCode = @HeaderCode

END;