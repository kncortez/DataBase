-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-03-19>
-- Description:	<Retorna los tipos de una ruta>
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
                               AND pv.ProvinceStatus = 1
   WHERE TownshipStatus = 1
     AND IIF(pv.IdCountry IS NULL, 'GT', pv.IdCountry) = @IdCountry

END
