

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

CREATE PROCEDURE [dbo].[sps_proof_onincident]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@PhoneNumber NVARCHAR(50),
	@IdIssue INT,
	--@PhotoIncidentB64 VARCHAR(MAX),
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

	-- Control de confirmación de incidencia
	DECLARE @VPLatitude NVARCHAR(50)
	DECLARE @VPLongitude NVARCHAR(50)
	DECLARE @StatusOrderId TINYINT
	DECLARE @IsValidDistance BIT
	DECLARE @DateStatusOrder DATETIME
	DECLARE @CatTypeConfirmationOfIncidenceId INT
	DECLARE @ConfirmationOfIncidenceId INT
	
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
                                           FROM [DeliveryBackOffice].[dbo].[Geofence] G
                                               INNER JOIN [DeliveryBackOffice].[dbo].[GeofencePoint] GP
                                                   ON G.IdGeofence = GP.IdGeofence
                                                      AND GP.RowStatus = 1
                                               INNER JOIN [DeliveryBackOffice].[dbo].[Point] P
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
        --SET @PhotoIncidentVB = (CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@PhotoIncidentB64"))', 'varbinary(max)'));

        -- buscar registros de tabla de entregas
        INSERT INTO @Table
        SELECT da.ID
        FROM DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr
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

			-- Validación del rango de distancia entre el VP y Courier

			-- Buscar ubicación del VP
			SELECT 
				@VPLatitude = vpc.Latitude
				,@VPLongitude = vpc.Longitude
			FROM DeliveryOrder do WITH (NOLOCK)
			INNER JOIN VisitPointClient vpc WITH (NOLOCK)
				ON vpc.CodeOfReference = (CASE WHEN do.IsLastMileReturn = 1 THEN do.Sender_ID ELSE do.Receiver_ID END)
			WHERE do.Guide_Serie = @GuideSerie
			AND do.Guide_Number = @GuideNumber

			-- Si tiene ubicación el VP
			IF (RTRIM(LTRIM(ISNULL(@VPLatitude, ''))) <> '' AND RTRIM(LTRIM(ISNULL(@VPLongitude, ''))) <> '')
				AND (RTRIM(LTRIM(ISNULL(@Latitude, ''))) <> '' AND RTRIM(LTRIM(ISNULL(@Longitude, ''))) <> '')
			BEGIN
				-- Validar rango
				IF ((GEOGRAPHY::STPointFromText (CONCAT('POINT (', @VPLongitude, ' ', @VPLatitude, ')'), 4326).STDistance(GEOGRAPHY::STPointFromText (CONCAT('POINT (', @Longitude, ' ', @Latitude, ')'), 4326)) ) <= @MaxDistance)
				BEGIN
					SET @IsValidDistance = 1
					SET @StatusOrderId = (SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription = 'Intento de entrega fallida')
					SET @CatTypeConfirmationOfIncidenceId = (SELECT IdCatTypeConfirmationOfIncidence FROM CatTypeConfirmationOfIncidence WHERE [Name] = 'Visita Fallida')
				END
				ELSE
				BEGIN
					SET @IsValidDistance = 0
					SET @StatusOrderId = (SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription = 'Incidencia en ruta')
					SET @CatTypeConfirmationOfIncidenceId = (SELECT IdCatTypeConfirmationOfIncidence FROM CatTypeConfirmationOfIncidence WHERE [Name] = 'Incidencia en Ruta')
				END
			END
			ELSE
			BEGIN
				-- Si no se puede validar
				--SET @IsValidDistance = 0
				--SET @StatusOrderId = (SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription = 'Incidencia en ruta')
				--SET @CatTypeConfirmationOfIncidenceId = (SELECT IdCatTypeConfirmationOfIncidence FROM CatTypeConfirmationOfIncidence WHERE [Name] = 'Incidencia en Ruta')
				-- de momento si no se puede validar se toma como intento de entrega fallida**
				SET @IsValidDistance = 1
				SET @StatusOrderId = (SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription = 'Intento de entrega fallida')
				SET @CatTypeConfirmationOfIncidenceId = (SELECT IdCatTypeConfirmationOfIncidence FROM CatTypeConfirmationOfIncidence WHERE [Name] = 'Visita Fallida')
			END

			SET @DateStatusOrder = GETDATE()

			INSERT INTO [dbo].[ConfirmationOfIncidence] ([ConfirmationOfIncidentToken]
			, [CatTypeConfirmationOfIncidenceId]
			, [IsValid]
			, [IsConfirmed]
			, [StatusOrderId]
			, [DateStatusOrder]
			, [RowStatus]
			, [TokenCreated]
			, [DateCreated])
				VALUES (CONCAT(@GuideSerie, @GuideNumber, ROUND(((99999 - 10000) * RAND() + 10000), 0)), @CatTypeConfirmationOfIncidenceId, @IsValidDistance, 0, @StatusOrderId, @DateStatusOrder, 1, 'sps_proof_onincident', GETDATE())
		
			SET @ConfirmationOfIncidenceId = SCOPE_IDENTITY()
				
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
            (@GuideSerie, @GuideNumber, @StatusOrderId, 'sps_proof_onincident', @DateStatusOrder, @DateStatusOrder, NULL, NULL);
            SET @RInserted = @@ROWCOUNT;

			

   -----------------WEBHOOK.INI-----------------------		
				DECLARE @WebhookCustomerId INT = -1;
				DECLARE @CustomerEndpointId INT = -1;
				-- Debido a que se procesa únicamente 1 guía
				DECLARE @GuideCurrentStatus INT = -1;

				BEGIN TRY
					DECLARE @GuideStatusChangeWebhook INT = (SELECT TOP 1 WT.IdWebhookType FROM [DeliveryBackOffice].[dbo].[WebhookType] WT WITH(NOLOCK) WHERE WT.WebhookName = 'GuideStatusChange' COLLATE Latin1_General_CI_AI AND WT.RowStatus = 1);

					SET @WebhookCustomerId = ISNULL((SELECT TOP 1 DO.IdCustomer FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Number = @GuideNumber AND DO.Guide_Serie = @GuideSerie),-1);
					SET @CustomerEndpointId = ISNULL((SELECT TOP 1 WE.IdWebhookEndpoint FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK) WHERE WE.CustomerId = @WebhookCustomerId AND  WE.WebhookTypeId = @GuideStatusChangeWebhook),-1);

					SET @GuideCurrentStatus = (SELECT TOP 1 DO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Number = @GuideNumber AND DO.Guide_Serie = @GuideSerie);

					-- Cliente tiene webhook configurado para el tipo especificado
					-- Estado actual de la guía coincide dentro de las restricciónes por usuario
					IF ( @WebhookCustomerId > 0 AND @CustomerEndpointId > 0 AND @GuideCurrentStatus IN (SELECT WRBU.StatusOrderId FROM [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH(NOLOCK) WHERE WRBU.CustomerId = @WebhookCustomerId AND WRBU.WebhookTypeId = @GuideStatusChangeWebhook) )
					BEGIN 

						DECLARE @ResponseTable AS TABLE (
							InsertedId BIGINT
						);

						INSERT INTO 
							[DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
							(
								[GuideSerie]
								,[GuideNumber]
								,[CustomerId]
								,[StatusOrderId]
								,[WebhookEndpointId]
								,[HasNotified]
								,[TokenCreated]
								,[DateCreated]
							)
						OUTPUT inserted.IdWebhookTrackingQueue INTO @ResponseTable (InsertedId)
						VALUES
							(
								@GuideSerie
								,@GuideNumber
								,@WebhookCustomerId
								,@GuideCurrentStatus
								,@CustomerEndpointId
								,0
								,'sps_proof_onincident'
								,GETDATE()
							)

					END

				END TRY
				BEGIN CATCH

				END CATCH
				-------------------WEBHOOK.FIN------------------------------

        END
		ELSE
		BEGIN
			INSERT INTO [dbo].[RoutePreparationLogError]
			(
			    [ErrorDescription],
			    [ErrorNumber],
			    [ErrorProcedure],
			    [ErrorLine],
			    [GuideSerie],
			    [GuideNumber],
			    [TokenCreated],
			    [DateCreated]
			)
			VALUES
			(   'no hay foto',     -- ErrorDescription - varchar(300)
			    409,     -- ErrorNumber - int
			    'sps_proof_onincident',     -- ErrorProcedure - varchar(100)
			    200,     -- ErrorLine - int
			    @GuideSerie,     -- GuideSerie - nvarchar(2)
			    @GuideNumber,     -- GuideNumber - int
			    'sps_proof_onincident',       -- TokenCreated - varchar(50)
			    GETDATE() -- DateCreated - datetime
			    )
		END

    END TRY
    BEGIN CATCH
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide';
        ROLLBACK TRANSACTION;

		INSERT INTO [dbo].[RoutePreparationLogError]
					   ([ErrorDescription]
					   ,[ErrorNumber]
					   ,[ErrorProcedure]
					   ,[ErrorLine]
					   ,[GuideSerie]
					   ,[GuideNumber]
					   ,[TokenCreated]
					   ,[DateCreated])
				 VALUES
					   (CAST(ERROR_MESSAGE() AS VARCHAR(300))
					   ,ERROR_NUMBER()
					   ,CAST(ERROR_PROCEDURE() AS VARCHAR(100))
					   ,ERROR_LINE()
					   ,@GuideSerie
					   ,@GuideNumber
					   ,'sps_proof_onincident'
					   ,GETDATE())
    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        IF (@RInserted > 0)
            SELECT 1 AS 'StatusCode',
                   'Registro guardado correctamente' AS 'Description',
                   CONVERT(BIGINT, @@TRANCOUNT) AS 'NumTransferID',
                   @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide';
        ELSE
            SELECT 0 AS 'StatusCode',
                   'Registro no encontrado' AS 'Description',
                   CONVERT(BIGINT, 0) AS 'NumTransferID',
                   @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide';

        COMMIT TRANSACTION;
    END;
    ELSE
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide';
END;
