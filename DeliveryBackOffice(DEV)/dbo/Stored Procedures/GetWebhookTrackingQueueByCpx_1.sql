/* =================================================
   SP:        GetWebhookTrackingQueueByCpx_1
   Propósito: Obtener listado de datos pendientes por enviar de webhooks
   Autor:     Andres Ruiz
   Historia:  ---
   Fecha:     2022-09-13

=== CHANGELOG ============================

2025-06-29 | Historia/épica: ---          | Autor: Tito Garcia       | Se agrega la consulta para obtener el listado de notificaciones pendientes para Ultra Entregas
2025-08-18 | Historia/épica: ---          | Autor: Tito Garcia       | Se agrega WTQ.CustomerId en la consulta
2026-01-19 | Historia/épica: FDAPI-5378   | Autor: Brandon Pedroza   | Se obtienen registros para notificar revesion de entrega

=========================================== */
CREATE PROCEDURE [dbo].[GetWebhookTrackingQueueByCpx_1]
AS
BEGIN

	--/***************************************************************************
	--************************** GUIAS PENDIENTES API ****************************
	--****************************************************************************/
DECLARE @TypeWebhookReversal INT = (SELECT IdWebhookType FROM [WebhookType] WITH(NOLOCK) WHERE WebhookName ='ReversalDeliveredGuides')
SELECT 
    X.IdWebhookTrackingQueue,
    X.WebhookName,
    X.IdWebhookType,
    X.GuideSerie,
    X.GuideNumber,
    X.WebhookEndpointURI,
    X.CustomerId,
    X.DateCreated
FROM (
    SELECT
        WTQ.IdWebhookTrackingQueue,
        WT.WebhookName,
        WT.IdWebhookType,
        WTQ.GuideSerie,
        WTQ.GuideNumber,
        WE.WebhookEndpointURI,
        WTQ.CustomerId,
        WTQ.DateCreated,
        (WTQ.IdWebhookTrackingQueue % 5) AS PartitionId
    FROM WebhookTrackingQueue WTQ WITH(NOLOCK)
    INNER JOIN WebhookEndpoint WE WITH(NOLOCK)
        ON WTQ.WebhookEndpointId = WE.IdWebhookEndpoint
    INNER JOIN WebhookType WT WITH(NOLOCK)
        ON WE.WebhookTypeId = WT.IdWebhookType
    WHERE WTQ.HasNotified = 0
      AND WTQ.RowStatus = 1
      AND WT.IdWebhookType IN (1, @TypeWebhookReversal)
      AND WTQ.CustomerId IN (1106,100020)
) X
WHERE X.PartitionId = 1
ORDER BY X.DateCreated ASC;
END;