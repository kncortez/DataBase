
CREATE PROCEDURE [dbo].[GetRoutes]
@RouteChar AS NVARCHAR 
AS
BEGIN

	SELECT IdRoute IdRoute, CodeRoute  FROM CatRoute
	WHERE LEFT(UPPER(CodeRoute),1) = @RouteChar 

END


