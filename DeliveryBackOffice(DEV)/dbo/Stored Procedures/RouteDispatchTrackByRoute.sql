
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Update date: <2024-10-21>
-- Description: < Setear/Obtener el valor de la ruta en Dispatch Tracker asociada a la ruta en Hermes para recolecciones>
-- =============================================
CREATE PROCEDURE [dbo].[RouteDispatchTrackByRoute]
(
  @IdRoute INT,
  @DateOfRoute DATE,
  @Option AS INT,
  @IdRouteDispatchTrack AS INT
)
AS
BEGIN
   -- Configurar no. de ruta generado
   IF @option  = 1 
   BEGIN
         IF (@IdRouteDispatchTrack = -1)
         BEGIN 
             SET @IdRouteDispatchTrack = NULL
         END

         UPDATE [RouteAssigment]
            SET IdRouteDispatchTrack = @IdRouteDispatchTrack
          WHERE IdRoute = @IdRoute
            AND DateOfRoute = @DateOfRoute

        SELECT ISNULL(IdRouteDispatchTrack,0)
          FROM [RouteAssigment]
         WHERE IdRoute = @IdRoute
           AND DateOfRoute = @DateOfRoute
   END
   ELSE IF @option  = 2
   BEGIN
        -- Obtener un servicio ya creado
        SELECT ISNULL(IdRouteDispatchTrack,0)
          FROM [RouteAssigment]
         WHERE IdRoute = @IdRoute
           AND DateOfRoute = @DateOfRoute
   END
END;