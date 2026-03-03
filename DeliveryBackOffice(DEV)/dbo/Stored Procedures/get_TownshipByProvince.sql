-- =============================================
-- Author:      <Cristian, Azurdia>
-- Create date: <2025-07-28>
-- Description: <Se agrega filtro por pais, por defecto GT>
-- =============================================
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2026-03-03>
-- Description: <Remover función doble condición>
-- =============================================
CREATE PROCEDURE [dbo].[get_TownshipByProvince]
(
 @IdCountry  AS NVARCHAR(2) = 'GT'
)
AS
BEGIN
        SELECT ts.IdTownship,
               ts.TownshipName,
               ts.IdProvince 
          FROM Township ts WITH(NOLOCK)
               INNER JOIN Province pv WITH(NOLOCK)
               ON pv.IdProvince = ts.IdProvince
         WHERE TownshipStatus = 1
           AND pv.ProvinceStatus = 1
           AND pv.IdCountry = @IdCountry
END