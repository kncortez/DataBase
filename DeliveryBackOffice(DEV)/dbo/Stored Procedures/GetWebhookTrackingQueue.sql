
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

    SELECT ROW_NUMBER() OVER(ORDER BY F.[CustomerId] DESC) AS Id,
			F.[CustomerId], 
			F.[Hostname], 
			F.[UserName], 
			F.[Password], 
			F.[Port]
	FROM
	(
		SELECT 
			[WE].[CustomerId], [WE].[Hostname], [WE].[UserName], [WE].[Password], [WE].[Port]
		FROM
			[DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailForSFTP] WTQDFS WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK)
				ON
					WTQDFS.[CustomerId] = WE.[CustomerId]
		WHERE 
			COALESCE(WTQDFS.[WebhookTrackingQueueForSFTPId],0) = 0
		UNION ALL
		SELECT 
			[WE].[CustomerId], [WE].[Hostname], [WE].[UserName], [WE].[Password], [WE].[Port]
		FROM
			[DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailPendingForSFTP] WTQDPFS WITH(NOLOCK)
			LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailForSFTP] WTQDFS WITH(NOLOCK)
				ON WTQDPFS.WebhookTrackingQueueForSFTPId = WTQDFS.IdWebhookTrackingQueueDetailForSFTP
			LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookTrackingQueueForSFTP] WTQFS WITH(NOLOCK)
				ON WTQFS.IdWebhookTrackingQueueForSFTP = WTQDPFS.WebhookTrackingQueueForSFTPId
			INNER JOIN [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK)
				ON WTQDFS.[CustomerId] = WE.[CustomerId] 
		WHERE 
			WTQFS.HasNotified = 0
			AND WTQDPFS.RowStatus = 1
			AND WTQDFS.RowStatus = 1
			AND WTQFS.RowStatus = 1
	)AS F

END