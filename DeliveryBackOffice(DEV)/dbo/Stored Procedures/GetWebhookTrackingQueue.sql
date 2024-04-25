
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-09-13>
-- Description:	< Obtener listado de datos pendientes por enviar de webhooks >
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
	FROM
		[DeliveryBackOffice].[dbo].[WebhookTrackingQueue] WTQ WITH(NOLOCK)
		INNER JOIN
			[DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK)
			ON
				WTQ.WebhookEndpointId = WE.IdWebhookEndpoint
		INNER JOIN
			[DeliveryBackOffice].[dbo].[WebhookType] WT WITH(NOLOCK)
			ON
				WE.WebhookTypeId = WT.IdWebhookType
	WHERE 
		WTQ.HasNotified = 0
		AND
		WTQ.RowStatus = 1
	ORDER BY
		WTQ.IdWebhookTrackingQueue ASC;

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
	--AND WE.CustomerId =24
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
	UNION
	SELECT [WE].[CustomerId],
			[WE].[Hostname],
			[WE].[UserName],
			[WE].[Password],
			[WE].[Port],
			[WE].[RemoteRoute]
	FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH (NOLOCK)
	WHERE WE.TypeConnectionId = 2
	--AND WE.CustomerId =24
	AND WE.RowStatus = 1
	AND EXISTS
	(
		SELECT 1 FROM DeliveryBackOffice.dbo.WebhookTrackingQueueDetailForSFTP A1 WITH(NOLOCK)		
		WHERE A1.CustomerId = WE.CustomerId
		AND A1.WebhookTrackingQueueForSFTPId IS NULL
		AND A1.RowStatus = 1		
	)

END