
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-11>
-- Description:	<Devuelve información sobre las rutas>
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
