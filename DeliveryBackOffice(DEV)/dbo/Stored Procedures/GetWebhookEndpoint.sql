
CREATE PROCEDURE [dbo].[GetWebhookEndpoint]
@IdCustomer as INT
AS
BEGIN

SELECT  [URI]      
FROM [dbo].[WebhookEndpoint]
WHERE [IdCustomer] = @IdCustomer

END
