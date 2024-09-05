-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-03-19>
-- Description:	<Retorna los tipos de una ruta>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-06-03>
-- Description: <Se agrega filtro por pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[get_Township]
(
 @IdCountry AS NVARCHAR(2) = 'GT'
)
AS
BEGIN

  SELECT ts.IdTownship,
         ts.TownshipName,
         ts.IdProvince 
    FROM Township ts
         INNER JOIN Province pv ON pv.IdProvince = ts.IdProvince
   WHERE TownshipStatus = 1
     AND pv.ProvinceStatus = 1
     AND IIF(pv.IdCountry IS NULL, 'GT', pv.IdCountry) = @IdCountry

END
