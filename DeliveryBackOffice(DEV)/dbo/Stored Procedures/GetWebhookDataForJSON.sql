
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-09-13>
-- Description:	< Obtener datos de guía para  >
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-10-24>
-- Description:	<Agregar flujo de respuesta de los diferentes estados de una guía>
-- =============================================
CREATE PROCEDURE [dbo].[GetWebhookDataForJSON] 
	 @WebhookTrackingQueueId BIGINT
	,@WebhookTypeId INT
	,@WebhookTypeName NVARCHAR(50)
AS 
BEGIN 



      DECLARE @StatusChange  AS NVARCHAR(200)
	  DECLARE @StatusId  AS INT
	
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

            SELECT @StatusChange = GuideStatus FROM @GuideStatusResponseTable 

            SELECT @StatusId = StatusOrderId FROM dbo.StatusOrder WITH (NOLOCK) WHERE OrderDescription = @StatusChange
			

			IF( EXISTS (SELECT TOP 1 1 FROM @GuideStatusResponseTable) )
			BEGIN
		
		   	    
		      
				SELECT
					CAST(1 AS BIT) [blnResult],
					'Exito obteniendo datos de webhook' [resultMessage]


            IF (@StatusId IN(5,22)) /* Estados de Entregado  */
				SELECT
					 GSRT.GuideSerie
					,GSRT.GuideNumber
					,GSRT.GuideStatus
					,GSRT.GuideStatusChange
					,ISNULL(DP.Path_Incident,'') AS ImageEvidence
					,ISNULL(NameOfReceiver,'')  AS ReceiverName
				FROM
					@GuideStatusResponseTable GSRT
					LEFT JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
					ON GSRT.GuideSerie= DA.Guide_Serie   AND  GSRT.GuideNumber =DA.Guide_Number
					LEFT JOIN
				    [DeliveryBackOffice].[dbo].[DeliveryProof] DP WITH(NOLOCK)
		            ON DA.ID_Proof = DP.ID
					LEFT JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
					ON GSRT.GuideSerie = DO.Guide_Serie AND GSRT.GuideNumber = DO.Guide_Number

			ELSE IF(@StatusId IN(25)) /* COD pagado  */
			       SELECT TOP 1
					 GSRT.GuideSerie
					,GSRT.GuideNumber
					,GSRT.GuideStatus
					,GSRT.GuideStatusChange
					,ISNULL(BDC.AuthorizationNumber,'') AS AuthorizationNumber
				FROM
					@GuideStatusResponseTable GSRT
					LEFT JOIN 
					[DeliveryBackOffice].[dbo].[BatchDetailCOD] BDC WITH(NOLOCK)
					ON GSRT.GuideSerie = BDC.GuideSerie AND GSRT.GuideNumber = BDC.GuideNumber
					
			ELSE IF(@StatusId IN(14,23))  /* Devuelto */
			     SELECT
					 GSRT.GuideSerie
					,GSRT.GuideNumber
					,GSRT.GuideStatus
					,GSRT.GuideStatusChange
					,ISNULL(DP.Path_Incident,'')  AS ImageEvidence
					,ISNULL(NameOfReceiver,'')  AS ReceiverName
				FROM
					@GuideStatusResponseTable GSRT
					LEFT JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
					ON GSRT.GuideSerie= DA.Guide_Serie   AND  GSRT.GuideNumber =DA.Guide_Number
					LEFT JOIN
				    [DeliveryBackOffice].[dbo].[DeliveryProof] DP WITH(NOLOCK)
		            ON DA.ID_Proof = DP.ID
					LEFT JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
					ON GSRT.GuideSerie = DO.Guide_Serie AND GSRT.GuideNumber = DO.Guide_Number

			ELSE IF(@StatusId IN(2))  /* Recolectado */
			       SELECT
					 GSRT.GuideSerie
					,GSRT.GuideNumber
					,GSRT.GuideStatus
					,GSRT.GuideStatusChange
				FROM
					@GuideStatusResponseTable GSRT

			ELSE IF(@StatusId IN(12)) /* Intento de entrega fallida */
			       SELECT
					 GSRT.GuideSerie
					,GSRT.GuideNumber
					,GSRT.GuideStatus
					,GSRT.GuideStatusChange
					,ISNULL(DA.Longitude,'') AS Longitude
					,ISNULL(DA.Latitude,'') AS Latitude
					,ISNULL(CTI.DescriptionIncidence,'') AS DescriptionIncidence
				FROM
					@GuideStatusResponseTable GSRT
					LEFT JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
					ON GSRT.GuideSerie= DA.Guide_Serie   AND  GSRT.GuideNumber = DA.Guide_Number
					LEFT JOIN
					 [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH(NOLOCK)
					ON  DA.ID_Incident = CTI.IdIncidenceType
				ELSE
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