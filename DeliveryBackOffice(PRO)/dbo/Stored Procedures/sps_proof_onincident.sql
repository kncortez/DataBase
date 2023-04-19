
-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-09-08>
-- Description:	<Registrar incidente de entrega en sitio>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <2022-03-21>
-- Description:	< Verificar si ubicación  existe dentro de geocerca >
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Update date: <2022-08-19>
-- Description:	<registro de incidencias en servicios de entrega registra en su proceso un registro en la “cola de incidencias pendientes de validar“ relacionado a la prueba de entrega realizada.>
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Create date: <2022-10-19>
-- Description:	<devolución ingreso a cola de webhooks>
-- =============================================

CREATE PROCEDURE [dbo].[sps_proof_onincident]
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
    @PhoneNumber NVARCHAR(50),
    @IdIssue INT,
    @ImageIncident VARCHAR(300),
    @Latitude NVARCHAR(20),
    @Longitude NVARCHAR(20),
    @Accuracy NVARCHAR(20),
    @MaxDistance FLOAT = 7000 --Distancia en metros
AS
BEGIN
    -- control de inserciones para transacción
    DECLARE @RInserted INT;
    -- tabla temporal para actualizar registros encontrados
    DECLARE @Table AS TABLE
    (
        ID INT
    );
    -- control de inserción de imagen en tabla de fotografías
    DECLARE @ID_Photo INT;
    -- variables auxiliares para conversión de imagen de base64 a varbinary
    DECLARE @PhotoIncidentVB VARBINARY(MAX);

    -- Variables para verificar ubicación en geocerca
    DECLARE @FixedLatitude NVARCHAR(20) = @Latitude;
    DECLARE @FixedLongitude NVARCHAR(20) = @Longitude;
    DECLARE @IdIncidenceReviewOrigin AS INT;

    -- Control de confirmación de incidencia
    DECLARE @VPLatitude NVARCHAR(50);
    DECLARE @VPLongitude NVARCHAR(50);
    DECLARE @StatusOrderId TINYINT;
    DECLARE @IsValidDistance BIT;
    DECLARE @DateStatusOrder DATETIME;
    DECLARE @CatTypeConfirmationOfIncidenceId INT;
    DECLARE @ConfirmationOfIncidenceId INT;
    DECLARE @MessageReturn NVARCHAR(100) = N'';

    DECLARE @TokenLinkGeneration NVARCHAR(100) = N'';

    BEGIN TRY

        IF (
               RTRIM(LTRIM(ISNULL(@Latitude, ''))) <> ''
               AND RTRIM(LTRIM(ISNULL(@Longitude, ''))) <> ''
           )
        BEGIN
            DECLARE @TargetGeofence GEOMETRY;
            DECLARE @TargetGeofenceAsText NVARCHAR(MAX);

            DECLARE @TargetPoint GEOMETRY;
            DECLARE @TargetPointAsText NVARCHAR(MAX) = CONCAT('POINT (', @Longitude, ' ', @Latitude, ')');

            SET @TargetGeofenceAsText
                = (CONCAT(
                             'POLYGON ((',
                   (
                       SELECT STUFF(
                                       (
                                           SELECT ', '
                                                  + CONCAT(
                                                              CAST(P.PointLongitude AS DECIMAL(9, 6)),
                                                              ' ',
                                                              CAST(P.PointLatitude AS DECIMAL(9, 6))
                                                          )
                                           FROM [DeliveryBackOffice].[dbo].[Geofence] G WITH (NOLOCK)
                                               INNER JOIN [DeliveryBackOffice].[dbo].[GeofencePoint] GP WITH (NOLOCK)
                                                   ON G.IdGeofence = GP.IdGeofence
                                                      AND GP.RowStatus = 1
                                               INNER JOIN [DeliveryBackOffice].[dbo].[Point] P WITH (NOLOCK)
                                                   ON GP.IdPoint = P.IdPoint
                                                      AND P.RowStatus = 1
                                           WHERE G.RowStatus = 1
                                                 AND G.IdGeofence = 1 -- Geocerca de GT
                                           ORDER BY GP.GeofencePointOrder ASC
                                           FOR XML PATH(''), TYPE
                                       ).value('.', 'varchar(max)'),
                                       1,
                                       1,
                                       ''
                                   )
                   ),
                             '))'
                         )
                  );

            SET @TargetGeofence = geometry::STGeomFromText(@TargetGeofenceAsText, 0);

            SET @TargetPoint = geometry::STGeomFromText(@TargetPointAsText, 0);

            DECLARE @IsValidLocation BIT
                = CASE
                      WHEN @TargetPoint.STIntersection(@TargetGeofence).ToString() = 'GEOMETRYCOLLECTION EMPTY' THEN
                          0
                      ELSE
                          1
                  END;

            IF (@IsValidLocation = 0)
            BEGIN
                SET @FixedLatitude = NULL;
                SET @FixedLongitude = NULL;
            END;
        END;

    END TRY
    BEGIN CATCH
        PRINT 'ERROR IN GEOLOCATION';

        SET @FixedLatitude = NULL;
        SET @FixedLongitude = NULL;
    END CATCH;

    BEGIN TRANSACTION;

    BEGIN TRY

        -- convertir base64 a varbinary
        -- buscar registros de tabla de entregas
        INSERT INTO @Table
        SELECT da.ID
        FROM DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr WITH (NOLOCK)
                ON sr.ID = da.ID_Courier
        WHERE sr.Phone LIKE '%' + @PhoneNumber + '%'
              AND da.Guide_Serie = @GuideSerie
              AND da.Guide_Number = @GuideNumber
              AND CONVERT(VARCHAR, da.Date_Created, 23) = CONVERT(VARCHAR, GETDATE(), 23);

        -- insertar foto y guardar ID para actualizar tabla de entregas
        INSERT INTO DeliveryBackOffice.dbo.DeliveryProof
        (
            Guide_Serie,
            Guide_Number,
            Date_Photo,
            Path_Incident
        )
        VALUES
        (@GuideSerie, @GuideNumber, GETDATE(), @ImageIncident);
        SET @ID_Photo = SCOPE_IDENTITY();

        IF (@ID_Photo > 0)
        BEGIN

            SET @DateStatusOrder = GETDATE();

            -- Validación del rango de distancia entre el VP y Courier
            DECLARE @IncidenceIssue TABLE
            (
                IdIncidence INT
            );

            INSERT INTO @IncidenceIssue
            (
                [IdIncidence]
            )
            SELECT [CTI].[IdIncidenceType]
            FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH (NOLOCK)
            WHERE [CTI].[IsForcedIncidence] = 1
                  AND [CTI].[ServiceType] = 'DELIVERY' COLLATE Latin1_General_CI_AI
                  AND [CTI].[RowStatus] = 1;

            IF (@IdIssue NOT IN ( SELECT [IdIncidence] FROM @IncidenceIssue ))
            BEGIN

                -- Buscar ubicación del VP
                SELECT @VPLatitude = vpc.Latitude,
                       @VPLongitude = vpc.Longitude
                FROM DeliveryOrder do WITH (NOLOCK)
                    INNER JOIN VisitPointClient vpc WITH (NOLOCK)
                        ON vpc.CodeOfReference = (CASE
                                                      WHEN do.IsLastMileReturn = 1 THEN
                                                          do.Sender_ID
                                                      ELSE
                                                          do.Receiver_ID
                                                  END
                                                 )
                WHERE do.Guide_Serie = @GuideSerie
                      AND do.Guide_Number = @GuideNumber;

                -- Si tiene ubicación el VP
                IF (
                       RTRIM(LTRIM(ISNULL(@VPLatitude, ''))) <> ''
                       AND RTRIM(LTRIM(ISNULL(@VPLongitude, ''))) <> ''
                   )
                   AND
                   (
                       RTRIM(LTRIM(ISNULL(@Latitude, ''))) <> ''
                       AND RTRIM(LTRIM(ISNULL(@Longitude, ''))) <> ''
                   )
                BEGIN
                    -- Validar rango
                    IF ((geography::STPointFromText(CONCAT('POINT (', @VPLongitude, ' ', @VPLatitude, ')'), 4326).STDistance(geography::STPointFromText(
                                                                                                                                                           CONCAT(
                                                                                                                                                                     'POINT (',
                                                                                                                                                                     @Longitude,
                                                                                                                                                                     ' ',
                                                                                                                                                                     @Latitude,
                                                                                                                                                                     ')'
                                                                                                                                                                 ),
                                                                                                                                                           4326
                                                                                                                                                       )
                                                                                                                            )
                        ) <= @MaxDistance
                       )
                    BEGIN
                        SET @IsValidDistance = 1;
                        SET @StatusOrderId =
                        (
                            SELECT StatusOrderId
                            FROM StatusOrder
                            WHERE OrderDescription = 'Intento de entrega fallida'
                        );
                        SET @CatTypeConfirmationOfIncidenceId =
                        (
                            SELECT IdCatTypeConfirmationOfIncidence
                            FROM CatTypeConfirmationOfIncidence
                            WHERE [Name] = 'Visita Fallida'
                        );
                    END;
                    ELSE
                    BEGIN
                        SET @IsValidDistance = 0;
                        SET @StatusOrderId =
                        (
                            SELECT StatusOrderId
                            FROM StatusOrder
                            WHERE OrderDescription = 'Incidencia en ruta'
                        );
                        SET @CatTypeConfirmationOfIncidenceId =
                        (
                            SELECT IdCatTypeConfirmationOfIncidence
                            FROM CatTypeConfirmationOfIncidence
                            WHERE [Name] = 'Incidencia en Ruta'
                        );
                    END;
                END;
                ELSE
                BEGIN

                    --FDAPI-1374 <Oscar Morales 2023-02-16> 
                    --Validar por geocercas

                    --Se buscan las geocercas de acuerdo a la ubicación 
                    DECLARE @Geo TABLE
                    (
                        Id INT NOT NULL
                    );

                    INSERT INTO @Geo
                    SELECT g.IdGeofence
                    FROM DeliveryOrder do WITH (NOLOCK)
                        INNER JOIN Geofence g WITH (NOLOCK)
                            ON g.Deparment = (CASE
                                                  WHEN do.IsLastMileReturn = 1 THEN
                                                      do.Sender_Department
                                                  ELSE
                                                      do.Receiver_Department
                                              END
                                             )
                               AND g.Town = (CASE
                                                 WHEN do.IsLastMileReturn = 1 THEN
                                                     do.Sender_Town
                                                 ELSE
                                                     do.Receiver_Town
                                             END
                                            )
                               AND
                               (
                                   g.Zone = (CASE
                                                 WHEN do.IsLastMileReturn = 1 THEN
                                                     do.Sender_Zone
                                                 ELSE
                                                     do.Receiver_Zone
                                             END
                                            )
                                   OR
                                   (
                                       do.IsLastMileReturn = 0
                                       AND g.SettlementId = do.ReceiverIdSettlement
                                   )
                               )
                    WHERE do.Guide_Serie = @GuideSerie
                          AND do.Guide_Number = @GuideNumber
                          AND g.RowStatus = 1;

                    -- Variables para verificar ubicación en geocerca
                    DECLARE @TargetGeofence2 GEOMETRY;
                    DECLARE @TargetGeofenceAsText2 NVARCHAR(MAX);

                    DECLARE @TargetPoint2 GEOMETRY;
                    DECLARE @TargetPointAsText2 NVARCHAR(MAX) = CONCAT('POINT (', @Longitude, ' ', @Latitude, ')');

                    DECLARE @IsValidLocation2 BIT = 0;
                    DECLARE @GeofenceId INT;

                    WHILE EXISTS (SELECT TOP 1 1 FROM @Geo)
                    BEGIN
                        SET @GeofenceId =
                        (
                            SELECT TOP 1 Id FROM @Geo
                        );

                        SET @TargetGeofenceAsText2
                            = (CONCAT(
                                         'POLYGON ((',
                               (
                                   SELECT STUFF(
                                                   (
                                                       SELECT ', '
                                                              + CONCAT(
                                                                          CAST(P.PointLongitude AS DECIMAL(9, 6)),
                                                                          ' ',
                                                                          CAST(P.PointLatitude AS DECIMAL(9, 6))
                                                                      )
                                                       FROM [DeliveryBackOffice].[dbo].[Geofence] G WITH (NOLOCK)
                                                           INNER JOIN [DeliveryBackOffice].[dbo].[GeofencePoint] GP WITH (NOLOCK)
                                                               ON G.IdGeofence = GP.IdGeofence
                                                                  AND GP.RowStatus = 1
                                                           INNER JOIN [DeliveryBackOffice].[dbo].[Point] P WITH (NOLOCK)
                                                               ON GP.IdPoint = P.IdPoint
                                                                  AND P.RowStatus = 1
                                                       WHERE G.RowStatus = 1
                                                             AND G.IdGeofence = @GeofenceId
                                                       ORDER BY GP.GeofencePointOrder ASC
                                                       FOR XML PATH(''), TYPE
                                                   ).value('.', 'varchar(max)'),
                                                   1,
                                                   1,
                                                   ''
                                               )
                               ),
                                         '))'
                                     )
                              );

                        SET @TargetGeofence2 = geometry::STGeomFromText(@TargetGeofenceAsText2, 0);
                        SET @TargetPoint2 = geometry::STGeomFromText(@TargetPointAsText2, 0);

                        IF @TargetPoint2.STIntersection(@TargetGeofence2).ToString() <> 'GEOMETRYCOLLECTION EMPTY'
                        BEGIN
                            SET @IsValidLocation2 = 1;
                            BREAK;
                        END;

                        DELETE FROM @Geo
                        WHERE Id = @GeofenceId;
                    END;

                    IF @IsValidLocation2 = 1
                    BEGIN
                        SET @IsValidDistance = 1;
                        SET @StatusOrderId =
                        (
                            SELECT StatusOrderId
                            FROM StatusOrder
                            WHERE OrderDescription = 'Intento de entrega fallida'
                        );
                        SET @CatTypeConfirmationOfIncidenceId =
                        (
                            SELECT IdCatTypeConfirmationOfIncidence
                            FROM CatTypeConfirmationOfIncidence
                            WHERE [Name] = 'Visita Fallida'
                        );
                    END;
                    ELSE
                    BEGIN
                        -- Si no se puede validar
                        SET @IsValidDistance = 0;
                        SET @StatusOrderId =
                        (
                            SELECT StatusOrderId
                            FROM StatusOrder
                            WHERE OrderDescription = 'Incidencia en ruta'
                        );
                        SET @CatTypeConfirmationOfIncidenceId =
                        (
                            SELECT IdCatTypeConfirmationOfIncidence
                            FROM CatTypeConfirmationOfIncidence
                            WHERE [Name] = 'Incidencia en Ruta'
                        );
                    END;
                END;

                IF @IsValidDistance = 0
                    SET @MessageReturn = N'Hemos detectado un comportamiento extraño y será investigado.';

                -- FIN FDAPI-1374 <Oscar Morales 2023-02-16> 

                INSERT INTO [dbo].[ConfirmationOfIncidence]
                (
                    [ConfirmationOfIncidentToken],
                    [CatTypeConfirmationOfIncidenceId],
                    [IsValid],
                    [IsConfirmed],
                    [StatusOrderId],
                    [DateStatusOrder],
                    [RowStatus],
                    [TokenCreated],
                    [DateCreated]
                )
                VALUES
                (CONCAT(@GuideSerie, @GuideNumber, ROUND(((99999 - 10000) * RAND() + 10000), 0)),
                 @CatTypeConfirmationOfIncidenceId, @IsValidDistance, 0, @StatusOrderId, @DateStatusOrder, 1,
                 'sps_proof_onincident', GETDATE());

                SET @ConfirmationOfIncidenceId = SCOPE_IDENTITY();

                SET @TokenLinkGeneration =
                (
                    SELECT ConfirmationOfIncidentToken
                    FROM [dbo].[ConfirmationOfIncidence]
                    WHERE IdConfirmationOfIncidence = @ConfirmationOfIncidenceId
                );

            END;
            ELSE
            BEGIN
                -- Forzar incidencia en ruta

                SET @StatusOrderId =
                (
                    SELECT StatusOrderId
                    FROM StatusOrder
                    WHERE OrderDescription = 'Incidencia en ruta'
                );
                SET @CatTypeConfirmationOfIncidenceId =
                (
                    SELECT IdCatTypeConfirmationOfIncidence
                    FROM CatTypeConfirmationOfIncidence
                    WHERE [Name] = 'Incidencia en Ruta'
                );

                SET @ConfirmationOfIncidenceId = NULL;
                SET @TokenLinkGeneration = N'';
            END;

            -- actualizar tabla de entregas
            UPDATE DeliveryBackOffice.dbo.DeliveryAttempt
            SET ID_Incident = @IdIssue,
                ID_Proof = @ID_Photo,
                Latitude = @FixedLatitude,
                Longitude = @FixedLongitude,
                LogLatitude = IIF(@Latitude = @FixedLatitude, NULL, @Latitude),
                LogLongitude = IIF(@Longitude = @FixedLongitude, NULL, @Longitude),
                Accuracy = @Accuracy,
                ConfirmationOfIncidenceId = @ConfirmationOfIncidenceId
            WHERE ID IN
                  (
                      SELECT ID FROM @Table
                  );

            -- actualizar tabla de registro de guías electrónicas
            UPDATE DeliveryBackOffice.dbo.DeliveryOrder
            SET StatusOrderId = @StatusOrderId
            WHERE Guide_Serie = @GuideSerie
                  AND Guide_Number = @GuideNumber;

            --- Actualizar el estado de las piezas
            UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece]
            SET StatusOrderId = @StatusOrderId
            WHERE GuideSerie = @GuideSerie
                  AND GuideNumber = @GuideNumber;

            -- registrar estado en tabla de checkpoints
            INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
            (
                Guide_Serie,
                Guide_Number,
                StatusOrderId,
                UserCreated,
                DateCreated,
                DateCreatedInSystem,
                Observations,
                Temperature_Celsius
            )
            VALUES
            (@GuideSerie, @GuideNumber, @StatusOrderId, 'sps_proof_onincident', @DateStatusOrder, @DateStatusOrder,
             NULL, NULL);
            SET @RInserted = @@ROWCOUNT;

            -----------------WEBHOOK.INI-----------------------		
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

                SET @WebhookCustomerId = ISNULL(
                                         (
                                             SELECT TOP 1
                                                    DO.IdCustomer
                                             FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                                             WHERE DO.Guide_Number = @GuideNumber
                                                   AND DO.Guide_Serie = @GuideSerie
                                         ),
                                         -1
                                               );
                SET @CustomerEndpointId = ISNULL(
                                          (
                                              SELECT TOP 1
                                                     WE.IdWebhookEndpoint
                                              FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH (NOLOCK)
                                              WHERE WE.CustomerId = @WebhookCustomerId
                                                    AND WE.WebhookTypeId = @GuideStatusChangeWebhook
                                          ),
                                          -1
                                                );

                SET @GuideCurrentStatus =
                (
                    SELECT TOP 1
                           DO.StatusOrderId
                    FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                    WHERE DO.Guide_Number = @GuideNumber
                          AND DO.Guide_Serie = @GuideSerie
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
                    (@GuideSerie, @GuideNumber, @WebhookCustomerId, @GuideCurrentStatus, @CustomerEndpointId, 0,
                     'sps_proof_onincident', GETDATE());

                END;

            END TRY
            BEGIN CATCH

            END CATCH;
        -------------------WEBHOOK.FIN------------------------------


        END;

    END TRY
    BEGIN CATCH
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide',
               @MessageReturn 'MessageReturn',
               @TokenLinkGeneration 'TokenLinkGeneration';
        ROLLBACK TRANSACTION;
    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        IF (@RInserted > 0)
            SELECT 1 AS 'StatusCode',
                   'Registro guardado correctamente' AS 'Description',
                   CONVERT(BIGINT, @@TRANCOUNT) AS 'NumTransferID',
                   @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide',
                   @MessageReturn 'MessageReturn',
                   @TokenLinkGeneration 'TokenLinkGeneration';
        ELSE
            SELECT 0 AS 'StatusCode',
                   'Registro no encontrado' AS 'Description',
                   CONVERT(BIGINT, 0) AS 'NumTransferID',
                   @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide',
                   @MessageReturn 'MessageReturn',
                   @TokenLinkGeneration 'TokenLinkGeneration';

        COMMIT TRANSACTION;
    END;
    ELSE
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide',
               @MessageReturn 'MessageReturn',
               @TokenLinkGeneration 'TokenLinkGeneration';
END;
