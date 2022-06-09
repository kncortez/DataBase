
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-11-02>
-- Description: <Obtener informacion de los municipios activos por ID de departamento.>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_getTownships]
    @ID AS INT
AS
BEGIN
    SELECT IdTownship, TownshipName
    FROM DeliveryBackOffice.[dbo].[Township]
    WHERE TownshipStatus = 1
    AND IdProvince = @ID
END