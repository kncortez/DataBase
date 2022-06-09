
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-12-28>
-- Description: <Valida si existe una ruta asignada para una fecha en específico>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_ExistRouteAssigment]
	@idRoute AS INT,
	@dateRoute AS DATE
AS	
BEGIN
	IF EXISTS (SELECT
				IdRouteAssigment
			FROM [DeliveryBackOffice].[dbo].[RouteAssigment]
			WHERE IdRoute = @idRoute
			AND DateOfRoute = @dateRoute)
	BEGIN
		SELECT
			1 AS result;
	END
	ELSE
	BEGIN
		SELECT
			0 AS result;
	END
END
