
-- Author:		<Bidcar Herrera>
-- Create date: <2023-09-25>
-- Description:	< Registro de incidencia>
CREATE PROCEDURE [dbo].[CreateIncidentRecord]
    @GuideSerie NVARCHAR(2) = 'FD',       --serie
    @GuideNumber INT,                     --número de guía
    @TokenCreated NVARCHAR(200),          --token de guardado
    @IsRealIncident BIT,                  --cliente indica que la incidencia es real?
    @IsServiceDesired BIT,                --cliente aún desea recibir el servicio?
    @IsAddressModificationRequested BIT,  --Solicita cambio de dirección?
    @IsExpressCenterAddress BIT,          --Se cambia a dirección de express center?
    @IdExpressCenter INT,                 --Express Center al que cambia
    @NewAddress NVARCHAR(600),            --Nueva dirección si se solicita
    @NewPhoneNumber NVARCHAR(100),        --Cambio de teléfono si se solicita
    @DeliveryDateChange BIT,              --Cambiar fecha de entrega?
    @NewDeliveryDate DATETIME = NULL,     --Nueva fecha de entrega si se solicita,
    @Observations NVARCHAR(600),          --Observaciones tracking
    @LiquidatorRemarks NVARCHAR(600) = '' --Observaciones para el liquidador
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
                FROM [dbo].[DeliveryOrder] [DO] WITH (NOLOCK)
                    INNER JOIN [dbo].[StatusOrder] [SO] WITH (NOLOCK)
                        ON [DO].[StatusOrderId] = [SO].[StatusOrderId]
                WHERE [SO].[RowStatus] = 1
                      AND [DO].[Guide_Serie] = @GuideSerie
                      AND [DO].[Guide_Number] = @GuideNumber
            );

            DECLARE @UserCreatedIncidence NVARCHAR(250) =
	                  (		Select  Top 1  RU.UsrNickName 
								 From  [dbo].[DeliveryOrderDetail] ddd WITH (NOLOCK)
									  LEFT JOIN [dbo].[TokenLog] TL WITH(NOLOCK)
								 ON ddd.UserCreated = TL.TknTokenCreated
									  LEFT JOIN [dbo].[RegisterUser] RU WITH(NOLOCK)
								 ON TL.TknIdUser = RU.UsrIdUser
							Where ddd.Guide_Serie =  @GuideSerie
							AND ddd.Guide_Number =   @GuideNumber
							AND ddd.StatusOrderId = 50
							AND CONVERT(DATE, ddd.DateCreatedInSystem) =  CONVERT(DATE, GETDATE())
					 
						);

    DECLARE @StatusIncidence INT= (
							   Select Top 1 StatusOrderId 
							   From dbo.DeliveryOrderDetail DOD WITH(NOLOCK)
								where DOD.Guide_Number =  @GuideNumber AND 
									  CONVERT(DATE, DOD.DateCreatedInSystem) =  CONVERT(DATE, GETDATE())
								ORDER BY DOD.DateCreatedInSystem Desc
							);

    DECLARE @NameStatusIncidence NVARCHAR(250)= (
									   Select Top 1 SO.OrderDescription
									   From [dbo].[DeliveryOrderDetail] DOD WITH(NOLOCK)
											INNER JOIN [dbo].[StatusOrder] SO WITH(NOLOCK)
											ON DOD.StatusOrderId = SO.StatusOrderId
										where DOD.Guide_Number =  @GuideNumber AND 
											  CONVERT(DATE, DOD.DateCreatedInSystem) =  CONVERT(DATE, GETDATE())
										ORDER BY DOD.DateCreatedInSystem Desc
							);

    BEGIN TRY
        SET @StatusOrderId = @IncidenceStatusId;
        SET @CatTypeConfirmationOfIncidenceId = @CatTypeCOIIncidenceStatusId;

        IF (@Terminal != 3)
        BEGIN

            IF (@IsRealIncident = 0) --Si courier mintió?
            BEGIN

                UPDATE t1
                --[dbo].[ConfirmationOfIncidence]
                SET t1.[LastStatusOrderId] = [StatusOrderId],
                    t1.[IsDenied] = 1,
                    t1.[TokenUpdated] = @TokenCreated, --'SetServiceTokenGuideData',
                    t1.[DateUpdated] = SYSDATETIME()
                FROM dbo.ConfirmationOfIncidence t1 WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt A1 WITH (NOLOCK)
                        ON A1.ConfirmationOfIncidenceId = t1.IdConfirmationOfIncidence
                WHERE t1.RowStatus = 1
                      AND A1.Guide_Serie = @GuideSerie
                      AND A1.Guide_Number = @GuideNumber;

                UPDATE dop
                SET StatusOrderId = @StatusOrderId
                FROM DeliveryOrderPiece dop WITH (NOLOCK)
                    INNER JOIN DeliveryAttempt da WITH (NOLOCK)
                        ON dop.GuideSerie = da.Guide_Serie
                           AND dop.GuideNumber = da.Guide_Number
                    INNER JOIN ConfirmationOfIncidence coi WITH (NOLOCK)
                        ON da.ConfirmationOfIncidenceId = coi.IdConfirmationOfIncidence
                WHERE --coi.ConfirmationOfIncidentToken = @GuideToken
                    dop.GuideSerie = @GuideSerie
                    AND dop.GuideNumber = @GuideNumber
                    AND coi.RowStatus = 1;


            END;
            ELSE
            BEGIN

                /* Validar si la incidencia fue manual desde sistema hermes desktop y quitar intento disponible de entrega */
                IF (EXISTS
                (
                    SELECT TOP 1
                           1
                    FROM [dbo].[DeliveryAttempt] DA WITH (NOLOCK)
                        INNER JOIN [dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                            ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
                        INNER JOIN [dbo].[DeliveryOrderDetail] DOD WITH (NOLOCK)
                            ON DA.Guide_Serie = DOD.Guide_Serie
                               AND DA.Guide_Number = DOD.Guide_Number
                    WHERE DA.Guide_Serie = @GuideSerie
                          AND DA.Guide_Number = @GuideNumber
                          AND DOD.StatusOrderId = 45
                          AND DOD.SystemOrigin = 2
                )
                   )
                BEGIN

                    IF (NOT EXISTS
                    (
                        SELECT TOP 1
                               1
                        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData] DOAD WITH (NOLOCK)
                        WHERE DOAD.GuideNumber = @GuideNumber
                    )
                       )
                    BEGIN
                        -- Insertar data para manejo de inténtos de entrega/devolución
                        INSERT INTO [dbo].[DeliveryOrderAttemptData]
                        (
                            [GuideSerie],
                            [GuideNumber],
                            [GuideDeliveryAttemptCount],
                            [GuideDeliveryMaxAttemptCount],
                            [GuideReturnAttemptCount],
                            [GuideReturnMaxAttemptCount],
                            [RowStatus],
                            [DateCreated],
                            [TokenCreated]
                        )
                        SELECT TOP 1
                               do.Guide_Serie,
                               do.Guide_Number,
                               1,
                               rh.Attempt,
                               0,
                               rh.AttemptReturn,
                               1,
                               GETDATE(),
                               @TokenCreated
                        FROM DeliveryOrder do WITH (NOLOCK)
                            LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
                                ON do.Sender_ID = vpc.CodeOfReference
                            INNER JOIN RatebyCustomer rbc WITH (NOLOCK)
                                ON ISNULL(do.IdCustomer, vpc.CustomerID) = rbc.RbcIdCustomer
                                   AND rbc.RbcRowStatus = 1
                                   AND
                                   (
                                       rbc.RbcCodeOfReference = vpc.CodeOfReference
                                       OR rbc.RbcCodeOfReference IS NULL
                                   )
                            INNER JOIN RateHeader rh WITH (NOLOCK)
                                ON rbc.RbcIdRate = rh.RheId
                            INNER JOIN DeliveryAttempt da WITH (NOLOCK)
                                ON do.Guide_Serie = da.Guide_Serie
                                   AND do.Guide_Number = da.Guide_Number
                            LEFT JOIN ConfirmationOfIncidence coi WITH (NOLOCK)
                                ON da.ConfirmationOfIncidenceId = coi.IdConfirmationOfIncidence
                            LEFT JOIN StatusOrder so
                                ON coi.StatusOrderId = so.StatusOrderId
                        WHERE do.Guide_Serie = @GuideSerie
                              AND do.Guide_Number = @GuideNumber
                        ORDER BY rbc.RbcCodeOfReference DESC;
                    END;
                    ELSE
                    BEGIN

                        -- Incrementar intentos de entrega de guía respecto a flujo correspondiente

                        UPDATE [DOAD]
                        SET [DOAD].[GuideDeliveryAttemptCount] = [DOAD].[GuideDeliveryAttemptCount] + 1,
                            [DOAD].[TokenUpdated] = @TokenCreated,
                            [DOAD].[DateUptaded] = GETDATE()
                        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData] DOAD
                        WHERE [DOAD].[GuideSerie] = @GuideSerie
                              AND [DOAD].[GuideNumber] = @GuideNumber;



                    END;


                END;

            /*Fin*/

            END;

            UPDATE t1
            SET t1.IsConfirmed = 1,
                t1.StatusOrderId = @ValidatedIncidentStatus,                --Registro de incidencia validada--@StatusOrderId,
                t1.CatTypeConfirmationOfIncidenceId = @CatTypeConfirmationOfIncidenceId,
                                                                            --CatTypeConfirmationOfIncidenceId = @CatTypeConfirmationOfIncidenceId,
                t1.ActionObservation = @Observations,
                t1.ClientConfirmsReturn = IIF(@IsServiceDesired = 1, 0, 1), --@CancelOrder,
                t1.IncidentfinalizedbySAC = 1,                              --@CompletedBySAC,
                t1.TokenUpdated = @TokenCreated,                            --'SetServiceTokenGuideData',
                t1.DateUpdated = GETDATE(),
                CourierContempt = 0,                                        --quitar desacatos
                t1.LiquidatorRemarks = @LiquidatorRemarks
            FROM dbo.ConfirmationOfIncidence t1
                INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt A1 WITH (NOLOCK)
                    ON A1.ConfirmationOfIncidenceId = t1.IdConfirmationOfIncidence
            WHERE --ConfirmationOfIncidentToken = @GuideToken
                --AND 
                A1.Guide_Serie = @GuideSerie
                AND A1.Guide_Number = @GuideNumber
                AND RowStatus = 1;

            UPDATE do
            SET StatusOrderId = @ValidatedIncidentStatus
            FROM dbo.DeliveryOrder do
            WHERE do.Guide_Serie = @GuideSerie
                  AND do.Guide_Number = @GuideNumber;

            DECLARE @DeliveryAttemptId AS BIGINT = NULL;
            DECLARE @SytemOrigin AS INT = NULL;

            --Copiar la imagen de incidencia de ruta hacia incidencia validada
            SELECT TOP 1
                   @DeliveryAttemptId = DeliveryAttemptId,
                   @SytemOrigin = SystemOrigin
            FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH (NOLOCK)
            WHERE Guide_Serie = @GuideSerie
                  AND Guide_Number = @GuideNumber
                  AND RowStatus = 1
                  AND StatusOrderId = @IncidentStatus
            ORDER BY DateCreatedInSystem DESC;

            INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
            (
                Guide_Serie,
                Guide_Number,
                StatusOrderId,
                UserCreated,
                DateCreated,
                DateCreatedInSystem,
                Observations,
                Temperature_Celsius,
                PieceId,
                RowStatus,
                DeliveryAttemptId,
                SystemOrigin
            )
            VALUES
            (   @GuideSerie,              -- Guide_Serie - nvarchar(2)
                @GuideNumber,             -- Guide_Number - int
                @ValidatedIncidentStatus, -- StatusOrderId - tinyint
                @TokenCreated,            -- UserCreated - nvarchar(50)
                GETDATE(),                -- DateCreated - datetime
                GETDATE(),                -- DateCreatedInSystem - datetime
                @Observations,            -- Observations - nvarchar(200)
                NULL,                     -- Temperature_Celsius - decimal(5, 2)
                NULL,                     -- PieceId - int
                1,                        -- RowStatus - bit
                @DeliveryAttemptId,       -- DeliveryAttemptId - bigint
                @SytemOrigin              -- SystemOrigin - int
                );

            UPDATE dop
            SET StatusOrderId = @ValidatedIncidentStatus
            FROM dbo.DeliveryOrderPiece dop
            WHERE dop.GuideSerie = @GuideSerie
                  AND dop.GuideNumber = @GuideNumber;

            --IF (@CancelOrder = 1)
            --IF (@IsServiceDesired = 0)
            IF (ISNULL(@IsAddressModificationRequested, 0) = 1) --Solicita cambio de dirección
            BEGIN
                UPDATE [DO]
                SET [DO].[Receiver_Address] = IIF((LTRIM(RTRIM(ISNULL(@NewAddress, ''))) != ''),
                                                  @NewAddress,
                                                  [DO].[Receiver_Address]),
                    [DO].[Receiver_Phone] = IIF((LTRIM(RTRIM(ISNULL(@NewPhoneNumber, ''))) != ''),
                                                @NewPhoneNumber,
                                                ISNULL([DO].[Receiver_Phone], ''))
                FROM [dbo].[DeliveryOrder] [DO]
                    INNER JOIN [dbo].[DeliveryAttempt] DA WITH (NOLOCK)
                        ON [DO].[Guide_Serie] = [DA].[Guide_Serie]
                           AND [DO].[Guide_Number] = [DA].[Guide_Number]
                    INNER JOIN [dbo].[ConfirmationOfIncidence] COI
                        ON [DA].[ConfirmationOfIncidenceId] = [COI].[IdConfirmationOfIncidence]
                WHERE DA.Guide_Serie = @GuideSerie
                      AND DA.Guide_Number = @GuideNumber
                      --[COI].[ConfirmationOfIncidentToken] = @GuideToken
                      AND [COI].[RowStatus] = 1;
            END;

            IF (ISNULL(@DeliveryDateChange, 0) = 1)
            BEGIN
                SELECT @OriginRouteId = RP.CatRouteId
                FROM [DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.RoutePreparationDetail RPD WITH (NOLOCK)
                        ON RPD.Guide_Serie = @GuideSerie
                           AND RPD.Guide_Number = @GuideNumber
                           AND RPD.RowStatus = 1
                           AND RPD.RoutePreparationId = RP.IdRoutePreparation
                WHERE RP.RowStatus = 1;
                --RP.IdRoutePreparation = @RoutePreparationId;

                SELECT @DeliverySettlementId = ID_DeliveryOrderBySettlement
                FROM dbo.DeliverySettlementDetail WITH (NOLOCK)
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber
                      AND RowStatus = 1;

                SELECT @NewRoutePreparation = COALESCE(IdRoutePreparation, 0),
                       @NewRouteManifest = COALESCE(DeliveryOrderBySettlementId, 0)
                FROM [DeliveryBackOffice].[dbo].RoutePreparation RP WITH (NOLOCK)
                WHERE CatRouteId = @OriginRouteId
                      AND DateRoutePreparation = @NewDeliveryDate --@RescheduleDate
                      AND RowStatus = 1;

                IF (@NewRouteManifest = 0)
                BEGIN

                    IF (@NewRoutePreparation = 0)
                    BEGIN

                        --- Ingresar nueva preparación de ruta por reasignación 
                        INSERT INTO [dbo].[RoutePreparation]
                        (
                            [CatRouteId],
                            [DateRoutePreparation],
                            [GuidesQuantity],
                            [PiecesDry],
                            [PiecesCold],
                            [RowStatus],
                            [TokenCreated],
                            [DateCreated],
                            [TokenUpdated],
                            [DateUpdated]
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

                    END;

                    IF (
                           ISNULL(@NewRoutePreparation, 0) > 0
                           AND NOT EXISTS
                    (
                        SELECT TOP 1
                               1
                        FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH (NOLOCK)
                            INNER JOIN [DeliveryBackOffice].[dbo].RoutePreparation RP WITH (NOLOCK)
                                ON RPD.RoutePreparationId = RP.IdRoutePreparation
                                   AND RP.DateRoutePreparation = @NewDeliveryDate --@RescheduleDate
                        WHERE RPD.Guide_Serie = @GuideSerie
                              AND RPD.Guide_Number = @GuideNumber --@TokenGuideNumber
                              AND RPD.RowStatus = 1
                    )
                       )
                    BEGIN

                        INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationDetail]
                        (
                            [RoutePreparationId],
                            [Guide_Serie],
                            [Guide_Number],
                            [RowStatus],
                            [TokenCreated],
                            [DateCreated],
                            [TokenUpdated],
                            [DateUpdated],
                            [IsCustomerReschedule]
                        )
                        OUTPUT inserted.IdRoutePreparationDetail
                        INTO @InsertedRoutePreparationDetail
                        (
                            IdRoutePreparationDetail
                        )
                        VALUES
                        (@NewRoutePreparation, @GuideSerie, @GuideNumber, 1, @TokenCreated, GETDATE(), NULL, NULL, 1);

                        IF @@ROWCOUNT > 0
                        BEGIN
                            SET @UpdatedRP = 1;
                        END;

                    END;

                END;

                -- Extraer guía del manifiesto de despacho actual
                UPDATE DSD
                SET DSD.RowStatus = 0,
                    DSD.TokenUpdated = @TokenCreated, --'SYS-HERMESROUTESLanding',
                    DSD.DateUpdated = GETDATE()
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
                        ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement
                           AND DSD.Guide_Serie = @GuideSerie --@TokenGuideSerie
                           AND DSD.Guide_Number = @GuideNumber --@TokenGuideNumber
                WHERE DOBS.ID = @DeliverySettlementId;

                -- Extraer guía de la ruta de despacho actual
                UPDATE RPD
                SET RPD.RowStatus = 0,
                    RPD.TokenUpdated = @TokenCreated, --'SYS-HERMESROUTESLanding',
                    RPD.DateUpdated = GETDATE()
                FROM [DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH (NOLOCK)
                        ON RP.IdRoutePreparation = RPD.RoutePreparationId
                           AND RPD.Guide_Serie = @GuideSerie --@TokenGuideSerie
                           AND RPD.Guide_Number = @GuideNumber -- @TokenGuideNumber
                WHERE RP.IdRoutePreparation = @OriginRouteId; --@RoutePreparationId;

                -- Extraer piezas de guía de la ruta de despacho actual
                UPDATE RPDP
                SET RPDP.RowStatus = 0,
                    RPDP.TokenUpdated = @TokenCreated, --'SYS-HERMESROUTESLanding',
                    RPDP.DateUpdated = GETDATE()
                FROM [DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH (NOLOCK)
                        ON RP.IdRoutePreparation = RPD.RoutePreparationId
                           AND RPD.Guide_Serie = @GuideSerie --@TokenGuideSerie
                           AND RPD.Guide_Number = @GuideNumber --@TokenGuideNumber
                    INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP WITH (NOLOCK)
                        ON RPD.IdRoutePreparationDetail = RPDP.IdRoutePreparationDetailPiece
                WHERE RP.IdRoutePreparation = @OriginRouteId; --@RoutePreparationId;

            END;

            IF (@IsExpressCenterAddress = 1) --Modificar dirección a express center
            BEGIN
                DECLARE @NewDeliveryOptionID INT =
                        (
                            SELECT TOP 1
                                   CDO.IdDeliveryOption
                            FROM [DeliveryBackOffice].[dbo].[CatDeliveryOptions] CDO WITH (NOLOCK)
                            WHERE CDO.[Name] = 'Express Center' COLLATE Latin1_General_CI_AI
                        );

                UPDATE dbo.DeliveryOrder
                SET Receiver_ID = @IdExpressCenter,
                    IdDeliveryOption = @NewDeliveryOptionID,
                    Receiver_Address = (CASE
                                            WHEN LTRIM(RTRIM(ISNULL(@NewAddress, ''))) != '' THEN
                                                @NewAddress
                                            ELSE
                                                Receiver_Address
                                        END
                                       ),
                    TokenUpdated = @TokenCreated,
                    DateUpdated = GETDATE()
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber;

            END;
        END;
        COMMIT TRANSACTION;
             SELECT @Terminal  AS 'boolResult',
				CASE 
				    WHEN  @Terminal = 3  THEN 'No se posible confirmar la incidencia. Guía se encuentra en estado final.' 
					WHEN  @StatusIncidence = 50 THEN 'Incidencia ya fue confirmada por el usuario: ' + UPPER(ISNULL(@UserCreatedIncidence,'Control de Calidad'))
			        ELSE 'Incidencia confirmada Exitosamente.'
			   END
			   AS 'DescriptionResult',
               CONVERT(BIGINT, ISNULL(@StatusIncidence,0)) AS 'NumTransferID',
			  ISNULL(@UserCreatedIncidence,'N/A') AS 'UserIncidence',
               CONCAT(@GuideSerie, @GuideNumber) AS 'Guide',
			   ISNULL(@NameStatusIncidence,'N/A') AS 'NameStatusIncidence'

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT CAST(0 AS BIT) AS 'boolResult',
               ERROR_MESSAGE() AS 'DescriptionResult',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               CONCAT(@GuideSerie, @GuideNumber) AS 'Guide';
    END CATCH;

END;

