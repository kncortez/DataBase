/*

Name: GetWebhookEndpoint
Description: ser retorna el URI del endpoint que pertenece a cada cliente
CreatedDate: 03/03/2021
     Author: Marco Jiménez
	  Email: marco.jimenez@forzalatam.com

*/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetWebhookEndpoint]
@IdCustomer as INT
AS
BEGIN

SELECT  [URI]      
FROM [dbo].[WebhookEndpoint]
WHERE [IdCustomer] = @IdCustomer

END
