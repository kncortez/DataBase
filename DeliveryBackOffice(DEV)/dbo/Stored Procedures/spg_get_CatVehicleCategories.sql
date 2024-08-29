
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-02>
-- Description:	<Devuelve todos los vehiculos disponibles>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-06-04>
-- Description: <Se agrega filtro para filtrar por pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_CatVehicleCategories]
@value bit = 1,
@IdCountry VARCHAR(2) = 'GT'
AS
BEGIN
	SELECT IdCatVehicleCategories, Name,COALESCE(Length,0) Length,COALESCE(Width,0) Width,COALESCE(High,0)High
	,COALESCE(UnitType,0) UnitType
	FROM CatVehicleCategories
	where RowStatus = 1
      AND IIF(IdCountry IS NULL,'GT',IdCountry) = @IdCountry
END