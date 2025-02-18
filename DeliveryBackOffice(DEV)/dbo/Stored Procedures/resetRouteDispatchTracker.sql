
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Update date: <07-10-2024>
-- Description: < Setear/Obtener el valor de la ruta masiva en Dispatch Tracker asociada a la ruta en Hermes para recolecciones>
-- =============================================
CREATE PROCEDURE [dbo].[resetRouteDispatchTracker]
(
  @IdRouteDispatchTrack AS INT,
  @IdRoute              AS INT
)
AS
BEGIN
        UPDATE [RouteAssigment]
           SET IdRouteDispatchTrack = NULL
         WHERE IdRouteDispatchTrack = @IdRouteDispatchTrack
           AND IdRoute = @IdRoute

        SELECT 1 AS result;
END;