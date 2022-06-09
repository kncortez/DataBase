CREATE PROC [dbo].[remove_WebhookEndpoint]
	@IdCustomer int,
    @URI nvarchar(max),
    @IdEcommerce int,
    @WebhookTypeId int
AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRAN

    UPDATE dbo.WebhookEndpoint
		 SET   RowStatus = 1
		  WHERE  IdCustomer = @IdCustomer AND IdEcommerce = @IdEcommerce AND URI = @URI AND WebhookTypeId = @WebhookTypeId

    COMMIT
