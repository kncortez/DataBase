/* =================================================
   SP:        [dbo].[APIForzaDeliveryCourier_SetValidCheckpointToHub]
   Propósito: Se hace validación por Hub para validar si la estación está habilitada para validar estados predecesores antes de procesar la operación.
   Autor:     Caleb Loarca
   Historia:  <FDAPI-6232>
   Fecha:     2026-05-05

=== CHANGELOG ============================
2026-??-?? | Historia/épica: FDAPI-????  | Autor: ???? | ????????
=========================================== */

CREATE PROCEDURE [dbo].[APIForzaDeliveryCourier_SetValidCheckpointToHub]

 @IdStation INT 

AS

BEGIN
	SELECT isStatusCheckEnabled FROM DeliveryBackOffice.dbo.catstation WITH(NOLOCK)
	WHERE IdStation = @IdStation
END