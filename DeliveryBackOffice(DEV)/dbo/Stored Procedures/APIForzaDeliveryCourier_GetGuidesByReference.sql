/* =================================================
   SP:        APIForzaDeliveryCourier_GetGuidesByReference
   Propósito: Obtiene GuideSerie y GuideNumber de DeliveryOrder por referencia (Ticket_Number).
   Autor:     Caleb Loarca
   Historia:  <FDAPI-5701>
   Fecha:     2026-04-29
*/
/* === CHANGELOG ============================
2026-04-29 | Historia/épica: FDAPI-5701 | Autor: Caleb Loarca | Recuperar guias por referencia (Ticket_Number) para Verificación de workflow según su estado.

=========================================== */

CREATE PROCEDURE [dbo].[APIForzaDeliveryCourier_GetGuidesByReference]
	@Reference NVARCHAR(100)

AS
BEGIN
	SELECT DO.Guide_Serie AS GuideSerie
		  ,DO.Guide_Number AS GuideNumber
	  FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
	 WHERE DO.Ticket_Number = @Reference
END
