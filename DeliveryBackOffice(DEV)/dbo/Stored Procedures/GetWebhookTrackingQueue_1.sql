/* =================================================
   SP:        GetWebhookTrackingQueue
   Propósito: Obtener listado de datos pendientes por enviar de webhooks
   Autor:     Andres Ruiz
   Historia:  ---
   Fecha:     2022-09-13

=== CHANGELOG ============================

2025-06-29 | Historia/épica: ---          | Autor: Tito Garcia       | Se agrega la consulta para obtener el listado de notificaciones pendientes para Ultra Entregas
2025-08-18 | Historia/épica: ---          | Autor: Tito Garcia       | Se agrega WTQ.CustomerId en la consulta
2026-01-19 | Historia/épica: FDAPI-5378   | Autor: Brandon Pedroza   | Se obtienen registros para notificar revesion de entrega

=========================================== */
CREATE PROCEDURE [dbo].[GetWebhookTrackingQueue] 
AS
BEGIN

	/***************************************************************************
	************************** GUIAS PENDIENTES API ****************************
	****************************************************************************/
	DECLARE @TypeWebhookReversal INT = (SELECT IdWebhookType FROM [WebhookType] WITH(NOLOCK) WHERE WebhookName ='ReversalDeliveredGuides')
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
		AND WT.IdWebhookType IN (1, @TypeWebhookReversal)
		AND WTQ.CustomerId NOT IN (1106, 100020)

	/***************************************************************************
	************************** GUIAS PENDIENTES SFTP ***************************
	****************************************************************************/

	SELECT [WE].[CustomerId],
			[WE].[Hostname],
			[WE].[UserName],
			[WE].[Password],
			[WE].[Port],
			[WE].[RemoteRoute]
	FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH (NOLOCK)
	WHERE WE.TypeConnectionId = 2
	AND WE.RowStatus = 1
	AND EXISTS
	(
		SELECT 1 FROM DeliveryBackOffice.dbo.WebhookTrackingQueueDetailForSFTP A1 WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.WebhookTrackingQueueForSFTP A2 WITH(NOLOCK)
		ON A2.IdWebhookTrackingQueueForSFTP = A1.WebhookTrackingQueueForSFTPId
		
		WHERE A1.CustomerId = WE.CustomerId
		AND A1.RowStatus = 1
		AND A2.RowStatus = 1
		AND A2.HasNotified = 0

	)
	UNION
	SELECT [WE].[CustomerId],
			[WE].[Hostname],
			[WE].[UserName],
			[WE].[Password],
			[WE].[Port],
			[WE].[RemoteRoute]
	FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH (NOLOCK)
	WHERE WE.TypeConnectionId = 2
	AND WE.RowStatus = 1
	AND EXISTS
	(
		SELECT 1 FROM DeliveryBackOffice.dbo.WebhookTrackingQueueDetailForSFTP A1 WITH(NOLOCK)		
		WHERE A1.CustomerId = WE.CustomerId
		AND A1.WebhookTrackingQueueForSFTPId IS NULL
		AND A1.RowStatus = 1		
	)

	/***************************************************************************
	**************** NOTIFICACIONES PENDIENTES ULTRA ENTREGAS ******************
	****************************************************************************/

	SELECT 
		WTQ.IdWebhookTrackingQueue
		,WT.WebhookName
		,WT.IdWebhookType
		,WTQ.GuideSerie
		,WTQ.GuideNumber
		,WE.WebhookEndpointURI
	FROM [DeliveryBackOffice].[dbo].[WebhookTrackingQueue] WTQ WITH(NOLOCK)
		INNER JOIN [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK)
			ON WTQ.WebhookEndpointId = WE.IdWebhookEndpoint
		INNER JOIN [DeliveryBackOffice].[dbo].[WebhookType] WT WITH(NOLOCK)
			ON WE.WebhookTypeId = WT.IdWebhookType
	WHERE WTQ.HasNotified = 0
		AND	WTQ.RowStatus = 1
		AND WT.IdWebhookType IN (2,3,4)
	ORDER BY WTQ.NotificationDate ASC;

END