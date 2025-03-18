
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Update date: <07-10-2024>
-- Description: < Setear/Obtener el valor de la ruta en Dispatch Tracker asociada a la ruta en Hermes para recolecciones>
-- =============================================
CREATE PROCEDURE [dbo].[GetRouteDispatchTrack]
(
  @idServiceManagement AS INT,
  @option AS INT,
  @IdRouteDispatchTrack AS INT
)
AS
BEGIN
  DECLARE @IdPuRouteAssigment INT

   -- Configurar no. de ruta generado
   IF @option  = 1 
   BEGIN
        SELECT @IdPuRouteAssigment = IdPuRouteAssigment
          FROM ServiceManagement WITH(NOLOCK) 
         WHERE IdServiceManagement = @idServiceManagement

         UPDATE [RouteAssigment]
            SET IdRouteDispatchTrack = @IdRouteDispatchTrack
          WHERE IdRouteAssigment = @IdPuRouteAssigment

        SELECT IdRouteDispatchTrack
          FROM [RouteAssigment] WITH(NOLOCK)
         WHERE idrouteAssigment = @IdPuRouteAssigment
   END
   ELSE IF @option  = 2
   BEGIN
        -- Obtener un servicio ya creado
        SELECT @IdPuRouteAssigment = IdPuRouteAssigment
          FROM ServiceManagement WITH(NOLOCK)
         WHERE IdServiceManagement = @idServiceManagement

        SELECT ISNULL(IdRouteDispatchTrack,0)
          FROM [RouteAssigment] WITH(NOLOCK)
         WHERE idrouteAssigment = @IdPuRouteAssigment
   END
END;