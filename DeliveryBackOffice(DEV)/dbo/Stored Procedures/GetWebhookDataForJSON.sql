
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-09-13>
-- Description:	< Obtener datos de guía para  >
-- =============================================
CREATE PROCEDURE [dbo].[GetWebhookDataForJSON] 
	@WebhookTrackingQueueId BIGINT
	,@WebhookTypeId INT
	,@WebhookTypeName NVARCHAR(50)
AS 
BEGIN 

	
	--========================================================================================================
	--===                                       STATUS CHANGE                                              ===
	--========================================================================================================
	IF (@WebhookTypeName = 'GuideStatusChange' COLLATE Latin1_General_CI_AI) 
	BEGIN
		BEGIN TRY

			DECLARE @GuideStatusResponseTable AS TABLE (
				GuideSerie NVARCHAR(2),
				GuideNumber INT,
				GuideStatus NVARCHAR(200),
				GuideStatusChange DATETIME
			);
			INSERT INTO @GuideStatusResponseTable
				(GuideSerie, GuideNumber, GuideStatus, GuideStatusChange)
			SELECT
				WTQ.GuideSerie
				,WTQ.GuideNumber
				,ISNULL(WRBY.StatusExternalName, SO.OrderDescription) 'GuideStatus'
				,(SELECT TOP 1 DOD.DateCreated FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH(NOLOCK) WHERE DOD.Guide_Serie = WTQ.GuideSerie AND DOD.Guide_Number = WTQ.GuideNumber AND DOD.StatusOrderId = WTQ.StatusOrderId ORDER BY DOD.DateCreated DESC) 'GuideStatusChange'
			FROM
				[DeliveryBackOffice].[dbo].[WebhookTrackingQueue] WTQ WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
					ON
						WTQ.StatusOrderId = SO.StatusOrderId
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBY WITH(NOLOCK)
					ON
						WTQ.CustomerId = WRBY.CustomerId
						AND
						WTQ.StatusOrderId = WRBY.StatusOrderId
						AND
						WRBY.WebhookTypeId = @WebhookTypeId
						AND
						WRBY.RowStatus = 1
			WHERE
				WTQ.IdWebhookTrackingQueue = @WebhookTrackingQueueId

			IF( EXISTS (SELECT TOP 1 1 FROM @GuideStatusResponseTable) )
			BEGIN
		
				SELECT
					CAST(1 AS BIT) [blnResult],
					'Exito obteniendo datos de webhook' [resultMessage]

				SELECT
					GSRT.GuideSerie
					,GSRT.GuideNumber
					,GSRT.GuideStatus
					,GSRT.GuideStatusChange
				FROM
					@GuideStatusResponseTable GSRT

			END
			ELSE
			BEGIN

				SELECT
					CAST(0 AS BIT) [blnResult],
					'Error obteniendo datos de webhook' [resultMessage]

			END

		END TRY
		BEGIN CATCH

			SELECT
				CAST(0 AS BIT) [blnResult],
				ERROR_MESSAGE() [resultMessage],
				@WebhookTypeName [webhookName]

		END CATCH
	END
	--========================================================================================================
	--===                                      NO WEBHOOK FOUND                                            ===
	--========================================================================================================
	ELSE
	BEGIN

		SELECT
			CAST(0 AS BIT) [blnResult],
			'Tipo de webhook inexistente, por favor, verifique su información' [resultMessage],
			@WebhookTypeName [webhookName]

	END

END