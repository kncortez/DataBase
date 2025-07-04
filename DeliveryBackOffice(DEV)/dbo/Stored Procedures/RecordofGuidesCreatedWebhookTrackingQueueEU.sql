-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2025-06-27>
-- Description:	<Description,Registrar guías creadas,entregadas y anuladas por cliente Ultraentregas para encolar notificaciones Webhook>
-- =============================================
CREATE PROCEDURE [dbo].[RecordofGuidesCreatedWebhookTrackingQueueEU] 
@GuideSerie VARCHAR(2)='FD',
@GuideNumber INT,
@Type NVARCHAR (25)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

    DECLARE @CustomerId INT = (Select IdCustomer From dbo.DeliveryOrder WITH(NOLOCK) 
	                                WHERE Guide_Serie = @GuideSerie AND Guide_Number=@GuideNumber);

    DECLARE @IdWebhookType INT = (SELECT IdWebhookType FROM dbo.WebhookType WITH(NOLOCK)
									  WHERE WebhookName = @Type );
   
    DECLARE @IdWebhookEndpoint INT =( SELECT IdWebhookEndpoint FROM WebhookEndpoint WITH(NOLOCK) 
									   WHERE WebhookTypeId = @IdWebhookType AND 
									   CustomerId = @CustomerId);
    DECLARE @StatusOrder INT =(
	                             SELECT CASE
								            WHEN @Type ='CreatedGuides' THEN 15
											WHEN @Type ='VoidedGuides' THEN 7
											ELSE 5 END
	
	                                   );

	DECLARE @CustomerWithUEId INT =
    (
        SELECT CASE WHEN  EXISTS
            (
                SELECT 1
					FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
					   INNER JOIN 
					     [dbo].[Customer] CU WITH (NOLOCK)
						ON DO.IdCustomer = CU.IdCustomer
					WHERE CU.CustomerUEId IS NOT NULL
						AND DO.Guide_Serie = @GuideSerie
						AND DO.Guide_Number = @GuideNumber
						AND DO.IdCustomer = @CustomerId
              ) THEN 1 ELSE 0 END
        );

			IF(@CustomerWithUEId > 0)
			BEGIN
				INSERT INTO [dbo].[WebhookTrackingQueue]
						   ([WebhookEndpointId]
						   ,[CustomerId]
						   ,[GuideSerie]
						   ,[GuideNumber]
						   ,[StatusOrderId]
						   ,[HasNotified]
						   ,[NotificationDate]
						   ,[RowStatus]
						   ,[DateCreated]
						   ,[TokenCreated]
						   ,[DateUpdated]
						   ,[TokenUpdated])
					 VALUES
						   (@IdWebhookEndpoint
						   ,@CustomerId
						   ,@GuideSerie
						   ,@GuideNumber 
						   ,@StatusOrder
						   ,0
						   ,GETDATE()
						   ,1
						   ,GETDATE()
						   ,'SYS-ULTRAENTREGAS'
						   ,NULL
						   ,NULL)
			END

		COMMIT TRANSACTION;

		SELECT 1 as 'Code' , 'Registro exitoso' as 'Result'
	END TRY
	BEGIN CATCH
	 
	 ROLLBACK TRANSACTION;
	 	SELECT 0 as 'Code' , 'Registro fallido' as 'Result'
	 DECLARE  @DataReceived NVARCHAR(500) = ERROR_MESSAGE() +' '+ ERROR_LINE();
	 DECLARE  @DataSend   NVARCHAR(255) = @Type +' '+@GuideSerie + CAST(@GuideNumber AS NVARCHAR(50));
	 EXEC [dbo].[SetWebhookLog]
				@IdWebhookEndpoint,
				@DataSend,
			    @DataReceived,
			   'SYS-HERMESWEBHOOKS'


    END CATCH
	  
END