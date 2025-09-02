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

    IF (@WebhookTypeName = 'GuideStatusChange')
    BEGIN
        BEGIN TRY
            SELECT TOP 1
                   @StatusId = WTQ.StatusOrderId,
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
                       'Error obteniendo datos de webhook/ La notificación ya fue realizada' AS resultMessage
                RETURN;
            END;

            -- Reemplazo de token {tracking_code}
            SET @URL = REPLACE(@URL, '{tracking_code}', @TicketNumber);
			
            SELECT CAST(1 AS BIT) AS blnResult,
                   'Datos de Webhook - Cliente Aeropost' AS resultMessage,
                   @URL AS EndpointUrl

			DECLARE @AttempNumber INT;
			DECLARE @TypeIncidenceId INT;
			DECLARE @StatusIncidenceId INT = (SELECT StatusOrderId FROM [DeliveryBackOffice].[dbo].[StatusOrder] WITH (NOLOCK) WHERE OrderDescription = 'Incidencia Validada')
			DECLARE @StatusInRouteId INT = (SELECT StatusOrderId FROM [DeliveryBackOffice].[dbo].[StatusOrder] WITH (NOLOCK) WHERE OrderDescription = 'En ruta')

			SELECT 
				@AttempNumber = CASE 
									WHEN att.AttemptCount = 1 THEN 1
									WHEN att.AttemptCount = 2 THEN 2
									ELSE 2
								END,
				@TypeIncidenceId =ISNULL(att.IdIncidenceType, 0)
			FROM dbo.WebhookTrackingQueue wtq WITH (NOLOCK)
			OUTER APPLY 
			(
				SELECT 
					COUNT(DISTINCT d.ID) AS AttemptCount,
					MAX(cti.IdIncidenceType) AS IdIncidenceType
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] dod WITH (NOLOCK)
				INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt] d WITH (NOLOCK)
					ON d.ID = dod.DeliveryAttemptId
				INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] cof WITH (NOLOCK)
					ON cof.IdConfirmationOfIncidence = d.ConfirmationOfIncidenceId
				LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence] cti WITH (NOLOCK)
					ON d.ID_Incident = cti.IdIncidenceType
				WHERE cof.IsConfirmed = 1
					AND wtq.GuideSerie = dod.Guide_Serie
					AND wtq.GuideNumber = dod.Guide_Number
					AND dod.DeliveryAttemptId IS NOT NULL
					AND dod.StatusOrderId = @StatusIncidenceId
			) att
			WHERE wtq.IdWebhookTrackingQueue = @WebhookTrackingQueueId
				AND wtq.HasNotified = 0
			ORDER BY wtq.GuideSerie, wtq.GuideNumber;

			DECLARE @NewCode INT = 0;

			IF (@StatusId = @StatusIncidenceId AND @TypeIncidenceId > 0)
			BEGIN
				SELECT @NewCode = COALESCE(NewCode, 0)
				FROM [DeliveryBackOffice].[dbo].[IncidenceStatusMapping] WITH (NOLOCK)
				WHERE AttemptNumber = @AttempNumber
				  AND IncidenceTypeId = @TypeIncidenceId
				  AND StatusOrderId = @StatusId;
    
				IF (@@ROWCOUNT = 0)
					SET @NewCode = 0;
			END
			ELSE IF (@StatusId = @StatusInRouteId AND @AttempNumber = 1)
			BEGIN
				SELECT @NewCode = COALESCE(NewCode, 0)
				FROM [DeliveryBackOffice].[dbo].[IncidenceStatusMapping] WITH (NOLOCK)
				WHERE AttemptNumber = @AttempNumber
				  AND StatusOrderId = @StatusId;
    
				IF (@@ROWCOUNT = 0)
					SET @NewCode = 0;
			END
			ELSE
			BEGIN
				SELECT @NewCode = COALESCE(NewCode, 0)
				FROM [DeliveryBackOffice].[dbo].[IncidenceStatusMapping] WITH (NOLOCK)
				WHERE AttemptNumber = @AttempNumber
				  AND StatusOrderId = @StatusId;
    
				IF (@@ROWCOUNT = 0)
					SET @NewCode = 0;
			END

			SELECT @NewCode AS [new_code];

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

        SELECT CAST(0 AS BIT) AS blnResult,
               'Tipo de webhook inexistente, por favor, verifique su información' AS resultMessage
    END;
END;
