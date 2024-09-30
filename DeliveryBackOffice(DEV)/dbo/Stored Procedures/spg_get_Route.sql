-- =============================================
-- Author:      <Abner, Juarez>
-- Create date: <2020-02-11>
-- Description: <Devuelve información sobre las rutas>
-- =============================================
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Update date: <2024-05-21>
-- Description: <Se agrega filtro por pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_Route]
(
  @IdCountry VARCHAR(2) = 'GT'
)
AS
BEGIN
     SELECT ctr.IdRoute
           ,ctr.CodeRoute
           ,ctr.[Description]
           ,ctr.IdTownship
           ,ts.TownshipName
           ,ctr.IdTypeRoute
           ,ctr.[Zone]
           ,ctr.RowStatus
           ,ctr.TokenCreated
           ,ctr.DateCreated
           ,ctr.TokenUpdated
           ,ctr.DateUpdated
      FROM [DeliveryBackOffice].[dbo].[CatRoute] ctr WITH(NOLOCK)
           INNER JOIN [DeliveryBackOffice].[dbo].[Township] ts WITH(NOLOCK) ON ts.IdTownship = ctr.IdTownship
           INNER JOIN [DeliveryBackOffice].[dbo].[Province] pr WITH(NOLOCK) ON pr.IdProvince = ts.IdProvince
     WHERE ctr.RowStatus = 1
       AND ProvinceStatus = 1
       AND IIF(pr.IdCountry IS NULL, 'GT', pr.IdCountry) = @IdCountry
END
