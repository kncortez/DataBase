
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-09-02>
-- Description:	< Registrar prueba de entrega en sitio para Fresh Delivery >
-- =============================================
CREATE PROCEDURE [dbo].[SetExternalDelivery]
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
    @CODPayment DECIMAL(12, 2) = 0,
    @CODCurrency NVARCHAR(5) = 'GTQ',
    @Latitude NVARCHAR(20),
    @Longitude NVARCHAR(20),
    @Accuracy NVARCHAR(20),
    @Token VARCHAR(50) = NULL, -- cideapp
	@DeliveryContent TblServiceRoutesContent READONLY
AS
BEGIN

    -- Variables de control de flujo
	DECLARE @IsProcessSuccessful BIT = 0;
    DECLARE @DeliveryProofProcess AS TABLE
    (
        IdDeliveryProofProcess INT
    );
    DECLARE @DeliveryAttemptProcess AS TABLE
    (
        IdDeliveryAttemptProcess INT,
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		CourierId INT,
		INDEX INDX_DeliveryAttemptProcess_Guide NONCLUSTERED(GuideSerie, GuideNumber)
    );

    -- Variables de origen de datos
    DECLARE @DataOriginId INT = ( SELECT TOP 1 CM.ModIdModule FROM DeliveryBackOffice.dbo.CatModule CM WITH(NOLOCK) WHERE CM.ModName = 'Fresh Delivery App' AND CM.ModRowStatus = 1 );

	-- Validación de geocerca
    -- Variables para verificar ubicación en geocerca
    DECLARE @FixedLatitude NVARCHAR(20) = @Latitude;
    DECLARE @FixedLongitude NVARCHAR(20) = @Longitude;

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
                                           FROM [DeliveryBackOffice].[dbo].[Geofence] G WITH(NOLOCK)
                                               JOIN [DeliveryBackOffice].[dbo].[GeofencePoint] GP WITH(NOLOCK)
                                                   ON G.IdGeofence = GP.IdGeofence
                                                      AND GP.RowStatus = 1
                                               JOIN [DeliveryBackOffice].[dbo].[Point] P WITH(NOLOCK)
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
	-- Fin de validación de geocerca

    BEGIN TRANSACTION SetExternalDeliveryTransaction;
    BEGIN TRY
	
        -- Buscar último delivery attempt del día
        INSERT INTO 
			@DeliveryAttemptProcess
			(IdDeliveryAttemptProcess, CourierId, GuideSerie, GuideNumber)
        SELECT 
			DA.ID,
			DA.ID_Courier,
			@GuideSerie,
			@GuideNumber
        FROM 
			DeliveryBackOffice.dbo.DeliveryAttempt DA WITH(NOLOCK)
        WHERE 
			DA.Guide_Serie = @GuideSerie
            AND 
			DA.Guide_Number = @GuideNumber
            AND 
			CONVERT(VARCHAR, DA.Date_Created, 23) = CONVERT(VARCHAR, GETDATE(), 23)
		ORDER BY	
			DA.Date_Created DESC,
			DA.ID DESC

        -- Ingresar dato de delivery proof
        INSERT INTO DeliveryBackOffice.dbo.DeliveryProof
        (
            Guide_Serie,
            Guide_Number,
            Date_Photo
        )
		OUTPUT inserted.ID INTO @DeliveryProofProcess(IdDeliveryProofProcess)
        VALUES
			(@GuideSerie, @GuideNumber, GETDATE());

        IF ( EXISTS (SELECT TOP 1 1 FROM @DeliveryProofProcess) )
        BEGIN

            -- Actualizar entrega
            UPDATE 
				DeliveryBackOffice.dbo.DeliveryAttempt
            SET 
				Delivered = 1,
                ID_Proof = (SELECT TOP 1 DPP.IdDeliveryProofProcess FROM @DeliveryProofProcess DPP),
                Latitude = @FixedLatitude,
                Longitude = @FixedLongitude,
                LogLatitude = IIF(@Latitude = @FixedLatitude, NULL, @Latitude),
                LogLongitude = IIF(@Longitude = @FixedLongitude, NULL, @Longitude),
                Accuracy = @Accuracy
			FROM
				DeliveryBackOffice.dbo.DeliveryAttempt DA WITH(NOLOCK)
				INNER JOIN
					@DeliveryAttemptProcess DAP
					ON
						DA.ID = DAP.IdDeliveryAttemptProcess

			-- Estado actual de la guía
            DECLARE @StatusId INT = ( SELECT TOP 1 DO.StatusOrderId FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK) WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber );

            IF (@StatusId NOT IN ( 5, 22 )) -- estado etregado
            BEGIN

				DECLARE @UpdatesDone AS TABLE (
					IdUpdate INT
				);

                -- Actualizar delivery order con datos
                UPDATE 
					DeliveryBackOffice.dbo.DeliveryOrder
                SET 
					NameOfReceiver = LTRIM(RTRIM(CONCAT(Receiver_FirstName, ' ', Receiver_LastName))),
                    StatusOrderId = 5,
                    LastCollectOnDelivery = Collect_OnDelivery,
                    Collect_OnDelivery = @CODPayment -- Es posible que el monto de COD pagado no sea igual al inicial debido a cambios durante la venta/entrega de contenido
				OUTPUT inserted.Guide_Number INTO @UpdatesDone(IdUpdate)
                WHERE 
					Guide_Serie = @GuideSerie
                    AND 
					Guide_Number = @GuideNumber;

                -- registrar estado en tabla de checkpoints
                INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
                (
                    Guide_Serie,
                    Guide_Number,
                    StatusOrderId,
                    UserCreated,
                    DateCreated,
                    DateCreatedInSystem
                )
				OUTPUT inserted.Guide_Number INTO @UpdatesDone(IdUpdate)
                VALUES
                (
					@GuideSerie
					,@GuideNumber
					,5
					,@Token
					,GETDATE()
					,GETDATE()
				);

				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderContentDelivered
					(GuideSerie, GuideNumber, ContentCode, ContentDescription, ContentPrice, DateCreated, TokenCreated)
				OUTPUT inserted.GuideNumber INTO @UpdatesDone(IdUpdate)
				SELECT
					@GuideSerie, @GuideNumber, DC.Code, DC.[Description], DC.Price, GETDATE(), @Token
				FROM
					@DeliveryContent DC

				IF ( (SELECT COUNT(1) FROM @UpdatesDone ) >= 3 )
				BEGIN
					SET @IsProcessSuccessful = 1;
				END

                -- ********************************** PROCESO DE COD ********************************************************************************
				BEGIN TRANSACTION SetExternalDeliveryCODTrans
				BEGIN TRY

					INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD
					(
						GuideSerie, GuideNumber, CourierManId, DataOriginId, Token, CustomerId
					)
					SELECT ord.Guide_Serie AS 'GuideSerie',
						   ord.Guide_Number AS 'GuideNumber',
						   DAP.CourierId AS 'CourierManId',
						   @DataOriginId AS 'DataOriginId',
						   @Token AS 'Token',
						   cus.IdCustomer
					FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH(NOLOCK)
						LEFT JOIN dbo.VisitPointClient vp WITH(NOLOCK)
							ON vp.CodeOfReference = ord.Sender_ID
						LEFT JOIN dbo.Customer cus WITH(NOLOCK)
							ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
						LEFT JOIN @DeliveryAttemptProcess DAP
							ON
								ord.Guide_Serie = DAP.GuideSerie
								AND
								ord.Guide_Number = DAP.GuideNumber
					WHERE Guide_Serie = @GuideSerie
						  AND Guide_Number = @GuideNumber
						  AND Collect_OnDelivery > 0
						  AND StatusOrderId = 5
					UNION
					SELECT ord.Guide_Serie AS 'GuideSerie',
						   ord.Guide_Number AS 'GuideNumber',
						   DAP.CourierId AS 'CourierManId',
						   @DataOriginId AS 'DataOriginId',
						   @Token AS 'Token',
						   cus.IdCustomer
					FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH(NOLOCK)
						LEFT JOIN dbo.VisitPointClient vp WITH(NOLOCK)
							ON vp.CodeOfReference = ord.Sender_ID
						LEFT JOIN dbo.Customer cus WITH(NOLOCK)
							ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
						LEFT JOIN @DeliveryAttemptProcess DAP
							ON
								ord.Guide_Serie = DAP.GuideSerie
								AND
								ord.Guide_Number = DAP.GuideNumber
					WHERE Guide_Serie = @GuideSerie
						  AND Guide_Number = @GuideNumber
						  AND Collect_OnDelivery = 0
						  AND IsCollect = 'true'
						  AND StatusOrderId = 5
					UNION
					SELECT ord.Guide_Serie AS 'GuideSerie',
						   ord.Guide_Number AS 'GuideNumber',
						   DAP.CourierId AS 'CourierManId',
						   @DataOriginId AS 'DataOriginId',
						   @Token AS 'Token',
						   cus.IdCustomer
					FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH(NOLOCK)
						INNER JOIN dbo.DeliveryOrderPaymentDetail DOP WITH(NOLOCK)
							ON ord.Guide_Serie = DOP.GuideSerie
							   AND ord.Guide_Number = DOP.GuideNumber
						LEFT JOIN dbo.VisitPointClient vp WITH(NOLOCK)
							ON vp.CodeOfReference = ord.Sender_ID
						LEFT JOIN dbo.Customer cus WITH(NOLOCK)
							ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
						LEFT JOIN @DeliveryAttemptProcess DAP
							ON
								ord.Guide_Serie = DAP.GuideSerie
								AND
								ord.Guide_Number = DAP.GuideNumber
					WHERE Guide_Serie = @GuideSerie
						  AND Guide_Number = @GuideNumber
						  AND IsCollect = 'false'
						  AND DOP.TimePlaId = 2
						  AND StatusOrderId = 5;

					COMMIT TRANSACTION SetExternalDeliveryCODTrans;
				END TRY
				BEGIN CATCH
					ROLLBACK TRANSACTION SetExternalDeliveryCODTrans;

					INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
						(GuideSerie, GuideNumber, ErrorProcedure, ErrorNumber, ErrorLine, ErrorDescription, DateCreated, TokenCreated)
					VALUES
						(@GuideSerie, @GuideNumber, CAST(ERROR_PROCEDURE() AS VARCHAR(100)), ERROR_NUMBER(), ERROR_LINE(), CAST(ERROR_MESSAGE() AS VARCHAR(300)), GETDATE(), '')

				END CATCH
            -- ********************************** FIN PROCESO DE COD ********************************************************************************
            END;
        END;

        IF (@IsProcessSuccessful > 0)
		BEGIN
			COMMIT TRANSACTION SetExternalDeliveryTransaction;

            SELECT 
				CAST(1 AS BIT) AS 'boolResult',
                'Registro guardado correctamente' AS 'DescriptionResult',
                CONVERT(BIGINT, @@TRANCOUNT) AS 'NumTransferID',
                CONCAT(@GuideSerie, @GuideNumber) AS 'Guide';
		END
        ELSE
		BEGIN
			ROLLBACK TRANSACTION SetExternalDeliveryTransaction;

            SELECT 
				CAST(0 AS BIT) AS 'boolResult',
                'Registro no guardado' AS 'DescriptionResult',
                CONVERT(BIGINT, 0) AS 'NumTransferID',
                CONCAT(@GuideSerie, @GuideNumber) AS 'Guide';
		END

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION SetExternalDeliveryTransaction;

        SELECT 
			CAST(0 AS BIT) AS 'boolResult',
            ERROR_MESSAGE() AS 'DescriptionResult',
            CONVERT(BIGINT, 0) AS 'NumTransferID',
            CONCAT(@GuideSerie, @GuideNumber) AS 'Guide';

    END CATCH;

END;