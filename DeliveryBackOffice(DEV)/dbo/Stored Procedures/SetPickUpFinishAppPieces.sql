-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-10-09>
-- Description:	<Se procesan las piezas escaneadas en la App de escaneo despues de DispatchTrack>
-- =============================================
CREATE PROCEDURE [dbo].[SetPickUpFinishAppPieces] 
		@InGuides NVARCHAR(MAX) = 'FD9559566-1,FD9559566-2',
		@IdPickup INT = 2,
		@TypeofInOutMoneyId INT = 1,
		@Token VARCHAR(200) = NULL,
		@Observations VARCHAR(200) = NULL,
		@StartDate DATETIME = NULL,
		@EndDate DATETIME = NULL,
		@PickupLatitude NVARCHAR(20) = NULL,
		@PickupLongitude NVARCHAR(20) = NULL,
		@IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
	BEGIN TRY
		DECLARE @Valid INT,
				@TokenAct INT,
				@hourtoken INT,
				@SenderId INT,
				@CustomerId INT,
				@IspickupGuide INT,
				@ValidCountry INT,
				@CourierID INT,
				@CodeOfReference INT,
				@SenderName NVARCHAR(50),
				@Sender_Phone NVARCHAR(20),
				@IdHublogistic INT,
				@Sender_Address NVARCHAR(200),
				@Sender_Email NVARCHAR(200),
				@ManifestSerie NVARCHAR(3) = 'FM',
				@ValidExis INT 

		IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
			DROP TABLE #listGuides;

		IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
			DROP TABLE #Temp;
	
		IF OBJECT_ID('tempdb.dbo.#NowInsert', 'U') IS NOT NULL 
			DROP TABLE #NowInsert;

		IF OBJECT_ID('tempdb.dbo.#Piece', 'U') IS NOT NULL 
			DROP TABLE #Piece;

		IF OBJECT_ID('tempdb.dbo.#Delivery', 'U') IS NOT NULL 
			DROP TABLE #Delivery;

		SELECT TOP 1
			   @TokenAct = RowStatus,
			   @hourtoken = DATEDIFF(HOUR, DateCreated, GETDATE()) 
		FROM LogTokenPOD
		WHERE LogTokenPOD = @Token 
		ORDER BY DateCreated DESC


		-- Variables para verificar ubicación en geocerca
		DECLARE @FixedLatitude NVARCHAR(20) = @PickupLatitude;
		DECLARE @FixedLongitude NVARCHAR(20) = @PickupLongitude;

		BEGIN TRY

			IF (
				   RTRIM(LTRIM(ISNULL(@PickupLatitude, ''))) <> ''
				   AND RTRIM(LTRIM(ISNULL(@PickupLongitude, ''))) <> ''
			   )
			BEGIN
				DECLARE @TargetGeofence GEOMETRY;
				DECLARE @TargetGeofenceAsText NVARCHAR(MAX);

				DECLARE @TargetPoint GEOMETRY;
				DECLARE @TargetPointAsText NVARCHAR(MAX) = CONCAT('POINT (', @PickupLongitude, ' ', @PickupLatitude, ')');

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
												   INNER JOIN [DeliveryBackOffice].[dbo].[Point] P WITH (NOLOCK)
													   ON GP.IdPoint = P.IdPoint                  
											   WHERE G.RowStatus = 1
													 AND GP.RowStatus = 1
													 AND P.RowStatus = 1
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

		IF(@TokenAct = 1 AND @hourtoken <= 8) OR 1 = 1
		BEGIN

			CREATE TABLE #Temp
			(
				Guide VARCHAR(255),
				Message VARCHAR(255),
			);

			CREATE NONCLUSTERED INDEX tempTemp ON #Temp (Guide);

			INSERT INTO #Temp
			(
				Guide,
				Message
			)
			EXEC [dbo].[spws_get_validate_guides_pickup]
				-- Add the parameters for the stored procedure here
				@InGuides = @InGuides,
				@IdPickup = @IdPickup,
				@Token = @Token;


			SET @Valid = (SELECT COUNT(*) FROM #Temp)

			IF @Valid = 0
			BEGIN

				CREATE TABLE #listGuides
				(
					ItemSerie NVARCHAR(2),
					ItemNumber INT,
					ItemPiece INT
				);

				CREATE NONCLUSTERED INDEX templistGuides_Piece495
				ON #listGuides (
								  ItemSerie,
								  ItemNumber
							   );

				INSERT INTO #listGuides
						(
							ItemSerie,
							ItemNumber,
							ItemPiece
						)
				SELECT SUBSTRING(Item, 1, 2) ItemSerie,
						SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber,
						ISNULL(   (CASE
										WHEN LEN(SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item))) > 1 THEN
											1
										ELSE
											SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item))
									END
									),
									0
								) ItemPiece
				FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',');

				UPDATE
					[#listGuides]
				SET
					[ItemPiece] = 1
				WHERE
					[ItemPiece] = 0;

				-- VALIDAMOS SI HAY ALGUNA GUIA QUE NO EXISTA

				SELECT DISTINCT
					LS.ItemSerie,
					LS.ItemNumber,
					CASE
						WHEN DO.Guide_Number IS NOT NULL THEN
							1
						ELSE
							0
					END AS Exist
				INTO #Delivery
				FROM #listGuides LS
					LEFT JOIN DeliveryOrder DO WITH (NOLOCK)
						ON DO.Guide_Serie = LS.ItemSerie
						   AND DO.Guide_Number = LS.ItemNumber

				CREATE NONCLUSTERED INDEX tempDelivery
					ON #Delivery (
									ItemNumber,
									Exist
								 );

				SET @ValidExis = (SELECT COUNT(*) FROM #Delivery WHERE Exist = 0)

				IF @ValidExis > 1
				BEGIN
						SELECT @ValidCountry = MAX(   CASE
													  WHEN DO.SenderCountryId = @IdCountry THEN
														  1
													  ELSE
														  0
												  END
											  )
					FROM DeliveryOrder DO WITH (NOLOCK)
						INNER JOIN #listGuides LS
							ON DO.Guide_Serie = LS.ItemSerie
							   AND DO.Guide_Number = LS.ItemNumber
					
					CREATE TABLE #Piece 
					(
						IsPickup BIT,
						GuideSerie NVARCHAR(10),
						GuideNumber NVARCHAR(15),
						ItemPiece INT
					)

					CREATE NONCLUSTERED INDEX tempPiece
					ON #Piece (
								GuideSerie,
								GuideNumber
								);

					INSERT INTO #Piece
					(
						IsPickup,
						GuideSerie,
						GuideNumber
					)
					SELECT DISTINCT ISNULL(DP.IsPickup,0) AS IsPickup,
						   DP.GuideSerie,
						   DP.GuideNumber
					FROM DeliveryOrderPiece DP WITH(NOLOCK)
					INNER JOIN #listGuides LS
						ON DP.GuideSerie = LS.ItemSerie
						   AND DP.GuideNumber = LS.ItemNumber
					WHERE ISNULL(DP.IsPickup,0) = 1

					
					SELECT @IspickupGuide = COUNT(*)
					FROM #Piece

					IF @ValidCountry = 1
					BEGIN
						IF @IspickupGuide = 0
						BEGIN
							BEGIN TRANSACTION
							----------------inserta en una tabla temporal, los campos requeridos para insertar en DeliveryPaymentDetail las guias no generadas en el portal----------------

							DECLARE @AmountPickup DECIMAL(14, 2) =
							(
								SELECT CONVERT(DECIMAL(14, 2), Value)
								FROM CatToCharge
								WHERE IdToCharge = 1
							);

							SELECT [Guide_Number],
									   [Guide_Serie],
									   [PriceShippment],
									   [recolect],
									   [IsCollect]
								INTO #NowInsert
								FROM
								(
									SELECT ord.Guide_Number,
										   ord.Guide_Serie,
										   ord.PriceShippment,
										   (@AmountPickup) AS recolect,
										   ord.IsCollect
									FROM DeliveryOrder ord WITH (NOLOCK)
										LEFT JOIN DeliveryOrderPaymentDetail dop WITH (NOLOCK)
											ON (
												   ord.Guide_Number = dop.GuideNumber
												   AND ord.Guide_Serie = dop.GuideSerie
											   )
										INNER JOIN #listGuides ls
											ON (
												   ord.Guide_Number = ls.ItemNumber
												   AND ord.Guide_Serie = ls.ItemSerie
											   )
									WHERE ord.Guide_Number IN
										  (
											  SELECT ItemNumber FROM #listGuides -- WHERE ItemSerie = 'fd'
										  )
										  AND ord.Guide_Serie IN 
										  (
												SELECT ItemSerie FROM #listGuides
										  )
										  AND ord.StatusOrderId IN ( 15, 1, 16 )
										  AND dop.GuideNumber IS NULL
								) AS Table1;

								CREATE NONCLUSTERED INDEX tempNowInsert
								ON #NowInsert (
												  Guide_Number,
												  Guide_Serie
											  );

								------------------------------Inserta en la tabla DeliveryOrderPaymentDetail los datos de la tabla temporal ---------------------------
								PRINT 'Inserta en la tabla DeliveryOrderPaymentDetail los datos de la tabla temporal ';
								INSERT INTO dbo.DeliveryOrderPaymentDetail
								(
									[GuideNumber],
									[GuideSerie],
									[PayTypeId],
									[TypeofInOutMoneyId],
									[TimePlaId],
									[amount],
									[TokenCreated],
									[DateCreated],
									[TokenUpdated],
									[DateUpdated],
									[PaymentRecollections],
									[PaymentNow],
									[PaymentDelivery],
									[StartDate],
									[EndDate],
									[ShipmentCompleted],
									[RecollectionCompleted],
									[PaidGuide],
									[TransaccionFAC],
									[IdHeaderRecolection],
									[RecolectNow],
									[RecolectDelivery],
									[RecolectPayment]
								)
								SELECT DISTINCT
									   ls.Guide_Number,
									   ls.Guide_Serie,
									   1,
									   @TypeofInOutMoneyId,
									   IIF(ls.IsCollect = 'true', 3, 4),
									   NULL,
									   @Token,
									   GETDATE(),
									   NULL,
									   NULL,
									   NULL,
									   0.00,
									   0.00,
									   NULL,
									   NULL,
									   NULL,
									   NULL,
									   NULL,
									   NULL,
									   @IdPickup,
									   0.00,
									   0.00,
									   @AmountPickup
								FROM #NowInsert ls;

								--------------------------------------------- Registra en la tabla DeliveryOrderDetail la recoleccion de la guia  ---------------------------------
								PRINT 'Registra en la tabla DeliveryOrderDetail la recoleccion de la guia';
								INSERT INTO DeliveryOrderDetail
								(
									[Guide_Serie],
									[Guide_Number],
									[StatusOrderId],
									[UserCreated],
									[DateCreated],
									[DateCreatedInSystem],
									[Observations],
									[Temperature_Celsius]
								)
								SELECT ni.ItemSerie,
									   ni.ItemNumber,
									   2,
									   @Token,
									   GETDATE(),
									   GETDATE(),
									   NULL,
									   NULL
								FROM #listGuides ni;

								DROP TABLE #NowInsert;

								---------------------------------Obtner los datos a actualizar del encabezado del lote de guias -------------------------------------
								PRINT 'Obtner los datos a actualizar del encabezado del lote de guias';

								SELECT TOP 1
										@SenderId = ord.Sender_ID,
										@CustomerId = ISNULL(ord.IdCustomer, 6),
										@SenderName = CONCAT(ord.Sender_FirstName, ord.Sender_LastName),
										@Sender_Phone = ord.Sender_Phone,
										@Sender_Address = ord.Sender_Address
								FROM #listGuides ls
									INNER JOIN DeliveryOrder ord WITH(NOLOCK)
										ON (
												ord.Guide_Number = ls.ItemNumber
												AND ord.Guide_Serie = ls.ItemSerie
											)
								WHERE ord.Guide_Number IN
										(
											SELECT ItemNumber FROM #listGuides
										)
										AND ord.Guide_Serie IN 
										(
											SELECT ItemSerie FROM #listGuides
										)
			
								SET @Sender_Email =
								(
									SELECT EmailDispatch
									FROM ServiceManagement
									WHERE IdSchedulePickup = @IdPickup
								)

								 SELECT TOP 1
										@IdHublogistic = HBG.IdHubLogistic
								FROM #listGuides ls
									INNER JOIN DeliveryOrder ord WITH (NOLOCK)
										ON (
												ord.Guide_Number = ls.ItemNumber
												AND ord.Guide_Serie = ls.ItemSerie
											)
									INNER JOIN DeliveryBackOffice.dbo.Township TWN WITH(NOLOCK)
										ON ord.SenderIdTownship = twn.IdTownship 
									INNER JOIN DeliveryBackOffice.dbo.DumpServiceCoverage THB WITH(NOLOCK)
										ON THB.HeaderCode = twn.HeaderCode
									INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBG WITH(NOLOCK)
										ON HBG.HubAbbreviation = THB.Hub 
									INNER JOIN DeliveryOrderPaymentDetail dop WITH (NOLOCK)
										ON (
												dop.GuideNumber = ord.Guide_Number
												AND dop.GuideSerie = ord.Guide_Serie
											)
								WHERE ord.Guide_Number IN
										(
											SELECT ItemNumber FROM #listGuides
										)
										AND ord.Guide_Serie IN 
										(
											SELECT ItemSerie FROM #listGuides
										)
										AND THB.RowStatus = 1
										AND twn.TownshipStatus = 1
										AND HBG.HubStatus = 1


							  --------------------Actualiza los datos obtenidos anteriormente para la tabla SchedulePickup--------------------

							  UPDATE dbo.SchedulePickup
								SET AmountPickup = @AmountPickup
								WHERE SchedulePickupId = @IdPickup;

							  ----------------------Agrupa el lote de guias a una sola transaccion-------------------------

							  UPDATE DeliveryOrderPaymentDetail
								SET IdHeaderRecolection = @IdPickup
								FROM DeliveryOrderPaymentDetail dop WITH(NOLOCK)
									INNER JOIN DeliveryOrder ord WITH(NOLOCK)
										ON (
											   ord.Guide_Number = dop.GuideNumber
											   AND ord.Guide_Serie = dop.GuideSerie
										   )
								WHERE dop.GuideSerie = 'fd'
									  AND dop.GuideNumber IN
										  (
											  SELECT ItemNumber FROM #listGuides
										  )

									  AND ord.StatusOrderId IN ( 15, 1, 16 )
									  AND
									  (
										  dop.IdHeaderRecolection = @IdPickup
										  OR dop.IdHeaderRecolection IS NULL
									  );

								-- Quitar guías no recolectadas asociadas al servicio
								UPDATE DeliveryOrderPaymentDetail
								SET IdHeaderRecolection = NULL
								FROM DeliveryOrderPaymentDetail dop WITH(NOLOCK)
									LEFT JOIN #listGuides LG
										ON dop.GuideNumber = LG.ItemNumber
										   AND dop.GuideSerie = LG.ItemSerie
								WHERE dop.IdHeaderRecolection = @IdPickup
									  AND LG.ItemNumber IS NULL
									  AND LG.ItemSerie IS NULL;

							---------------Actualiza su StatusId a 2 = Recoleccion todas las guias del lote-------------------

							UPDATE DeliveryOrder
								SET StatusOrderId = 2
								WHERE Guide_Number IN
									  (
										  SELECT ItemNumber FROM #listGuides
									  )
									  AND Guide_Serie IN
										  (
											  SELECT ItemSerie FROM #listGuides
										  );

								UPDATE ASCD
								SET RowStatus = 0,
									TokenUpdated = @Token,
									DateUpdated = GETDATE()
								FROM [DeliveryBackOffice].[dbo].[AccountServiceCartDetail] ASCD WITH (NOLOCK)
									INNER JOIN #listGuides LGE WITH (NOLOCK)
										ON ASCD.GuideSerie = LGE.ItemSerie
										   AND ASCD.GuideNumber = LGE.ItemNumber
										WHERE ASCD.RowStatus = 1;

							---------------Coloca true a IsPickup para que se entienda que es Recoleccion o fue escaneada la guia-------------

							UPDATE DeliveryOrderPiece
								SET IsPickup = 1
								WHERE GuideNumber IN
									  (
										  SELECT ItemNumber FROM #listGuides
									  )
									  AND GuideSerie IN
										  (
											  SELECT ItemSerie FROM #listGuides
										  );

							---------------Actualiza el Status del Servicio ya se encuentra en estado recolectado para Dispatch--------------------
								DECLARE @Status INT =
								(
									SELECT IdServiceStatus FROM CatServiceStatus WHERE Name = 'Recolectado'
								);
				
								UPDATE ServiceManagement
								SET CiPuDate = @StartDate,
									CoPuDate = @EndDate,
									Amount = 0,
									TokenUpdated = @Token,
									DateUpdated = GETDATE(),
									CatPaymentTimeId = NULL -- En Dispatch Track no se ven pagos
								WHERE IdSchedulePickup = @IdPickup;


								DECLARE @transac INT =
										(
											SELECT TOP 1
												   IdServiceManagement
											FROM ServiceManagement WITH(NOLOCK)
											WHERE IdSchedulePickup = @IdPickup
										);
								---------------Inserta en EventService el comportamiento del Pickup----------------------
								INSERT INTO EventService
								(
									ServiceManagementId,
									ServiceStatusId,
									RowStauts,
									TokenCreated,
									DateCreated,
									Observations
								)
								VALUES
								(@transac, @Status, 1, @Token, GETDATE(), @Observations);

								-----------------Registrar Manifiesto--------------------------

								SELECT TOP 1
											@CourierID = sr.ID
								FROM DeliveryBackOffice.dbo.SenderReceiver sr WITH(NOLOCK)
									INNER JOIN DeliveryBackOffice.dbo.LogTokenPOD ltp WITH (NOLOCK)
										ON ltp.IdCourierman = sr.ID
										   --AND ltp.RowStatus = 1
									WHERE ltp.LogTokenPOD = @Token

								INSERT INTO [dbo].[CourierPickupManifest]
								(
									[ManifestSerie],
									[SenderReceiverId],
									[ManifestURL],
									[RowStatus],
									[TokenCreated],
									[DateCreated],
									[TokenUpdated],
									[DateUpdated]
								)
								VALUES
								(@ManifestSerie, @CourierID, NULL, 1, @Token, GETDATE(), NULL, NULL);

								DECLARE @IdManifest AS BIGINT = SCOPE_IDENTITY();

								INSERT INTO [dbo].[CourierPickupManifestDetail]
								(
									[ManifestId],
									[GuideSerie],
									[GuideNumber],
									[PieceNumber],
									[TokenCreated],
									[DateCreated],
									[TokenUpdated],
									[DateUpdated],
									[RowStatus]
								)

								SELECT @IdManifest,
									   lg.ItemSerie,
									   lg.ItemNumber,
									   lg.ItemPiece,
									   @Token,
									   GETDATE(),
									   NULL,
									   NULL,
									   1
								FROM #listGuides lg;

								IF @@TRANCOUNT > 0
									COMMIT TRANSACTION;
									SELECT 200 AS StatusCode,
										   'Piezas procesadas con exito' AS Message
									   
								---- DATOS DEL MANIFIESTO A GENERAR
								SELECT @IdManifest AS 'IdManifest',
									   @ManifestSerie AS 'Manifest_Serie',
									   @IdManifest AS 'Manifest_Number',
									   slp.SenderName AS 'Sender_FirstName',
									   slp.AddressPickup AS 'Sender_Address',
									   ISNULL(vpc.Zone, '') AS 'Sender_Zone',
									   ISNULL(vpc.Town, '') AS 'Sender_Town',
									   ISNULL(vpc.Department, '') AS 'Sender_Department',
									   0 AS 'Consolidated_Number',
									   @Sender_Email AS 'Sender_Email'
								FROM DeliveryBackOffice.dbo.SchedulePickup slp WITH(NOLOCK)
									RIGHT JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK)
										ON vpc.CodeOfReference = slp.SenderId
								WHERE slp.SchedulePickupId = @IdPickup;
						
								-- DETALLE DE LAS GUIAS RECOLECTADAS
								WITH GUIDEMONITOR (GuideNumber, PiecesColdCounter, PiecesDryCounter, TotalPieces)
								AS (
									SELECT COALESCE(dop.GuideNumber, dop2.GuideNumber) GuideNumber,
										   COUNT(dop.GuideNumber) 'PiecesColdCounter',
										   COUNT(dop2.GuideNumber) 'PiecesDryCounter',
										   COUNT(dop.NoPiece) + COUNT(dop2.NoPiece) 'TotalPieces'
									FROM #listGuides lp
										LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH (NOLOCK)
											ON lp.ItemSerie = dop.GuideSerie
											   AND lp.ItemNumber = dop.GuideNumber
											   AND lp.ItemPiece = dop.NoPiece
											   AND dop.IsDry = 0
										LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop2 WITH (NOLOCK)
											ON lp.ItemSerie = dop2.GuideSerie
											   AND lp.ItemNumber = dop2.GuideNumber
											   AND lp.ItemPiece = dop2.NoPiece
											   AND dop2.IsDry = 1
									GROUP BY dop.GuideNumber,
											 dop2.GuideNumber
								)
								SELECT COUNT(GM.GuideNumber) 'GuidesCounter',
									   SUM(GM.PiecesColdCounter) 'PiecesColdCounter',
									   SUM(GM.PiecesDryCounter) 'PiecesDryCounter',
									   SUM(GM.TotalPieces) 'TotalPieces'
								FROM GUIDEMONITOR GM;

								-- DETALLE DE LAS PIEZAS DE LAS GUIAS RECOLECTADAS
								SELECT CONCAT(dop.GuideSerie, dop.GuideNumber, '-', dop.NoPiece) [Piece],
									   CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName)  [ReceiverName],
									   LEFT(do.Receiver_Address, 200)							 [ReceiverAddress],
									   ISNULL(do.ReceiverCountryId,'GT')						 [ReceiverCountryId]
								FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH (NOLOCK)
									INNER JOIN #listGuides lp
										ON lp.ItemSerie = dop.GuideSerie
										   AND lp.ItemNumber = dop.GuideNumber
									INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
										ON do.Guide_Serie = dop.GuideSerie
										   AND do.Guide_Number = dop.GuideNumber
								GROUP BY dop.GuideNumber,
										 dop.GuideSerie,
										 dop.NoPiece,
										 do.Receiver_FirstName,
										 do.Receiver_LastName,
										 do.Receiver_Address,
										 do.ReceiverCountryId
								ORDER BY dop.GuideNumber ASC;



						END
						ELSE
						BEGIN
							SELECT 1 AS StatusCode, 
								'Las piezas ya se encuentran procesadas' AS Message

							SELECT CONCAT(GuideSerie, GuideNumber) AS Guide,
								   'Las piezas de  esta guía ya fueron escaneadas' AS Message
							FROM #Piece
						END
					END				
					ELSE
					BEGIN
						SELECT 0 AS StatusCode, 
							  'La guía pertenece a otro País' AS Message
					END
				END
				ELSE
				BEGIN
					SELECT 1 AS StatusCode,
						   'La guia no existe' AS Message

						   SELECT CONCAT(ItemSerie, ItemNumber) AS Guide, 
								  'La guía no existe' AS Message
						   FROM #Delivery
						   WHERE Exist = 0
				END
			END
			ELSE
			BEGIN
			------Guia no valida----------
					SELECT 1 AS StatusCode,
					  'Guías no válidas' AS Message

					SELECT Message,
						   Guide
					FROM #Temp
			END
		END
		ELSE
		BEGIN
			SELECT 0 AS StatusCode,
				  'El Token con es válido'
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;

		SELECT 0 AS StatusCode,
				   ERROR_MESSAGE() AS Description,
				   ERROR_LINE() AS ErrorLine
	END CATCH
END