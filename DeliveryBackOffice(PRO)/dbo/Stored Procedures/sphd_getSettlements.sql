
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-11-02>
-- Description: <Obtener informacion de los poblados activos por ID de municipio.>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_getSettlements]
    @ID AS INT
AS
BEGIN
    SELECT IdSettlement, Settlement
    FROM [dbo].[Settlement]
    WHERE SettlementSatus = 1
    AND IdTownship = @ID
END