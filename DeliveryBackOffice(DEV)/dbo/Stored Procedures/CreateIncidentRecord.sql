
-- Author:		<Bidcar Herrera>
-- Create date: <2023-09-25>
-- Description:	< Registro de incidencia>
-- =============================================
-- Author:		<Edelman>
-- Update date: <2024-03-07>
-- Description:	<Registrar incidencia para cliente DHL>
-- =============================================
ALTER PROCEDURE [dbo].[CreateIncidentRecord]
    @GuideSerie NVARCHAR(2) = 'FD'        --serie
  , @GuideNumber INT                      --número de guía
  , @TokenCreated NVARCHAR(200)           --token de guardado
  , @IsRealIncident BIT                   --cliente indica que la incidencia es real?
  , @IsServiceDesired BIT                 --cliente aún desea recibir el servicio?
  , @IsAddressModificationRequested BIT   --Solicita cambio de dirección?
  , @IsExpressCenterAddress BIT           --Se cambia a dirección de express center?
  , @IdExpressCenter INT                  --Express Center al que cambia
  , @NewAddress NVARCHAR(600)             --Nueva dirección si se solicita
  , @NewPhoneNumber NVARCHAR(100)         --Cambio  de teléfono si se solicita
  , @DeliveryDateChange BIT               --Cambiar fecha de entrega?
  , @NewDeliveryDate DATE = NULL          --Nueva fecha de entrega si se solicita,
  , @Observations NVARCHAR(600)           --Observaciones tracking
  , @LiquidatorRemarks NVARCHAR(600) = '' --Observaciones para el liquidador
  , @ValidGeolocationEvidence BIT         --indica si la incidecia de geolocalziación es valdia
  , @ValidPhotographicEvidence BIT        --indica si la evidencia fotografica es valida
  , @IdIncident INT                  --Id incidencia
AS
BEGIN
    DECLARE @StatusOrderId TINYINT;
    DECLARE @ValidatedIncidentStatus TINYINT = 50;
    DECLARE @IncidentStatus TINYINT = 45;
    DECLARE @CatTypeConfirmationOfIncidenceId INT;
    DECLARE @FailedVisitStatusId INT;
    DECLARE @IncidenceStatusId INT;
    DECLARE @CatTypeCOIFailedVisitStatusId INT;
    DECLARE @CatTypeCOIIncidenceStatusId INT;
    DECLARE @DeliveryAttemptId AS BIGINT = NULL;
    DECLARE @SytemOrigin AS INT = NULL;
    DECLARE @IdCountrySender AS NVARCHAR(2) = 'GT';

    BEGIN TRANSACTION;
    DECLARE @OriginRouteId INT = NULL;
    DECLARE @NewRoutePreparation INT = 0;
    DECLARE @NewRouteManifest INT = 0;
    DECLARE @DeliverySettlementId INT = NULL;
    DECLARE @InsertedRoutePreparation TABLE
    (
        IdRoutePreparation INT
    );
    DECLARE @InsertedRoutePreparationDetail TABLE
    (
        IdRoutePreparationDetail INT
    );

    SET @IncidenceStatusId =
    (
        SELECT TOP 1
               StatusOrderId
        FROM StatusOrder WITH (NOLOCK)
        WHERE OrderDescription = 'Incidencia en ruta'
    );
    SET @CatTypeCOIIncidenceStatusId =
    (
        SELECT TOP 1
               IdCatTypeConfirmationOfIncidence
        FROM CatTypeConfirmationOfIncidence WITH (NOLOCK)
        WHERE [Name] = 'Incidencia en Ruta'
    );

    -- Variables de control de cambios
    DECLARE @UpdatedRP BIT = 0;

    DECLARE @Terminal INT =
            (
                SELECT TOP 1
                       [SO].[CatCheckpointTypeId]
                FROM [dbo].[DeliveryOrder]         [DO] WITH (NOLOCK)
                    INNER JOIN [dbo].[StatusOrder] [SO] WITH (NOLOCK)
                        ON [DO].[StatusOrderId] = [SO].[StatusOrderId]
                WHERE [SO].[RowStatus] = 1
                      AND [DO].[Guide_Serie] = @GuideSerie
                      AND [DO].[Guide_Number] = @GuideNumber
            );

    SET @IdCountrySender  =
            (
                SELECT TOP 1
                       ISNULL([DO].[SenderCountryId],'GT')
                  FROM [dbo].[DeliveryOrder]         [DO] WITH (NOLOCK)
                 WHERE [DO].[Guide_Serie] = @GuideSerie
                   AND [DO].[Guide_Number] = @GuideNumber
            );

    DECLARE @UserCreatedIncidence NVARCHAR(250) =
            (
                SELECT TOP 1
                       it.Username
                FROM [dbo].[DeliveryOrderDetail]   ddd WITH (NOLOCK)
                    LEFT JOIN [dbo].[TokenLog]     TL WITH (NOLOCK)
                        ON ddd.UserCreated = TL.TknTokenCreated
                    LEFT JOIN [dbo].[RegisterUser] RU WITH (NOLOCK)
                        ON TL.TknIdUser = RU.UsrIdUser
                    LEFT JOIN dbo.InternalUser     it WITH (NOLOCK)
                        ON it.RegisterUserID = RU.UsrIdUser
                WHERE ddd.Guide_Serie = @GuideSerie
                      AND ddd.Guide_Number = @GuideNumber
                      AND ddd.StatusOrderId = 50
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
            );

    DECLARE @StatusIncidence INT =
            (
                SELECT TOP 1
                       StatusOrderId
                FROM dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
                WHERE DOD.Guide_Number = @GuideNumber
                      AND CONVERT(DATE, DOD.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                ORDER BY DOD.DateCreatedInSystem DESC
            );

    DECLARE @NameStatusIncidence NVARCHAR(250) =
            (
                SELECT TOP 1
                       SO.OrderDescription
                FROM [dbo].[DeliveryOrderDetail]   DOD WITH (NOLOCK)
                    INNER JOIN [dbo].[StatusOrder] SO WITH (NOLOCK)
                        ON DOD.StatusOrderId = SO.StatusOrderId
                WHERE DOD.Guide_Number = @GuideNumber
                      AND CONVERT(DATE, DOD.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                ORDER BY DOD.DateCreatedInSystem DESC
            );

    BEGIN TRY
        SET @StatusOrderId = @IncidenceStatusId;
        SET @CatTypeConfirmationOfIncidenceId = @CatTypeCOIIncidenceStatusId;

        SELECT TOP 1
               @DeliveryAttemptId = DeliveryAttemptId
             , @SytemOrigin       = SystemOrigin
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH (NOLOCK)
        WHERE Guide_Serie = @GuideSerie
              AND Guide_Number = @GuideNumber
              AND RowStatus = 1
              AND StatusOrderId = @IncidentStatus
        ORDER BY DateCreatedInSystem DESC;

        IF (@Terminal != 3 AND @StatusIncidence != 50)
        BEGIN

            UPDATE [COI]
            SET [COI].[ValidGeolocationEvidence] = ISNULL(@ValidGeolocationEvidence, 0)
              , [COI].[ValidPhotographicEvidence] = ISNULL(@ValidPhotographicEvidence, 0)
            FROM [dbo].[DeliveryOrder]                     [DO]
                INNER JOIN [dbo].[DeliveryAttempt]         DA WITH (NOLOCK)
                    ON [DO].[Guide_Serie] = [DA].[Guide_Serie]
                       AND [DO].[Guide_Number] = [DA].[Guide_Number]
                INNER JOIN [dbo].[ConfirmationOfIncidence] COI
                    ON [DA].[ConfirmationOfIncidenceId] = [COI].[IdConfirmationOfIncidence]
            WHERE DA.Guide_Serie = @GuideSerie
                  AND DA.Guide_Number = @GuideNumber
                  AND [COI].[RowStatus] = 1
                  AND DA.ID = @DeliveryAttemptId;

            IF (@IsRealIncident = 0) --Si courier mintió?
            BEGIN

                UPDATE t1
                --[dbo].[ConfirmationOfIncidence]
                SET t1.[LastStatusOrderId] = [StatusOrderId]
                  , t1.[IsDenied] = 1
                  , t1.[TokenUpdated] = @TokenCreated --'SetServiceTokenGuideData',
                  , t1.[DateUpdated] = SYSDATETIME()
                FROM dbo.ConfirmationOfIncidence                      t1 WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt A1 WITH (NOLOCK)
                        ON A1.ConfirmationOfIncidenceId = t1.IdConfirmationOfIncidence
                WHERE t1.RowStatus = 1
                      AND A1.Guide_Serie = @GuideSerie
                      AND A1.Guide_Number = @GuideNumber
                      AND A1.ID = @DeliveryAttemptId;

                UPDATE dop
                SET StatusOrderId = @StatusOrderId
                FROM DeliveryOrderPiece                dop WITH (NOLOCK)
                    INNER JOIN DeliveryAttempt         da WITH (NOLOCK)
                        ON dop.GuideSerie = da.Guide_Serie
                           AND dop.GuideNumber = da.Guide_Number
                    INNER JOIN ConfirmationOfIncidence coi WITH (NOLOCK)
                        ON da.ConfirmationOfIncidenceId = coi.IdConfirmationOfIncidence
                WHERE --coi.ConfirmationOfIncidentToken = @GuideToken
                    dop.GuideSerie = @GuideSerie
                    AND dop.GuideNumber = @GuideNumber
                    AND coi.RowStatus = 1
                    AND da.ID = @DeliveryAttemptId;;


            END;
            ELSE
            BEGIN

                /* Validar si la incidencia fue manual desde sistema hermes desktop y quitar intento disponible de entrega */
                IF (EXISTS
                (
                    SELECT TOP 1
                           1
                    FROM [dbo].[DeliveryAttempt]                   DA WITH (NOLOCK)
                        INNER JOIN [dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                            ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
                        INNER JOIN [dbo].[DeliveryOrderDetail]     DOD WITH (NOLOCK)
                            ON DA.Guide_Serie = DOD.Guide_Serie
                               AND DA.Guide_Number = DOD.Guide_Number
						INNER JOIN [dbo].[CatTypeIncidence] CTP
						    ON DA.ID_Incident = CTP.IdIncidenceType
                    WHERE DA.Guide_Serie = @GuideSerie
                          AND DA.Guide_Number = @GuideNumber
                          AND DOD.StatusOrderId = 45
                          AND DOD.SystemOrigin = 2
						  AND CTP.IncidenceClasificationId = 1 --Contar intento solo cuando es de tipo de "intento fallido".
						   AND DA.ID_Incident = @IdIncident
                )
                   )
                BEGIN

                    IF (NOT EXISTS
                    (
                        SELECT TOP 1
                               1
                        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData] DOAD WITH (NOLOCK)
                        WHERE DOAD.GuideSerie = @GuideSerie
                        AND DOAD.GuideNumber = @GuideNumber
                    )
                       )
                    BEGIN
                        -- Insertar data para manejo de inténtos de entrega/devolución
                        INSERT INTO [dbo].[DeliveryOrderAttemptData]
                        (
                            [GuideSerie]
                          , [GuideNumber]
                          , [GuideDeliveryAttemptCount]
                          , [GuideDeliveryMaxAttemptCount]
                          , [GuideReturnAttemptCount]
                          , [GuideReturnMaxAttemptCount]
                          , [RowStatus]
                          , [DateCreated]
                          , [TokenCreated]
                        )
                        SELECT TOP 1
                               do.Guide_Serie
                             , do.Guide_Number
                             , 1
                             , rh.Attempt
                             , 0
                             , rh.AttemptReturn
                             , 1
                             , GETDATE()
                             , @TokenCreated
                        FROM DeliveryOrder                    do WITH (NOLOCK)
                            LEFT JOIN VisitPointClient        vpc WITH (NOLOCK)
                                ON do.Sender_ID = vpc.CodeOfReference
                            INNER JOIN RatebyCustomer         rbc WITH (NOLOCK)
                                ON ISNULL(do.IdCustomer, vpc.CustomerID) = rbc.RbcIdCustomer
                                   AND rbc.RbcRowStatus = 1
                                   AND
                                   (
                                       rbc.RbcCodeOfReference = vpc.CodeOfReference
                                       OR rbc.RbcCodeOfReference IS NULL
                                   )
                            INNER JOIN RateHeader             rh WITH (NOLOCK)
                                ON rbc.RbcIdRate = rh.RheId
                            INNER JOIN DeliveryAttempt        da WITH (NOLOCK)
                                ON do.Guide_Serie = da.Guide_Serie
                                   AND do.Guide_Number = da.Guide_Number
                            LEFT JOIN ConfirmationOfIncidence coi WITH (NOLOCK)
                                ON da.ConfirmationOfIncidenceId = coi.IdConfirmationOfIncidence
                            LEFT JOIN StatusOrder             so
                                ON coi.StatusOrderId = so.StatusOrderId
                        WHERE do.Guide_Serie = @GuideSerie
                              AND do.Guide_Number = @GuideNumber
                        ORDER BY rbc.RbcCodeOfReference DESC;
                    END;
                    ELSE
                    BEGIN

                        -- Incrementar intentos de entrega de guía respecto a flujo correspondiente

                        UPDATE [DOAD]
                        SET [DOAD].[GuideDeliveryAttemptCount] = [DOAD].[GuideDeliveryAttemptCount] + 1
                          , [DOAD].[TokenUpdated] = @TokenCreated
                          , [DOAD].[DateUptaded] = GETDATE()
                        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData] DOAD
                        WHERE [DOAD].[GuideSerie] = @GuideSerie
                              AND [DOAD].[GuideNumber] = @GuideNumber;



                    END;


                END;
                ELSE
                BEGIN

                    UPDATE [COI]
                    SET [COI].[ValidGeolocationEvidence] = @ValidGeolocationEvidence
                      , [COI].[ValidPhotographicEvidence] = @ValidPhotographicEvidence
                    FROM [dbo].[DeliveryOrder]                     [DO]
                        INNER JOIN [dbo].[DeliveryAttempt]         DA WITH (NOLOCK)
                            ON [DO].[Guide_Serie] = [DA].[Guide_Serie]
                               AND [DO].[Guide_Number] = [DA].[Guide_Number]
                        INNER JOIN [dbo].[ConfirmationOfIncidence] COI
                            ON [DA].[ConfirmationOfIncidenceId] = [COI].[IdConfirmationOfIncidence]
                    WHERE DA.Guide_Serie = @GuideSerie
                          AND DA.Guide_Number = @GuideNumber
                          AND [COI].[RowStatus] = 1
                          AND DA.ID = @DeliveryAttemptId;
                END;

            /*Fin*/
            END;

            UPDATE t1
            SET t1.IsConfirmed = 1
              , t1.StatusOrderId = @ValidatedIncidentStatus                --Registro de incidencia validada--@StatusOrderId,
              , t1.CatTypeConfirmationOfIncidenceId = @CatTypeConfirmationOfIncidenceId
                                                                           --CatTypeConfirmationOfIncidenceId = @CatTypeConfirmationOfIncidenceId,
              , t1.ActionObservation = @Observations
              , t1.ClientConfirmsReturn = IIF(@IsServiceDesired = 1, 0, 1) --@CancelOrder,
              , t1.IncidentfinalizedbySAC = 1                              --@CompletedBySAC,
              , t1.TokenUpdated = @TokenCreated                            --'SetServiceTokenGuideData',
              , t1.DateUpdated = GETDATE()
              , CourierContempt = 0                                        --quitar desacatos
              , t1.LiquidatorRemarks = @LiquidatorRemarks
            FROM dbo.ConfirmationOfIncidence                      t1 WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt A1 WITH (NOLOCK)
                    ON A1.ConfirmationOfIncidenceId = t1.IdConfirmationOfIncidence
            WHERE A1.Guide_Serie = @GuideSerie
                  AND A1.Guide_Number = @GuideNumber
                  AND RowStatus = 1
                  AND A1.ID = @DeliveryAttemptId;

           UPDATE do
            SET StatusOrderId = @ValidatedIncidentStatus,
				[TokenUpdated] = @TokenCreated,
                [DateUpdated] = getdate()
            FROM dbo.DeliveryOrder do
            WHERE do.Guide_Serie = @GuideSerie
                  AND do.Guide_Number = @GuideNumber;



            --Copiar la imagen de incidencia de ruta hacia incidencia validada


            INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
            (
                Guide_Serie
              , Guide_Number
              , StatusOrderId
              , UserCreated
              , DateCreated
              , DateCreatedInSystem
              , Observations
              , Temperature_Celsius
              , PieceId
              , RowStatus
              , DeliveryAttemptId
              , SystemOrigin
            )
            VALUES
            (   @GuideSerie              -- Guide_Serie - nvarchar(2)
              , @GuideNumber             -- Guide_Number - int
              , @ValidatedIncidentStatus -- StatusOrderId - tinyint
              , @TokenCreated            -- UserCreated - nvarchar(z)
              , GETDATE()                -- DateCreated - datetime
              , GETDATE()                -- DateCreatedInSystem - datetime
              , @Observations            -- Observations - nvarchar(200)
              , NULL                     -- Temperature_Celsius - decimal(5, 2)
              , NULL                     -- PieceId - int
              , 1                        -- RowStatus - bit
              , @DeliveryAttemptId       -- DeliveryAttemptId - bigint
              , @SytemOrigin             -- SystemOrigin - int
                );

            UPDATE dop
            SET StatusOrderId = @ValidatedIncidentStatus
            FROM dbo.DeliveryOrderPiece dop
            WHERE dop.GuideSerie = @GuideSerie
                  AND dop.GuideNumber = @GuideNumber;

                    -------------------WEBHOOK.INI--------------------------------------------------------------------------------------------
                        DECLARE @WebhookCustomerId INT = -1;
                        DECLARE @CustomerEndpointId INT = -1;
                        -- Debido a que se procesa únicamente 1 guía
                        DECLARE @GuideCurrentStatus INT = -1;

                        BEGIN TRY
                            DECLARE @GuideStatusChangeWebhook INT =
                                    (
                                        SELECT TOP 1
                                               WT.IdWebhookType
                                        FROM [DeliveryBackOffice].[dbo].[WebhookType] WT WITH (NOLOCK)
                                        WHERE WT.WebhookName = 'GuideStatusChange' COLLATE Latin1_General_CI_AI
                                              AND WT.RowStatus = 1
                                    );

                          
                                      SELECT TOP 1
                                             @WebhookCustomerId =  DO.IdCustomer,
											 @GuideCurrentStatus = DO.StatusOrderId
                                      FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                                      WHERE DO.Guide_Number = @GuideNumber
                                            AND DO.Guide_Serie = @GuideSerie
                              
                            SET @CustomerEndpointId
                                = ISNULL(
                                  (
                                      SELECT TOP 1
                                             WE.IdWebhookEndpoint
                                      FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH (NOLOCK)
                                      WHERE WE.CustomerId = @WebhookCustomerId
                                            AND WE.WebhookTypeId = @GuideStatusChangeWebhook
                                  ),
                                  -1
                                        );

                                
							
								 
                            -- Cliente tiene webhook configurado para el tipo especificado
                            -- Estado actual de la guía coincide dentro de las restricciónes por usuario
                            IF (
                                   @WebhookCustomerId > 0
                                   AND @CustomerEndpointId > 0
                                   AND @GuideCurrentStatus IN
                                       (
                                           SELECT WRBU.StatusOrderId
                                           FROM [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH (NOLOCK)
                                           WHERE WRBU.CustomerId = @WebhookCustomerId
                                                 AND WRBU.WebhookTypeId = @GuideStatusChangeWebhook
                                       )
                               )
                            BEGIN

                                DECLARE @ResponseTable AS TABLE
                                (
                                    InsertedId BIGINT
                                );

						DECLARE @TypeConnect INT = 0;

						SET @TypeConnect = (SELECT top 1 TypeConnectionId 
								FROM WebhookEndpoint wh
								INNER JOIN WebhookCatTypeConnection wc
									ON wh.TypeConnectionId = wc.IdCatTypeConnection
								WHERE wh.CustomerId = @WebhookCustomerId)
								

						IF(@TypeConnect = 1)
							 BEGIN

                                INSERT INTO [DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
                                (
                                    [GuideSerie],
                                    [GuideNumber],
                                    [CustomerId],
                                    [StatusOrderId],
                                    [WebhookEndpointId],
                                    [HasNotified],
                                    [TokenCreated],
                                    [DateCreated]
                                )
                                OUTPUT inserted.IdWebhookTrackingQueue
                                INTO @ResponseTable
                                (
                                    InsertedId
                                )
                                VALUES
                                (@GuideSerie, @GuideNumber, @WebhookCustomerId, @GuideCurrentStatus,
                                 @CustomerEndpointId, 0, @TokenCreated, GETDATE());

								

							END
						ELSE
						    BEGIN
								-----------------------------------
									 DECLARE @GuidePiecesTable AS TABLE
									(
									    CustomerId INT,
									    CustomerEndpointId BIGINT,
									    WebhookType INT,
									    GuideSerie NVARCHAR(2),
									    GuideNumber INT,
									    GuideStatusId TINYINT,
										NumberPieces INT,
										NumberRelatedPieces INT
										
									);

									INSERT INTO @GuidePiecesTable 
												( 
											CustomerId,
									        GuideSerie,
									        GuideNumber,
									        GuideStatusId,
											NumberPieces
											)
											SELECT @WebhookCustomerId,
											dop.GuideSerie,dop.GuideNumber, 
											@GuideCurrentStatus,
											Count(dop.GuideNumber)
											FROM DeliveryOrder do WITH(NOLOCK)
											INNER JOIN DeliveryOrderPiece dop WITH(NOLOCK)
												ON do.Guide_Serie = dop.GuideSerie
												AND do.Guide_Number = dop.GuideNumber
												INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
											    ON do.IdCustomer = WHE.CustomerId
												WHERE do.Guide_Number = @GuideNumber
													AND WHE.TypeConnectionId = 2
												GROUP BY dop.GuideSerie,dop.GuideNumber

									   DECLARE @PiecesGuideRelatedTable AS TABLE
									(
									    CustomerId INT,
									    CustomerEndpointId BIGINT,
									    WebhookType INT,
									    GuideSerie NVARCHAR(2),
									    GuideNumber INT,
									    GuideStatusId TINYINT,
										NumberRelatedPieces INT
										
									);

									INSERT INTO @PiecesGuideRelatedTable 
												( 
											CustomerId,
									        GuideSerie,
									        GuideNumber,
									        GuideStatusId,
											NumberRelatedPieces
											)
											SELECT @WebhookCustomerId,
											dop.GuideSerie,dop.GuideNumber, 
											@GuideCurrentStatus,
											Count(dop.GuideNumber)
											FROM DeliveryOrder do WITH(NOLOCK)
											INNER JOIN DeliveryOrderPiece dop WITH(NOLOCK)
												ON do.Guide_Serie = dop.GuideSerie
												AND do.Guide_Number = dop.GuideNumber
												INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
											    ON do.IdCustomer = WHE.CustomerId
												WHERE do.Guide_Number = @GuideNumber
												AND dop.ExternalPieceId IS NOT NULL
												AND WHE.TypeConnectionId = 2
												GROUP BY dop.GuideSerie,dop.GuideNumber
					  
					  
						        IF EXISTS(SELECT TOP 1 1 FROM IncidentTypeRelation WITH (NOLOCK)
												WHERE 
												IncidenceTypeId = @IdIncident) AND @IsRealIncident = 1
                                                AND  @IsServiceDesired = 1
									 BEGIN

					  					INSERT INTO WebhookTrackingQueueDetailForSFTP 
											(CustomerId,
											GuideSerie,
											GuideNumber,
											GuidePiece,
											ExternalNumber,
											ExternalPieceId,
											StatusOrderId,
											RowStatus,
											DateCreated,
											TokenCreated,
											NewDeliveryDate,
											DeliveryAttemptId
											)
										SELECT @WebhookCustomerId,
										dop.GuideSerie,dop.GuideNumber, dop.GuidePiece, do.Ticket_Number,dop.ExternalPieceId, 
										@GuideCurrentStatus, 1 AS RowStatus, GETDATE()AS DateCreated,@TokenCreated AS TokenCreated, @NewDeliveryDate, @DeliveryAttemptId
										FROM DeliveryOrderPiece dop WITH(NOLOCK)
										INNER JOIN DeliveryOrder do WITH(NOLOCK)
											ON dop.GuideSerie = do.Guide_Serie
											AND dop.GuideNumber = do.Guide_Number
										INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
										    ON do.IdCustomer = WHE.CustomerId
										INNER JOIN @GuidePiecesTable gpt
										    ON dop.GuideNumber = gpt.GuideNumber
										INNER JOIN @PiecesGuideRelatedTable pgt
										    ON gpt.GuideNumber = pgt.GuideNumber
											WHERE gpt.NumberPieces = pgt.NumberRelatedPieces
												AND WHE.TypeConnectionId = 2

												
														     

                                  END 

								END

                            END;
								
                        END TRY
                        BEGIN CATCH

                        END CATCH;

                    -------------------WEBHOOK.INI FIN---------------------------------------------------------------------------------------
					

            --IF (@CancelOrder = 1)
            --IF (@IsServiceDesired = 0)
            IF (ISNULL(@IsAddressModificationRequested, 0) = 1) --Solicita cambio de dirección
            BEGIN
                UPDATE [DO]
                SET [DO].[Receiver_Address] = IIF((LTRIM(RTRIM(ISNULL(@NewAddress, ''))) != '')
                                                  , @NewAddress
                                                  , [DO].[Receiver_Address])
                  , [DO].[Receiver_Phone] = IIF((LTRIM(RTRIM(ISNULL(@NewPhoneNumber, ''))) != '')
                                                , @NewPhoneNumber
                                                , ISNULL([DO].[Receiver_Phone], ''))
                FROM [dbo].[DeliveryOrder]                     [DO]
                    INNER JOIN [dbo].[DeliveryAttempt]         DA WITH (NOLOCK)
                        ON [DO].[Guide_Serie] = [DA].[Guide_Serie]
                           AND [DO].[Guide_Number] = [DA].[Guide_Number]
                    INNER JOIN [dbo].[ConfirmationOfIncidence] COI
                        ON [DA].[ConfirmationOfIncidenceId] = [COI].[IdConfirmationOfIncidence]
                WHERE DA.Guide_Serie = @GuideSerie
                      AND DA.Guide_Number = @GuideNumber
                      --[COI].[ConfirmationOfIncidentToken] = @GuideToken
                      AND [COI].[RowStatus] = 1;


                UPDATE [COI]
                SET [COI].IsAddressModificationRequested = 1
                FROM [dbo].[DeliveryOrder]                     [DO]
                    INNER JOIN [dbo].[DeliveryAttempt]         DA WITH (NOLOCK)
                        ON [DO].[Guide_Serie] = [DA].[Guide_Serie]
                           AND [DO].[Guide_Number] = [DA].[Guide_Number]
                    INNER JOIN [dbo].[ConfirmationOfIncidence] COI
                        ON [DA].[ConfirmationOfIncidenceId] = [COI].[IdConfirmationOfIncidence]
                WHERE DA.Guide_Serie = @GuideSerie
                      AND DA.Guide_Number = @GuideNumber
                      AND [COI].[RowStatus] = 1;

            END;

            IF (ISNULL(@DeliveryDateChange, 0) = 1)
            BEGIN

                --------- Obtener Id de la Ruta 
                SELECT TOP 1
                       @OriginRouteId = RP.CatRouteId
                FROM [DeliveryBackOffice].[dbo].[RoutePreparation]           RP WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.RoutePreparationDetail RPD WITH (NOLOCK)
                        ON RPD.Guide_Serie = @GuideSerie
                           AND RPD.Guide_Number = @GuideNumber
                           AND RPD.RowStatus = 1
                           AND RP.IdRoutePreparation = RPD.RoutePreparationId
                WHERE RP.RowStatus = 1
                ORDER BY RP.DateRoutePreparation DESC;

                -------- Obtener  Id de ruta de preparación del encabezado, esto si ya existe solo se inserta detalle
                SELECT TOP 1
                       @NewRoutePreparation = COALESCE(RP.IdRoutePreparation, 0)
                FROM [DeliveryBackOffice].[dbo].[RoutePreparation]                 RP WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH (NOLOCK)
                        ON RP.IdRoutePreparation = RPD.RoutePreparationId
                WHERE RP.CatRouteId = @OriginRouteId
                      AND RP.DateRoutePreparation = @NewDeliveryDate
                      AND RP.RowStatus = 1
                      AND RPD.Guide_Serie = @GuideSerie
                      AND RPD.Guide_Number = @GuideNumber
                ORDER BY RP.IdRoutePreparation DESC;


                         UPDATE RP
                               SET RP.RowStatus = 0,
                               RP.TokenUpdated = @TokenCreated,
                               	RP.DateUpdated = GETDATE()
								FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
								INNER JOIN 
								[DeliveryBackOffice].[dbo].[RoutePreparation] RP
								ON RPD.RoutePreparationId = RP.IdRoutePreparation
                               WHERE
                               Guide_Serie =  @GuideSerie
                                AND Guide_Number = @GuideNumber
                                AND  RP.DateRoutePreparation > CONVERT(DATE,GETDATE());





                IF (EXISTS
                (
                    SELECT TOP 1
                           1
                    FROM [DeliveryBackOffice].[dbo].RoutePreparation                   RP WITH (NOLOCK)
                        INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH (NOLOCK)
                            ON RPD.RoutePreparationId = RP.IdRoutePreparation
                    WHERE RP.CatRouteId = @OriginRouteId
                          AND RP.DateRoutePreparation = @NewDeliveryDate
                          AND RP.RowStatus = 1
                )
                   )
                BEGIN

                    INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationDetail]
                    (
                        [RoutePreparationId]
                      , [Guide_Serie]
                      , [Guide_Number]
                      , [RowStatus]
                      , [TokenCreated]
                      , [DateCreated]
                      , [TokenUpdated]
                      , [DateUpdated]
                      , [IsCustomerReschedule]
                    )
                    VALUES
                    (@NewRoutePreparation, @GuideSerie, @GuideNumber, 1, @TokenCreated, GETDATE(), NULL, NULL, 1);



                END;
                ELSE
                BEGIN
                    INSERT INTO [dbo].[RoutePreparation]
                    (
                        [CatRouteId]
                      , [DateRoutePreparation]
                      , [GuidesQuantity]
                      , [PiecesDry]
                      , [PiecesCold]
                      , [RowStatus]
                      , [TokenCreated]
                      , [DateCreated]
                      , [TokenUpdated]
                      , [DateUpdated]
                    )
                    OUTPUT inserted.IdRoutePreparation
                    INTO @InsertedRoutePreparation
                    (
                        IdRoutePreparation
                    )
                    VALUES
                    (@OriginRouteId, @NewDeliveryDate, 1, 0, 0, 1, @TokenCreated, GETDATE(), NULL, NULL);

                    SELECT TOP 1
                           @NewRoutePreparation = IdRoutePreparation
                    FROM @InsertedRoutePreparation;




                    INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationDetail]
                    (
                        [RoutePreparationId]
                      , [Guide_Serie]
                      , [Guide_Number]
                      , [RowStatus]
                      , [TokenCreated]
                      , [DateCreated]
                      , [TokenUpdated]
                      , [DateUpdated]
                      , [IsCustomerReschedule]
                    )
                    OUTPUT inserted.IdRoutePreparationDetail
                    INTO @InsertedRoutePreparationDetail
                    (
                        IdRoutePreparationDetail
                    )
                    VALUES
                    (@NewRoutePreparation, @GuideSerie, @GuideNumber, 1, @TokenCreated, GETDATE(), NULL, NULL, 1);



                END;

                IF @@ROWCOUNT > 0
                BEGIN
                    SET @UpdatedRP = 1;
                END;







            END;

            IF (@IsExpressCenterAddress = 1) --Modificar dirección a express center
            BEGIN
                DECLARE @NewDeliveryOptionID INT =
                        (
                            SELECT TOP 1
                                   CDO.IdDeliveryOption
                            FROM [DeliveryBackOffice].[dbo].[CatDeliveryOptions] CDO WITH (NOLOCK)
                            WHERE CDO.[Name] = 'Express Center' COLLATE Latin1_General_CI_AI
                              AND IdCountry = @IdCountrySender
                        );

                UPDATE dbo.DeliveryOrder
                SET Receiver_ID = @IdExpressCenter
                  , IdDeliveryOption = @NewDeliveryOptionID
                  , Receiver_Address = (CASE
                                            WHEN LTRIM(RTRIM(ISNULL(@NewAddress, ''))) != '' THEN
                                                @NewAddress
                                            ELSE
                                                Receiver_Address
                                        END
                                       )
                  , TokenUpdated = @TokenCreated
                  , DateUpdated = GETDATE()
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber;

            END;
        END;
        COMMIT TRANSACTION;
        SELECT @Terminal                                    AS 'boolResult'
             , CASE
                   WHEN @Terminal = 3 THEN
                       'No se posible confirmar la incidencia. Guía se encuentra en estado final.'
                   WHEN @StatusIncidence = 50 THEN
                       'Incidencia ya fue confirmada por el usuario: '
                       + UPPER(ISNULL(@UserCreatedIncidence, 'Control de Calidad'))
                   ELSE
                       'Incidencia confirmada Exitosamente.'
               END                                          AS 'DescriptionResult'
             , CONVERT(BIGINT, ISNULL(@StatusIncidence, 0)) AS 'NumTransferID'
             , ISNULL(@UserCreatedIncidence, 'N/A')         AS 'UserIncidence'
             , CONCAT(@GuideSerie, @GuideNumber)            AS 'Guide'
             , ISNULL(@NameStatusIncidence, 'N/A')          AS 'NameStatusIncidence';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT CAST(0 AS BIT)                    AS 'boolResult'
             , ERROR_MESSAGE()                   AS 'DescriptionResult'
             , CONVERT(BIGINT, 0)                AS 'NumTransferID'
             , CONCAT(@GuideSerie, @GuideNumber) AS 'Guide';
    END CATCH;

END;

