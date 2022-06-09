
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-09-30>
-- Description:	< Realiza updates en las tablas de ExtPlatformService e ingresa datos como el SP SetIncidenceService >
-- =============================================

CREATE PROCEDURE [dbo].[sp_set_FailServiceData_SimpliWebhook]
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
	-- DATA SIGNATURE AND PICTURES
	@IDIncident INT = 0,
	@PictureIncidentLink NVARCHAR(MAX) = ''
AS
BEGIN
	-- control de inserciones para transacción
    DECLARE @RInserted INT;
    -- control de inserción de imagen en tabla de fotografías
    DECLARE @ID_Photo INT;
	-- variables auxiliares para conversión de imagen de base64 a varbinary
	-- DE MOMENTO SIMPLIROUTE MANDA LO QUE SON LINKS DE IMAGENES ALMACENADAS EN AWS S3 (30/09/2021)
	DECLARE @PhotoIncidentVB VARBINARY(MAX)
	-- tabla temporal para actualizar registros encontrados
    DECLARE @Table AS TABLE
    (
        ID INT
    );
		
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
	
	-- DATOS AUXILIAR 
	DECLARE @GuideSerie NVARCHAR(2) = LEFT(@VisitReference,2);
	DECLARE @GuideNumber INT = CAST( (SUBSTRING(@VisitReference,3,LEN(@VisitReference))) AS INT );
		
	BEGIN TRANSACTION
	BEGIN TRY
        -- convertir base64 a varbinary
		SET @PhotoIncidentVB = CAST (@PictureIncidentLink AS VARBINARY)

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
            Proof_Incident
        )
        VALUES
        (@GuideSerie, @GuideNumber, GETDATE(), @PhotoIncidentVB);
        SET @ID_Photo = SCOPE_IDENTITY();
		
		-- SI IMAGENES INSERTADAS
		IF (@ID_Photo > 0)
			BEGIN
			UPDATE DeliveryBackOffice.dbo.DeliveryAttempt
			SET 
				ID_Incident = @IDIncident,
				ID_Proof = @ID_Photo,
				Latitude = @VisitCheckoutLat,
				Longitude = @VisitCheckoutLng
			WHERE ID IN	
				(
					SELECT ID FROM @Table
				);
			-- ACTUALIZAR DELIVRY ORDER - TABLA DE REGISTRO DE GUIAS ELECTRONICAS
			UPDATE DeliveryBackOffice.dbo.DeliveryOrder
			SET
				StatusOrderId = 12
			WHERE
				DeliveryBackOffice.dbo.DeliveryOrder.Guide_Serie = @GuideSerie
				AND
				DeliveryBackOffice.dbo.DeliveryOrder.Guide_Number = @GuideNumber;

			INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
			(
				[Guide_Serie]
				, [Guide_Number]
				, [StatusOrderId]
				, [UserCreated]
				, [DateCreated]
				, [DateCreatedInSystem]
				, [Observations]
				, [Temperature_Celsius]
			)
			VALUES
			(
				@GuideSerie
				, @GuideNumber
				, 12
				, (SELECT Token FROM @DatosCourier)
				, GETDATE()
				, GETDATE()
				, @VisitCheckoutObservation
				, NULL
			);

			SET @RInserted = @@ROWCOUNT;

		END
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
    END;
    ELSE
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               @GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide';
END
