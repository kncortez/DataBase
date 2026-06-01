-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-09-13>
-- Description:	< Obtener listado de datos pendientes por enviar de webhooks >
-- =============================================
-- Author:		<Tito Garcia>
-- Updated date: <2025-06-29>
-- Description:	< Se agrega la consulta para obtener el listado de notificaciones pendientes para Ultra Entregas >
-- =============================================
-- Author:		<Tito Garcia>
-- Updated date: <2025-08-18>
-- Description:	<Se agrega WTQ.CustomerId en consulta para manejar el cliente de la notificación>
-- =============================================
CREATE PROCEDURE [dbo].[GetWebhookTrackingQueueByCpx_BNHL] 
AS
BEGIN

	/***************************************************************************
	************************** GUIAS PENDIENTES API ****************************
	****************************************************************************/
SELECT
		WTQ.IdWebhookTrackingQueue
		,WT.WebhookName
		,WT.IdWebhookType
		,WTQ.GuideSerie
		,WTQ.GuideNumber
		,WE.WebhookEndpointURI
		,WTQ.CustomerId
	FROM [DeliveryBackOffice].[dbo].[WebhookTrackingQueue] WTQ WITH(NOLOCK)
		INNER JOIN [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK)
			ON WTQ.WebhookEndpointId = WE.IdWebhookEndpoint
		INNER JOIN [DeliveryBackOffice].[dbo].[WebhookType] WT WITH(NOLOCK)
			ON WE.WebhookTypeId = WT.IdWebhookType
	WHERE WTQ.HasNotified = 0
		AND	WTQ.RowStatus = 1
		AND WT.IdWebhookType  = 1
		AND WTQ.CustomerId IN (1106,100020)
		AND WTQ.DateCreated > '2025-12-15 16:00:00'
	ORDER BY wtq.DateCreated ASC


END