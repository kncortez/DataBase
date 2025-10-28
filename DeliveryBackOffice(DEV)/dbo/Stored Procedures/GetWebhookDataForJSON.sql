/* =================================================
   SP:        [dbo].[GetWebhookDataForJSON]
   Propósito: <Obtener datos de los estados de las guias para las notificaciones webhook>
   Autor:     <Andres Ruiz>
   Historia:  <> 
   Fecha:     <2022-09-13>
============================================
=== CHANGELOG ================================
2022-10-24 | Historia/épica:  | Autor: <Edelman Vasquez> |
-------------------------------
2025-08-13 | Historia/épica:  | Autor: <Tito Garcia>  |
-------------------------------
2025-09-05 | Historia/épica:  | Autor: <Tito Garcia>  |
-------------------------------
2025-10-28 | Historia/épica: <FDAPI-4871> | Autor: <Tito Garcia>  |
=========================================== */
CREATE PROCEDURE [dbo].[GetWebhookDataForJSON]
    @WebhookTrackingQueueId BIGINT,
    @WebhookTypeId INT,
    @WebhookTypeName NVARCHAR(50)
AS
BEGIN
    DECLARE @StatusId AS INT;
    DECLARE @IsCountryRequired AS BIT;
    DECLARE @IsPartyResponsibleRequired AS BIT;
    DECLARE @RestrictValidatedIncidents AS BIT;

    --========================================================================================================
    --===                                       STATUS CHANGE                                              ===
    --========================================================================================================
    IF (@WebhookTypeName = 'GuideStatusChange')
    BEGIN
        BEGIN TRY

            DECLARE @GuideStatusResponseTable AS TABLE
            (
                GuideSerie NVARCHAR(2),
                GuideNumber INT,
                GuideStatus NVARCHAR(200),
                GuideStatusId INT,
                GuideStatusChange DATETIME,
				IsCountryRequired BIT,
				IsPartyResponsibleRequired BIT,
				CustomerId INT,
				RestrictValidatedIncidents BIT
            );
            INSERT INTO @GuideStatusResponseTable
            (
                GuideSerie,
                GuideNumber,
                GuideStatus,
                GuideStatusId,
                GuideStatusChange,
				IsCountryRequired,
				IsPartyResponsibleRequired,
				CustomerId,
				RestrictValidatedIncidents
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
                   ) 'GuideStatusChange',
				   WE.IsCountryRequired,
				   WE.IsPartyResponsibleRequired,
				   WTQ.CustomerId,
				   WE.RestrictValidatedIncidents
            FROM [DeliveryBackOffice].[dbo].[WebhookTrackingQueue] WTQ WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH (NOLOCK)
                    ON WTQ.StatusOrderId = SO.StatusOrderId
				INNER JOIN [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH (NOLOCK)
					ON WTQ.WebhookEndpointId = WE.IdWebhookEndpoint
                LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBY WITH (NOLOCK)
                    ON WTQ.CustomerId = WRBY.CustomerId
                       AND WTQ.StatusOrderId = WRBY.StatusOrderId
                       AND WRBY.WebhookTypeId = @WebhookTypeId
                       AND WRBY.RowStatus = 1
            WHERE WTQ.IdWebhookTrackingQueue = @WebhookTrackingQueueId;

			SELECT @StatusId = GuideStatusId, @IsCountryRequired = IsCountryRequired, @RestrictValidatedIncidents = RestrictValidatedIncidents, @IsPartyResponsibleRequired = IsPartyResponsibleRequired
			FROM @GuideStatusResponseTable;

            IF (EXISTS (SELECT 1 FROM @GuideStatusResponseTable))
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
                           ISNULL(DAP.Path_Dry, '') AS ImageEvidence,
                           ISNULL(DO.NameOfReceiver, '') AS ReceiverName,
                           ISNULL(DAP.Longitude, '') AS Longitude,
                           ISNULL(DAP.Latitude, '') AS Latitude,
						   CASE 
                                WHEN @IsCountryRequired = 1 THEN DO.ReceiverCountryId
                                ELSE NULL
						   END AS [Country]
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
							  AND DA.ID_Proof IS NOT NULL
                        ORDER BY DA.Date_Created DESC
                    ) DAP
                    LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                        ON GSRT.GuideSerie = DO.Guide_Serie
                            AND GSRT.GuideNumber = DO.Guide_Number;

                END;
                ELSE IF (@StatusId IN ( 25 )) /* COD pagado  */
                BEGIN


                    DECLARE @GuidePaymentConceptId INT =
                            (
                                SELECT TOP (1)
                                       [CCCOD].[IdCatConceptCOD]
                                FROM [DeliveryBackOffice].[dbo].[CatConceptCOD] CCCOD WITH (NOLOCK)
                                WHERE [CCCOD].[Concept] = 'PAGO DE LA GUIA'
                            );

                    SELECT TOP (1)
                           GSRT.GuideSerie,
                           GSRT.GuideNumber,
                           GSRT.GuideStatus,
                           GSRT.GuideStatusId,
                           GSRT.GuideStatusChange,
                           ISNULL(BDC.AuthorizationNumber, '') AS AuthorizationNumber,
                           [BDC].[Amount] TransactionAmount
                    FROM @GuideStatusResponseTable GSRT
                        LEFT JOIN [DeliveryBackOffice].[dbo].[BatchDetailCOD] BDC WITH (NOLOCK)
                            ON GSRT.GuideSerie = BDC.GuideSerie
                               AND GSRT.GuideNumber = BDC.GuideNumber
                               AND [BDC].[CatConceptCODId] = @GuidePaymentConceptId;

                END;
                ELSE IF (@StatusId IN ( 14, 23 )) /* Devuelto */
                BEGIN

                    SELECT GSRT.GuideSerie,
                           GSRT.GuideNumber,
                           GSRT.GuideStatus,
                           GSRT.GuideStatusId,
                           GSRT.GuideStatusChange,
                           ISNULL(DAP.Path_Dry, '') AS ImageEvidence,
                           ISNULL(DO.NameOfReceiver, '') AS ReceiverName,
                           ISNULL(DAP.Longitude, '') AS Longitude,
                           ISNULL(DAP.Latitude, '') AS Latitude
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
                    ) DAP
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
                           ISNULL(DAP.Longitude, '') AS Longitude,
                           ISNULL(DAP.Latitude, '') AS Latitude,
                           ISNULL(DAP.DescriptionIncidence, '') AS DescriptionIncidence
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
                    ) DAP;

                END;
                ELSE IF (@StatusId IN ( 50 )) /* Incidencia validada */
                BEGIN

					SELECT 
						GSRT.GuideSerie  AS [GuideSerie],
						GSRT.GuideNumber  AS [GuideNumber],
						GSRT.GuideStatus  AS [GuideStatus],
						GSRT.GuideStatusId AS [GuideStatusId],
						GSRT.GuideStatusChange AS [GuideStatusChange],
						ISNULL(DAP.Path_Dry, '') AS [ImageEvidence],
						ISNULL(DO.NameOfReceiver, '') AS [ReceiverName],
						ISNULL(DAP.Longitude, '') AS [Longitude],
						ISNULL(DAP.Latitude, '') AS [Latitude]
					FROM @GuideStatusResponseTable GSRT
					OUTER APPLY
					(
						SELECT TOP 1
							   DA.Longitude AS Longitude,
							   DA.Latitude AS Latitude,
							   DP.Path_Dry AS Path_Dry
						FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
						INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
							ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
						LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryProof] DP WITH (NOLOCK)
							ON DA.ID_Proof = DP.ID
						WHERE GSRT.GuideSerie = DA.Guide_Serie
							  AND GSRT.GuideNumber = DA.Guide_Number
							  AND DA.Delivered = 1
							  AND COI.IsConfirmed = 1
							  AND COI.StatusOrderId = @StatusId
						ORDER BY DA.Date_Created DESC
					) DAP
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
						ON GSRT.GuideSerie = DO.Guide_Serie
					   AND GSRT.GuideNumber = DO.Guide_Number;
                END                
                ELSE IF (@StatusId IN (45)) /* Incidencia en ruta */
                BEGIN

					SELECT 
						GSRT.GuideSerie  AS [GuideSerie],
						GSRT.GuideNumber  AS [GuideNumber],
						GSRT.GuideStatus  AS [GuideStatus],
						GSRT.GuideStatusId AS [GuideStatusId],
						GSRT.GuideStatusChange AS [GuideStatusChange],
						CASE 
                            WHEN @IsPartyResponsibleRequired = 1 THEN DAP.PartyResponsibleName
                            ELSE NULL
						END AS [PartyResponsibleName]						
					FROM @GuideStatusResponseTable GSRT
					OUTER APPLY
					(
						SELECT TOP 1
							CPR.PartyResponsibleName
						FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)						
						INNER JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH (NOLOCK)
							ON DA.ID_Incident = CTI.IdIncidenceType
						INNER JOIN [DeliveryBackOffice].[dbo].[CatPartyResponsible] CPR
							ON CTI.CatPartyResponsibleId = CPR.IdCatPartyResponsible
						WHERE GSRT.GuideSerie = DA.Guide_Serie
							  AND GSRT.GuideNumber = DA.Guide_Number
							  AND DA.Delivered = 1
                              AND CTI.RowStatus = 1
							  AND CPR.RowStatus = 1
						ORDER BY DA.Date_Created DESC
					) DAP
                END
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