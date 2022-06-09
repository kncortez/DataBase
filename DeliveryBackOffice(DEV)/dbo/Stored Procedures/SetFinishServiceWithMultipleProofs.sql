


-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-05-17>
-- Description:	< Finalizar servicios de entrega los cuales requieren multiples imagenes de comprobante de entrega >
-- =============================================

CREATE PROCEDURE [dbo].[SetFinishServiceWithMultipleProofs]
	@CourierId INT,
	@CourierToken VARCHAR(50),
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@Latitude NVARCHAR(20),
	@Longitude NVARCHAR(20),
	@Accuracy NVARCHAR(20) = '',
	@ReceiverName NVARCHAR(200),
	@ImagesProof TblImagUrlList READONLY
AS
BEGIN
	-- Variables de respuesta
	DECLARE @jsonResult NVARCHAR(MAX);
	-- control de inserciones para transacción
	DECLARE @RInserted INT;
	DECLARE @SomeProofs BIT = 0;
	-- tabla temporal para actualizar registros encontrados
	DECLARE @Table AS TABLE (
		ID INT
	);
	-- control de inserción de imagen en tabla de fotografías
	DECLARE @ID_Photo INT;
	-- variable para obtener el módulo de origen de los datos
	DECLARE @DataOriginId INT;
	-- variable para setear el nombre del módulo del cuál se desea obtener su id
	DECLARE @ModName NVARCHAR(50);

	--Estado para Reenviado a Express Center
	DECLARE @StatusEXC AS INT = (SELECT TOP 1
			StatusOrderId
		FROM StatusOrder WITH (NOLOCK)
		WHERE OrderDescription = 'Traslado a Express Center'); --FDAPI-337
	--Se obtiene el IdDeliveryOption configurado
	DECLARE @IdDeliveryOption AS INT = (SELECT TOP 1
			IdDeliveryOption
		FROM DeliveryBackOffice.dbo.CatDeliveryOptions WITH (NOLOCK)
		WHERE Name = 'Express Center'); --FDAPI-337
	--Se obtiene el IdDeliveryOption que tiene la guía
	DECLARE @IdDeliveryOptionGuide AS INT;
	DECLARE @IsExpress AS BIT;

	SELECT TOP 1
		@IdDeliveryOptionGuide = IdDeliveryOption
	   ,@IsExpress = IIF(ISNULL(kvp.KindOfVPName, '') = 'Express Center', 'true', 'false')
	FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
	LEFT JOIN dbo.VisitPointClient vpr WITH (NOLOCK)
		ON vpr.CodeOfReference = DeliveryOrder.Receiver_ID
	LEFT JOIN dbo.KindOfVPClient kvp WITH (NOLOCK)
		ON kvp.IdKindOfVPClient = vpr.IdKindOfVPClient
	WHERE Guide_Serie = @GuideSerie
	AND Guide_Number = @GuideNumber; --FDAPI-337

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
			'POLYGON ((', (SELECT
					STUFF((SELECT
							', '
							+ CONCAT(
							CAST(P.PointLongitude AS DECIMAL(9, 6)),
							' ',
							CAST(P.PointLatitude AS DECIMAL(9, 6))
							)
						FROM [DeliveryBackOffice].[dbo].[Geofence] G WITH (NOLOCK)
						JOIN [DeliveryBackOffice].[dbo].[GeofencePoint] GP WITH (NOLOCK)
							ON G.IdGeofence = GP.IdGeofence
							AND GP.RowStatus = 1
						JOIN [DeliveryBackOffice].[dbo].[Point] P WITH (NOLOCK)
							ON GP.IdPoint = P.IdPoint
							AND P.RowStatus = 1
						WHERE G.RowStatus = 1
						AND G.IdGeofence = 1 -- Geocerca de GT
						ORDER BY GP.GeofencePointOrder ASC
						FOR XML PATH (''), TYPE)
					.value('.', 'varchar(max)'),
					1,
					1,
					''
					))
			,
			'))'
			)
			);

			SET @TargetGeofence = GEOMETRY::STGeomFromText(@TargetGeofenceAsText, 0);

			SET @TargetPoint = GEOMETRY::STGeomFromText(@TargetPointAsText, 0);

			DECLARE @IsValidLocation BIT
			= CASE
				WHEN @TargetPoint.STIntersection(@TargetGeofence).ToString() = 'GEOMETRYCOLLECTION EMPTY' THEN 0
				ELSE 1
			END;

			IF (@IsValidLocation = 0)
			BEGIN
				SET @FixedLatitude = NULL;
				SET @FixedLongitude = NULL;
			END;
		END;

	END TRY
	BEGIN CATCH
		SET @FixedLatitude = NULL;
		SET @FixedLongitude = NULL;
	END CATCH;

	SET @SomeProofs = ISNULL((SELECT TOP 1 1 FROM @ImagesProof),0);

	BEGIN TRANSACTION;

	BEGIN TRY

		IF(@SomeProofs = 1)
		BEGIN
			-- asignar valor a la variable ModName
			SET @ModName = N'Courier App';

			-- buscar registros de tabla de entregas
			INSERT INTO @Table
				SELECT
					da.ID
				FROM DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
				JOIN DeliveryBackOffice.dbo.SenderReceiver sr WITH (NOLOCK)
					ON sr.ID = da.ID_Courier
				WHERE sr.ID = @CourierId
				AND da.Guide_Serie = @GuideSerie
				AND da.Guide_Number = @GuideNumber
				AND CONVERT(VARCHAR, da.Date_Created, 23) = CONVERT(VARCHAR, GETDATE(), 23);

			DECLARE @InsertedImaged AS TABLE (
				insertedId INT
			);

			-- insertar foto y guardar ID para actualizar tabla de entregas
			INSERT INTO DeliveryBackOffice.dbo.DeliveryProof (
				Guide_Serie,
				Guide_Number,
				Date_Photo,
				PathSignature,
				Path_Dry,
				Path_Cold
			)
			OUTPUT inserted.ID INTO @InsertedImaged(insertedId)
			SELECT
				@GuideSerie, @GuideNumber, GETDATE(), NULL, ImP.imageURL, NULL
			FROM
				@ImagesProof ImP

			SET @ID_Photo = (SELECT TOP 1 insertedId FROM @InsertedImaged ORDER BY insertedId ASC)

			IF (@ID_Photo > 0)
			BEGIN
				-- actualizar tabla de entregas
				UPDATE DeliveryBackOffice.dbo.DeliveryAttempt
				SET Delivered = 1
				   ,ID_Proof = @ID_Photo
				   ,Latitude = @FixedLatitude
				   ,Longitude = @FixedLongitude
				   ,LogLatitude = IIF(@Latitude = @FixedLatitude, NULL, @Latitude)
				   ,LogLongitude = IIF(@Longitude = @FixedLongitude, NULL, @Longitude)
				   ,Accuracy = @Accuracy
				WHERE ID IN (SELECT
						ID
					FROM @Table);

				DECLARE @StatusId INT = (SELECT TOP 1
						ISNULL(StatusOrderId, 1)
					FROM dbo.DeliveryOrder
					WHERE Guide_Serie = @GuideSerie
					AND Guide_Number = @GuideNumber);

				IF @StatusId NOT IN (5, 22) -- estado etregado
				BEGIN

					-- actualizar tabla de registro de guías electrónicas
					
					UPDATE DeliveryBackOffice.dbo.DeliveryOrder
					SET NameOfReceiver = @ReceiverName
					   ,StatusOrderId = IIF(@IdDeliveryOptionGuide = @IdDeliveryOption, @StatusEXC, IIF(@IsExpress = 'true', @StatusEXC, 5))
					WHERE Guide_Serie = @GuideSerie
					AND Guide_Number = @GuideNumber;

					-- registrar estado en tabla de checkpoints
					INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail (
					Guide_Serie,
					Guide_Number,
					StatusOrderId,
					UserCreated,
					DateCreated,
					DateCreatedInSystem,
					Temperature_Celsius,
					Observations
					)
						VALUES (@GuideSerie, @GuideNumber, IIF(@IdDeliveryOptionGuide = @IdDeliveryOption, @StatusEXC, IIF(@IsExpress = 'true', @StatusEXC, 5)), @CourierToken, GETDATE(), GETDATE(), NULL, NULL);

					SET @RInserted = @@rowcount;
					
					SET @RInserted = 1;
					SELECT
						@DataOriginId = cm.ModIdModule
					FROM DeliveryBackOffice.dbo.CatModule cm WITH (NOLOCK)
					WHERE cm.ModName = @ModName;

				END;
			END;
		
			IF @@trancount > 0
			BEGIN
				IF (@RInserted > 0)
	
					SET @jsonResult = (SELECT STUFF(( 
										SELECT  
											',{' + 
												'"IdResult":200' + ',' + 
												'"Guide":"' +  CONCAT(@GuideSerie, @GuideNumber) + '",' +
												'"GuideMessage":"Registro guardado correctamente"' +
											+ '}'
										FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,''
										) )
				ELSE
			
					SET @jsonResult = (SELECT STUFF(( 
										SELECT  
											',{' + 
												'"IdResult":204' + ',' + 
												'"Guide":"' +  CONCAT(@GuideSerie, @GuideNumber) + '",' +
												'"GuideMessage":"Registro no encontrado"' +
											+ '}'
										FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,''
										) )
				   
				SELECT @jsonResult 'JsonResult'

				COMMIT TRANSACTION;
			END;
			ELSE
	
				SET @jsonResult = (SELECT STUFF(( 
									SELECT  
										',{' + 
											'"IdResult":500' + ',' + 
											'"Guide":"' +  CONCAT(@GuideSerie, @GuideNumber) + '",' +
											'"GuideMessage":"' + ERROR_MESSAGE() + '"' +
										+ '}'
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,''
									) )

				SELECT @jsonResult 'JsonError'

				ROLLBACK TRANSACTION;
		END
		ELSE
		BEGIN
	
			SET @jsonResult = (SELECT STUFF(( 
								SELECT  
									',{' + 
										'"IdResult":400' + ',' + 
										'"Guide":"' +  CONCAT(@GuideSerie, @GuideNumber) + '",' +
										'"GuideMessage":"No se proveen imagenes de prueba de entrega esperados."' +
									+ '}'
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,''
								) )

			SELECT @jsonResult 'JsonError'

			ROLLBACK TRANSACTION;

		END
	END TRY
	BEGIN CATCH
	
		SET @jsonResult = (SELECT STUFF(( 
							SELECT  
								',{' + 
									'"IdResult":500' + ',' + 
									'"Guide":"' +  CONCAT(@GuideSerie, @GuideNumber) + '",' +
									'"GuideMessage":"' + ERROR_MESSAGE() + '"' +
								+ '}'
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
							) )

		SELECT @jsonResult 'JsonError'

		ROLLBACK TRANSACTION;
	END CATCH;
END;
