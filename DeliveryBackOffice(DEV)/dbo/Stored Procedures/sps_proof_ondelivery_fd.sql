
-- =============================================
-- Author:		<Aquino, César>
-- Create date: <2021-03-23>
-- Description:	<Registrar prueba de entrega en sitio <API Delivery >>
-- =============================================
-- =============================================
-- Modiff:		<Marco,Jiménez>
-- Create date: <2021-09-16>
-- Description:	<Se agregan validaciones para NO insertar 
--               el checkpoint Entregado cuando la entrega sea en un Express Center,
--               en cambio se debe insertar el checkpoint Reenviado a Express Center>
-- Hotfix: FDAPI-337
-- =============================================
-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2023-03-02>
-- Description:	<En proceso de entregas desde CourierApp, cuando sea flujo de guías marcadas para devolución, ingresar las guías marcadas para devolución al proceso de COD para lotes Collect>
-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <03-09-2024>
-- Description:	<Se agrega la variable @Receiver_CUI para almacenar el CUI de la persona que recibe>
-- =============================================
-- Author:		<Brandon Pedroza>
-- Update date: <2024-11-29>
-- Description:	<Se agrega validacion para no insertar registro en ProcessedGuideCOD si la guia fue creada con cod anticipado>
-- =============================================
-- Author:		<Cristian Azurdia>
-- Update date: <2024-11-18>
-- Description:	<Se agrega la Campo IsCompleted em tabla ProcessedGuideCOD, así como actualizacion de campos en Commmit padre>
-- =============================================
CREATE PROCEDURE [dbo].[sps_proof_ondelivery_fd]
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
    @PhoneNumber NVARCHAR(50),
    @ReceiverName NVARCHAR(200),
    -- @PhotoDryB64 VARCHAR(MAX),
    -- @PhotoColdB64 VARCHAR(MAX),
    @Latitude NVARCHAR(20),
    @Longitude NVARCHAR(20),
    @Accuracy NVARCHAR(20),
    @TblDetail AS TblPaymentList READONLY,
    @FullPayment DECIMAL(12, 2) = 0,
    @Token VARCHAR(50),
    @Signature VARCHAR(300),
    @ImageDry VARCHAR(300),
    @ImageCold VARCHAR(300),
    @CODPayment DECIMAL(12, 2) = 0,
    @ExcludeCODPyament BIT = 'false',
	@IdCountry NVARCHAR(8) = 'GT'
    @Receiver_CUI NVARCHAR(25) = ''
AS
BEGIN
    -- control de inserciones para transacción
    DECLARE @RInserted INT;
    DECLARE @IsReturn BIT = 0;
    -- tabla temporal para actualizar registros encontrados
    DECLARE @Table AS TABLE
    (
        ID INT
    );
    -- control de inserción de imagen en tabla de fotografías
    DECLARE @ID_Photo INT;
    -- variables auxiliares para conversión de imagen de base64 a varbinary
    -- DECLARE @PhotoDryVB VARBINARY(MAX);
    -- DECLARE @PhotoColdVB VARBINARY(MAX);
    -- variable para obtener el módulo de origen de los datos
    DECLARE @DataOriginId INT;
    -- variable para setear el nombre del módulo del cuál se desea obtener su id
    DECLARE @ModName NVARCHAR(50);

    --Estado para Reenviado a Express Center
    DECLARE @StatusEXC AS INT =
            (
                SELECT TOP 1
                       StatusOrderId
                FROM StatusOrder WITH (NOLOCK)
                WHERE OrderDescription = 'Traslado a Express Center'
            ); --FDAPI-337
    --Se obtiene el IdDeliveryOption configurado
    DECLARE @IdDeliveryOption AS INT =
            (
                SELECT TOP 1
                       IdDeliveryOption
                FROM DeliveryBackOffice.dbo.CatDeliveryOptions WITH (NOLOCK)
                WHERE Name = 'Express Center'
            ); --FDAPI-337
    --Se obtiene el IdDeliveryOption que tiene la guía
    DECLARE @IdDeliveryOptionGuide AS INT;
    DECLARE @IsExpress AS BIT;

    SELECT TOP 1
           @IdDeliveryOptionGuide = IdDeliveryOption,
           @IsExpress = IIF(ISNULL(kvp.KindOfVPName, '') = 'Express Center', 'true', 'false'),
           @IsReturn = ISNULL(IsLastMileReturn, 0)
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
                                           WHERE G.CountryId = @IdCountry -- Geocerca de GT
												 AND G.RowStatus = 1
												 AND GP.RowStatus = 1
												 AND P.RowStatus = 1
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

    	IF (NOT EXISTS(Select 
				Top 1 1
				From  [dbo].[DeliveryAttempt] WITH (NOLOCK)
				 Where Guide_Serie = @GuideSerie AND
				 Guide_Number= @GuideNumber
				 AND ID_Incident IS NULL
				 AND ISNULL(Delivered,0)=0)
				 )
      BEGIN
	-- registrar nuevo intento de entrega
			INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryAttempt] 
			([Guide_Serie],
			 [Guide_Number],
			 [Dry],
			 [Cold],
			 [Latitude],
			 [Longitude],
			 [Delivered],
			 [ID_Courier],
			 [ID_DeliveryOrderBySettlement],
			 [User_Created],
			 [Date_Created],
			 [Guide_Piece]) 
			VALUES (@GuideSerie,
			        @GuideNumber,
					(
					 Select Top 1
                           ISNULL(DRY,0)
                     From  [dbo].[DeliveryAttempt] WITH(NOLOCK) 
                     Where 
					 Guide_Serie = @GuideSerie AND
					 Guide_Number= @GuideNumber
					 ORDER BY  Date_Created DESC
					 ),
					  (Select Top 1
                           ISNULL(Cold,0)
                     From  [dbo].[DeliveryAttempt] WITH(NOLOCK) 
                     Where Guide_Serie = @GuideSerie AND 
					 Guide_Number= @GuideNumber
					 ORDER BY  Date_Created DESC
					 ),
					@Latitude,
					@Longitude,
					0,
			         (
					 Select Top 1
                            ID_Courier
                     From  [dbo].[DeliveryAttempt] WITH(NOLOCK) 
                     Where Guide_Serie = @GuideSerie AND
					 Guide_Number= @GuideNumber
					 ORDER BY  Date_Created DESC
					 ),
				  (
				  Select 
						Top 1
						ID_DeliveryOrderBySettlement
                   From  [dbo].[DeliveryAttempt] WITH (NOLOCK)
                   Where Guide_Serie = @GuideSerie AND 
				   Guide_Number= @GuideNumber
				   ORDER BY  Date_Created DESC
				  ),
			      @Token,
				  GETDATE(),
				  1)

				 

		   END; 

        -- asignar valor a la variable ModName
        SET @ModName = N'Courier App';

        -- convertir base64 a varbinary
        -- SET @PhotoDryVB = (CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@PhotoDryB64"))', 'varbinary(max)'));
        --SET @PhotoColdVB
        -- = (CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@PhotoColdB64"))', 'varbinary(max)'));

        -- buscar registros de tabla de entregas
        INSERT INTO @Table
        SELECT Top 1 da.ID
        FROM DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr WITH (NOLOCK)
                ON sr.ID = da.ID_Courier
			LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiverLoginToken] SRLT  WITH(NOLOCK) 
			ON
				[SRLT].[SenderReceiverId] = [sr].[ID]
        WHERE (sr.Phone LIKE '%' + @PhoneNumber + '%'
				OR
			  [sr].[UniqueCode] = @PhoneNumber
			  OR
			  [SRLT].[LoginToken] = @PhoneNumber)
              AND da.Guide_Serie = @GuideSerie
              AND da.Guide_Number = @GuideNumber
              AND CONVERT(VARCHAR, da.Date_Created, 23) = CONVERT(VARCHAR, GETDATE(), 23)
               ORDER BY da.Date_Created desc;

        -- insertar foto y guardar ID para actualizar tabla de entregas
        INSERT INTO DeliveryBackOffice.dbo.DeliveryProof
        (
            Guide_Serie,
            Guide_Number,
            Date_Photo,
            --Proof_Dry,
            --Proof_Cold,
            PathSignature,
            Path_Dry,
            Path_Cold
        )
        VALUES
        --(@GuideSerie, @GuideNumber, GETDATE(), @PhotoDryVB, @PhotoColdVB, @Signature,@Image);
        (@GuideSerie, @GuideNumber, GETDATE(), @Signature, @ImageDry, @ImageCold);
        SET @ID_Photo = SCOPE_IDENTITY();

        IF (@ID_Photo > 0)
        BEGIN
            -- actualizar tabla de entregas
            UPDATE DeliveryBackOffice.dbo.DeliveryAttempt
            SET Delivered = 1,
                ID_Proof = @ID_Photo,
                Latitude = @FixedLatitude,
                Longitude = @FixedLongitude,
                LogLatitude = IIF(@Latitude = @FixedLatitude, NULL, @Latitude),
                LogLongitude = IIF(@Longitude = @FixedLongitude, NULL, @Longitude),
                Accuracy = @Accuracy
            WHERE ID IN
                  (
                      SELECT ID FROM @Table
                  );

            DECLARE @StatusId INT =
                    (
                        SELECT TOP 1
                               ISNULL(StatusOrderId, 1)
                        FROM dbo.DeliveryOrder WITH (NOLOCK)
                        WHERE Guide_Serie = @GuideSerie
                              AND Guide_Number = @GuideNumber
                    );



            IF @StatusId NOT IN ( 5, 14, 22 ) -- estado etregado
            BEGIN

                PRINT 'ACUTALIZADO DELIVERYORDER';
                PRINT @ExcludeCODPyament;
                -- actualizar tabla de registro de guías electrónicas
                UPDATE DeliveryBackOffice.dbo.DeliveryOrder
                SET NameOfReceiver = @ReceiverName,
					Receiver_CUI = @Receiver_CUI,
                    StatusOrderId = IIF(@IdDeliveryOptionGuide = @IdDeliveryOption AND ISNULL(@IsReturn, 0) = 0,
                                        @StatusEXC,
                                        IIF(@IsExpress = 'true' AND ISNULL(@IsReturn, 0) = 0, @StatusEXC, IIF(@IsReturn = 1, 14, 5))),
                    LastCollectOnDelivery = IIF(@ExcludeCODPyament = 'false', NULL, Collect_OnDelivery),
                    Collect_OnDelivery = IIF(@ExcludeCODPyament = 'true', 0, Collect_OnDelivery) -- 2021-09-09 si el flag de exlucion de pago COD es true actualizar monto COD a 0
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber;

                DECLARE @Observation NVARCHAR(200) = NULL;

                SELECT TOP 1
                       @Observation = CONCAT(ISNULL(td.Voucher, ''), ' ', ISNULL(td.Responsible, ''))
                FROM @TblDetail td
                WHERE LEN(ISNULL(td.Responsible, '')) > 0;

				---------actualizar el estado de la guía en detalle de manifiesto ----------------------------
				
		
				  
					;WITH LatestID AS (
									SELECT TOP 1
										A.Guide_Serie,
										A.Guide_Number,
										MAX(ID) AS LastID
									FROM 
										[dbo].[DeliverySettlementDetail] A WITH (NOLOCK)
									WHERE Guide_Serie = @GuideSerie AND  Guide_Number = @GuideNumber
								GROUP BY Guide_Number, Guide_Serie
								)
								UPDATE ds
								SET 
									ds.StatusOrderId = IIF(@IdDeliveryOptionGuide = @IdDeliveryOption AND ISNULL(@IsReturn, 0) = 0,
                                        @StatusEXC,
                                        IIF(@IsExpress = 'true' AND ISNULL(@IsReturn, 0) = 0, @StatusEXC, IIF(@IsReturn = 1, 14, 5)))
								FROM 
									[dbo].[DeliverySettlementDetail] ds WITH (NOLOCK)
								INNER JOIN [LatestID] li 
									ON ds.Guide_Serie = li.Guide_Serie AND ds.Guide_Number = li.Guide_Number AND ds.ID = li.LastID
					
				---------------------------------------------------------------------------------------------

                -- registrar estado en tabla de checkpoints
                INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
                (
                    Guide_Serie,
                    Guide_Number,
                    StatusOrderId,
                    UserCreated,
                    DateCreated,
                    DateCreatedInSystem,
                    Temperature_Celsius,
                    Observations
                )
                VALUES
                (@GuideSerie, @GuideNumber,
                 IIF(@IdDeliveryOptionGuide = @IdDeliveryOption AND ISNULL(@IsReturn, 0) = 0,
                     @StatusEXC,
                     IIF(@IsExpress = 'true' AND ISNULL(@IsReturn, 0) = 0, @StatusEXC, IIF(@IsReturn = 1, 14, 5))), @Token, GETDATE(), GETDATE(),
                 NULL, IIF(LEN(@Observation) > 0, CONCAT('ENTREGA SIN COBRO COD ', @Observation), ''));

                SET @RInserted = @@ROWCOUNT;

                SELECT @DataOriginId = cm.ModIdModule
                FROM DeliveryBackOffice.dbo.CatModule cm
                WHERE cm.ModName = @ModName;

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
									 (@GuideSerie, @GuideNumber, @WebhookCustomerId, @GuideCurrentStatus, @CustomerEndpointId, 0,
									  @Token, GETDATE());
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
										AND do.Guide_Serie = @GuideSerie
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
									AND do.Guide_Serie = @GuideSerie
									AND dop.ExternalPieceId IS NOT NULL
									AND WHE.TypeConnectionId = 2
									GROUP BY dop.GuideSerie,dop.GuideNumber
					  
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
								TokenCreated)
									SELECT @WebhookCustomerId,
									dop.GuideSerie,dop.GuideNumber, dop.GuidePiece, do.Ticket_Number,dop.ExternalPieceId, 
									@GuideCurrentStatus, 1 AS RowStatus, GETDATE()AS DateCreated,@Token AS TokenCreated
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

                    END;
                END TRY
                BEGIN CATCH

                END CATCH;
                -------------------WEBHOOK.FIN------------------------------			
				
				-------------------FORZA POINTS.INI------------------------------
				BEGIN TRY

					-- Datos generales de la guía 
					DECLARE @CustomerId INT 
					DECLARE @AccountId BIGINT
					DECLARE @MembershipId INT
					DECLARE @GuidePrice DECIMAL(14, 2)
					DECLARE @GuideIsCollect BIT = 0;
					DECLARE @GuideAlreadyInPointLog BIT = 0;
					DECLARE @IsGuideValidForPoints BIT = NULL;
			
					-- Datos de puntos generados
					DECLARE @PointsGenerated INT = 0;
					DECLARE @ForzaPointsGenerationValue DECIMAL = 0;
					DECLARE @ForzaPointsGenerationType NVARCHAR(50) = '';
					
					-- Promociones validas de generación de puntos forza
					DECLARE @CatPointPromoTbl TABLE (	IdPointPromo INT, 
													PointPromoDescription NVARCHAR(400),
													Monday BIT,
													Tuesday BIT,
													Wednesday BIT,
													Thursday BIT,
													Friday BIT,
													Saturday BIT,
													Sunday BIT,
													PointPromoFactor DECIMAL);
					-- Promoción de mayor peso a aplicar
					INSERT INTO @CatPointPromoTbl
					SELECT	TOP 1	[CPP].[IdPointPromo],
									[CPP].[PointPromoDescription],
									[CPP].[Monday],
									[CPP].[Tuesday],
									[CPP].[Wednesday],
									[CPP].[Thursday],
									[CPP].[Friday],
									[CPP].[Saturday],
									[CPP].[Sunday],
									[CPP].[PointPromoFactor]
					FROM	[dbo].[CatPointPromo] CPP
					WHERE	[CPP].[RowStatus] = 1
						AND [CPP].[InPointGeneration] = 1
						AND SYSDATETIME() BETWEEN [CPP].[StartPromoDate] AND [CPP].[FinishPromoDate]
					ORDER BY [CPP].[PointPromoWeight] DESC;
					
					SET @ForzaPointsGenerationType = (	SELECT	[CP].[Value]
														FROM	[dbo].[ConfigParams] CP
														WHERE	[CP].[Name] = 'ForzaPointsGenerationType'
															AND [CP].[Status] = 1);

					SET @ForzaPointsGenerationValue = ( SELECT	[CP].[Value]
														FROM	[dbo].[ConfigParams] CP
														WHERE	[CP].[Name] = 'ForzaPointsGenerationValue'
															AND [CP].[Status] = 1);

					-- Datos generales de la guía para cálculo de puntos
					SELECT 
						TOP 1 
							@CustomerId = DO.IdCustomer,
							@AccountId = Acc.AccIdAccount,
							@GuidePrice = DO.PriceShippment,
							@GuideIsCollect = DO.IsCollect,
							@MembershipId = ISNULL(MMBSHP.IdMembership, -1)
					FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
						INNER JOIN 
							[DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK)
							ON
								Do.IdCustomer = Acc.IdCustomer
						LEFT JOIN
							[DeliveryBackOffice].[dbo].[Membership] MMBSHP WITH(NOLOCK)
							ON
								Acc.AccIdAccount = MMBSHP.AccountId
								AND
								MMBSHP.RowStatus = 1
								AND
								MMBSHP.ExpirationDate >= GETDATE()
					WHERE
						DO.Guide_Serie = @GuideSerie
						AND
						DO.Guide_Number = @GuideNumber;

					-- Si es NULL asegurar dato como falso
					IF(ISNULL(@GuideIsCollect, 0) = 0)
						SET @GuideIsCollect = 0

					-- Revisar si la guía pertenece a servicios de monto fijo de membresía o suscripción
					-- Por membresía
					SELECT
						TOP 1
							@IsGuideValidForPoints = 0
					FROM
						[DeliveryBackOffice].[dbo].[MembershipSubscriptionLog] MSL WITH(NOLOCK)
						INNER JOIN
							[DeliveryBackOffice].[dbo].[Membership] MMBSHP WITH(NOLOCK)
							ON
								MSL.MembershipId = MMBSHP.IdMembership
								AND
								MSL.SubscriptionId IS NULL
					WHERE
						MSL.LogGuideSerie = @GuideSerie
						AND
						MSL.LogGuideNumber = @GuideNumber
						AND
						MSL.RowStatus = 1
						AND
						MSL.LogServiceNumber <= MMBSHP.MembershipMaxServiceFixedValue

					-- Por suscripción
					SELECT
						TOP 1
							@IsGuideValidForPoints = 0
					FROM
						[DeliveryBackOffice].[dbo].[MembershipSubscriptionLog] MSL WITH(NOLOCK)
						INNER JOIN
							[DeliveryBackOffice].[dbo].[Subscription] SBSCPN WITH(NOLOCK)
							ON
								MSL.MembershipId = SBSCPN.MembershipId
								AND
								MSL.SubscriptionId = SBSCPN.IdSubscription
					WHERE
						MSL.LogGuideSerie = @GuideSerie
						AND
						MSL.LogGuideNumber = @GuideNumber
						AND
						MSL.RowStatus = 1
						AND
						MSL.LogServiceNumber <= SBSCPN.SubscriptionMaxServiceFixedValue

					-- Si permanece NULL, entonces es valida para acumular puntos
					IF(@IsGuideValidForPoints IS NULL)
						SET @IsGuideValidForPoints = 1

					-- Revisar si existe en bitácora de puntos lógicamente activa
					SELECT
						TOP 1
							@GuideAlreadyInPointLog = 1
					FROM
						[DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL
					WHERE
						PBSL.GuideNumber = @GuideNumber
						AND
						PBSL.GuideSerie = @GuideSerie
						AND
						PBSL.RowStatus = 1

					-- Solo si se reconoce membresía activa y que guía es collect y que no este dentro de la bitácora de guías de membresía o que no se encuentre bajo y que no este ya en bitácora de puntos
					IF (@MembershipId > 0 AND @GuideIsCollect = 1 AND ISNULL(@IsGuideValidForPoints, 0) = 1 AND ISNULL(@GuideAlreadyInPointLog, 0) = 0)
						BEGIN

							-- Agregar Log de puntos 
							INSERT INTO 
								[DeliveryBackOffice].[dbo].[PointsByServiceLog] 
								(
									[MembershipId],
									[GuideSerie],
									[GuideNumber],
									[GuidePrice],
									[PointsReceived],
									[PointsConsumed],
									[TypeTransaction],
									[CatPointPromoId],
									[RowStatus],
									[DateCreated],
									[TokenCreated]
								)
							VALUES
								(
									@MembershipId,
									@GuideSerie,
									@GuideNumber, 
									@GuidePrice,
									(CASE
										WHEN @ForzaPointsGenerationType = 'SERVICIO' THEN CAST(@ForzaPointsGenerationValue AS INT)
										WHEN @ForzaPointsGenerationType = 'MONTO' THEN CAST((@GuidePrice / @ForzaPointsGenerationValue) AS INT)
										ELSE 0
									END),	 -- POINTS RECEIVED
									0,		-- POINTS CONSUMED
									@ForzaPointsGenerationType,
									NULL,
									1,
									SYSDATETIME(),
									@Token
								);

							-- Acumulación adicional por promoción
					
							IF ((SELECT COUNT(IdPointPromo) FROM @CatPointPromoTbl) > 0)
								BEGIN
									DECLARE @DayName NVARCHAR(20) = '';
									DECLARE @IsValidDay BIT = 0;

									SET @DayName = (SELECT DATENAME(dw, SYSDATETIME()));
									SET @IsValidDay =	CASE 
															WHEN @DayName = 'Monday'	THEN (SELECT TOP 1 Monday FROM @CatPointPromoTbl)
															WHEN @DayName = 'Tuesday'	THEN (SELECT TOP 1 Tuesday FROM @CatPointPromoTbl)
															WHEN @DayName = 'Wednesday' THEN (SELECT TOP 1 Wednesday FROM @CatPointPromoTbl)
															WHEN @DayName = 'Thursday'	THEN (SELECT TOP 1 Thursday FROM @CatPointPromoTbl)
															WHEN @DayName = 'Friday'	THEN (SELECT TOP 1 Friday FROM @CatPointPromoTbl)
															WHEN @DayName = 'Saturday'	THEN (SELECT TOP 1 Saturday FROM @CatPointPromoTbl)
															WHEN @DayName = 'Sunday'	THEN (SELECT TOP 1 Sunday FROM @CatPointPromoTbl)
															ELSE 0
														END
									IF (@IsValidDay = 1)
										BEGIN

											UPDATE		PSL
											SET			[PSL].[CatPointPromoId] = (SELECT IdPointPromo FROM @CatPointPromoTbl),
														[PSL].[PointsReceived] = [PSL].[PointsReceived] +	CASE 
																												WHEN @ForzaPointsGenerationType = 'SERVICIO' THEN CAST((SELECT PointPromoFactor FROM @CatPointPromoTbl) AS INT)
																												WHEN @ForzaPointsGenerationType = 'MONTO' THEN CAST([PSL].[PointsReceived] / (SELECT PointPromoFactor FROM @CatPointPromoTbl) AS INT)
																												ELSE 0
																											END
											FROM		[dbo].[PointsByServiceLog] PSL
											WHERE PSL.GuideSerie = @GuideSerie
											AND PSL.GuideNumber = @GuideNumber
											AND PSL.RowStatus = 1;
										END
								END

							-- Agregar puntos a membresía
							SET @PointsGenerated = ISNULL((SELECT	SUM([PSL].[PointsReceived])
													FROM	[dbo].[PointsByServiceLog] PSL
													WHERE	[PSL].[GuideSerie] = @GuideSerie
														AND [PSL].[GuideNumber] = @GuideNumber
														AND PSL.RowStatus = 1), 0);
					
							UPDATE	[dbo].[Membership] 
							SET		[AccumulatedPoints] = ISNULL([AccumulatedPoints], 0) + (@PointsGenerated),
									[AvailablePoints] = ISNULL([AvailablePoints], 0) + (@PointsGenerated)
							WHERE	[IdMembership] = @MembershipId;

						END

				END TRY
				BEGIN CATCH

				END CATCH
				-------------------FORZA POINTS.FIN------------------------------
                -- ********************************** PROCESO DE COD ********************************************************************************
                INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD
                (
                    GuideSerie,
                    GuideNumber,
                    CourierManId,
                    DataOriginId,
                    Token,
                    CustomerId
                )
                SELECT ord.Guide_Serie AS 'GuideSerie',
                       ord.Guide_Number AS 'GuideNumber',
                       (
                           SELECT TOP 1 IdCourierman
                           FROM DeliveryBackOffice.dbo.LogTokenPOD
                           WHERE LogTokenPOD = @Token
                       ) AS 'CourierManId',
                       @DataOriginId AS 'DataOriginId',
                       @Token AS 'Token',
                       cus.IdCustomer
                FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH (NOLOCK)
                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                        ON vp.CodeOfReference = ord.Sender_ID
                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                        ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber
                      AND Collect_OnDelivery > 0
                      AND StatusOrderId = 5
                UNION
                SELECT ord.Guide_Serie AS 'GuideSerie',
                       ord.Guide_Number AS 'GuideNumber',
                       (
                           SELECT TOP 1 IdCourierman
                           FROM DeliveryBackOffice.dbo.LogTokenPOD WITH (NOLOCK)
                           WHERE LogTokenPOD = @Token
                       ) AS 'CourierManId',
                       @DataOriginId AS 'DataOriginId',
                       @Token AS 'Token',
                       cus.IdCustomer
                FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH (NOLOCK)
                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                        ON vp.CodeOfReference = ord.Sender_ID
                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                        ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber
                      AND Collect_OnDelivery = 0
                      AND IsCollect = 'true'
                      AND StatusOrderId = 5
                UNION
                SELECT ord.Guide_Serie AS 'GuideSerie',
                       ord.Guide_Number AS 'GuideNumber',
                       (
                           SELECT TOP 1 IdCourierman
                           FROM DeliveryBackOffice.dbo.LogTokenPOD WITH (NOLOCK)
                           WHERE LogTokenPOD = @Token
                       ) AS 'CourierManId',
                       @DataOriginId AS 'DataOriginId',
                       @Token AS 'Token',
                       cus.IdCustomer
                FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH (NOLOCK)
                    INNER JOIN dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
                        ON ord.Guide_Serie = DOP.GuideSerie
                           AND ord.Guide_Number = DOP.GuideNumber
                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                        ON vp.CodeOfReference = ord.Sender_ID
                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                        ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber
                      AND IsCollect = 'false'
                      AND DOP.TimePlaId = 2
                      AND StatusOrderId = 5;
            -- ********************************** FIN PROCESO DE COD ********************************************************************************
            END;
        END;

        IF (@FullPayment > 0 OR @CODPayment > 0) -- si se intenta registrar un pago
        BEGIN
            DECLARE @PNumber VARCHAR(20) =
                    (
                        SELECT CONCAT(@GuideSerie, @GuideNumber)
                    );
            -- Guardar Costos
            EXEC [dbo].[SetPaymentCost] @TypeProduct = 1, --1 = Guia electronica
                                        @ProductNumber = @PNumber,
                                        @TblDetail = @TblDetail,
                                        @FullPayment = @FullPayment,
                                        @TypeCharge = 1,  -- 1 = costo de envío
                                        @Token = @Token,
                                        @CODPayment = @CODPayment;
        END;

		 IF(EXISTS(SELECT  Top 1 1 FROM [dbo].[DeliveryOrder] dlo WITH (NOLOCK) WHERE dlo.Guide_Serie = @GuideSerie AND dlo.Guide_Number = @GuideNumber AND dlo.IsLastMileReturn=1)) -- guía marcada para devolución
            BEGIN
		
			-- agregar guía marcada para devolución en tabla de proceso de COD
			  INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD
                                (
                                    GuideSerie,
                                    GuideNumber,
                                    DataOriginId,
                                    Token,
                                    CustomerId
                                )
                                SELECT @GuideSerie,
                                       @GuideNumber,
                                       @DataOriginId,
                                       @Token,
                                       cus.IdCustomer
                                FROM DeliveryOrder dlo WITH (NOLOCK)
                                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                                        ON vp.CodeOfReference = Case when  dlo.IsLastMileReturn = 1 AND  dlo.Sender_ID != 0  Then dlo.Sender_ID Else dlo.Receiver_ID End
                                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                                        ON cus.IdCustomer = ISNULL(dlo.IdCustomer, vp.CustomerID)
                                    LEFT JOIN ProcessedGuideCOD pcd WITH (NOLOCK)
                                        ON pcd.GuideSerie = dlo.Guide_Serie
                                           AND pcd.GuideNumber = dlo.Guide_Number
                                WHERE pcd.IdProcessedGuideCOD IS NULL AND dlo.Guide_Serie = @GuideSerie AND dlo.Guide_Number = @GuideNumber AND dlo.IsLastMileReturn=1 AND dlo.[IsCollect] = 1
                 END

		-- Actualizar ubicación de punto de visita correspondiente
		BEGIN TRY
		    
			DECLARE @CodeOfReference INT = 0;
			SET @CodeOfReference = 
			(
				ISNULL
				(
					(
						SELECT 
							TOP (1) 
								(
									CASE
										WHEN DO.[IsLastMileReturn] = 1 THEN [DO].[Sender_ID]
										ELSE [DO].[Receiver_ID]
									END
								)
						FROM 
							[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
						WHERE
							DO.[Guide_Serie] = @GuideSerie
							AND
							DO.[Guide_Number] = @GuideNumber
					)
				, 0)
			)

			IF( ISNULL(@CodeOfReference, 0) != 0 )
			BEGIN

				DECLARE @VPLatitude NVARCHAR(20)
				DECLARE @VPLongitude NVARCHAR(20)
				
				SELECT 
					@VPLatitude = vpc.Latitude
					,@VPLongitude = vpc.Longitude
				FROM VisitPointClient vpc WITH (NOLOCK)
				WHERE 
					vpc.CodeOfReference = @CodeOfReference

				IF 
					(RTRIM(LTRIM(ISNULL(@VPLatitude, ''))) <> '' AND RTRIM(LTRIM(ISNULL(@VPLongitude, ''))) <> '')
				BEGIN
					
					-- Punto de visita con ubicación existente
					IF 
						(RTRIM(LTRIM(ISNULL(@FixedLatitude, ''))) <> '' AND RTRIM(LTRIM(ISNULL(@FixedLongitude, ''))) <> '')
					BEGIN
					
						-- Si existe una ubicación para registrar
						-- Distancia (en metros) entre recolección y el punto de visita
						-- Se coloca en 10 metros para evitar actualizar puntos de visita con ubicación correcta
						IF ((GEOGRAPHY::STPointFromText (CONCAT('POINT (', @VPLongitude, ' ', @VPLatitude, ')'), 4326).STDistance(GEOGRAPHY::STPointFromText (CONCAT('POINT (', @FixedLongitude, ' ', @FixedLatitude, ')'), 4326)) ) < 10)
						BEGIN
							-- Si la distancia es menor a 10 metros
							-- Guardar última ubicación
							
							UPDATE
								[DeliveryBackOffice].[dbo].[VisitPointClient]
							SET
								LogLatitude = Latitude
								,LogLongitude = Longitude
								,TokenUpdated = @Token
								,DateUpdated = GETDATE()
							WHERE
								CodeOfReference = @CodeOfReference

							-- Guardar nueva ubicación de recolección
							UPDATE
								[DeliveryBackOffice].[dbo].[VisitPointClient]
							SET
								Latitude = @FixedLatitude
								,Longitude = @FixedLongitude
								,[Accuracy] = @Accuracy
								,TokenUpdated = @Token
								,DateUpdated = GETDATE()
							WHERE
								CodeOfReference = @CodeOfReference

						END
						ELSE
						BEGIN
							   
								-- Guardar nueva ubicación de recolección en "bitácora" para revisión
								UPDATE
									[DeliveryBackOffice].[dbo].[VisitPointClient]
								SET
									LogLatitude = @FixedLatitude
									,LogLongitude = @FixedLongitude
									,TokenUpdated = @Token
									,DateUpdated = GETDATE()
								WHERE
									CodeOfReference = @CodeOfReference

						END
					END

				END
				ELSE
				BEGIN
					
					-- Punto de visita sin ubicación registrada
					IF 
						(RTRIM(LTRIM(ISNULL(@FixedLatitude, ''))) <> '' AND RTRIM(LTRIM(ISNULL(@FixedLongitude, ''))) <> '')
					BEGIN

						-- Si existe una ubicación para registrar
						UPDATE
							[DeliveryBackOffice].[dbo].[VisitPointClient]
						SET
							Latitude = ISNULL(@FixedLatitude, Latitude)
							,Longitude = ISNULL(@FixedLongitude, Longitude)
							,TokenUpdated = @Token
							,DateUpdated = GETDATE()
						WHERE
							CodeOfReference = @CodeOfReference

					END
				END
			END

		END TRY
		BEGIN CATCH
		    
		END CATCH

    END TRY
    BEGIN CATCH
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide';
        ROLLBACK TRANSACTION;

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
		(   
			ERROR_MESSAGE(),     -- ErrorDescription - varchar(300)
		    ERROR_NUMBER(),     -- ErrorNumber - int
		    ERROR_PROCEDURE(),     -- ErrorProcedure - varchar(100)
		    ERROR_LINE(),     -- ErrorLine - int
		    NULL,     -- GuideSerie - nvarchar(2)
		    NULL,     -- GuideNumber - int
		    '',       -- TokenCreated - varchar(50)
		    GETDATE() -- DateCreated - datetime
		    )
    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        IF (@RInserted > 0)
            SELECT 1 AS 'StatusCode',
                   'Registro guardado correctamente' AS 'Description',
                   CONVERT(BIGINT, @@TRANCOUNT) AS 'NumTransferID',
                   @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide';
        ELSE
            SELECT 1 AS 'StatusCode',
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