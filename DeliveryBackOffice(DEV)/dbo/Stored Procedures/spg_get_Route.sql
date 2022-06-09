
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-11>
-- Description:	<Devuelve información sobre las rutas>
-- =============================================

-- =============================================
-- Author:		<Cesar, Sazo>
-- Update date: <2021-12-30>
-- Description:	<Devuelve información sobre las rutas, piloto y unidad >
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_Route]
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
	FROM [DeliveryBackOffice].[dbo].[CatRoute] ctr
	JOIN [DeliveryBackOffice].[dbo].[Township] ts ON ts.IdTownship = ctr.IdTownship
	Where ctr.RowStatus = 1
END
