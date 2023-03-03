
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
    @WebhookTrackingQueueId BIGINT,
    @WebhookTypeId INT,
    @WebhookTypeName NVARCHAR(50)
AS
BEGIN



    DECLARE @StatusChange AS NVARCHAR(200);
    DECLARE @StatusId AS INT;

    --========================================================================================================
    --===                                       STATUS CHANGE                                              ===
    --========================================================================================================
    IF (@WebhookTypeName = 'GuideStatusChange' COLLATE Latin1_General_CI_AI)
    BEGIN
        BEGIN TRY

            DECLARE @GuideStatusResponseTable AS TABLE
            (
                GuideSerie NVARCHAR(2),
                GuideNumber INT,
                GuideStatus NVARCHAR(200),
                GuideStatusId INT,
                GuideStatusChange DATETIME
            );
            INSERT INTO @GuideStatusResponseTable
            (
                GuideSerie,
                GuideNumber,
                GuideStatus,
                GuideStatusId,
                GuideStatusChange
            )
            SELECT WTQ.GuideSerie,
                   WTQ.GuideNumber,
                   ISNULL(WRBY.StatusExternalName, SO.OrderDescription) 'GuideStatus',
                   SO.StatusOrderId,
                   (
                       SELECT TOP 1
                              DOD.DateCreated
                       FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH (NOLOCK)
                       WHERE DOD.Guide_Serie = WTQ.GuideSerie
                             AND DOD.Guide_Number = WTQ.GuideNumber
                             AND DOD.StatusOrderId = WTQ.StatusOrderId
                       ORDER BY DOD.DateCreated DESC
                   ) 'GuideStatusChange'
            FROM [DeliveryBackOffice].[dbo].[WebhookTrackingQueue] WTQ WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH (NOLOCK)
                    ON WTQ.StatusOrderId = SO.StatusOrderId
                LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBY WITH (NOLOCK)
                    ON WTQ.CustomerId = WRBY.CustomerId
                       AND WTQ.StatusOrderId = WRBY.StatusOrderId
                       AND WRBY.WebhookTypeId = @WebhookTypeId
                       AND WRBY.RowStatus = 1
            WHERE WTQ.IdWebhookTrackingQueue = @WebhookTrackingQueueId;

            SELECT @StatusId = WTQ.StatusOrderId
            FROM [DeliveryBackOffice].[dbo].[WebhookTrackingQueue] WTQ WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH (NOLOCK)
                    ON WTQ.StatusOrderId = SO.StatusOrderId
            WHERE WTQ.IdWebhookTrackingQueue = @WebhookTrackingQueueId;

            IF (EXISTS (SELECT TOP 1 1 FROM @GuideStatusResponseTable))
            BEGIN



                SELECT CAST(1 AS BIT) [blnResult],
                       'Exito obteniendo datos de webhook 2' [resultMessage];


                IF (@StatusId IN ( 5, 22 )) /* Estados de Entregado  */
                BEGIN

                    SELECT GSRT.GuideSerie,
                           GSRT.GuideNumber,
                           GSRT.GuideStatus,
                           GSRT.GuideStatusId,
                           GSRT.GuideStatusChange,
                           ISNULL(DA.Path_Dry, '') AS ImageEvidence,
                           ISNULL(DO.NameOfReceiver, '') AS ReceiverName,
                           ISNULL(DA.Longitude, '') AS Longitude,
                           ISNULL(DA.Latitude, '') AS Latitude
                    FROM @GuideStatusResponseTable GSRT
                        OUTER APPLY
                    (
                        SELECT TOP 1
                               DA.Longitude 'Longitude',
                               DA.Latitude 'Latitude',
                               DP.Path_Dry 'Path_Dry'
                        FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
                            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryProof] DP WITH (NOLOCK)
                                ON DA.ID_Proof = DP.ID
                        WHERE GSRT.GuideSerie = DA.Guide_Serie
                              AND GSRT.GuideNumber = DA.Guide_Number
                              AND DA.Delivered = 1
                        ORDER BY DA.Date_Created DESC
                    ) DA
                        LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                            ON GSRT.GuideSerie = DO.Guide_Serie
                               AND GSRT.GuideNumber = DO.Guide_Number;

                END;
                ELSE IF (@StatusId IN ( 25 )) /* COD pagado  */
                BEGIN

                    SELECT TOP 1
                           GSRT.GuideSerie,
                           GSRT.GuideNumber,
                           GSRT.GuideStatus,
                           GSRT.GuideStatusId,
                           GSRT.GuideStatusChange,
                           ISNULL(BDC.AuthorizationNumber, '') AS AuthorizationNumber
                    FROM @GuideStatusResponseTable GSRT
                        LEFT JOIN [DeliveryBackOffice].[dbo].[BatchDetailCOD] BDC WITH (NOLOCK)
                            ON GSRT.GuideSerie = BDC.GuideSerie
                               AND GSRT.GuideNumber = BDC.GuideNumber;

                END;
                ELSE IF (@StatusId IN ( 14, 23 )) /* Devuelto */
                BEGIN

                    SELECT GSRT.GuideSerie,
                           GSRT.GuideNumber,
                           GSRT.GuideStatus,
                           GSRT.GuideStatusId,
                           GSRT.GuideStatusChange,
                           ISNULL(DA.Path_Dry, '') AS ImageEvidence,
                           ISNULL(DO.NameOfReceiver, '') AS ReceiverName,
                           ISNULL(DA.Longitude, '') AS Longitude,
                           ISNULL(DA.Latitude, '') AS Latitude
                    FROM @GuideStatusResponseTable GSRT
                        OUTER APPLY
                    (
                        SELECT TOP 1
                               DA.Longitude 'Longitude',
                               DA.Latitude 'Latitude',
                               DP.Path_Dry 'Path_Dry'
                        FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
                            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryProof] DP WITH (NOLOCK)
                                ON DA.ID_Proof = DP.ID
                        WHERE GSRT.GuideSerie = DA.Guide_Serie
                              AND GSRT.GuideNumber = DA.Guide_Number
                              AND DA.Delivered = 1
                        ORDER BY DA.Date_Created DESC
                    ) DA
                        LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                            ON GSRT.GuideSerie = DO.Guide_Serie
                               AND GSRT.GuideNumber = DO.Guide_Number;

                END;
                ELSE IF (@StatusId IN ( 12 )) /* Intento de entrega fallida */
                BEGIN

                    SELECT GSRT.GuideSerie,
                           GSRT.GuideNumber,
                           GSRT.GuideStatus,
                           GSRT.GuideStatusId,
                           GSRT.GuideStatusChange,
                           ISNULL(DA.Longitude, '') AS Longitude,
                           ISNULL(DA.Latitude, '') AS Latitude,
                           ISNULL(DA.DescriptionIncidence, '') AS DescriptionIncidence
                    FROM @GuideStatusResponseTable GSRT
                        OUTER APPLY
                    (
                        SELECT TOP 1
                               DA.Longitude 'Longitude',
                               DA.Latitude 'Latitude',
                               DP.Path_Dry 'Path_Dry',
                               CTI.DescriptionIncidence 'DescriptionIncidence'
                        FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
                            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryProof] DP WITH (NOLOCK)
                                ON DA.ID_Proof = DP.ID
                            LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH (NOLOCK)
                                ON DA.ID_Incident = CTI.IdIncidenceType
                        WHERE GSRT.GuideSerie = DA.Guide_Serie
                              AND GSRT.GuideNumber = DA.Guide_Number
                              AND DA.Delivered = 0
                              AND DA.ID_Incident IS NOT NULL
                        ORDER BY DA.Date_Created DESC
                    ) DA;

                END;
                ELSE
                BEGIN

                    SELECT GSRT.GuideSerie,
                           GSRT.GuideNumber,
                           GSRT.GuideStatus,
                           GSRT.GuideStatusId,
                           GSRT.GuideStatusChange
                    FROM @GuideStatusResponseTable GSRT;

                END;

            END;
            ELSE
            BEGIN

                SELECT CAST(0 AS BIT) [blnResult],
                       'Error obteniendo datos de webhook' [resultMessage];

            END;

        END TRY
        BEGIN CATCH

            SELECT CAST(0 AS BIT) [blnResult],
                   ERROR_MESSAGE() [resultMessage],
                   @WebhookTypeName [webhookName];

        END CATCH;
    END;
    --========================================================================================================
    --===                                      NO WEBHOOK FOUND                                            ===
    --========================================================================================================
    ELSE
    BEGIN

        SELECT CAST(0 AS BIT) [blnResult],
               'Tipo de webhook inexistente, por favor, verifique su información' [resultMessage],
               @WebhookTypeName [webhookName];

    END;

END;