/* =================================================
   SP:        SPHDGetInvalidStatusArrivalAtFacilities
   Propósito: Obtiene los estados que no deben permitir el modulo de arribo a instalaciones
   Autor:     Brandon Pedroza
   Historia:  FDAPI-5348
   Fecha:     2026-01-08

=== CHANGELOG ============================

=========================================== */

CREATE PROCEDURE [dbo].[SPHDGetInvalidStatusArrivalAtFacilities]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT StatusOrderId
    FROM DeliveryBackOffice.dbo.StatusOrder WITH(NOLOCK)
    WHERE CatCheckpointTypeId = 3
      AND RowStatus = 1

    UNION

    SELECT 4 AS StatusOrderId; -- EN RUTA
END
GO