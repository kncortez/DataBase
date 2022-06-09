
CREATE PROCEDURE [dbo].[GetWebhookJSON] 
     @WebhookTrackingQueueId    AS BIGINT
	,@Guide_Serie			    AS VARCHAR(5)
	,@Guide_Number			    AS BIGINT
	,@IdCustomer				AS INT
	,@Status					AS INT
	,@WebhookEndpointId		    AS BIGINT

AS 
BEGIN 
 DECLARE @jsonResult			NVARCHAR(MAX) 
 DECLARE @WebhookTypeId			INT
 DECLARE @fullname				VARCHAR(350)   
 DECLARE @OriginAdress			NVARCHAR(1000) 
 DECLARE @DestinyAddress		NVARCHAR(1000)                
 DECLARE @receiver				NVARCHAR(350)	 
 DECLARE @Place					NVARCHAR(1000) 
 DECLARE @ManifestNumber		VARCHAR(200)	 
 DECLARE @Latitude				VARCHAR(40)	 
 DECLARE @Longitude				VARCHAR(40)	 
 DECLARE @EstimatedDeliveryDate VARCHAR(100)
 DECLARE @WebhookTypeName       VARCHAR(100)
 
 SELECT @WebhookTypeId = WebhookTypeId 
 FROM [dbo].[WebhookEndpoint] WHERE WebhookEndpointId = @WebhookEndpointId

 SELECT 
 @WebhookTypeName = [Name]
 FROM [dbo].[WebhookType] WHERE WebhookTypeId = @WebhookTypeId

 IF (@WebhookTypeId = 1)
BEGIN
  BEGIN TRY
--========================================================================================================
--===                                        TRACKING                                                  ===
--========================================================================================================

SELECT 
			ROW_NUMBER() OVER (ORDER BY dod.DateCreated ASC)  AS EventID,
			Cast(dod.StatusOrderId as nvarchar) as [StageId], -- status order id
			dod.DateCreated as [Date], -- date of status id
			'web' as [Source],
			so.OrderDescription as [Title], -- status order name			
			(CASE 
				WHEN dod.StatusOrderId IN (6,8) THEN ISNULL(dod.Observations,'') 
				WHEN dod.StatusOrderId IN (12) THEN ISNULL((
															SELECT TOP 1 
																ISNULL(I.[Description] ,'')
															FROM DeliveryBackOffice.dbo.Incident I with(nolock) 
															JOIN DeliveryBackOffice.dbo.DeliveryAttempt da with(nolock) ON da.ID_Incident = I.ID
															WHERE dod.Guide_Serie = da.Guide_Serie AND dod.Guide_Number = da.Guide_Number
															ORDER BY da.Date_Created DESC)
														,'')
			ELSE ''
			END) as [Description],
			CASE WHEN (ROW_NUMBER() OVER (ORDER BY dod.DateCreated ASC)) = 1 THEN
			'[
						{
							"description": "",
							"image": ""
						}
					]' 
			WHEN (ROW_NUMBER() OVER (ORDER BY dod.DateCreated ASC)) <> 1 THEN 
			'null' 
			END AS attachments,
			'null' AS 'action'
			INTO  #Milestones
		FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod with(nolock) 
		   JOIN DeliveryBackOffice.dbo.StatusOrder so with(nolock) on so.StatusOrderId = dod.StatusOrderId
		WHERE dod.Guide_Serie = @Guide_Serie and dod.Guide_Number = @Guide_Number AND dod.StatusOrderId = @Status --SE AGREGA FILTRO POR STATUSORDERID para solo enviar el último cambio de estado de una guía
	 
	 DECLARE @JSONMilestones as NVARCHAR(MAX)
	 Select @JSONMilestones=(replace(replace(replace([dbo].[toJSON](0,1,(Select * From #Milestones for XML RAW)),'"[','['),']"',']'),'"null"','null'))

		SELECT
			@fullname       = ISNULL(do.Receiver_FirstName + ' ' + do.Receiver_LastName,''), 
			@OriginAdress   = do.Sender_Address, 	
			@DestinyAddress = do.Receiver_Address,
			@EstimatedDeliveryDate = CONVERT(varchar,do.Delivery_Max_Date ,120), 
			@receiver		= ISNULL([NameOfReceiver],'') ,
			@Place			= ISNULL(Sender_FirstName + ' ' + Sender_LastName, '') ,
			@ManifestNumber = do.Manifest_Serie + CAST(ISNULL(do.Manifest_Number,'') AS VARCHAR) ,
			@Latitude		= da.Latitude,
			@Longitude		= da.Longitude
		FROM DeliveryBackOffice.dbo.DeliveryOrder do with(nolock)
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryAttempt da with(nolock) on da.Guide_Serie = do.Guide_Serie and da.Guide_Number = do.Guide_Number
		WHERE do.Guide_Serie = @Guide_Serie AND do.Guide_Number = @Guide_Number

SET @jsonResult = N'{
"PayLoad":{ 
"WebhookType": "'+   ISNULL(@WebhookTypeName,'')  +'",
"StatusCode": 200,
"Description":"Success",
	"TrackOrder": {
		"GuideSerie":  "'+ ISNULL(CAST(@Guide_Serie  AS VARCHAR),'')  + '",
		"GuideNumber": '+ ISNULL(CAST(@Guide_Number AS VARCHAR),'') + ',
		"ManifestNumber": "'+ ISNULL(CAST(@ManifestNumber AS VARCHAR),'') + '",
		"Message": "Success",
		"Latitude": "'+ ISNULL(CAST(@Latitude AS VARCHAR),'') + '",
		"Longitude": "'+ ISNULL(CAST(@Longitude AS VARCHAR),'') + '",
		"OrderDetail": {
			"id": '+ ISNULL(CAST(@Guide_Number AS VARCHAR),'') + ',
			"customer": {
				"id": '+ ISNULL(CAST(@IdCustomer AS VARCHAR),'') + ',
				"fullname": "'+ ISNULL(CAST(@fullname AS VARCHAR),'') + '"
			},
			"origin": {
				"address":"'+ ISNULL(CAST(@OriginAdress AS VARCHAR),'') + '",
				"latitude": "",
				"longitude": "",
				"place":"'+ ISNULL(CAST(@Place AS VARCHAR),'') + '"
			},
			"destiny": {
				"address": "'+ ISNULL(CAST(@DestinyAddress AS VARCHAR),'') + '",
				"latitude": "",
				"longitude": "",
				"receiver": "'+ ISNULL(CAST(@receiver AS VARCHAR),'') +'"
			},
			"milestones":' + @JSONMilestones + '
		}
	}
  }
}';

--Se cambia el estado de HasNotified a 1 para indicar que ya fue notificado al endpoint del cliente
UPDATE [dbo].[WebhookTrackingQueue] SET HasNotified = 1 WHERE WebhookTrackingQueueId = @WebhookTrackingQueueId

 END TRY
 BEGIN CATCH
 SET @jsonResult = '';
 SET @jsonResult = N'{
"PayLoad":"{ 
"WebhookType": '+ @WebhookTypeName +',
"StatusCode": 500,
"Description":'+ ERROR_MESSAGE() +',
	"TrackOrder": null
  }
}';

 END CATCH
  SELECT  @jsonResult AS FormatJson;

   IF OBJECT_ID('tempdb.dbo.#Milestones', 'U') IS NOT NULL
   DROP TABLE #Milestones;
END

--========================================================================================================
--===                                        TRACKING                                                  ===
--========================================================================================================

END

