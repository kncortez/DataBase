
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-21>
-- Description:	<Devuelve información sobre las rutas Linehauls >
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_RouteLinehauls]
AS
BEGIN
	SELECT DISTINCT
	   ctr.CodeRoute
      ,ctr.IdTypeRoute
      ,ctr.RowStatus
	  ,ctr.IdRoute
	FROM [DeliveryBackOffice].[dbo].[CatRoute] ctr WITH (NOLOCK)
	Where ctr.RowStatus = 1 AND ctr.IdTypeRoute=2
	ORDER BY  ctr.CodeRoute
END