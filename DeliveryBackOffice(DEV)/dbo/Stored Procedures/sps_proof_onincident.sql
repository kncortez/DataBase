

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

CREATE PROCEDURE [dbo].[sps_proof_onincident]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@PhoneNumber NVARCHAR(50),
	@IdIssue INT,
	--@PhotoIncidentB64 VARCHAR(MAX),
	@ImageIncident VARCHAR(300),
	@Latitude NVARCHAR(20),
	@Longitude NVARCHAR(20),
	@Accuracy NVARCHAR(20)
AS
BEGIN
	-- control de inserciones para transacción
	DECLARE @RInserted INT
	-- tabla temporal para actualizar registros encontrados
	DECLARE @Table AS TABLE (ID INT)
	-- control de inserción de imagen en tabla de fotografías
	DECLARE @ID_Photo INT
	-- variables auxiliares para conversión de imagen de base64 a varbinary
	DECLARE @PhotoIncidentVB VARBINARY(MAX)

	-- Variables para verificar ubicación en geocerca
	DECLARE @FixedLatitude NVARCHAR(20) = @Latitude
	DECLARE @FixedLongitude NVARCHAR(20) = @Longitude
	DECLARE @IdIncidenceReviewOrigin AS INT;

	BEGIN TRY

		IF(RTRIM(LTRIM(ISNULL(@Latitude,''))) <> '' AND RTRIM(LTRIM(ISNULL(@Longitude,''))) <> '')
		BEGIN
			DECLARE @TargetGeofence GEOMETRY;
			DECLARE @TargetGeofenceAsText NVARCHAR(MAX);

			DECLARE @TargetPoint GEOMETRY;
			DECLARE @TargetPointAsText NVARCHAR(MAX) = CONCAT('POINT (',@Longitude,' ',@Latitude,')');

			SET @TargetGeofenceAsText = 
			(
				CONCAT(
					'POLYGON (('
					,(
						SELECT STUFF(
						( 
							SELECT 
								', '+CONCAT(CAST(P.PointLongitude AS DECIMAL(9,6)),' ',CAST(P.PointLatitude AS DECIMAL(9,6)))
							FROM
								[DeliveryBackOffice].[dbo].[Geofence] G 
								INNER JOIN 
									[DeliveryBackOffice].[dbo].[GeofencePoint] GP
									ON
										G.IdGeofence = GP.IdGeofence
										AND
										GP.RowStatus = 1
								INNER JOIN
									[DeliveryBackOffice].[dbo].[Point] P
									ON
										GP.IdPoint = P.IdPoint
										AND
										P.RowStatus = 1
							WHERE
								G.RowStatus = 1
								AND
								G.IdGeofence = 1 -- Geocerca de GT
							ORDER BY
								GP.GeofencePointOrder ASC
							FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,'')
					)
					,'))'
				)
			)
	
			SET @TargetGeofence = GEOMETRY::STGeomFromText(@TargetGeofenceAsText, 0);

			SET @TargetPoint = GEOMETRY::STGeomFromText(@TargetPointAsText, 0);

			DECLARE @IsValidLocation BIT =
				CASE	
					WHEN
						@TargetPoint.STIntersection(@TargetGeofence).ToString() = 'GEOMETRYCOLLECTION EMPTY' THEN 0
					ELSE 1
				END
		
			IF(@IsValidLocation = 0)
			BEGIN
				SET @FixedLatitude = NULL
				SET @FixedLongitude = NULL
			END
		END
	
	END TRY
	BEGIN CATCH
		PRINT 'ERROR IN GEOLOCATION'
		
		SET @FixedLatitude = NULL
		SET @FixedLongitude = NULL
	END CATCH

	BEGIN TRANSACTION

		BEGIN TRY

			-- convertir base64 a varbinary
			--SET @PhotoIncidentVB = (CAST(N'' AS xml).value('xs:base64Binary(sql:variable("@PhotoIncidentB64"))', 'varbinary(max)'))

			-- buscar registros de tabla de entregas
			INSERT INTO @Table
			SELECT
				da.ID
			FROM DeliveryBackOffice.dbo.DeliveryAttempt da
			INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = da.ID_Courier
			WHERE sr.Phone like '%' + @PhoneNumber + '%'
				AND da.Guide_Serie = @GuideSerie
				AND da.Guide_Number = @GuideNumber
				AND CONVERT(VARCHAR, da.Date_Created, 23) = CONVERT(VARCHAR, GETDATE(), 23)

			-- insertar foto y guardar ID para actualizar tabla de entregas
			INSERT INTO DeliveryBackOffice.dbo.DeliveryProof (Guide_Serie, Guide_Number, Date_Photo, Path_Incident) VALUES (@GuideSerie, @GuideNumber, GETDATE(), @ImageIncident)
			SET @ID_Photo = SCOPE_IDENTITY()

			IF (@ID_Photo > 0)
			BEGIN
				-- actualizar tabla de entregas
				UPDATE 
					DeliveryBackOffice.dbo.DeliveryAttempt 
				SET 
					ID_Incident = @IdIssue
					, ID_Proof = @ID_Photo
					, Latitude = @FixedLatitude
					, Longitude = @FixedLongitude
					, LogLatitude = IIF(@Latitude = @FixedLatitude,NULL,@Latitude)
					, LogLongitude = IIF(@Longitude = @FixedLongitude,NULL,@Longitude)
					, Accuracy = @Accuracy
				WHERE ID IN (SELECT ID FROM @Table)
			
				-- actualizar tabla de registro de guías electrónicas
				UPDATE DeliveryBackOffice.dbo.DeliveryOrder SET StatusOrderId = 12 WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber

				--- Actualizar el estado de las piezas
				UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece]
				SET
					StatusOrderId = 12
				WHERE GuideSerie = @GuideSerie AND GuideNumber =  @GuideNumber
			
				-- registrar estado en tabla de checkpoints
				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail (Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations, Temperature_Celsius)
				VALUES (@GuideSerie, @GuideNumber, 12, 'sps_proof_onincident',GETDATE(), GETDATE(), NULL, NULL)
				SET @RInserted = @@ROWCOUNT

				
					-- (A) Paso 1 ; Cálcular @idissue es calificado (Landing page) o no calificado (Distancia lineal)
						/*
							Calculado (Landing page)
								15	No hay nadie en destino
								20	Dirección y teléfono incorrecto
						*/
				SELECT
				    	@IdIncidenceReviewOrigin = IncidenceClasificationId
				FROM
					[DeliveryBackOffice].[dbo].[CatTypeIncidence]
				WHERE IdIncidenceType = @idissue
                   
			        
					INSERT INTO [dbo].[ReviewIncidence]
						( IncidenceReviewOrigin, DeliveryProofId, ReviewIncidenceToken, IsReviewed, RowStatus, TokenCreated, DateCreated )
					VALUES
						( @IdIncidenceReviewOrigin, @ID_PHOTO, CONCAT( @GuideSerie, @GuideNumber , RIGHT ('00000'+CAST( (FLOOR(RAND()*(99999-0+1))+0) AS NVARCHAR),5),10) , 0, 1, 'sps_proof_onincident', GETDATE() )

				
			END

		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RInserted > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					CONVERT(BIGINT, @@TRANCOUNT) AS 'NumTransferID',
					@GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					CONVERT(BIGINT,0) AS 'NumTransferID',
					@GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'
END
