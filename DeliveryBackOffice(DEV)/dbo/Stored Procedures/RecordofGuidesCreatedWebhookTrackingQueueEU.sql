-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2025-06-27>
-- Description:	<Description,Registrar guías creadas,entregadas y anuladas por cliente Ultraentregas para encolar notificaciones Webhook>
-- =============================================
CREATE PROCEDURE [dbo].[RecordofGuidesCreatedWebhookTrackingQueueEU] 
@GuideSerie NVARCHAR(2)='FD',
@GuideNumber INT,
@Type NVARCHAR (25)
AS
BEGIN

    SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY

    DECLARE @CustomerId INT;
	DECLARE @IdWebhookType INT;
	DECLARE @IdWebhookEndpoint INT;
     
   
  
    DECLARE @StatusOrder INT = CASE
								  WHEN @Type ='CreatedGuides' THEN 15
								  WHEN @Type ='VoidedGuides' THEN 7
							      ELSE 5 
							    END;
	  SELECT 
			 Top 1 @CustomerId=IdCustomer
	   From dbo.DeliveryOrder WITH(NOLOCK) 
	   WHERE Guide_Serie = @GuideSerie AND 
		                                Guide_Number=@GuideNumber;
	
	   SELECT 
	        @IdWebhookType = IdWebhookType 
	   FROM dbo.WebhookType WITH(NOLOCK)
	   WHERE WebhookName = @Type;  
	   
	   SELECT 
	        @IdWebhookEndpoint=IdWebhookEndpoint 
	   FROM WebhookEndpoint WITH(NOLOCK) 
	   WHERE WebhookTypeId = @IdWebhookType AND 
									   CustomerId = @CustomerId;

	 

	
        IF ( EXISTS
            (
                SELECT  1 
					  FROM   [dbo].[Customer] CU WITH (NOLOCK)
					WHERE CU.CustomerUEId IS NOT NULL
						AND CU.IdCustomer = @CustomerId
            )
			 )
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

						    SELECT 1 as 'Code' , 'Registro exitoso' as 'Result'
			END 
			   ELSE
			       BEGIN
				         
						 SELECT 0 as 'Code' , 'Registro fallido' as 'Result'

				      	 

				   END

		COMMIT TRANSACTION;

		
	END TRY
	BEGIN CATCH
	 
	 ROLLBACK TRANSACTION;
	 	SELECT 0 as 'Code' , 'Registro fallido' as 'Result'
	 DECLARE  @DataReceived NVARCHAR(500) = ERROR_MESSAGE() +' '+ ERROR_LINE();
	 DECLARE  @DataSend   NVARCHAR(255) = @Type +' '+@GuideSerie + CAST(@GuideNumber AS NVARCHAR(50));

	 EXEC [dbo].[SetIntegrationForzaUELog]
		@GuideSerie = @GuideSerie,
		@GuideNumber = @GuideNumber,
		@Description = @DataReceived,
		@System = N'WebhookService',
		@Token = N'SYS-HERMESWEBHOOKS'

	

    END CATCH
	  
END