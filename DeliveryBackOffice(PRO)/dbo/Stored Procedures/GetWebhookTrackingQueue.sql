
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-09-13>
-- Description:	< Obtener listado de datos pendientes por enviar de webhooks >
-- =============================================
CREATE PROCEDURE [dbo].[GetWebhookTrackingQueue] 
AS
BEGIN

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

END