-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <19/08/2025>
-- Description:	<Se crea SP para obtener la información que se enviará en las notificaciones webhook al cliente Areopost>
-- =============================================
CREATE PROCEDURE [dbo].[GetWebhookDataForJSONAeropost]
    @WebhookTrackingQueueId BIGINT,
    @WebhookTypeId INT,
    @WebhookTypeName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StatusId INT,
            @URL NVARCHAR(500),
            @TicketNumber NVARCHAR(50);

    --========================================================================================================
    --===                                       STATUS CHANGE                                              ===
    --========================================================================================================
    IF (@WebhookTypeName = 'GuideStatusChange')
    BEGIN
        BEGIN TRY
            SELECT TOP 1
                   @StatusId = SO.StatusOrderId,
                   @URL = WE.WebhookEndpointURI,
                   @TicketNumber = DO.Ticket_Number
            FROM [DeliveryBackOffice].[dbo].[WebhookTrackingQueue] WTQ WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH (NOLOCK)
                    ON WTQ.StatusOrderId = SO.StatusOrderId
                INNER JOIN [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH (NOLOCK)
                    ON WTQ.WebhookEndpointId = WE.IdWebhookEndpoint
                INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                    ON DO.Guide_Serie = WTQ.GuideSerie
                   AND DO.Guide_Number = WTQ.GuideNumber
                LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBY WITH (NOLOCK)
                    ON WTQ.CustomerId = WRBY.CustomerId
                   AND WTQ.StatusOrderId = WRBY.StatusOrderId
                   AND WRBY.WebhookTypeId = @WebhookTypeId
            WHERE WTQ.IdWebhookTrackingQueue = @WebhookTrackingQueueId
              AND WTQ.HasNotified = 0
              AND WRBY.RowStatus = 1;

            -- Validar existencia
            IF (@StatusId IS NULL)
            BEGIN
                SELECT CAST(0 AS BIT) AS blnResult,
                       'Error obteniendo datos de webhook' AS resultMessage
                RETURN;
            END;

            -- Reemplazo de token {tracking_code}
            SET @URL = REPLACE(@URL, '{tracking_code}', @TicketNumber);
			
            SELECT CAST(1 AS BIT) AS blnResult,
                   'Datos de Webhook - Cliente Aeropost' AS resultMessage,
                   @URL AS EndpointUrl

			
			IF (@StatusId = 50)  -- Incidencias validadas StatusOrderId = 50
			BEGIN
			-- Se verifica número de intento (primero o segundo)
				;WITH Attempts AS
				(
					SELECT
						wtq.GuideNumber,
						itc.IdIncidenceType,
						ROW_NUMBER() OVER (
							PARTITION BY wtq.GuideSerie, wtq.GuideNumber
							ORDER BY da.Date_Created ASC
						) AS rn,
						COUNT(*) OVER (
							PARTITION BY wtq.GuideSerie, wtq.GuideNumber
						) AS total_attempts
					FROM [DeliveryBackOffice].[dbo].[WebhookTrackingQueue] wtq WITH (NOLOCK)
					INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] dod WITH (NOLOCK)
						ON wtq.GuideSerie = dod.Guide_Serie
					   AND wtq.GuideNumber = dod.Guide_Number
					INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt] da WITH (NOLOCK)
						ON da.ID = dod.DeliveryAttemptId
					INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] coi WITH (NOLOCK)
						ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
					INNER JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence] itc WITH (NOLOCK)
						ON da.ID_Incident = itc.IdIncidenceType
					WHERE coi.IsConfirmed = 1
                        AND dod.StatusOrderId = @StatusId
					    AND wtq.IdWebhookTrackingQueue = @WebhookTrackingQueueId
				)
				SELECT 
					m.NewCode
				FROM Attempts a
				INNER JOIN [DeliveryBackOffice].[dbo].[IncidenceStatusMapping] m
					ON m.StatusOrderId = @StatusId
				   AND m.IncidenceTypeId = a.IdIncidenceType
				   AND m.AttemptNumber = a.total_attempts
				WHERE a.rn = a.total_attempts
				ORDER BY a.GuideNumber;
			END
			ELSE
			BEGIN
				SELECT ISM.NewCode
				FROM [DeliveryBackOffice].[dbo].[IncidenceStatusMapping] ISM
				WHERE ISM.StatusOrderId = @StatusId
				  AND ISM.IncidenceTypeId IS NULL
				  AND ISM.AttemptNumber IS NULL;
			END

        END TRY
        BEGIN CATCH
            SELECT CAST(0 AS BIT) AS blnResult,
                   ERROR_MESSAGE() AS resultMessage,
                   ERROR_NUMBER() AS ErrorNumber,
                   ERROR_LINE() AS ErrorLine
        END CATCH;
    END
    ELSE
    BEGIN
        --========================================================================================================
        --===                                      NO WEBHOOK FOUND                                            ===
        --========================================================================================================
        SELECT CAST(0 AS BIT) AS blnResult,
               'Tipo de webhook inexistente, por favor, verifique su información' AS resultMessage
    END;
END;

