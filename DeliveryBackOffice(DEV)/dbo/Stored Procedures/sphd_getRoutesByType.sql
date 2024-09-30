
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-12-22>
-- Description: <Obtiene las rutas por tipo, si se envia ALL se retornan todas>
-- =============================================
-- Author:      <Cristian,Suazo>
-- Create date: <2024-06-13>
-- Description: <Se agrego filtro por pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_getRoutesByType]
	@TypeRouteName VARCHAR(100),
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
		WHERE ctr.RowStatus = 1
          AND ISNULL(ctr.CountryId, 'GT') = @Country
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
		AND ctr1.Name = @TypeRouteName AND ISNULL(ctr.CountryId, 'GT') = @Country
		ORDER BY ctr.CodeRoute
	END
END
