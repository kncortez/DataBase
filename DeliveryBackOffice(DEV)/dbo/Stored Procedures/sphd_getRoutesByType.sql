
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-12-21>
-- Description: <Obtiene las rutas por tipo, si se envia ALL retorna todas las rutas>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_getRoutesByType]
	@TypeRouteName VARCHAR(100)
AS	
BEGIN
	IF UPPER(@TypeRouteName) = 'ALL'
	BEGIN
		SELECT
			ctr.IdRoute
		   ,ctr.CodeRoute
		FROM [DeliveryBackOffice].[dbo].[CatRoute] ctr
		INNER JOIN [DeliveryBackOffice].[dbo].[CatTypeRoute] ctr1
		ON ctr.IdTypeRoute = ctr1.IdTypeRoute
		WHERE ctr.RowStatus = 1
		ORDER BY ctr.CodeRoute
	END
	ELSE
	BEGIN
		SELECT
			ctr.IdRoute
		   ,ctr.CodeRoute
		FROM [DeliveryBackOffice].[dbo].[CatRoute] ctr
		INNER JOIN [DeliveryBackOffice].[dbo].[CatTypeRoute] ctr1
		ON ctr.IdTypeRoute = ctr1.IdTypeRoute
		WHERE ctr.RowStatus = 1
		AND ctr1.Name = @TypeRouteName
		ORDER BY ctr.CodeRoute
	END
END
