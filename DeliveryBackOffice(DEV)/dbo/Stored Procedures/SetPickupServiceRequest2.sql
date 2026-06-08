-- =============================================
-- Author:      <Juan, Ramirez>
-- Create date: <2025-06-05>
-- Modified:    Optimización de rendimiento
-- Description: Creación de servicio de recolección por medio de API
-- Optimizado:	José Miguel Chuy Ochoa
-- =============================================
CREATE PROCEDURE [dbo].[SetPickupServiceRequest2]
(
  @CodeOfReference  AS BIGINT,
  @StartDate        AS DATETIME,
  @EndDate          AS DATETIME,
  @QuantityOfPieces AS INT,
  @TypeVehicle      AS INT = 2,  -- 2 Panel
  @CodeApp          AS NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON; -- [OPT-1] Evita el overhead de mensajes de filas afectadas en cada operación

    DECLARE @SchedulePickupFinded           AS BIGINT       = 0,
            @ServiceManagementFinded        AS INT,
            @CatServiceStatusFinded         AS NVARCHAR(50),
            @ResultService                  AS BIGINT,
            @IdResult                       AS INT          = 0,
            @ErrorMessage                   AS NVARCHAR(500) = '',
            @IsSuccess                      AS BIT          = 0,
            @Today                          AS DATE         = GETDATE(),
            @TodayTime                      AS DATETIME     = GETDATE(),  -- [OPT-2] GETDATE() llamado una sola vez y guardado en variable
            @InsdTypeVehicle                AS INT          = 2,
            @InsdDescTypeVehicle            AS NVARCHAR(500),
            @IdCountry                      AS NVARCHAR(2),
            @LimitHour                      AS NVARCHAR(5),
            @TransactionStarted             AS INT          = 0,
            @ResultStartDate                AS DATETIME     = NULL,
            @ResultEndDate                  AS DATETIME     = NULL,
            @ResultTypeVehiculeId           AS INT,
            @ResultQuantityRegularPackages  AS INT          = NULL,
            @StartDateOnly                  AS DATE,        -- [OPT-3] Se pre-castea una vez para evitar CONVERT/CAST repetidos
            @addressPickUp                  AS VARCHAR(500),
            @nameSender                     AS VARCHAR(200),
            @phoneSender                    AS VARCHAR(50),
            @idHub                          AS INT,
            @idTownship                     AS INT,
            @idProvince                     AS INT;

    -- [OPT-3] Pre-calcular el CAST de fecha una sola vez
    SET @StartDateOnly = CAST(@StartDate AS DATE);

    BEGIN TRY
        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @TransactionStarted = 1;
        END

        -- -----------------------------------------------------------------------
        -- VALIDACIÓN: Fecha anterior al día actual --> salida inmediata
        -- [OPT-4] Se valida primero la condición más barata antes de ir a la BD
        -- -----------------------------------------------------------------------
        IF @StartDateOnly < @Today
        BEGIN
            SELECT @IdResult      = 409,
                   @ErrorMessage  = 'No es posible solicitar una recolección para un día anterior al día actual',
                   @IsSuccess     = 1,
                   @ResultService = 0;

            -- Commit y salida temprana para no ejecutar lógica innecesaria
            IF @TransactionStarted = 1
            BEGIN
                COMMIT TRANSACTION;
                SET @TransactionStarted = 0;
            END
            GOTO FinalSelect; -- [OPT-5] Salida temprana con GOTO evita anidamiento profundo
        END

        -- -----------------------------------------------------------------------
        -- 1. Verificar si ya existe un servicio de recolección para ese día
        --    [OPT-6] Se usa CAST en columna indexable en lugar de CONVERT en la
        --            columna para permitir uso de índices (si existe índice en StartDate)
        --            Se evita CONVERT(DATE, SP.StartDate) y se usa rango de fechas.
        -- -----------------------------------------------------------------------
        DECLARE @StartOfDay AS DATETIME = @StartDateOnly,
                @EndOfDay   AS DATETIME = DATEADD(DAY, 1, @StartDateOnly);

        SELECT TOP 1                            -- [OPT-7] TOP 1 por si hay duplicados, evita trabajo extra
               @SchedulePickupFinded           = SP.SchedulePickupId,
               @ServiceManagementFinded        = SM.IdServiceManagement,
               @CatServiceStatusFinded         = cs.[name],
               @ResultStartDate                = sp.StartDate,
               @ResultEndDate                  = sp.EndDate,
               @ResultTypeVehiculeId           = sp.TypeVehicleId,
               @ResultQuantityRegularPackages  = sp.QuantityRegularPackages
          FROM dbo.SchedulePickup sp WITH (NOLOCK)
               LEFT JOIN dbo.ServiceManagement sm WITH (NOLOCK)
                    ON sm.IdSchedulePickup = sp.SchedulePickupId
               LEFT JOIN DeliveryBackOffice.dbo.CatServiceStatus cs WITH (NOLOCK)
                    ON cs.IdServiceStatus = sm.ServiceStatusId
         WHERE sp.SenderId = @CodeOfReference
           AND sp.RowStatus = 1
           AND (sp.SchedulePickupStatus IS NULL OR sp.SchedulePickupStatus = 1)
           AND sm.RowStatus = 1
           -- [OPT-6] Rango de fechas en lugar de CONVERT en columna --> sargable
           AND sp.StartDate >= @StartOfDay
           AND sp.StartDate  < @EndOfDay;

        IF @SchedulePickupFinded > 0
        BEGIN
            -- [OPT-8] Se elimina la 2da. consulta CatTypeVehicle; la descripción se puede derivar del ID sin ir a la BD de nuevo.
            SET @ResultTypeVehiculeId = CASE @ResultTypeVehiculeId
                                            WHEN 1 THEN 1  -- Motocicleta
                                            WHEN 2 THEN 2  -- Panel
                                            WHEN 3 THEN 3  -- Camión
                                            ELSE 2         -- Panel por defecto
                                        END;

            IF @ServiceManagementFinded > 0
                SELECT @IdResult                       = 409,
                       @ErrorMessage                   = CONCAT('Ya fue solicitado un servicio de recolección el día de hoy para este Punto de Visita ',
                                                                '/ En estado: ', @CatServiceStatusFinded),
                       @IsSuccess                      = 1,
                       @ResultService                  = @ServiceManagementFinded,
                       @ResultStartDate                = FORMAT(@ResultStartDate, 'd/MM/yyyy HH:mm:ss'),
                       @ResultEndDate                  = FORMAT(@ResultEndDate,   'd/MM/yyyy HH:mm:ss'),
                       @ResultQuantityRegularPackages  = @ResultQuantityRegularPackages;
            ELSE
                SELECT @IdResult                       = 409,
                       @ErrorMessage                   = 'Ya fue solicitado un servicio de recolección el día de hoy para este punto de Visita pero ocurrió un error',
                       @IsSuccess                      = 1,
                       @ResultService                  = 0,
                       @ResultStartDate                = FORMAT(@ResultStartDate, 'd/MM/yyyy HH:mm:ss'),
                       @ResultEndDate                  = FORMAT(@ResultEndDate,   'd/MM/yyyy HH:mm:ss'),
                       @ResultQuantityRegularPackages  = @ResultQuantityRegularPackages;

            IF @TransactionStarted = 1
            BEGIN
                COMMIT TRANSACTION;
                SET @TransactionStarted = 0;
            END
            GOTO FinalSelect;
        END

        -- -----------------------------------------------------------------------------------------------------------------------------------
        -- 2. Obtener datos del Punto de Visita y Hub en una sola consulta
        --    [OPT-9] Consolido la lectura de DefaultValuesPerCountry dentro del mismo SELECT mediante OUTER APPLY para evitar un segundo
        --            round-trip a la BD.
        -- -----------------------------------------------------------------------------------------------------------------------------------
        SELECT @nameSender    = ISNULL(Cu.[Name], ''),
               @phoneSender   = CASE
                                    WHEN vpc.Phone LIKE '(%' THEN
                                        ISNULL(TRANSLATE(SUBSTRING(vpc.Phone, CHARINDEX(')', vpc.Phone) + 1, LEN(vpc.Phone)), '()- ', '    '), '')
                                    ELSE
                                        ISNULL(TRANSLATE(vpc.Phone, '()- ', '    '), '')
                                END,
               @addressPickUp = ISNULL(VPC.[Address], ''),
               @idTownship    = ISNULL(VPC.IdTownship, 0),
               @idHub         = ISNULL(HL.IdHubLogistic, 0),
               @idProvince    = ISNULL(Tw.IdProvince, 0),
               @IdCountry     = ISNULL(Cu.CountryID, 'GT'),
               -- [OPT-9] LimitHour obtenido en la misma consulta
               @LimitHour     = dfv.LimitHourPickupByApi
          FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
               LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] Cu WITH (NOLOCK)
                    ON Cu.IdCustomer = VPC.CustomerID
               LEFT JOIN [DeliveryBackOffice].[dbo].[Township] Tw WITH (NOLOCK)
                    ON Tw.IdTownship = VPC.IdTownship
               OUTER APPLY (
                    SELECT TOP 1
                           DSC.HeaderCode,
                           MAX(DSC.Hub) AS [Hub]
                      FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH (NOLOCK)
                     WHERE DSC.RowStatus = 1
                       AND DSC.HeaderCode = Tw.HeaderCode
                     GROUP BY DSC.HeaderCode
               ) DSC
               LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics] HL WITH (NOLOCK)
                    ON HL.HubAbbreviation = DSC.Hub
               -- [OPT-9] JOIN directo con DefaultValuesPerCountry
               LEFT JOIN DeliveryBackOffice.dbo.DefaultValuesPerCountry dfv WITH (NOLOCK)
                    ON dfv.IdCountry = Cu.CountryID
         WHERE VPC.CodeOfReference = @CodeOfReference
           AND (Cu.RowSatus = 1 OR Cu.RowSatus IS NULL)
           AND VPC.StatusClient = 1;

        -- -----------------------------------------------------------------------
        -- 3. Validar límite horario
        -- -----------------------------------------------------------------------
        IF NOT (
               (CONVERT(TIME, @TodayTime) <= @LimitHour AND @StartDateOnly = @Today)
               OR (@StartDateOnly > @Today)
           )
        BEGIN
            SELECT @IdResult      = 409,
                   @ErrorMessage  = CONCAT('Las solicitudes de recolección no pueden solicitarse después de las ', ISNULL(@LimitHour, '17:00'), ' hrs.'),
                   @IsSuccess     = 1,
                   @ResultService = 0;

            IF @TransactionStarted = 1
            BEGIN
                COMMIT TRANSACTION;
                SET @TransactionStarted = 0;
            END
            GOTO FinalSelect;
        END

        -- -----------------------------------------------------------------------------------------------------------------------------------
        -- 4. Validaciones de datos del punto de visita
        --    [OPT-10] Un solo IF con todas las condiciones negativas para no evaluar caso a caso cuando hay múltiples errores posibles.
        --             Se mantiene la lógica original de reporte individual de error.
        -- -----------------------------------------------------------------------
        IF LEN(@addressPickUp) <= 0
        BEGIN
            SELECT @IdResult = 400, @IsSuccess = 0,
                   @ErrorMessage = 'La dirección del punto de visita indicado está vacía / No es posible procesar la solicitud';
            GOTO RollbackAndSelect;
        END
        ELSE IF LEN(@nameSender) <= 0
        BEGIN
            SELECT @IdResult = 400, @IsSuccess = 0,
                   @ErrorMessage = 'El nombre del cliente relacionado al punto de visita está vacío / No es posible procesar la solicitud';
            GOTO RollbackAndSelect;
        END
        ELSE IF ISNULL(@idProvince, 0) <= 0
        BEGIN
            SELECT @IdResult = 400, @IsSuccess = 0,
                   @ErrorMessage = 'El Id de Provincia del punto de visita indicado está vacío / No es posible procesar la solicitud';
            GOTO RollbackAndSelect;
        END
        ELSE IF ISNULL(@idTownship, 0) <= 0
        BEGIN
            SELECT @IdResult = 400, @IsSuccess = 0,
                   @ErrorMessage = 'El Id de Poblado del punto de visita indicado está vacío / No es posible procesar la solicitud';
            GOTO RollbackAndSelect;
        END
        ELSE IF LEN(@phoneSender) <= 0
        BEGIN
            SELECT @IdResult = 400, @IsSuccess = 0,
                   @ErrorMessage = 'El Número de teléfono asociado al punto de visita está vacío / No es posible procesar la solicitud';
            GOTO RollbackAndSelect;
        END
        ELSE IF ISNULL(@idHub, 0) <= 0
        BEGIN
            SELECT @IdResult = 400, @IsSuccess = 0,
                   @ErrorMessage = 'El cliente no tiene cobertura con ningún Hub para el punto de visita indicado / No es posible procesar la solicitud';
            GOTO RollbackAndSelect;
        END

        -- ---------------------------------------------------------------------------------------------------------------
        -- 5. Determinar tipo de vehículo y obtener su ID
        --    [OPT-11] Se evita el CASE que convierte INT --> descripción solo para buscar el mismo ID de vuelta. 
		--    Se hace el lookup directo por ID.
		-- ---------------------------------------------------------------------------------------------------------------
        IF @EndDate IS NULL
            SET @EndDate = DATEADD(HOUR, 2, @StartDate);

        SELECT @InsdTypeVehicle = IdTypeVehicle
          FROM DeliveryBackOffice.dbo.CatTypeVehicle WITH (NOLOCK)
         WHERE IdTypeVehicle = @TypeVehicle  -- [OPT-11] Lookup directo por ID, no por nombre
           AND IdCountry = @IdCountry;

        -- Si no se encontró el tipo de vehículo, usar panel (2) como fallback
        IF @InsdTypeVehicle IS NULL
            SET @InsdTypeVehicle = 2;

        -- -----------------------------------------------------------------------
        -- 6. Insertar SchedulePickup
        -- -----------------------------------------------------------------------
        INSERT INTO [DeliveryBackOffice].[dbo].[SchedulePickup]
        (
          StartDate, EndDate, EstimatedWeight, IsLargePackage,
          QuantityRegularPackages, QuantityOverDimensionedPackage,
          RowStatus, TokenCreated, DateCreated, SenderId, SenderName,
          SenderPhone, IdHubLogistics, AmountPickup, IdSourcePlataform,
          AddressPickup, TownshipId, TypeVehicleId, IsScheduled
        )
        VALUES
        (
          LEFT(CONVERT(VARCHAR, @StartDate, 120), 16),
          LEFT(CONVERT(VARCHAR, @EndDate,   120), 16),
          0, 0, @QuantityOfPieces, 0, 1, @CodeApp, @TodayTime,  -- [OPT-2] Usa variable en lugar de GETDATE()
          @CodeOfReference, @nameSender,
          REPLACE(@phoneSender, ' ', ''),
          @idHub, 0.00, 8, @addressPickUp, @idTownship,
          @InsdTypeVehicle, 0
        );

        SET @SchedulePickupFinded = SCOPE_IDENTITY();

        IF @SchedulePickupFinded > 0
        BEGIN
            -- -----------------------------------------------------------------------
            -- 7. Insertar ServiceManagement
            -- -----------------------------------------------------------------------
            INSERT INTO [DeliveryBackOffice].[dbo].[ServiceManagement]
            (
              IdSchedulePickup, RowStatus, TokenCreated, DateCreated,
              ServiceStatusId, Amount, CatPaymentTimeId
            )
            VALUES
            (
              @SchedulePickupFinded, 1, @CodeApp, @TodayTime, 1, 0.00, NULL  -- [OPT-2] Usa variable
            );

            SET @ServiceManagementFinded = SCOPE_IDENTITY();

            -- -----------------------------------------------------------------------
            -- 8. Insertar EventService
            -- -----------------------------------------------------------------------
            INSERT INTO [DeliveryBackOffice].[dbo].[EventService]
            (
              ServiceManagementId, ServiceStatusId, RowStauts,
              TokenCreated, DateCreated
            )
            VALUES
            (
              @ServiceManagementFinded, 1, 1, @CodeApp, @TodayTime  -- [OPT-2] Usa variable
            );

            SELECT @IdResult                      = 200,
                   @ErrorMessage                  = 'Solicitud de recolección procesada correctamente',
                   @IsSuccess                     = 1,
                   @ResultStartDate               = @StartDate,
                   @ResultEndDate                 = @EndDate,
                   @ResultService                 = @ServiceManagementFinded,
                   @ResultQuantityRegularPackages = @QuantityOfPieces,
                   @ResultTypeVehiculeId          = @TypeVehicle;

            IF @TransactionStarted = 1
            BEGIN
                COMMIT TRANSACTION;
                SET @TransactionStarted = 0;
            END
        END
        ELSE
        BEGIN
            SELECT @IdResult      = 400,
                   @ErrorMessage  = 'No es posible solicitar una recolección',
                   @IsSuccess     = 1,
                   @ResultService = 0;

            RollbackAndSelect:
            SET @CodeOfReference = @CodeOfReference; -- no-op necesario para el label
            IF @TransactionStarted = 1 AND @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION;
                SET @TransactionStarted = 0;
            END
        END

        -- COMMIT final si quedó pendiente
        IF @TransactionStarted = 1
        BEGIN
            COMMIT TRANSACTION;
            SET @TransactionStarted = 0;
        END

    END TRY
    BEGIN CATCH
        IF @TransactionStarted = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT @IdResult      = 500,
               @ErrorMessage  = CONCAT('Error del sistema: ', CAST(ERROR_MESSAGE() AS NVARCHAR(250))),
               @IsSuccess     = 0;
    END CATCH;

    FinalSelect:
    -- [OPT-12] Se elimina REPLACE(@IsSuccess, ' ', '') – un BIT nunca tiene espacios
    SELECT @IsSuccess                    AS IsSuccess,
           @IdResult                     AS IdResult,
           @ErrorMessage                 AS ErrorMessage,
           @CodeOfReference              AS CodeOfReference,
           @ResultStartDate              AS ResultStartDate,
           @ResultEndDate                AS ResultEndDate,
           @ResultService                AS ResultService,
           @ResultTypeVehiculeId         AS ResultTypeVehiculeId,
           @ResultQuantityRegularPackages AS ResultQuantityRegularPackages,
           CASE
               WHEN @IdResult = 200 THEN 'CREATED'
               WHEN @IdResult = 409 THEN 'ERROR_IN_PROCESS'
               ELSE 'SYSTEM_ERROR'
           END AS ResultType;

    RETURN;
END;