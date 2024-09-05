
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-02>
-- Description:	<Devuelve todos los vehiculos disponibles>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-06-04>
-- Description: <Se agrega filtro para filtrar por pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_CatVehicleType]
@value bit = 1,
@IdCountry VARCHAR(2) = 'GT'
AS
BEGIN
    SELECT IdTypeVehicle,
           [Name]
      FROM CatTypeVehicle
     WHERE RowStatus = 1
       AND IIF(IdCountry IS NULL, 'GT', IdCountry) = @IdCountry 
END