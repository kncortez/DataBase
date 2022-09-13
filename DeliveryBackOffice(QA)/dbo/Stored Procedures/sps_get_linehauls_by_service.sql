
-- =============================================
-- Author:		<Andres,Ruiz>
-- Update date: <2022-07-26>
-- Description:	< Mejora de rendimiento del SP, realizando el cast de tipo de dato de @IdRoute, adicionando WITH(NOLOCK) y removiendo subconsulta innecesaria >
-- =============================================
CREATE PROCEDURE [dbo].[sps_get_linehauls_by_service] 
	@IdRoute AS NVARCHAR(50) = 99999,
	@DateOfRoute DATE
AS
BEGIN
	DECLARE @IdRouteAsINT INT = CAST(@IdRoute AS INT)
	DECLARE @IdRouteASG INT

	SET @IdRouteASG = (
		SELECT
			ra.IdRouteAssigment
		FROM 
			DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK)
		WHERE 
			ra.IdRoute = @IdRouteAsINT
			AND 
			ra.DateOfRoute = @DateOfRoute
	)


	SELECT 
		sm.IdServiceManagement,
		COUNT(1) 'contador'
	FROM 
		DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
	WHERE 
		sm.IdPuRouteAssigment = @IdRouteASG 
	GROUP BY
		sm.IdServiceManagement
				
END
