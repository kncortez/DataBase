-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,2023-01-04>
-- Description:	<Description, Sp para obtener cabecera dinamica de webhook>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetListofWebHookHeaders]
@IdWebhookTrackingQueue AS BIGINT
AS
BEGIN

    Declare  @IdWebhookEndpoint AS BIGINT =	(SELECT WebhookEndpointId FROM [dbo].[WebhookTrackingQueue] WITH(NOLOCK) WHERE IdWebhookTrackingQueue = @IdWebhookTrackingQueue)

	SELECT 
			whEph.IdWebhookEndpointHeader,
			whEph.WebhookEndpointId,
			whEph.WebhookHeaderName,
			whEph.WebhookHeaderValue,
			whEph.RowStatus,
			whEph.DateCreated,
			whEph.TokenCreated		
	FROM [dbo].[WebhookEndpointHeader] whEph WITH(NOLOCK)
	WHERE whEph.RowStatus = 1 AND 
	      whEph.WebhookEndpointId = @IdWebhookEndpoint

   
END