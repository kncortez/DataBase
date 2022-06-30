
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
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-06-28>
-- Description:	< Agregar validación para saber si se tiene pagos con TC o Datafono en dbo.CostDetail>

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
    @ExcludeCODPyament BIT = 'false'
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
                FROM StatusOrder WITH(NOLOCK)
                WHERE OrderDescription = 'Reenviado a Express Center'
            ); --FDAPI-337
    --Se obtiene el IdDeliveryOption configurado
    DECLARE @IdDeliveryOption AS INT =
            (
                SELECT TOP 1
                       IdDeliveryOption 
                FROM DeliveryBackOffice.dbo.CatDeliveryOptions WITH(NOLOCK)
                WHERE Name = 'Express Center'
            ); --FDAPI-337
    --Se obtiene el IdDeliveryOption que tiene la guía
    DECLARE @IdDeliveryOptionGuide AS INT;
    DECLARE @IsExpress AS BIT;

    SELECT TOP 1
           @IdDeliveryOptionGuide = IdDeliveryOption,
           @IsExpress = IIF(ISNULL(kvp.KindOfVPName, '') = 'Express Center', 'true', 'false')
    FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
        LEFT JOIN dbo.VisitPointClient vpr WITH(NOLOCK)
            ON vpr.CodeOfReference = DeliveryOrder.Receiver_ID
        LEFT JOIN dbo.KindOfVPClient kvp WITH(NOLOCK)
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

    BEGIN TRANSACTION;

    BEGIN TRY

        -- asignar valor a la variable ModName
        SET @ModName = N'Courier App';

        -- convertir base64 a varbinary
        -- SET @PhotoDryVB = (CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@PhotoDryB64"))', 'varbinary(max)'));
        --SET @PhotoColdVB
        -- = (CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@PhotoColdB64"))', 'varbinary(max)'));

        -- buscar registros de tabla de entregas
        INSERT INTO @Table
        SELECT da.ID
        FROM DeliveryBackOffice.dbo.DeliveryAttempt da WITH(NOLOCK)
            JOIN DeliveryBackOffice.dbo.SenderReceiver sr WITH(NOLOCK)
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
                        FROM dbo.DeliveryOrder
                        WHERE Guide_Serie = @GuideSerie
                              AND Guide_Number = @GuideNumber
                    );



            IF @StatusId NOT IN ( 5, 22 ) -- estado etregado
            BEGIN

                PRINT 'ACUTALIZADO DELIVERYORDER';
                PRINT @ExcludeCODPyament;
                -- actualizar tabla de registro de guías electrónicas
                UPDATE DeliveryBackOffice.dbo.DeliveryOrder
                SET NameOfReceiver = @ReceiverName,
                    StatusOrderId = IIF(@IdDeliveryOptionGuide = @IdDeliveryOption,
                                        @StatusEXC,
                                        IIF(@IsExpress = 'true', @StatusEXC, 5)),
                    LastCollectOnDelivery = IIF(@ExcludeCODPyament = 'false', null, Collect_OnDelivery),
                    Collect_OnDelivery = IIF(@ExcludeCODPyament = 'true', 0, Collect_OnDelivery) -- 2021-09-09 si el flag de exlucion de pago COD es true actualizar monto COD a 0
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber;

                DECLARE @Observation NVARCHAR(200) = NULL;

                SELECT TOP 1
                       @Observation = CONCAT(ISNULL(td.Voucher, ''), ' ', ISNULL(td.Responsible, ''))
                FROM @TblDetail td
                WHERE LEN(ISNULL(td.Responsible, '')) > 0;

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
                 IIF(@IdDeliveryOptionGuide = @IdDeliveryOption, @StatusEXC, IIF(@IsExpress = 'true', @StatusEXC, 5)),
                 @Token, GETDATE(), GETDATE(), NULL,
                 IIF(LEN(@Observation) > 0, CONCAT('ENTREGA SIN COBRO COD ', @Observation), ''));

                SET @RInserted = @@ROWCOUNT;

                SELECT @DataOriginId = cm.ModIdModule
                FROM DeliveryBackOffice.dbo.CatModule cm
                WHERE cm.ModName = @ModName;
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
                           SELECT IdCourierman
                           FROM DeliveryBackOffice.dbo.LogTokenPOD
                           WHERE LogTokenPOD = @Token
                       ) AS 'CourierManId',
                       @DataOriginId AS 'DataOriginId',
                       @Token AS 'Token',
                       cus.IdCustomer
                FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH(NOLOCK)
                    LEFT JOIN dbo.VisitPointClient vp WITH(NOLOCK)
                        ON vp.CodeOfReference = ord.Sender_ID
                    LEFT JOIN dbo.Customer cus WITH(NOLOCK)
                        ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber
                      AND Collect_OnDelivery > 0
                      AND StatusOrderId = 5
                UNION
                SELECT ord.Guide_Serie AS 'GuideSerie',
                       ord.Guide_Number AS 'GuideNumber',
                       (
                           SELECT IdCourierman
                           FROM DeliveryBackOffice.dbo.LogTokenPOD WITH(NOLOCK)
                           WHERE LogTokenPOD = @Token
                       ) AS 'CourierManId',
                       @DataOriginId AS 'DataOriginId',
                       @Token AS 'Token',
                       cus.IdCustomer
                FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH(NOLOCK)
                    LEFT JOIN dbo.VisitPointClient vp WITH(NOLOCK)
                        ON vp.CodeOfReference = ord.Sender_ID
                    LEFT JOIN dbo.Customer cus WITH(NOLOCK)
                        ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber
                      AND Collect_OnDelivery = 0
                      AND IsCollect = 'true'
                      AND StatusOrderId = 5
					   AND NOT EXISTS (SELECT
							Top 1 1
						FROM [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
						JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
							ON CD.IdCost = C.IdCost
						AND CD.IdTypeOfMoney IN (2, 6)
						WHERE C.ProductNumber = CONCAT(@GuideSerie, CAST(@GuideNumber AS VARCHAR(50))))
                UNION
                SELECT ord.Guide_Serie AS 'GuideSerie',
                       ord.Guide_Number AS 'GuideNumber',
                       (
                           SELECT IdCourierman
                           FROM DeliveryBackOffice.dbo.LogTokenPOD WITH(NOLOCK)
                           WHERE LogTokenPOD = @Token
                       ) AS 'CourierManId',
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
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber
                      AND IsCollect = 'false'
                      AND DOP.TimePlaId = 2
                      AND StatusOrderId = 5
					  AND NOT EXISTS (SELECT
							Top 1 1
						FROM [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
						JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
							ON CD.IdCost = C.IdCost
						AND CD.IdTypeOfMoney IN (2, 6)
						WHERE C.ProductNumber = CONCAT(@GuideSerie, CAST(@GuideNumber AS VARCHAR(50))));
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

    END TRY
    BEGIN CATCH
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide';
        ROLLBACK TRANSACTION;
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



