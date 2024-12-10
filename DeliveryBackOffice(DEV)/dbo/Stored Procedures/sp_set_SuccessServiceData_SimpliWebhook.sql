
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-09-30>
-- Description:	< Realiza updates en las tablas de ExtPlatformService e ingresa datos como el SP SetProofOnDelivery >
-- =============================================
-- Author:		<Tito Garcia>
-- Updated date:<18-11-2024>
-- Description:	<Se agrega nueva validación IsCompleted>
-- =============================================
CREATE PROCEDURE [dbo].[sp_set_SuccessServiceData_SimpliWebhook]
	-- DATA PLAN
	@PlanID NVARCHAR(50),
	-- DATA ROUTE
	@RouteID NVARCHAR(50),
	@RouteDriverID INT = 0,
	@RouteDriverName NVARCHAR(200) = '',
	-- DATA VISIT
	@VisitID INT,
	@VisitReference NVARCHAR(15),
	@VisitNewStatus NVARCHAR(30),
	@VisitCheckin DATETIME = NULL, -- PUEDE QUE FALTE DATO DEL CHECKIN
	@VisitCheckout DATETIME,
	@VisitCheckoutLat DECIMAL(18,15) = 0.0, -- PUEDE QUE POR FALTA DE INTERNET ESTE DATO NO ESTE DISPONIBLE O VENGA CON DATOS NO EXACTOS
	@VisitCheckoutLng DECIMAL(18,15) = 0.0, -- PUEDE QUE POR FALTA DE INTERNET ESTE DATO NO ESTE DISPONIBLE O VENGA CON DATOS NO EXACTOS
	@VisitCheckoutObservation NVARCHAR(200) = '', -- OBSERVACION O INCIDENCIA
	@VisitCheckoutNotes NVARCHAR(200) = '', -- NOTAS DEL COURIERMAN
	@VisitReceiver NVARCHAR(200) = '',
	-- DATA SERVICE
	@ServicePaymentType INT = NULL,
	@ServiceTotalPrice DECIMAL(12,2) = 0,
	@ServicePrice DECIMAL(12,2) = 0,
	@ServiceCoD DECIMAL(12,2) = 0,
	@ServiceVoucher NVARCHAR(200) = '',
	@ServiceVoucherResponsible NVARCHAR(200) = '',
	@ServiceCoDIgnore BIT = 'false',
	-- DATA SIGNATURE AND PICTURES
	@SignatureLink NVARCHAR(200) = '',
	@PictureDryLink NVARCHAR(MAX) = '',
	@PictureColdLink NVARCHAR(MAX) = ''
AS
BEGIN
	-- control de inserciones para transacción
    DECLARE @RInserted INT;
    -- control de inserción de imagen en tabla de fotografías
    DECLARE @ID_Photo INT;
    -- variables auxiliares para conversión de imagen de base64 a varbinary
	-- DE MOMENTO SIMPLIROUTE MANDA LO QUE SON LINKS DE IMAGENES ALMACENADAS EN AWS S3 (30/09/2021)
    DECLARE @PhotoDryVB VARBINARY(MAX);
    DECLARE @PhotoColdVB VARBINARY(MAX); 
	-- tabla temporal para actualizar registros encontrados
    DECLARE @Table AS TABLE
    (
        ID INT
    );

	DECLARE @TablePhotoID AS TABLE
	(
		ID INT
	);
	
	-- DATOS AUXILIAR 
	DECLARE @GuideSerie NVARCHAR(2) = LEFT(@VisitReference,2);
	DECLARE @GuideNumber INT = CAST( (SUBSTRING(@VisitReference,3,LEN(@VisitReference))) AS INT );
		
    -- variable para obtener el módulo de origen de los datos
    DECLARE @DataOriginId INT;
    -- variable para setear el nombre del módulo del cuál se desea obtener su id
    DECLARE @ModName NVARCHAR(50);
	--Estado para Reenviado a Express Center
	DECLARE @StatusEXC AS INT = ( SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription = 'Reenviado a Express Center') --FDAPI-337
	--Se obtiene el IdDeliveryOption configurado
	DECLARE @IdDeliveryOption AS INT  = (SELECT IdDeliveryOption FROM DeliveryBackOffice.dbo.CatDeliveryOptions WHERE Name = 'Express Center') --FDAPI-337
	--Se obtiene el IdDeliveryOption que tiene la guía
	DECLARE @IdDeliveryOptionGuide AS INT  = (SELECT IdDeliveryOption FROM DeliveryBackOffice.dbo.DeliveryOrder WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber ) --FDAPI-337

	IF OBJECT_ID('tempdb.dbo.#InsertedRecordT', 'U') IS NOT NULL
		DROP TABLE #InsertedRecordT;

	CREATE TABLE #InsertedRecordT (
		GuideNumber INT,
		GuideSerie  NVARCHAR(2),
		IdProcessedGuideCOD INT
	);
	CREATE NONCLUSTERED INDEX INDX_ProcessedGuideCOD_Te ON #InsertedRecordT (GuideSerie, GuideNumber);

	BEGIN TRANSACTION
	BEGIN TRY
		-- PROCESO DE OBTENCION DE DATOS
		SET @ModName = N'Webhooks Externos';
        -- convertir base64 a varbinary
        SET @PhotoDryVB = CAST(@PictureDryLink AS VARBINARY);
        SET @PhotoColdVB = CAST(@PictureColdLink AS VARBINARY);

		SELECT @DataOriginId = cm.ModIdModule
		FROM DeliveryBackOffice.dbo.CatModule cm
		WHERE cm.ModName = @ModName;
		
		DECLARE @DatosCourier AS TABLE(
			IdCourierman INT,
			Token NVARCHAR(50)
		)

		INSERT INTO @DatosCourier
		SELECT TOP 1
			sr.ID,
			ltpod.LogTokenPOD
		FROM
			dbo.SenderReceiver sr
			JOIN dbo.LogTokenPOD ltpod
			ON sr.ID = ltpod.IdCourierman
		WHERE
			sr.CUI = @RouteDriverName
			AND
			ltpod.RowStatus = 1
		ORDER BY ltpod.DateCreated DESC;

		-- ACTUALIZAR VISITAS DE PLATAFORMA EXTERNA
		UPDATE DeliveryBackOffice.dbo.ExtPlatformService
		SET
			[StartServiceDateTime] = @VisitCheckin,
			[EndServiceDateTime] = @VisitCheckout,
			[CheckoutLatitude] = @VisitCheckoutLat,
			[CheckoutLongitude] = @VisitCheckoutLng,
			[Observation] = @VisitCheckoutObservation,
			[ServiceStatus] = @VisitNewStatus,
			[TokenUpdated] = (SELECT Token FROM @DatosCourier) ,
			[DateUpdated] = GETDATE()
		WHERE 
			DeliveryBackOffice.dbo.ExtPlatformService.IdService = @VisitID;

		-- PROCESO NORMAL DE SET PROOF ON DELIVERY 

		-- BUSCAR REGISTROS DE TABLA DE ENTREGAS
		INSERT INTO @Table
        SELECT da.ID
        FROM DeliveryBackOffice.dbo.DeliveryAttempt da
            JOIN DeliveryBackOffice.dbo.SenderReceiver sr
                ON sr.ID = da.ID_Courier
        WHERE sr.CUI LIKE '%' + @RouteDriverName + '%'
              AND da.Guide_Serie = @GuideSerie
              AND da.Guide_Number = @GuideNumber
              AND CONVERT(VARCHAR, da.Date_Created, 23) = CONVERT(VARCHAR, GETDATE(), 23);

		-- MANEJO DE IMAGENES
		INSERT INTO DeliveryBackOffice.dbo.DeliveryProof
        (
            Guide_Serie,
            Guide_Number,
            Date_Photo,
            Proof_Dry,
            Proof_Cold,
            PathSignature
        )
		OUTPUT inserted.ID INTO @TablePhotoID(ID)
        VALUES
        (@GuideSerie, @GuideNumber, GETDATE(), @PhotoDryVB, @PhotoColdVB, @SignatureLink);
        SET @ID_Photo = (SELECT TOP 1 ID FROM @TablePhotoID ORDER BY ID DESC);

		IF (@ID_Photo > 0)
			BEGIN
				-- SI IMAGENES INSERTADAS
			UPDATE DeliveryBackOffice.dbo.DeliveryAttempt
			SET 
				Delivered = 1,
				ID_Proof = @ID_Photo,
				Latitude = @VisitCheckoutLat,
				Longitude = @VisitCheckoutLng
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

			-- ACTLUALIZAR DELIVERY ORDER
			IF @StatusId != 5
			BEGIN
				-- ACTUALIZAR DELIVRY ORDER - TABLA DE REGISTRO DE GUIAS ELECTRONICAS
				UPDATE DeliveryBackOffice.dbo.DeliveryOrder
				SET
					NameOfReceiver = @VisitReceiver,
					StatusOrderId = IIF(@IdDeliveryOptionGuide = @IdDeliveryOption, @StatusEXC, 5),
					LastCollectOnDelivery = IIF(@ServiceCoDIgnore = 'false', 0, Collect_OnDelivery),
					Collect_OnDelivery = IIF(@ServiceCoDIgnore = 'true', 0, Collect_OnDelivery)
				WHERE
					DeliveryBackOffice.dbo.DeliveryOrder.Guide_Serie = @GuideSerie
					AND
					DeliveryBackOffice.dbo.DeliveryOrder.Guide_Number = @GuideNumber;

				DECLARE @Observation NVARCHAR(200) = NULL;

				SET @Observation = IIF(LEN(@ServiceVoucherResponsible)>0, CONCAT( ISNULL(@ServiceVoucher, ''), ' ', ISNULL(@ServiceVoucherResponsible, '') ), '' ) ;

				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
				(
					[Guide_Serie]
					, [Guide_Number]
					, [StatusOrderId]
					, [UserCreated]
					, [DateCreated]
					, [DateCreatedInSystem]
					, [Temperature_Celsius]
					, [Observations]
				)
				VALUES
				(
					@GuideSerie
					, @GuideNumber
					, IIF(@IdDeliveryOptionGuide = @IdDeliveryOption, @StatusEXC, 5)
					, (SELECT Token FROM @DatosCourier)
					, GETDATE()
					, GETDATE()
					, NULL
					, IIF(LEN(@Observation) > 0, CONCAT('ENTREGA SIN COBRO COD ', @Observation), @VisitCheckoutNotes)
				);

				SET @RInserted = @@ROWCOUNT;

				-- PROCESO COD

				INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD
				(
					GuideSerie,
					GuideNumber,
					CourierManId,
					DataOriginId,
					Token,
					Date
				)
				OUTPUT
					inserted.GuideSerie,
					inserted.GuideNumber,
					inserted.IdProcessedGuideCOD
				INTO #InsertedRecordT
				SELECT Guide_Serie AS 'GuideSerie',
						Guide_Number AS 'GuideNumber',
						(
							SELECT IdCourierman
							FROM @DatosCourier
						) AS 'CourierManId',
						@DataOriginId AS 'DataOriginId',
						(
							SELECT Token
							FROM @DatosCourier
						) AS 'Token',
						GETDATE()
				FROM DeliveryBackOffice.dbo.DeliveryOrder
				WHERE Guide_Serie = @GuideSerie
						AND Guide_Number = @GuideNumber
						AND Collect_OnDelivery > 0
						AND StatusOrderId = 5;
			END
		END
		-- SI SE INTENTA REGISTAR COBRO
		IF (@ServicePrice > 0 OR @ServiceCoD > 0) -- si se intenta registrar un pago
        BEGIN
            DECLARE @PNumber VARCHAR(20) =
                    (
                        SELECT CONCAT(@GuideSerie, @GuideNumber)
                    );
			DECLARE @TblDetail TblPaymentList;
			INSERT INTO @TblDetail (RowNumber,Amount,IdTypeOfMoney,Voucher,Responsible)
			VALUES(
				1, @ServicePrice, @ServicePaymentType, @ServiceVoucher, @ServiceVoucherResponsible
			)
            -- Guardar Costos
			DECLARE @TokenCourier NVARCHAR(50) = (SELECT Token FROM @DatosCourier);
            EXEC [dbo].[SetPaymentCost] @TypeProduct = 1, --1 = Guia electronica
                                        @ProductNumber = @PNumber,
                                        @TblDetail = @TblDetail,
                                        @FullPayment = @ServicePrice,
                                        @TypeCharge = 1,  -- 1 = costo de envío
                                        @Token = @TokenCourier,
                                        @CODPayment = @ServiceCoD;
        END;
	END TRY
	BEGIN CATCH
		SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide';
        ROLLBACK TRANSACTION;
	END CATCH
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
		
		UPDATE PG
		SET IsCompleted = 1
		FROM DeliveryBackOffice.dbo.ProcessedGuideCOD PG  WITH(NOLOCK)
		INNER JOIN #InsertedRecordT IR
			ON PG.GuideSerie = IR.GuideSerie
				AND PG.GuideNumber = IR.GuideNumber
		WHERE PG.IdProcessedGuideCOD = IR.IdProcessedGuideCOD;

		IF OBJECT_ID('tempdb.dbo.#InsertedRecordT', 'U') IS NOT NULL
			DROP TABLE #InsertedRecordT;
    END;
    ELSE
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide';
END
