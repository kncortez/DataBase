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
CREATE PROCEDURE [dbo].[GetWebhookTrackingQueue] 
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
		AND WT.IdWebhookType IN (SELECT IdWebhookType FROM [WebhookType] WHERE WebhookName IN ('GuideStatusChange'));

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
		AND A2.RowStatus = 1
		AND A2.HasNotified = 0
		WHERE A1.CustomerId = WE.CustomerId
		AND A1.RowStatus = 1		
	)
	--AND 1=0 --TEMPORAL BNHL
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
	--AND 1=0 --TEMPORAL BNHL

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
		AND WT.IdWebhookType IN (SELECT IdWebhookType FROM [WebhookType] WHERE WebhookName IN ('CreatedGuides','VoidedGuides','DeliveredGuides'))
	ORDER BY WTQ.NotificationDate ASC;
END
