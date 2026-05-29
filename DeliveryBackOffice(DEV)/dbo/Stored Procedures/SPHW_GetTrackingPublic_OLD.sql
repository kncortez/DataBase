-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-10-08>
-- Description:	<Delivery Tracking - Método para obtener información pública para rastreo de parquete.>
-- Create date: <2025-07-25>
-- Description:	<Se modifica la bandera de cambio de dirección, no se puede si es entrega EXC.>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-11-04>
-- Description:	<Se agrega el DeliveryETA para el trackin y muestra nuevo estado en timeline >
-- =============================================
-- =============================================
-- Propósito: Obtener deshabilitaido temporalmente "Recibir Alertas",
-- Autor:     <Freddy Camposeco>
-- Historia:  <FDAPI-4780>
-- Fecha:     <2025-10-08>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_GetTrackingPublic_OLD]
    @GuideSerie NVARCHAR(4)
  , @GuideNumber INT
AS
BEGIN
    BEGIN TRY

        DECLARE @SenderName      AS NVARCHAR(50)
              , @ReceiverName    AS NVARCHAR(50)
              , @Hub             AS NVARCHAR(20)
              , @StatusGuide     AS NVARCHAR(20)
              , @StatusDelivered AS INT
              , @HubCourier      AS NVARCHAR(25)
			  , @StatusArribal AS INT;
        --Encabezados
        DECLARE @EncabezadoRastreo TABLE
        (
            Id INT IDENTITY(1, 1) PRIMARY KEY
          , Nombre NVARCHAR(50)
          , Descripcion NVARCHAR(255)
        );

        SET @StatusDelivered =
        (
            SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription = 'Entregado'
        );

		SET @StatusArribal =
		(
			SELECT StatusOrderId FROM StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Arribó a las instalaciones'
		);

         -- 1) Carga 1 fila de DeliveryOrder
        SELECT
          DO.Guide_Serie, DO.Guide_Number, DO.StatusOrderId, DO.Sender_FirstName, DO.Sender_LastName,
          DO.Receiver_FirstName, DO.Receiver_LastName, DO.ReceiverIdSettlement, DO.ReceiverIdTownship,
          DO.ReceiverCountryId, DO.DeliveryETA, DO.IdDeliveryOption, DO.IsLastMileReturn, DO.IdCustomer,
          DO.NameOfReceiver,DO.Receiver_Phone
        INTO #DO
        FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
        WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber;

        -- 2) Carga todo el historial de esa guía
        SELECT DOD.Guide_Serie, DOD.Guide_Number, DOD.StatusOrderId, DOD.DateCreated, DOD.UserCreated
        INTO #DOD
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
        WHERE DOD.Guide_Serie = @GuideSerie AND DOD.Guide_Number = @GuideNumber;

        -- Opcional: índices temporales (baratos y útiles)
        CREATE CLUSTERED INDEX IX_DOD_GuideDate ON #DOD (StatusOrderId, DateCreated DESC);


        ----NOTA EL HUB QUEDA PENDIENTE DE VALIDAR, SEGUN SEAN LOS NUEVOS REQUERIMIENTOS
        SELECT @SenderName   = CONCAT(ISNULL(DO.Sender_FirstName, ''), ' ', ISNULL(DO.Sender_LastName, ''))
             , @ReceiverName = DO.NameOfReceiver
             , @StatusGuide  = CST.NameStatusProcess
        FROM #DO                                DO WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH (NOLOCK)
                ON DO.StatusOrderId = SO.StatusOrderId
            INNER JOIN CatStatusProcess                   CST WITH (NOLOCK)
                ON SO.CatStatusProcessId = CST.IdStatusProcess
        WHERE DO.Guide_Serie = @GuideSerie
              AND DO.Guide_Number = @GuideNumber;

        IF (@Hub IS NULL)
        BEGIN
            SET @Hub =
            (
                SELECT TOP 1
                       TB2.Hub
                FROM
                (
                    SELECT dat.DateCreated
                         , COALESCE((
                                        SELECT TOP 1
                                               ISNULL(HSB.HubName, VP.DescriptionOfClient) StationName
                                        FROM dbo.RolByUserBySystem         rus WITH (NOLOCK)
                                            INNER JOIN dbo.CatStation      ct WITH (NOLOCK)
                                                ON ct.IdStation = rus.StationId
                                            LEFT JOIN dbo.HubLogistics     HSB WITH (NOLOCK)
                                                ON HSB.IdHubLogistic = ct.HubLogisticId
                                            LEFT JOIN dbo.VisitPointClient VP WITH (NOLOCK)
                                                ON VP.CodeOfReference = ct.CodeOfReference
                                        WHERE rus.RusIdUser = it.RegisterUserID
                                    )
                                  , ''
                                   ) AS Hub
                    FROM #DOD                      dat WITH (NOLOCK)
                        LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tkd WITH (NOLOCK)
                            ON tkd.SSN_IdToken = dat.UserCreated
                        LEFT JOIN dbo.InternalUser                    it WITH (NOLOCK)
                            ON it.IdUser = tkd.SSN_IdUser
                               AND it.Username = tkd.SSN_Username
                    WHERE dat.Guide_Serie = @GuideSerie
                          AND dat.Guide_Number = @GuideNumber
                ) AS TB2
                WHERE TB2.Hub IS NOT NULL
                ORDER BY TB2.DateCreated DESC
            );

        END;


        INSERT INTO @EncabezadoRastreo
        (
            Nombre
          , Descripcion
        )
        SELECT 'Creado por'
             , 'Fecha estimada de entrega'
        UNION ALL --1
        SELECT 'Recibido por Forza'
             , 'Fecha estimada de entrega'
        UNION ALL --2
        SELECT 'Arribó a las instalaciones'
             , 'Fecha estimada de entrega'
        UNION ALL --3
        SELECT 'En ruta'
             , 'Fecha estimada de entrega'
        UNION ALL --4
        SELECT 'Entregado'
             , 'Entregado el'; --5


        SET @HubCourier =
        (
            SELECT TOP 1
                   ISNULL((
                              SELECT TOP (1)
                                     CS.StationName
                              FROM DeliveryBackOffice.dbo.CatStation                  CS WITH (NOLOCK)
                                  INNER JOIN DeliveryBackOffice.dbo.RolByUserBySystem RBUBS WITH (NOLOCK)
                                      ON CS.IdStation = RBUBS.StationId
                              WHERE IU.RegisterUserID = RBUBS.RusIdUser
                                    AND CS.RowStatus = 1
                              ORDER BY CS.IdStation DESC
                          )
                        , ''
                         ) AS Hub
            FROM #DOD                               DOD WITH (NOLOCK)
                LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken      token WITH (NOLOCK)
                    ON DOD.UserCreated = token.SSN_IdToken
                LEFT JOIN DenariusUser_Dev.dbo.LGN_User            duser WITH (NOLOCK)
                    ON duser.USR_IdUser = token.SSN_IdUser
                       AND duser.USR_Username = token.SSN_Username
                LEFT JOIN DenariusDesktop_Dev.dbo.LGT_INF_Employee epl WITH (NOLOCK)
                    ON epl.IdEmployee = duser.USR_IdEmployee
                LEFT JOIN DeliveryBackOffice.dbo.InternalUser      IU WITH (NOLOCK)
                    ON epl.CodeEmployee = CAST(IU.IdUser AS VARCHAR(20))
                INNER JOIN StatusOrder                             SO WITH (NOLOCK)
                    ON DOD.StatusOrderId = SO.StatusOrderId
                INNER JOIN CatStatusProcess                        CT WITH (NOLOCK)
                    ON SO.CatStatusProcessId = CT.IdStatusProcess
            WHERE DOD.Guide_Serie = @GuideSerie
                  AND DOD.Guide_Number = @GuideNumber
                  AND CT.NameStatusProcess = 'En Ruta'
            ORDER BY DOD.DateCreated DESC
        );


        --Iconos
        SELECT NameStatusProcess AS 'label'
             , Icon              AS 'icon'
             , CASE
                   WHEN CST.NameStatusProcess = 'Creado'
                        AND @StatusGuide = 'Creado'
                        OR CST.NameStatusProcess = 'Creado'
                           AND @StatusGuide = 'Recibido por Forza'
                        OR CST.NameStatusProcess = 'Creado'
                           AND @StatusGuide = 'En instalaciones'
                        OR CST.NameStatusProcess = 'Creado'
                           AND @StatusGuide = 'En Ruta'
                        OR CST.NameStatusProcess = 'Creado'
                           AND @StatusGuide = 'Entregado' THEN
                       @SenderName
                   WHEN CST.NameStatusProcess = 'Recibido por Forza'
                        AND @StatusGuide = 'Recibido por Forza'
                        OR CST.NameStatusProcess = 'Recibido por Forza'
                           AND @StatusGuide = 'Recibido por Forza'
                        OR CST.NameStatusProcess = 'Recibido por Forza'
                           AND @StatusGuide = 'En Ruta'
                        OR CST.NameStatusProcess = 'Recibido por Forza'
                           AND @StatusGuide = 'Entregado' THEN
                       @SenderName
                   WHEN CST.NameStatusProcess = 'En instalaciones'
                        AND @StatusGuide = 'En instalaciones'
                        OR CST.NameStatusProcess = 'En instalaciones'
                           AND @StatusGuide = 'En Ruta'
                        OR CST.NameStatusProcess = 'En instalaciones'
                           AND @StatusGuide = 'Entregado' THEN
                       @Hub
                   WHEN CST.NameStatusProcess = 'En Ruta'
                        AND @StatusGuide = 'En Ruta'
                        OR CST.NameStatusProcess = 'En Ruta'
                           AND @StatusGuide = 'Entregado' THEN
                       @HubCourier
                   WHEN CST.NameStatusProcess = 'Entregado'
                        AND @StatusGuide = 'Entregado' THEN
                       @ReceiverName
                   ELSE
                       NULL
               END               AS Description
             , CASE
                   WHEN CST.NameStatusProcess = 'Creado' THEN
                   (
                       SELECT TOP 1
                              DO.DateCreated
                       FROM #DOD        DO WITH (NOLOCK)
                           INNER JOIN StatusOrder      SO WITH (NOLOCK)
                               ON DO.StatusOrderId = SO.StatusOrderId
                           INNER JOIN CatStatusProcess CSC WITH (NOLOCK)
                               ON SO.CatStatusProcessId = CSC.IdStatusProcess
                       WHERE DO.Guide_Serie = @GuideSerie
                             AND DO.Guide_Number = @GuideNumber
                             AND CSC.NameStatusProcess = CST.NameStatusProcess
                       ORDER BY DO.DateCreated DESC
                   )
                   WHEN CST.NameStatusProcess = 'Recibido por Forza' THEN
                   (
                       SELECT TOP 1
                              DO.DateCreated
                       FROM #DOD        DO WITH (NOLOCK)
                           INNER JOIN StatusOrder      SO WITH (NOLOCK)
                               ON DO.StatusOrderId = SO.StatusOrderId
                           INNER JOIN CatStatusProcess CSC WITH (NOLOCK)
                               ON SO.CatStatusProcessId = CSC.IdStatusProcess
                       WHERE DO.Guide_Serie = @GuideSerie
                             AND DO.Guide_Number = @GuideNumber
                             AND CSC.NameStatusProcess = CST.NameStatusProcess
                       ORDER BY DO.DateCreated DESC
                   )
                   WHEN CST.NameStatusProcess = 'En instalaciones' THEN
                   (
                       SELECT TOP 1
                              DO.DateCreated
                       FROM #DOD        DO WITH (NOLOCK)
                           INNER JOIN StatusOrder      SO WITH (NOLOCK)
                               ON DO.StatusOrderId = SO.StatusOrderId
                           INNER JOIN CatStatusProcess CSC WITH (NOLOCK)
                               ON SO.CatStatusProcessId = CSC.IdStatusProcess
                       WHERE DO.Guide_Serie = @GuideSerie
                             AND DO.Guide_Number = @GuideNumber
                             AND CSC.NameStatusProcess = CST.NameStatusProcess
                       ORDER BY DO.DateCreated DESC
                   )
                   WHEN CST.NameStatusProcess = 'En Ruta' THEN
                   (
                       SELECT TOP 1
                              DO.DateCreated
                       FROM #DOD        DO WITH (NOLOCK)
                           INNER JOIN StatusOrder      SO WITH (NOLOCK)
                               ON DO.StatusOrderId = SO.StatusOrderId
                           INNER JOIN CatStatusProcess CSC WITH (NOLOCK)
                               ON SO.CatStatusProcessId = CSC.IdStatusProcess
                       WHERE DO.Guide_Serie = @GuideSerie
                             AND DO.Guide_Number = @GuideNumber
                             AND CSC.NameStatusProcess = CST.NameStatusProcess
                       ORDER BY DO.DateCreated DESC
                   )
                   WHEN CST.NameStatusProcess = 'Entregado' THEN
                   (
                       SELECT TOP 1
                              DO.DateCreated
                       FROM #DOD        DO WITH (NOLOCK)
                           INNER JOIN StatusOrder      SO WITH (NOLOCK)
                               ON DO.StatusOrderId = SO.StatusOrderId
                           INNER JOIN CatStatusProcess CSC WITH (NOLOCK)
                               ON SO.CatStatusProcessId = CSC.IdStatusProcess
                       WHERE DO.Guide_Serie = @GuideSerie
                             AND DO.Guide_Number = @GuideNumber
                             AND CSC.NameStatusProcess = CST.NameStatusProcess
                       ORDER BY DO.DateCreated DESC
                   )
                   ELSE
                       NULL
               END               AS DateCreated
        FROM DeliveryBackOffice.dbo.CatStatusProcess CST WITH (NOLOCK);

        DECLARE @Piezas NVARCHAR(20) = N'';
        DECLARE @Description NVARCHAR(200) = N'';

        -- Calcula el total de piezas
        SELECT @Piezas      = CASE
                                  WHEN COUNT(DOP.ParcelCode) = 1 THEN
                                      '1 pieza'
                                  ELSE
                                      CAST(COUNT(DOP.ParcelCode) AS NVARCHAR(5)) + ' piezas'
                              END
             , @Description =
        (
            SELECT TOP 1
                   DOP.Detail
            FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
            WHERE DOP.GuideSerie = @GuideSerie
                  AND DOP.GuideNumber = @GuideNumber
        )
        FROM DeliveryBackOffice.dbo.DeliveryOrder                DO WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
                ON DO.Guide_Serie = DOP.GuideSerie
                   AND DO.Guide_Number = DOP.GuideNumber
        WHERE DO.Guide_Serie = @GuideSerie
              AND DO.Guide_Number = @GuideNumber;


        --Informacion pública
        SELECT CONCAT(ISNULL(DO.Sender_FirstName, ''), ' ', ISNULL(DO.Sender_LastName, ''))     AS 'SenderName'
             , CONCAT(ISNULL(DO.Receiver_FirstName, ''), ' ', ISNULL(DO.Receiver_LastName, '')) AS 'ReceiverName'
             , ISNULL(S.Settlement, '')                                                         AS 'Poblado'
             , IIF(T.TownshipName IS NOT NULL, T.TownshipName, ISNULL(T2.TownshipName, ''))     AS 'Municipio'
             , IIF(P.ProvinceName IS NOT NULL, P.ProvinceName, ISNULL(P2.ProvinceName, ''))     AS 'Departamento'
             , ISNULL(@Piezas, '')                                                              AS 'Pieces'
             , ISNULL(@Description, '')                                                         AS 'Description'
             , DO.ReceiverCountryId																AS 'Country'
             , SO.CatStatusProcessId                                                            AS 'StatusTracking'
             , ISNULL(ER.Nombre, '')                                                            AS 'StatusTrackingTitle'
             , ISNULL(ER.Descripcion, '')                                                       AS 'StatusTrackingDescription'
             , CASE
                   -- Caso 1: El número comienza con '+' y tiene al menos 11 dígitos (ej. +50244444444)
                   WHEN LEFT(Receiver_Phone, 1) = '+'
                        AND LEN(Receiver_Phone) >= 11 THEN
                       SUBSTRING(Receiver_Phone, 2, 3)

                   -- Caso 2: El número comienza con un código de área sin '+' y tiene al menos 10 dígitos (ej. 50244444444)
                   WHEN LEN(Receiver_Phone) >= 10
                        AND ISNUMERIC(LEFT(Receiver_Phone, 3)) = 1 THEN
                       LEFT(Receiver_Phone, 3)

                   -- Caso 3: Si no tiene código de área válido, devuelve NULL (ej. 2345-6789)
                   ELSE
                       ISNULL(CP.[Value], '502')
               END                                                                              AS 'AreaCode'
             , CASE
                   WHEN ER.Nombre = 'Entregado' THEN
                   (
                       SELECT TOP 1
                              CAST(DateCreated AS DATE)
                       FROM #DOD D WITH (NOLOCK)
                       WHERE D.Guide_Serie = DO.Guide_Serie
                             AND D.Guide_Number = DO.Guide_Number
                       --AND D.StatusOrderId = @StatusDelivered
                       ORDER BY D.DateCreated DESC
                   )
                   WHEN ER.Nombre = 'En ruta' THEN
                       CAST(GETDATE() AS DATE)
                   WHEN ER.Nombre = 'En ruta'
                        AND DO.DeliveryETA < GETDATE() THEN
                       CAST(DATEADD(DAY, 1, GETDATE()) AS DATE)
                   WHEN ER.Nombre != 'En ruta'
                        AND DO.DeliveryETA > GETDATE() THEN
                       IIF(DO.DeliveryETA IS NULL, GETDATE(), CAST(DO.DeliveryETA AS DATE))
                   WHEN CONVERT(DATE, DO.DeliveryETA) < CONVERT(DATE, GETDATE()) THEN
                       CAST(DATEADD(DAY, 1, GETDATE()) AS DATE)
                   ELSE
                       IIF(DO.DeliveryETA IS NULL, GETDATE(), CAST(DO.DeliveryETA AS DATE))
               END                                                                              AS DeliveryETA
        FROM #DO         DO WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH (NOLOCK)
                ON DO.StatusOrderId = SO.StatusOrderId
            LEFT JOIN DeliveryBackOffice.dbo.Settlement   S WITH (NOLOCK)
                ON DO.ReceiverIdSettlement = S.IdSettlement
            LEFT JOIN DeliveryBackOffice.dbo.Township     T WITH (NOLOCK)
                ON S.IdTownship = T.IdTownship
            LEFT JOIN DeliveryBackOffice.dbo.Province     P WITH (NOLOCK)
                ON S.IdProvince = P.IdProvince
            LEFT JOIN DeliveryBackOffice.dbo.Township     T2 WITH (NOLOCK)
                ON DO.ReceiverIdTownship = T2.IdTownship
            LEFT JOIN DeliveryBackOffice.dbo.Province     P2 WITH (NOLOCK)
                ON T2.IdProvince = P2.IdProvince
            LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CP WITH (NOLOCK)
                ON CP.[Name] = 'AreaCode'
                   AND DO.ReceiverCountryId = CP.IdCountry
            LEFT JOIN @EncabezadoRastreo                  ER
                ON SO.CatStatusProcessId = ER.Id
        WHERE DO.Guide_Serie = @GuideSerie
              AND DO.Guide_Number = @GuideNumber;

        DECLARE @StatusIncVal INT =
                (
                    SELECT StatusOrderId
                    FROM DeliveryBackOffice.dbo.StatusOrder
                    WHERE OrderDescription = 'Incidencia Validada'
                );

        DECLARE @CheckpointType INT =
                (
                    SELECT IdCatCheckpointType
                    FROM DeliveryBackOffice.dbo.CatCheckpointType
                    WHERE CheckpointTypeDescription = 'Checkpoint final'
                );

        DECLARE @StatusProcessFinal INT =
                (
                    SELECT IdStatusProcess
                    FROM DeliveryBackOffice.dbo.CatStatusProcess
                    WHERE NameStatusProcess = 'Entregado'
                );

        DECLARE @f1 NVARCHAR(10)
            =
                (
                    SELECT CASE
                               WHEN IsLastMileReturn = 1
                                    OR
                                    (
                                        SELECT COUNT(CI.IdConfirmationOfIncidence)
                                        FROM DeliveryBackOffice.dbo.DeliveryAttempt                   DA WITH (NOLOCK)
                                            INNER JOIN DeliveryBackOffice.dbo.ConfirmationOfIncidence CI WITH (NOLOCK)
                                                ON DA.ConfirmationOfIncidenceId = CI.IdConfirmationOfIncidence
                                        WHERE DA.Guide_Serie = @GuideSerie
                                              AND DA.Guide_Number = @GuideNumber
                                              AND CI.StatusOrderId = @StatusIncVal
                                              AND CI.IsConfirmed = 1
                                              AND CI.IsDenied = 0
                                    ) > 1 --INTENTO DEVOLUCIONES
                                    OR SO.CatStatusProcessId = @StatusProcessFinal --LA GUÍA SE ENCUENTRA EN UN ESTADO ENTREGADO
                        THEN
                                   'false'
                               ELSE
                                   'true'
                           END AS 'flagRescheduleDelivery'
                    FROM #DO         DO WITH (NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH (NOLOCK)
                            ON DO.StatusOrderId = SO.StatusOrderId
                    WHERE Guide_Serie = @GuideSerie
                          AND Guide_Number = @GuideNumber
                );

        DECLARE @f2 NVARCHAR(10)
            =
                (
                    SELECT CASE
                               WHEN IsLastMileReturn = 1
                                    OR
                                    (
                                        SELECT COUNT(CI.IdConfirmationOfIncidence)
                                        FROM DeliveryBackOffice.dbo.DeliveryAttempt                   DA WITH (NOLOCK)
                                            INNER JOIN DeliveryBackOffice.dbo.ConfirmationOfIncidence CI WITH (NOLOCK)
                                                ON DA.ConfirmationOfIncidenceId = CI.IdConfirmationOfIncidence
                                        WHERE DA.Guide_Serie = @GuideSerie
                                              AND DA.Guide_Number = @GuideNumber
                                              AND CI.StatusOrderId = @StatusIncVal
                                              AND CI.IsConfirmed = 1
                                              AND CI.IsDenied = 0
                                    ) > 1 --INTENTO DEVOLUCIONES
                                    OR SO.CatStatusProcessId = @StatusProcessFinal --LA GUÍA SE ENCUENTRA EN UN ESTADO ENTREGADO
                                    OR --La guia esta configurada para entregarse en EXC
									(DO.IdDeliveryOption = ( SELECT IdDeliveryOption FROM [DeliveryBackOffice].[dbo].[CatDeliveryOptions] WITH (NOLOCK)
															 WHERE [Name] = 'Express Center' AND [IdCountry] = DO.ReceiverCountryId))
                        THEN
                                   'false'
                               ELSE
                                   'true'
                           END AS 'flagChangeAdress'
                    FROM #DO        DO WITH (NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH (NOLOCK)
                            ON DO.StatusOrderId = SO.StatusOrderId
                    WHERE Guide_Serie = @GuideSerie
                          AND Guide_Number = @GuideNumber
                );

        DECLARE @f3 NVARCHAR(10)
            =
                (
                    SELECT CASE
                               WHEN (
                                        C.TotalAmountPaid IS NOT NULL
                                        OR C.TotalAmountPaid != 0
                                    ) -- ESTA PAGADA LA GUIA
                                    OR IIF(ISNULL(CCP.ConditionOfPayment, 'Contado') = 'Contado', 0, 1) = 1 -- NO TIENE CREDITO
                                    OR SO.CatStatusProcessId = @StatusProcessFinal --LA GUÍA SE ENCUENTRA EN UN ESTADO ENTREGADO
                        THEN
                                   'false'
                               ELSE
                                   'true'
                           END AS 'flagPayDelivery'
                    FROM #DO                  DO WITH (NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.StatusOrder          SO WITH (NOLOCK)
                            ON DO.StatusOrderId = SO.StatusOrderId
                        INNER JOIN DeliveryBackOffice.dbo.Customer             CU WITH (NOLOCK)
                            ON DO.IdCustomer = CU.IdCustomer
                        LEFT JOIN DeliveryBackOffice.dbo.CatConditionOfPayment CCP WITH (NOLOCK)
                            ON CU.ConditionOfPaymentID = CCP.IdConditionOfPayment
                        LEFT JOIN DeliveryBackOffice.dbo.Cost                  C WITH (NOLOCK)
                            ON DO.Guide_Serie = C.GuideSerie
                               AND DO.Guide_Number = C.GuideNumber
                    WHERE DO.Guide_Serie = @GuideSerie
                          AND DO.Guide_Number = @GuideNumber
                );
                
        DECLARE @f4 NVARCHAR(10) = 'false';

        DECLARE @f5 NVARCHAR(10) =
                (
                    SELECT CASE
                               WHEN
                               (
                                   SELECT CatStatusProcessId
                                   FROM DeliveryBackOffice.dbo.StatusOrder WITH (NOLOCK)
                                   WHERE StatusOrderId = DO.StatusOrderId
                               ) = 1 --NO ESTAR EN ESTADO CREADO
                        THEN
                                   'false'
                               ELSE
                                   'true'
                           END AS 'flagQualify'
                    FROM #DO DO WITH (NOLOCK)
                    WHERE DO.Guide_Serie = @GuideSerie
                          AND DO.Guide_Number = @GuideNumber
                );

        -- Variables de tipo bit para verificar si cada campo tiene datos
        DECLARE @HasImagePath BIT
              , @HasDry       BIT
              , @HasCold      BIT
              , @HasLatitude  BIT
              , @HasLongitude BIT
			  , @ConfirmGuide NVARCHAR(10);

        -- Consultamos los valores y asignamos las variables
        SET @HasImagePath = IIF(
                                EXISTS
                                (
                                    SELECT TOP 1
                                           1
                                    FROM DeliveryProof                                        dp WITH (NOLOCK)
                                        INNER JOIN #DOD dod 
                                            ON dp.Guide_Serie = dod.Guide_Serie
                                               AND dp.Guide_Number = dod.Guide_Number
                                    WHERE dp.Guide_Serie = @GuideSerie
                                          AND dp.Guide_Number = @GuideNumber
                                          AND dod.StatusOrderId = 5
                                          AND
                                          (
                                              dp.Path_Dry IS NOT NULL
                                              AND dp.Path_Dry <> ''
                                              OR dp.Path_Cold IS NOT NULL
                                                 AND dp.Path_Cold <> ''
                                          )
                                )
                              , 1
                              , 0);

        SET @HasDry = IIF(
                          EXISTS
                          (
                              SELECT TOP 1
                                     1
                              FROM DeliveryBackOffice.dbo.DeliveryProof                 dp WITH (NOLOCK)
                                  INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt     da WITH (NOLOCK)
                                      ON da.Guide_Serie = dp.Guide_Serie
                                         AND da.Guide_Number = dp.Guide_Number
                                  INNER JOIN #DOD dod WITH (NOLOCK)
                                      ON dp.Guide_Serie = dod.Guide_Serie
                                         AND dp.Guide_Number = dod.Guide_Number
                              WHERE dp.Guide_Serie = @GuideSerie
                                    AND dp.Guide_Number = @GuideNumber
                                    AND da.Delivered = 1
                                    AND dod.StatusOrderId = 5
                                    AND dp.Path_Dry IS NOT NULL
                                    AND dp.Path_Dry <> ''
                          )
                        , 1
                        , 0);

        SET @HasCold = IIF(
                           EXISTS
                           (
                               SELECT TOP 1
                                      1
                               FROM DeliveryBackOffice.dbo.DeliveryProof                 dp WITH (NOLOCK)
                                   INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt     da WITH (NOLOCK)
                                       ON da.Guide_Serie = dp.Guide_Serie
                                          AND da.Guide_Number = dp.Guide_Number
                                   INNER JOIN #DOD dod 
                                       ON dp.Guide_Serie = dod.Guide_Serie
                                          AND dp.Guide_Number = dod.Guide_Number
                               WHERE dp.Guide_Serie = @GuideSerie
                                     AND dp.Guide_Number = @GuideNumber
                                     AND da.Delivered = 1
                                     AND dod.StatusOrderId = 5
                                     AND dp.Path_Cold IS NOT NULL
                                     AND dp.Path_Cold <> ''
                           )
                         , 1
                         , 0);

        SET @HasLatitude = IIF(
                               EXISTS
                               (
                                   SELECT TOP 1
                                          1
                                   FROM DeliveryBackOffice.dbo.DeliveryAttempt               DA WITH (NOLOCK)
                                       INNER JOIN #DOD dod
                                           ON DA.Guide_Serie = dod.Guide_Serie
                                              AND DA.Guide_Number = dod.Guide_Number
                                   WHERE DA.Guide_Serie = @GuideSerie
                                         AND DA.Guide_Number = @GuideNumber
                                         AND DA.Delivered = 1
                                         AND dod.StatusOrderId = 5
                                         AND DA.Latitude IS NOT NULL
                                         AND DA.Latitude <> ''
                               )
                             , 1
                             , 0);

        SET @HasLongitude = IIF(
                                EXISTS
                                (
                                    SELECT TOP 1
                                           1
                                    FROM DeliveryBackOffice.dbo.DeliveryAttempt               DA WITH (NOLOCK)
                                        INNER JOIN #DOD dod
                                            ON DA.Guide_Serie = dod.Guide_Serie
                                               AND DA.Guide_Number = dod.Guide_Number
                                    WHERE DA.Guide_Serie = @GuideSerie
                                          AND DA.Guide_Number = @GuideNumber
                                          AND DA.Delivered = 1
                                          AND dod.StatusOrderId = 5
                                          AND DA.Longitude IS NOT NULL
                                          AND DA.Longitude <> ''
                                )
                              , 1
                              , 0);

		SET @ConfirmGuide = 
		(
			SELECT CASE WHEN DO.StatusOrderId = @StatusArribal THEN 'true' ELSE 'false' END 
			FROM #DO DO WITH (NOLOCK)
			WHERE DO.Guide_Serie = @GuideSerie
				AND DO.Guide_Number = @GuideNumber
		);

		

        --Banderas
        SELECT ISNULL(@f1, 'false')                                                                         AS 'flagRescheduleDelivery'
             , ISNULL(@f2, 'false')                                                                         AS 'flagChangeAdress'
             , ISNULL(@f3, 'false')                                                                         AS 'flagPayDelivery'
             , ISNULL(@f4, 'false')                                                                         AS 'flagNotifications'
             , IIF(@HasImagePath = 1, 'true', IIF(@HasDry = 1, 'true', IIF(@HasCold = 1, 'true', 'false'))) AS 'flagShowImage'
             , IIF(@HasLatitude = 1 AND @HasLongitude = 1, 'true', 'false')                                 AS 'flagShowMapa'
             , 'true'                                                                                       AS 'flagRequestHelp' --Esta bandera siempre va visible para frontend
             , ISNULL(@f5, 'false')                                                                         AS 'flagQualify'
			 , @ConfirmGuide																				AS 'flagConfirmAdress';

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT @ErrorMessage = ERROR_MESSAGE();
        PRINT 'Error: ' + @ErrorMessage;
    END CATCH;
END;