
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-12-22>
-- Description: <Obtiene las rutas por tipo, si se envia ALL se retornan todas>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_getRoutesByType]
	@TypeRouteName VARCHAR(100)
	@Country NVARCHAR(5) = 'GT'
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
		LEFT JOIN TownShip T ON ctr.IdTownship = T.IdTownship
		LEFT JOIN Province P ON T.IdProvince=P.IdProvince
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
		LEFT JOIN TownShip T ON ctr.IdTownship = T.IdTownship
		LEFT JOIN Province P ON T.IdProvince=P.IdProvince
		WHERE ctr.RowStatus = 1
		AND ctr1.Name = @TypeRouteName AND P.IdCountry = @Country
		ORDER BY ctr.CodeRoute
	END
END
