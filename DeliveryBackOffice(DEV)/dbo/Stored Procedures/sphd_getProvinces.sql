-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-11-02>
-- Description: <Obtener informacion de los departamentos activos.>
-- =============================================
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-05-23>
-- Description: <Agregar filtro por pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_getProvinces]
(
  @IdCountry  NVARCHAR(2) = 'GT'
)
AS
BEGIN
    SELECT IdProvince, ProvinceName
      FROM DeliveryBackOffice.[dbo].[Province]
     WHERE ProvinceStatus = 1
       AND IIF(IdCountry IS NULL, 'GT', IdCountry) = @IdCountry
END