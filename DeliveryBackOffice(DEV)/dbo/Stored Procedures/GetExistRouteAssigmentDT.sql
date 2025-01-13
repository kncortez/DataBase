
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-10-21>
-- Description: <Valida si existe una ruta masiva asignada para una fecha en específico>
-- =============================================

CREATE PROCEDURE [dbo].[GetExistRouteAssigmentDT]
(
 @idRoute AS INT,
 @dateRoute AS DATE
)
AS
BEGIN
    IF EXISTS (SELECT IdRouteAssigment
                 FROM [DeliveryBackOffice].[dbo].[RouteAssigment]
                WHERE IdRoute = @idRoute
                  AND DateOfRoute = @dateRoute)
    BEGIN
         SELECT ISNULL(IdRouteDispatchTrack,0) AS [IdRouteDispatchTrack]
           FROM [DeliveryBackOffice].[dbo].[RouteAssigment]
          WHERE IdRoute = @idRoute
            AND DateOfRoute = @dateRoute
    END
    ELSE
    BEGIN
         SELECT 0 AS [IdRouteDispatchTrack]
    END
END
