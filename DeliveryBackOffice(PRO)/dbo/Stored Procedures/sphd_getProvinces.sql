
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-11-02>
-- Description: <Obtener informacion de los departamentos activos.>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_getProvinces]
AS
BEGIN
    SELECT IdProvince, ProvinceName
    FROM DeliveryBackOffice.[dbo].[Province]
    WHERE ProvinceStatus = 1
END