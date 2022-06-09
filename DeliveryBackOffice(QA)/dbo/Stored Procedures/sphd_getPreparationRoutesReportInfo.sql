
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-12-28>
-- Description: <Obtiene la información para el reporte de preparación
-- de rutas, se manda como parametro la fecha, día y el id de la ruta>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_getPreparationRoutesReportInfo]
	@dateRoute DATE,
	@IdRoute SMALLINT
AS
BEGIN

	SELECT smt.[Order] [OrderSequence],
			spu.SenderName [Name],
			vpc.Department,
			vpc.Town,
			vpc.Address,
			CONVERT(VARCHAR(5), spu.StartDate, 108) InitializationTimeOfVisit,
			CONVERT(VARCHAR(5), spu.EndDate, 108) FinalizationTimeOfVisit
	FROM [DeliveryBackOffice].[dbo].[SchedulePickup] spu WITH (NOLOCK)
		JOIN [DeliveryBackOffice].[dbo].[ServiceManagement] smt  WITH (NOLOCK)
			ON spu.SchedulePickupId = smt.IdSchedulePickup
		JOIN [DeliveryBackOffice].[dbo].[RouteAssigment] rat  WITH (NOLOCK)
			ON smt.IdPuRouteAssigment = rat.IdRouteAssigment		
		JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc  WITH (NOLOCK)
			ON spu.SenderId = vpc.CodeOfReference
	WHERE rat.IdRoute = @idRoute
			AND rat.DateOfRoute = @dateRoute
			AND spu.AssigmentStatus = '1'
	ORDER BY smt.[Order] ASC

END