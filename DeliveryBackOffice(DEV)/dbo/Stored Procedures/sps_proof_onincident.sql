/* =================================================
   SP:        [dbo].[sps_proof_onincident]
   Propósito: <Registrar incidente de entrega en sitio>
   Autor:     <Carlos Cano>
   Historia:  <>
   Fecha:     2020-09-08
============================================
=== CHANGELOG ================================
-- 2026-04-09 | Historia/épica: FDAPI-5867 | Autor: Mario Herrarte  |
-- 2025-12-11 | Historia/épica: FDAPI-4775 | Autor: Tito Garcia     |
-- 2025-11-20 | Historia/épica: FDAPI-5030 | Autor: Tito Garcia     |
-- 2024-07-23 | Historia/épica:            | Autor: Tito Garcia     |
-- 2022-10-19 | Historia/épica:            | Autor: Edelman Vasquez |
-- 2022-08-19 | Historia/épica:            | Autor: Edelman Vasquez |
-- 2022-03-21 | Historia/épica:            | Autor: Andres Ruiz     |
=========================================== */
CREATE PROCEDURE [dbo].[sps_proof_onincident]
    @GuideSerie NVARCHAR(2)
  , @GuideNumber INT
  , @PhoneNumber NVARCHAR(50)
  , @IdIssue INT
  , @ImageIncident VARCHAR(300)
  , @Latitude NVARCHAR(20)
  , @Longitude NVARCHAR(20)
  , @Accuracy NVARCHAR(20)
  , @MaxDistance FLOAT = 7000 --Distancia en metros
  , @CommentOnIncident NVARCHAR(200) = ''
  , @StationId INT = NULL
AS
BEGIN
    -- control de inserciones para transacción
    DECLARE @RInserted INT;
    -- tabla temporal para actualizar registros encontrados
    DECLARE @Table AS TABLE
    (
        ID INT
    );
    DECLARE @SystemOrigin INT = 3; --'CourierAPP'
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
    DECLARE @DateGlobal DATE = CONVERT(DATE, GETDATE());
    DECLARE @EmailNotificationMedium INT = 3; -- [CatNotificationMedium] -> 'Correo SMTP'
    DECLARE @NotificationType BIGINT = 1 -- [CatNotificationType] -> 'DailyGuideIncidenceToOrigin';
    DECLARE @TokenLinkGeneration NVARCHAR(100) = N'';
    DECLARE @factor DECIMAL(10,6)= CAST((2.00/24.00) AS DECIMAL(10,6));
    DECLARE @CurrentIncidentCount INT =
            (
                SELECT TOP 1
                       COUNT(DA.ID)
                FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt]                   DA WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                        ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
                WHERE DA.Guide_Serie = @GuideSerie
                    AND DA.Guide_Number = @GuideNumber
                    AND CONVERT(DATE, DA.Date_Created) = @DateGlobal
            );

    IF (ISNULL(@CurrentIncidentCount, 0) <= 0)
    BEGIN

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
                                 'POLYGON (('
                               , (
                                     SELECT STUFF(
                                                     (
                                                         SELECT ', '
                                                                + CONCAT(
                                                                            CAST(P.PointLongitude AS DECIMAL(9, 6))
                                                                          , ' '
                                                                          , CAST(P.PointLatitude AS DECIMAL(9, 6))
                                                                        )
                                                         FROM [DeliveryBackOffice].[dbo].[Geofence]                G WITH (NOLOCK)
                                                             INNER JOIN [DeliveryBackOffice].[dbo].[GeofencePoint] GP WITH (NOLOCK)
                                                                 ON G.IdGeofence = GP.IdGeofence                                                                   
                                                             INNER JOIN [DeliveryBackOffice].[dbo].[Point]         P WITH (NOLOCK)
                                                                 ON GP.IdPoint = P.IdPoint                                                                   
                                                         WHERE G.RowStatus = 1
                                                               AND G.IdGeofence = 1 -- Geocerca de GT
															    AND GP.RowStatus = 1
																 AND P.RowStatus = 1
                                                         ORDER BY GP.GeofencePointOrder ASC
                                                         FOR XML PATH(''), TYPE
                                                     ).value('.', 'varchar(max)')
                                                   , 1
                                                   , 1
                                                   , ''
                                                 )
                                 )
                               , '))'
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

            IF (NOT EXISTS
            (
                SELECT TOP 1
                       1
                FROM [dbo].[DeliveryAttempt] WITH (NOLOCK)
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber
                      AND Latitude = ''
                      AND Longitude = ''
            )
               )
            BEGIN
                -- registrar nuevo intento de entrega
                INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryAttempt]
                (
                    [Guide_Serie]
                  , [Guide_Number]
                  , [Dry]
                  , [Cold]
                  , [Latitude]
                  , [Longitude]
                  , [Delivered]
                  , [ID_Courier]
                  , [ID_DeliveryOrderBySettlement]
                  , [User_Created]
                  , [Date_Created]
                  , [Guide_Piece]
                )
                VALUES
                (@GuideSerie, @GuideNumber, (
                                                SELECT TOP 1
                                                       ISNULL(Dry, 0)
                                                FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] WITH (NOLOCK)
                                                WHERE Guide_Serie = @GuideSerie
                                                      AND Guide_Number = @GuideNumber
                                                ORDER BY Date_Created DESC
                                            ), (
                                                   SELECT TOP 1
                                                          ISNULL(Cold, 0)
                                                   FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] WITH (NOLOCK)
                                                   WHERE Guide_Serie = @GuideSerie
                                                         AND Guide_Number = @GuideNumber
                                                   ORDER BY Date_Created DESC
                                               ), @Latitude, @Longitude, 0
               , (
                     SELECT TOP 1
                            ID_Courier
                     FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] WITH (NOLOCK)
                     WHERE Guide_Serie = @GuideSerie
                           AND Guide_Number = @GuideNumber
                     ORDER BY Date_Created DESC
                 ), (
                        SELECT TOP 1
                               ID_DeliveryOrderBySettlement
                        FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] WITH (NOLOCK)
                        WHERE Guide_Serie = @GuideSerie
                              AND Guide_Number = @GuideNumber
                        ORDER BY Date_Created DESC
                    ), (
                           SELECT TOP 1
                                  User_Created
                           FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] WITH (NOLOCK)
                           WHERE Guide_Serie = @GuideSerie
                                 AND Guide_Number = @GuideNumber
                           ORDER BY Date_Created DESC
                       ), GETDATE(), 1);
            END;


            -- convertir base64 a varbinary
            -- buscar registros de tabla de entregas
            INSERT INTO @Table
            SELECT TOP 1
                   da.ID
            FROM DeliveryBackOffice.dbo.DeliveryAttempt                         da WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.SenderReceiver                sr WITH (NOLOCK)
                    ON sr.ID = da.ID_Courier
                LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiverLoginToken] SRLT WITH (NOLOCK)
                    ON [SRLT].[SenderReceiverId] = [sr].[ID]
            WHERE (
                      sr.Phone LIKE @PhoneNumber + '%'
                      OR [sr].[UniqueCode] = @PhoneNumber
                      OR [SRLT].[LoginToken] = @PhoneNumber
                  )
                  AND da.Guide_Serie = @GuideSerie
                  AND da.Guide_Number = @GuideNumber
                  AND CONVERT(VARCHAR, da.Date_Created, 23) = @DateGlobal
            ORDER BY da.Date_Created DESC;

            -- insertar foto y guardar ID para actualizar tabla de entregas
            INSERT INTO DeliveryBackOffice.dbo.DeliveryProof
            (
                Guide_Serie
              , Guide_Number
              , Date_Photo
              , Path_Incident
            )
            VALUES
            (@GuideSerie, @GuideNumber, GETDATE(), @ImageIncident);
            SET @ID_Photo = SCOPE_IDENTITY();

            IF (@ID_Photo > 0)
            BEGIN

                SET @DateStatusOrder = GETDATE();

                -- Verificar procesos de incidencia
                DECLARE @IsRouteIncidence BIT = 0;
                DECLARE @ValidateLocation BIT = 0;
                DECLARE @ConfirmationOfIncidenceProcess BIT = 0;
                DECLARE @NotifyOrigin BIT = 0;

                -- Revisar que procesos de incidencia proceden
                SELECT TOP (1)
                       @ValidateLocation               = [CTI].[ValidatesLocation]
                     , @IsRouteIncidence               = [CTI].[IsForcedIncidence]
                     , @ConfirmationOfIncidenceProcess = [CTI].[HasConfirmationProcess]
                     , @NotifyOrigin                   = [CTI].[NotifiesOrigin]
                FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH (NOLOCK)
                WHERE [CTI].[IdIncidenceType] = @IdIssue
                      AND [CTI].[RowStatus] = 1;

                -- Validación del rango de distancia entre el VP y Courier
                IF (ISNULL(@ValidateLocation, 0) = 1)
                BEGIN

                    -- Buscar ubicación del VP
                    SELECT @VPLatitude  = vpc.Latitude
                         , @VPLongitude = vpc.Longitude
                    FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH (NOLOCK)
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
                                                                                                                                                                         'POINT ('
                                                                                                                                                                       , @Longitude
                                                                                                                                                                       , ' '
                                                                                                                                                                       , @Latitude
                                                                                                                                                                       , ')'
                                                                                                                                                                     )
                                                                                                                                                             , 4326
                                                                                                                                                           )
                                                                                                                                )
                            ) <= @MaxDistance
                           )
                        BEGIN
                            SET @IsValidDistance = 1;
                            SET @StatusOrderId = 45; --'Incidencia en ruta'
                            SET @CatTypeConfirmationOfIncidenceId = 2; --'Visita Fallida'
                        END;
                        ELSE
                        BEGIN
                            SET @IsValidDistance = 0;
                            SET @StatusOrderId = 45;
                            SET @CatTypeConfirmationOfIncidenceId = 1; --'Incidencia en Ruta'
                         END;
                    END;
                    ELSE
                    BEGIN

                        --Validar por geocercas
                        --Se buscan las geocercas de acuerdo a la ubicación 
                        DECLARE @Geo TABLE
                        (
                            Id INT NOT NULL
                        );

                        INSERT INTO @Geo
                        SELECT g.IdGeofence
                        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH (NOLOCK)
                            INNER JOIN [DeliveryBackOffice].[dbo].[Geofence] g WITH (NOLOCK)
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
                                             'POLYGON (('
                                           , (
                                                 SELECT STUFF(
                                                                 (
                                                                     SELECT ', '
                                                                            + CONCAT(
                                                                                        CAST(P.PointLongitude AS DECIMAL(9, 6))
                                                                                      , ' '
                                                                                      , CAST(P.PointLatitude AS DECIMAL(9, 6))
                                                                                    )
                                                                     FROM [DeliveryBackOffice].[dbo].[Geofence]                G WITH (NOLOCK)
                                                                         INNER JOIN [DeliveryBackOffice].[dbo].[GeofencePoint] GP WITH (NOLOCK)
                                                                             ON G.IdGeofence = GP.IdGeofence
                                                                                
                                                                         INNER JOIN [DeliveryBackOffice].[dbo].[Point]         P WITH (NOLOCK)
                                                                             ON GP.IdPoint = P.IdPoint
                                                                               
                                                                     WHERE G.RowStatus = 1
                                                                           AND G.IdGeofence = @GeofenceId
																		   AND GP.RowStatus = 1
																		    AND P.RowStatus = 1
                                                                     ORDER BY GP.GeofencePointOrder ASC
                                                                     FOR XML PATH(''), TYPE
                                                                 ).value('.', 'varchar(max)')
                                                               , 1
                                                               , 1
                                                               , ''
                                                             )
                                             )
                                           , '))'
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
                            SET @StatusOrderId = 45;
                            SET @CatTypeConfirmationOfIncidenceId = 2;
                        END;
                        ELSE
                        BEGIN
                            -- Si no se puede validar
                            SET @IsValidDistance = 0;
                            SET @StatusOrderId = 45;
                            SET @CatTypeConfirmationOfIncidenceId = 1;
                        END;
                    END;

                    IF @IsValidDistance = 0
                        SET @MessageReturn = N'Hemos detectado un comportamiento extraño y será investigado.';

                -- FIN FDAPI-1374 <Oscar Morales 2023-02-16> 

                END;
                ELSE
                BEGIN

                    -- Verificar si es incidencia en ruta o intento de entrega fallido por defecto
                    IF (ISNULL(@IsRouteIncidence, 0) = 1)
                    BEGIN

                        -- Incidencia en ruta
                        SET @StatusOrderId = 45;
                        SET @CatTypeConfirmationOfIncidenceId = 1;

                        SET @ConfirmationOfIncidenceId = NULL;
                        SET @TokenLinkGeneration = N'';

                    END;
                    ELSE
                    BEGIN

                        -- Intento de entrega fallido
                        SET @StatusOrderId = 45;
                        SET @CatTypeConfirmationOfIncidenceId = 2;

                        SET @ConfirmationOfIncidenceId = NULL;
                        SET @TokenLinkGeneration = N'';

                    END;
                END;

                -- Generar proceso de token de incidencia
                IF (ISNULL(@ConfirmationOfIncidenceProcess, 0) = 1)
                BEGIN

                    -- debe procesar confirmación de la incidencia
                    INSERT INTO [dbo].[ConfirmationOfIncidence]
                    (
                        [ConfirmationOfIncidentToken]
                      , [CatTypeConfirmationOfIncidenceId]
                      , [IsValid]
                      , [IsConfirmed]
                      , [StatusOrderId]
                      , [DateStatusOrder]
                      , [RowStatus]
                      , [TokenCreated]
                      , [DateCreated]
                      , [CommentOnIncident]
                    )
                    VALUES
                    (CONCAT(@GuideSerie, @GuideNumber, ROUND(((99999 - 10000) * RAND() + 10000), 0))
                   , @CatTypeConfirmationOfIncidenceId, ISNULL(@IsValidDistance, 0), 0, @StatusOrderId
                   , @DateStatusOrder, 1, 'sps_proof_onincident', GETDATE(), @CommentOnIncident);

                    SET @ConfirmationOfIncidenceId = SCOPE_IDENTITY();

                    SET @TokenLinkGeneration =
                    (
                        SELECT ConfirmationOfIncidentToken
                        FROM [dbo].[ConfirmationOfIncidence]  WITH (NOLOCK)
                        WHERE IdConfirmationOfIncidence = @ConfirmationOfIncidenceId
                    );

                END;

                -- Generar proceso de notificación a remitente
                IF (ISNULL(@NotifyOrigin, 0) = 1)
                BEGIN

                    -- Debe procesar notificación por correo a remitente
                    -- Obtener datos de destino de notificación
                    DECLARE @NotificationCustomerId INT;
                    DECLARE @NotificationEmail NVARCHAR(200);

                    -- Datos para notificación por correo
                    SELECT TOP (1)
                           @NotificationEmail      = (CASE
                                                          WHEN LTRIM(RTRIM(ISNULL([DO].[Sender_Mail], ''))) <> '' THEN
                                                              [DO].[Sender_Mail]
                                                          WHEN LTRIM(RTRIM(ISNULL([Cu].[CODContactEmail], ''))) <> '' THEN
                                                              [Cu].[CODContactEmail]
                                                      END
                                                     )
                         , @NotificationCustomerId = [DO].[IdCustomer]
                    FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]     DO WITH (NOLOCK)
                        LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] Cu WITH (NOLOCK)
                            ON [Cu].[IdCustomer] = [DO].[IdCustomer]
                    WHERE [DO].[Guide_Serie] = @GuideSerie
                          AND [DO].[Guide_Number] = @GuideNumber;

                    -- Notificación activa para destino de notificación y tipo de notificación
                    DECLARE @NotificationQueueId BIGINT =
                            (
                                SELECT TOP (1)
                                       [NQ].[IdNotificationQueue]
                                FROM [DeliveryBackOffice].[dbo].[NotificationQueue] NQ WITH (NOLOCK)
                                WHERE [NQ].[CustomerId] = @NotificationCustomerId
                                      AND [NQ].[CatNotificationTypeId] = @NotificationType
                                      AND [NQ].[CatNotificationMediumId] = @EmailNotificationMedium
                                      AND [NQ].[IsSent] = 0
                                      AND [NQ].[RowStatus] = 1
                                      AND [NQ].[DateToSend] = @DateGlobal
                                ORDER BY [NQ].[DateToSend] ASC
                            );

                    -- Revisar si existe notificación activa para el destino de notificación y tipo de notificación
                    IF (ISNULL(@NotificationQueueId, 0) > 0)
                    BEGIN
                        -- Existe un registro activo pendiente para adjuntar información

                        -- Revisar si la guía ya existe en detalle
                        IF (NOT EXISTS
                        (
                            SELECT TOP 1
                                   1
                            FROM [DeliveryBackOffice].[dbo].[NotificationQueueDetail] NQD WITH (NOLOCK)
                            WHERE [NQD].[NotificationQueueId] = @NotificationQueueId
                                  AND [NQD].[GuideSerie] = @GuideSerie
                                  AND [NQD].[GuideNumber] = @GuideNumber
                                  AND [NQD].[RowStatus] = 1
                        )
                           )
                        BEGIN

                            -- Adicionar guía a detalle de notificaciones si no existe
                            INSERT INTO [DeliveryBackOffice].[dbo].[NotificationQueueDetail]
                            (
                                [NotificationQueueId]
                              , [GuideSerie]
                              , [GuideNumber]
                              , [MembershipId]
                              , [SubscriptionId]
                              , [RowStatus]
                              , [TokenCreated]
                              , [DateCreated]
                              , [TokenUpdated]
                              , [DateUpdated]
                            )
                            VALUES
                            (   @NotificationQueueId    -- NotificationQueueId - bigint
                              , @GuideSerie             -- GuideSerie - nvarchar(10)
                              , @GuideNumber            -- GuideNumber - int
                              , NULL                    -- MembershipId - int
                              , NULL                    -- SubscriptionId - int
                              , 1                       -- RowStatus - bit
                              , N'sps_proof_onincident' -- TokenCreated - nvarchar(50)
                              , GETDATE()               -- DateCreated - datetime
                              , NULL                    -- TokenUpdated - nvarchar(50)
                              , NULL                    -- DateUpdated - datetime
                                );

                        END;

                    END;
                    ELSE
                    BEGIN

                        -- No existe registro activo pendiente, generar uno
                        DECLARE @NotificationOutput TABLE
                        (
                            NotificationQueueId BIGINT NULL
                        );

                        INSERT INTO [DeliveryBackOffice].[dbo].[NotificationQueue]
                        (
                            [CatNotificationMediumId]
                          , [CatNotificationTypeId]
                          , [CustomerId]
                          , [AccountId]
                          , [DestinationPhone]
                          , [DestinationEmail]
                          , [NotificationDate]
                          , [DateToSend]
                          , [IsSent]
                          , [RowStatus]
                          , [TokenCreated]
                          , [DateCreated]
                          , [TokenUpdated]
                          , [DateUpdated]
                        )
                        OUTPUT [Inserted].[IdNotificationQueue]
                        INTO @NotificationOutput
                        (
                            [NotificationQueueId]
                        )
                        VALUES
                        (   @EmailNotificationMedium -- CatNotificationMediumId - int
                          , @NotificationType        -- CatNotificationTypeId - bigint
                          , @NotificationCustomerId  -- CustomerId - int
                          , NULL                     -- AccountId - bigint
                          , NULL                     -- DestinationPhone - nvarchar(200)
                          , @NotificationEmail       -- DestinationEmail - nvarchar(200)
                          , GETDATE()                -- NotificationDate - date
                          , GETDATE()                -- DateToSend - date
                          , 0                        -- IsSent - bit
                          , 1                        -- RowStatus - bit
                          , N'sps_proof_onincident'  -- TokenCreated - nvarchar(50)
                          , GETDATE()                -- DateCreated - datetime
                          , NULL                     -- TokenUpdated - nvarchar(50)
                          , NULL                     -- DateUpdated - datetime
                            );

                        SET @NotificationQueueId =
                        (
                            SELECT TOP (1) [NotO].[NotificationQueueId] FROM @NotificationOutput NotO
                        );

                        INSERT INTO [DeliveryBackOffice].[dbo].[NotificationQueueDetail]
                        (
                            [NotificationQueueId]
                          , [GuideSerie]
                          , [GuideNumber]
                          , [MembershipId]
                          , [SubscriptionId]
                          , [RowStatus]
                          , [TokenCreated]
                          , [DateCreated]
                          , [TokenUpdated]
                          , [DateUpdated]
                        )
                        VALUES
                        (   @NotificationQueueId    -- NotificationQueueId - bigint
                          , @GuideSerie             -- GuideSerie - nvarchar(10)
                          , @GuideNumber            -- GuideNumber - int
                          , NULL                    -- MembershipId - int
                          , NULL                    -- SubscriptionId - int
                          , 1                       -- RowStatus - bit
                          , N'sps_proof_onincident' -- TokenCreated - nvarchar(50)
                          , GETDATE()               -- DateCreated - datetime
                          , NULL                    -- TokenUpdated - nvarchar(50)
                          , NULL                    -- DateUpdated - datetime
                            );

                    END;

                END;

                -- actualizar tabla de entregas
                IF (ISNULL(@IdIssue, 0) > 0)
                BEGIN
                    UPDATE DeliveryBackOffice.dbo.DeliveryAttempt
                    SET ID_Incident = @IdIssue
                      , ID_Proof = @ID_Photo
                      , Latitude = @FixedLatitude
                      , Longitude = @FixedLongitude
                      , LogLatitude = IIF(@Latitude = @FixedLatitude, NULL, @Latitude)
                      , LogLongitude = IIF(@Longitude = @FixedLongitude, NULL, @Longitude)
                      , Accuracy = @Accuracy
                      , ConfirmationOfIncidenceId = @ConfirmationOfIncidenceId
                    WHERE ID IN
                          (
                              SELECT ID FROM @Table
                          );

                END;
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

                -- Registro de Arribo a instalaciones si este aun no existe --
                INSERT INTO DeliveryOrderDetail
                    (
                     Guide_Serie,
                     Guide_Number,
                     StatusOrderId,
                     UserCreated,
                     DateCreated,
                     DateCreatedInSystem,
                     StationId
                    )
                SELECT 
                    @GuideSerie,
                    @GuideNumber,
                    11,
                    'sps_proof_onincident',
                    CASE
				        WHEN DODF.StatusOrderId IN (4,5,22) THEN
					        CASE 
					           WHEN CAST(DODF.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
							        THEN DATEADD(SECOND, -1, DODF.DateCreated)
					           WHEN CAST(DATEDIFF(DAY,DO.DateCreated,(DODF.DateCreatedInSystem)) AS INT) = 1
						           THEN CONVERT(NVARCHAR,DO.DateCreated + @factor,20)
					           ELSE CONVERT(NVARCHAR,(DO.DateCreated + DATEDIFF(DAY,DO.DateCreated,(DODF.DateCreatedInSystem))) - 1,20)
					        END
				        WHEN DODF.StatusOrderId IN (1,15) 
					        AND CAST(DODF.DateCreated AS DATE) = CAST(GETDATE() AS DATE) 
					        THEN 
						        DATEADD(SECOND, 1, DODF.DateCreated)
				        ELSE 
					        CASE 
					           WHEN CAST(DATEDIFF(DAY,DO.DateCreated,(GETDATE())) AS INT) = 1
						           THEN CONVERT(NVARCHAR,DO.DateCreated + @factor,20)
					           ELSE CONVERT(NVARCHAR,(DO.DateCreated + DATEDIFF(DAY,DO.DateCreated,(GETDATE()))) - 1,20)
					        END
				    END,
                    GETDATE(),
                    @StationId
                FROM (
				    SELECT
	    		        Guide_Serie,
	    		        Guide_Number,
	    		        CASE
	    			        WHEN DATEPART(MILLISECOND, DateCreated) >= 500
	    				        THEN DATEADD(SECOND, 1, DateCreated)
	    			        ELSE DATEADD(MILLISECOND, -DATEPART(MILLISECOND, DateCreated), DateCreated)
	    			        END DateCreated
				        FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
				        WHERE Guide_Serie = @GuideSerie
					        AND Guide_Number = @GuideNumber
				) DO
				OUTER APPLY (
				    SELECT TOP 1
				         D.DateCreatedInSystem
				        ,D.StatusOrderId
				        ,D.DateCreated
				    FROM DeliveryBackOffice.dbo.DeliveryOrderDetail D WITH(NOLOCK)
				    WHERE D.Guide_Serie = @GuideSerie
				      AND D.Guide_Number = @GuideNumber
				    ORDER BY 
				        CASE 
					        WHEN D.StatusOrderId IN (4,5,22) THEN 0
					        ELSE 1
				        END,
				        D.DateCreated ASC
				) DODF
				WHERE NOT EXISTS (
				    SELECT 1
				    FROM DeliveryOrderDetail DOD WITH(NOLOCK)
				    WHERE DOD.Guide_Serie = @GuideSerie
					    AND DOD.Guide_Number = @GuideNumber
					    AND DOD.StatusOrderId = 11
				);

                -- registrar estado en tabla de checkpoints
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
                  , [DeliveryAttemptId]
                  , [SystemOrigin]
                  , StationId
                )
                VALUES
                (@GuideSerie, @GuideNumber, @StatusOrderId, 'sps_proof_onincident', @DateStatusOrder, @DateStatusOrder
               , NULL, NULL, (
                                 SELECT TOP (1) [ID] FROM @Table ORDER BY [ID] DESC
                             ), @SystemOrigin, @StationId);
                SET @RInserted = @@ROWCOUNT;

                -----------------WEBHOOK.INI-----------------------		
                DECLARE @WebhookCustomerId INT = -1;
                DECLARE @CustomerEndpointId INT = -1;
                -- Debido a que se procesa únicamente 1 guía
                DECLARE @GuideCurrentStatus INT = -1;

                BEGIN TRY
                    DECLARE @GuideStatusChangeWebhook INT = 1; --'GuideStatusChange'

                    SET @WebhookCustomerId
                        = ISNULL((
                                     SELECT TOP 1
                                            DO.IdCustomer
                                     FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                                     WHERE DO.Guide_Serie = @GuideSerie
                                           AND DO.Guide_Number = @GuideNumber
                                 )
                               , -1
                                );
                    SET @CustomerEndpointId
                        = ISNULL((
                                     SELECT TOP 1
                                            WE.IdWebhookEndpoint
                                     FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH (NOLOCK)
                                     WHERE WE.CustomerId = @WebhookCustomerId
                                           AND WE.WebhookTypeId = @GuideStatusChangeWebhook
                                 )
                               , -1
                                );

                    SET @GuideCurrentStatus =
                    (
                        SELECT TOP 1
                               DO.StatusOrderId
                        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                        WHERE DO.Guide_Serie = @GuideSerie
                              AND DO.Guide_Number = @GuideNumber
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
                            [GuideSerie]
                          , [GuideNumber]
                          , [CustomerId]
                          , [StatusOrderId]
                          , [WebhookEndpointId]
                          , [HasNotified]
                          , [TokenCreated]
                          , [DateCreated]
                        )
                        OUTPUT inserted.IdWebhookTrackingQueue
                        INTO @ResponseTable
                        (
                            InsertedId
                        )
                        VALUES
                        (@GuideSerie, @GuideNumber, @WebhookCustomerId, @GuideCurrentStatus, @CustomerEndpointId, 0
                       , 'sps_proof_onincident', GETDATE());

                    END;

                END TRY
                BEGIN CATCH

                END CATCH;
            -------------------WEBHOOK.FIN------------------------------


            END;

        END TRY
        BEGIN CATCH
            SELECT 0                                           AS 'StatusCode'
                 , ERROR_MESSAGE()                             AS 'Description'
                 , CONVERT(BIGINT, 0)                          AS 'NumTransferID'
                 , @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'
                 , @MessageReturn                              'MessageReturn'
                 , @TokenLinkGeneration                        'TokenLinkGeneration';
            ROLLBACK TRANSACTION;
        END CATCH;

        IF @@TRANCOUNT > 0
        BEGIN

            IF (@RInserted > 0)
                SELECT 1                                           AS 'StatusCode'
                     , 'Registro guardado correctamente'           AS 'Description'
                     , CONVERT(BIGINT, @@TRANCOUNT)                AS 'NumTransferID'
                     , @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'
                     , @MessageReturn                              'MessageReturn'
                     , @TokenLinkGeneration                        'TokenLinkGeneration';
            ELSE
                SELECT 0                                           AS 'StatusCode'
                     , 'Registro no encontrado'                    AS 'Description'
                     , CONVERT(BIGINT, 0)                          AS 'NumTransferID'
                     , @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'
                     , @MessageReturn                              'MessageReturn'
                     , @TokenLinkGeneration                        'TokenLinkGeneration';

            COMMIT TRANSACTION;

            -- Proceso para autoconfirmar inciencias por temporada alta activada, ID's especificados en epica
            IF @IdIssue IN (82,135,196)
            BEGIN
                EXEC dbo.CreateIncidentRecord @GuideSerie = @GuideSerie                      -- nvarchar(2)
                                        , @GuideNumber = @GuideNumber                       -- int
                                        , @TokenCreated = 'SYS-AUTOSIGNED'                    -- nvarchar(200)
                                        , @IsRealIncident = 1                 -- bit
                                        , @IsServiceDesired = 1               -- bit
                                        , @IsAddressModificationRequested = 0 -- bit
                                        , @IsExpressCenterAddress = 0         -- bit
                                        , @IdExpressCenter = 0                   -- int
                                        , @NewAddress = N''                      -- nvarchar(600)
                                        , @NewPhoneNumber = N''                  -- nvarchar(100)
                                        , @DeliveryDateChange =0             -- bit
                                        , @NewDeliveryDate = '2024-12-04'        -- date
                                        , @Observations = N''                    -- nvarchar(600)
                                        , @LiquidatorRemarks = N'Incidencia autoconfirmada por temporada alta'               -- nvarchar(600)
                                        , @ValidGeolocationEvidence = 1       -- bit
                                        , @ValidPhotographicEvidence = 1      -- bit
                                        , @IdIncident = 0                        -- int
                                        , @ConfirmedTypeIncidenceId = 0          -- int
                                        , @CommentOnConfirmedTypeIncidence = N'' -- nvarchar(600)
                                        , @StationId = @StationId
            END;
        END;
        ELSE
            SELECT 0                                           AS 'StatusCode'
                 , ERROR_MESSAGE()                             AS 'Description'
                 , CONVERT(BIGINT, 0)                          AS 'NumTransferID'
                 , @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'
                 , @MessageReturn                              'MessageReturn'
                 , @TokenLinkGeneration                        'TokenLinkGeneration';
    END;
    ELSE
        SELECT 0                                                               AS 'StatusCode'
             , 'Excedió la cantidad disponible de incidencias durante el día.' AS 'Description'
             , CONVERT(BIGINT, @@TRANCOUNT)                                    AS 'NumTransferID'
             , @GuideSerie + CAST(@GuideNumber AS VARCHAR)                     AS 'Guide'
             , @MessageReturn                                                  'MessageReturn'
             , @TokenLinkGeneration                                            'TokenLinkGeneration';
END;
