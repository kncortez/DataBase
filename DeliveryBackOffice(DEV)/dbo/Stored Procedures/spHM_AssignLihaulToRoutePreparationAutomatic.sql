/* =================================================
   SP:        [dbo].[spHM_AssignLihaulToRoutePreparationAutomatic]
   Propósito: Realiza el proceso de preparación de rutas atomaticamente para piezas que hayan pasado por liquidación de linehaul
   Autor:     Brandon Pedroza
   Historia:  FDAPI-6096
   Fecha:     2026-05-15
============================================
=== CHANGELOG ================================

=========================================== */
CREATE PROCEDURE [dbo].[spHM_AssignLihaulToRoutePreparationAutomatic]
    @LinehaulRouteSettlementId INT =23659,
    @Date DATE = '05-13-2026',
    @Token NVARCHAR(50) = 'SYSTEM',
    @StationId INT = NULL,
    @GuidePieceType INT = 1
AS
BEGIN
    DECLARE @LRP_ID AS INT;
    DECLARE @STATUS_LIQUID AS INT = 3; -- Liquidado <- CatLinehaulStatus 
    DECLARE @RModified               INT = 0;

    SET @LRP_ID =
    (
        SELECT [LRS].[LinehaulRoutePreparationId]
        FROM [dbo].[LinehaulRouteSettlement] LRS WITH (NOLOCK)
        WHERE [LRS].[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId 
    );

    IF OBJECT_ID('tempdb..#GuidesTmp') IS NOT NULL
        DROP TABLE #GuidesTmp;

    CREATE TABLE #GuidesTmp
    (
        GuideSerie NVARCHAR(2),
        GuideNumber INT,
        GuidePiece INT
    );

    IF OBJECT_ID('tempdb..#GuidesTmpRoute') IS NOT NULL
        DROP TABLE #GuidesTmpRoute;

    CREATE TABLE #GuidesTmpRoute
    (
        GuideSerie NVARCHAR(2),
        GuideNumber INT,
        GuidePiece INT,
        IdRoute INT
    );

    INSERT INTO #GuidesTmp
    (
        GuideSerie,
        GuideNumber,
        GuidePiece
    )
    SELECT LRPCD.GuideSerie,
           LRPCD.GuideNumber,
           LRPCDP.PieceNumber
    FROM [dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP WITH (NOLOCK)
        INNER JOIN [dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
            ON [LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
        INNER JOIN [dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
            ON [LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
        INNER JOIN [dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
            ON [LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
    WHERE [LRPCDP].[ActCode] IS NULL
          AND [LRPCDP].[RowStatus] = 1
          AND [LRP].[IdLinehaulRoutePreparation] = @LRP_ID
          AND [LRPCD].[RowStatus] = 1
          AND     [LRPCDP].CatLinehaulStatusId   = @STATUS_LIQUID;

    INSERT INTO #GuidesTmpRoute
    (
        GuideSerie,
        GuideNumber,
        GuidePiece,
        IdRoute
    )
    SELECT DO.Guide_Serie,
           DO.Guide_Number,
           GT.GuidePiece,
           CR.IdRoute
    FROM DeliveryOrder DO WITH (NOLOCK)
        INNER JOIN #GuidesTmp GT
            ON DO.Guide_Serie = GT.GuideSerie
               AND DO.Guide_Number = GT.GuideNumber
        INNER JOIN DumpServiceCoverage DSC WITH (NOLOCK)
            ON DO.ReceiverIdSettlement = DSC.IdSettlement
        CROSS APPLY
    (
        SELECT TOP 1
            *
        FROM CatRoute CR
        WHERE DSC.RouteCode = CR.CodeRoute
        ORDER BY CR.IdRoute
    ) CR
    WHERE DO.IsLastMileReturn != 1
	BEGIN TRY
    BEGIN TRANSACTION

    -- =========================================================================
    -- FDD-1321: Rutas cuya preparación más reciente ya tiene manifiesto asociado
    --           → forzar nueva RoutePreparation
    -- =========================================================================
    DECLARE @ForcedNewPrep TABLE (IdRoute INT);

    INSERT INTO @ForcedNewPrep
    (
        IdRoute
    )
    SELECT rp.CatRouteId
    FROM
    (
        SELECT rp.CatRouteId,
               rp.DeliveryOrderBySettlementId,
               ROW_NUMBER() OVER (PARTITION BY rp.CatRouteId ORDER BY rp.IdRoutePreparation DESC) AS rn
        FROM RoutePreparation rp WITH (NOLOCK)
        WHERE rp.CatRouteId IN (
                                   SELECT DISTINCT IdRoute FROM #GuidesTmpRoute
                               )
              AND rp.DateRoutePreparation = @Date
              AND rp.RowStatus = 1
    ) rp
        INNER JOIN DeliveryOrderBySettlement dobs WITH (NOLOCK)
            ON rp.DeliveryOrderBySettlementId = dobs.ID
    WHERE rp.rn = 1;

    -- =========================================================================
    -- Mapa IdRoute → IdRoutePreparation para uso en los pasos siguientes
    -- =========================================================================
    DECLARE @RoutePreparationMap TABLE
    (
        IdRoute INT,
        IdRoutePreparation INT
    );

    --- Rutas con preparación activa válida (no forzadas) → reutilizar la más reciente
    INSERT INTO @RoutePreparationMap
    (
        IdRoute,
        IdRoutePreparation
    )
    SELECT rp.CatRouteId,
           MAX(rp.IdRoutePreparation)
    FROM RoutePreparation rp WITH (NOLOCK)
    WHERE rp.CatRouteId IN (
                               SELECT DISTINCT
                                   IdRoute
                               FROM #GuidesTmpRoute
                               WHERE IdRoute NOT IN (
                                                        SELECT IdRoute FROM @ForcedNewPrep
                                                    )
                           )
          AND rp.DateRoutePreparation = @Date
          AND rp.RowStatus = 1
    GROUP BY rp.CatRouteId;

    --ACTUALIZA EL TOTAL DE GUIAS Y PIEZAS EN PREPARACION EXISTENTE
    UPDATE rp
    SET rp.GuidesQuantity = rp.GuidesQuantity + agg.GuidesCount,
        rp.PiecesDry = rp.PiecesDry + agg.DryCount,
        rp.PiecesCold = rp.PiecesCold + agg.ColdCount,
        rp.TokenUpdated = @Token,
        rp.DateUpdated = GETDATE()
    FROM [DeliveryBackOffice].[dbo].[RoutePreparation] rp
        INNER JOIN @RoutePreparationMap rpm
            ON rp.IdRoutePreparation = rpm.IdRoutePreparation
        INNER JOIN
        (
            SELECT GTR.IdRoute,
                   COUNT(DISTINCT GTR.GuideNumber) AS GuidesCount,
                   IIF(@GuidePieceType = 1, COUNT(1), 0) AS DryCount,
                   IIF(@GuidePieceType = 0, COUNT(1), 0) AS ColdCount
            FROM #GuidesTmpRoute GTR
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM RoutePreparationDetail RPD
                    INNER JOIN RoutePreparation RP
                        ON RPD.RoutePreparationId = RP.IdRoutePreparation
                WHERE RP.CatRouteId = GTR.IdRoute
                      AND RPD.Guide_Serie = GTR.GuideSerie
                      AND RPD.Guide_Number = GTR.GuideNumber
                      AND RP.DateRoutePreparation = @Date
                      AND RP.RowStatus = 1
            )
            GROUP BY GTR.IdRoute
        ) agg
            ON rpm.IdRoute = agg.IdRoute;

    --- Crear nueva RoutePreparation para rutas sin preparación o con preparación forzada
    DECLARE @NewRoutePreparations TABLE
    (
        IdRoute INT,
        IdRoutePreparation INT
    );

    INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparation]
    (
        [CatRouteId],
        [DateRoutePreparation],
        [GuidesQuantity],
        [PiecesDry],
        [PiecesCold],
        [RowStatus],
        [TokenCreated],
        [DateCreated],
        [TokenUpdated],
        [DateUpdated]
    )
    OUTPUT inserted.CatRouteId,
           inserted.IdRoutePreparation
    INTO @NewRoutePreparations
    (
        IdRoute,
        IdRoutePreparation
    )
    SELECT agg.IdRoute,
           @Date,
           agg.GuidesCount,
           agg.DryCount,
           agg.ColdCount,
           1,
           @Token,
           GETDATE(),
           NULL,
           NULL
    FROM
    (
        SELECT IdRoute,
               COUNT(DISTINCT GuideNumber) AS GuidesCount,
               IIF(@GuidePieceType = 1, COUNT(1), 0) AS DryCount,
               IIF(@GuidePieceType = 0, COUNT(1), 0) AS ColdCount
        FROM #GuidesTmpRoute
        GROUP BY IdRoute
    ) agg
    WHERE agg.IdRoute NOT IN (
                                 SELECT IdRoute FROM @RoutePreparationMap
                             );

    --agregar detalle de ruta de preparacion
    INSERT INTO @RoutePreparationMap
    (
        IdRoute,
        IdRoutePreparation
    )
    SELECT IdRoute,
           IdRoutePreparation
    FROM @NewRoutePreparations;

    -- =========================================================================
    -- RoutePreparationDetail: insertar por cada guía distinta que no exista aún
    -- =========================================================================
    INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationDetail]
    (
        [RoutePreparationId],
        [Guide_Serie],
        [Guide_Number],
        [RowStatus],
        [TokenCreated],
        [DateCreated],
        [TokenUpdated],
        [DateUpdated]
    )
    SELECT rpm.IdRoutePreparation,
           gl.GuideSerie,
           gl.GuideNumber,
           1,
           @Token,
           GETDATE(),
           NULL,
           NULL
    FROM
    (
        SELECT DISTINCT
            GuideSerie,
            GuideNumber,
            IdRoute
        FROM #GuidesTmpRoute
    ) gl
        INNER JOIN @RoutePreparationMap rpm
            ON gl.IdRoute = rpm.IdRoute
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetail] rpd WITH (NOLOCK)
        WHERE rpd.RoutePreparationId = rpm.IdRoutePreparation
              AND rpd.Guide_Serie = gl.GuideSerie
              AND rpd.Guide_Number = gl.GuideNumber
              AND rpd.RowStatus = 1
    );

    --agregar detalle de piezas
    --- Insertar solo las piezas específicas del TVP que existen y no están registradas aún
    INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece]
    (
        [RoutePreparationDetailId],
        [PieceNumber],
        [PieceType],
        [RowStatus],
        [TokenCreated],
        [DateCreated]
    )
    SELECT rpd.IdRoutePreparationDetail,
           gl.GuidePiece,
           IIF(@GuidePieceType = 1, 1, 0),
           1,
           @Token,
           GETDATE()
    FROM #GuidesTmpRoute gl
        INNER JOIN @RoutePreparationMap rpm
            ON gl.IdRoute = rpm.IdRoute
        INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] rpd WITH (NOLOCK)
            ON rpd.RoutePreparationId = rpm.IdRoutePreparation
               AND rpd.Guide_Serie = gl.GuideSerie
               AND rpd.Guide_Number = gl.GuideNumber
               AND rpd.RowStatus = 1
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] rpdp WITH (NOLOCK)
        WHERE rpdp.RoutePreparationDetailId = rpd.IdRoutePreparationDetail
              AND rpdp.PieceNumber = gl.GuidePiece
              AND rpdp.RowStatus = 1
    );

    -- =========================================================================
    -- Retirar piezas de estas guías de otras preparaciones de la misma fecha
    -- =========================================================================
    --- Desactivar piezas registradas en otras preparaciones activas
    UPDATE rpdp
    SET rpdp.RowStatus = 0,
        rpdp.TokenUpdated = @Token,
        rpdp.DateUpdated = GETDATE()
    FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] rpdp
        INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] rpd WITH (NOLOCK)
            ON rpdp.RoutePreparationDetailId = rpd.IdRoutePreparationDetail
        INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparation] rp WITH (NOLOCK)
            ON rpd.RoutePreparationId = rp.IdRoutePreparation
        INNER JOIN
        (
            SELECT DISTINCT
                GuideSerie,
                GuideNumber,
                IdRoute
            FROM #GuidesTmpRoute
        ) gl
            ON rpd.Guide_Serie = gl.GuideSerie
               AND rpd.Guide_Number = gl.GuideNumber
        INNER JOIN @RoutePreparationMap rpm
            ON gl.IdRoute = rpm.IdRoute
    WHERE rpdp.RowStatus = 1
          AND rpd.RowStatus = 1
          AND rp.RowStatus = 1
          --AND rp.DateRoutePreparation = @Date
          AND rp.IdRoutePreparation <> rpm.IdRoutePreparation; -- excluir la preparación actual

    --- Desactivar el detalle de la guía en otras preparaciones
    UPDATE rpd
    SET rpd.RowStatus = 0,
        rpd.TokenUpdated = @Token,
        rpd.DateUpdated = GETDATE()
    FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetail] rpd
        INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparation] rp WITH (NOLOCK)
            ON rpd.RoutePreparationId = rp.IdRoutePreparation
        INNER JOIN
        (
            SELECT DISTINCT
                GuideSerie,
                GuideNumber,
                IdRoute
            FROM #GuidesTmpRoute
        ) gl
            ON rpd.Guide_Serie = gl.GuideSerie
               AND rpd.Guide_Number = gl.GuideNumber
        INNER JOIN @RoutePreparationMap rpm
            ON gl.IdRoute = rpm.IdRoute
    WHERE rpd.RowStatus = 1
          AND rp.RowStatus = 1
          --AND rp.DateRoutePreparation = @Date
          AND rp.IdRoutePreparation <> rpm.IdRoutePreparation;

    -- =========================================================================
    -- Actualizar estado de guías y piezas → Programado para entrega (3)
    -- =========================================================================
    UPDATE do
    SET do.StatusOrderId = 3
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] do
        INNER JOIN
        (SELECT DISTINCT GuideSerie, GuideNumber FROM #GuidesTmpRoute) gl
            ON do.Guide_Serie = gl.GuideSerie
               AND do.Guide_Number = gl.GuideNumber;

    --- Bitácora: insertar estado por guía solo si no existe registro del día en esta preparación
    INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
    (
        [Guide_Serie],
        [Guide_Number],
        [StatusOrderId],
        [UserCreated],
        [DateCreated],
        [DateCreatedInSystem],
        [StationId]
    )
    SELECT DISTINCT
        gl.GuideSerie,
        gl.GuideNumber,
        3,
        @Token,
        GETDATE(),
        GETDATE(),
        @StationId
    FROM #GuidesTmpRoute gl
        INNER JOIN @RoutePreparationMap rpm
            ON gl.IdRoute = rpm.IdRoute
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetail] rpd WITH (NOLOCK)
        WHERE rpd.RoutePreparationId = rpm.IdRoutePreparation
              AND rpd.Guide_Serie = gl.GuideSerie
              AND rpd.Guide_Number = gl.GuideNumber
              AND CAST(rpd.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
    );

    UPDATE dop
    SET dop.StatusOrderId = 3
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop
        INNER JOIN #GuidesTmpRoute gl
            ON dop.GuideSerie = gl.GuideSerie
               AND dop.GuideNumber = gl.GuideNumber
               AND dop.NoPiece = gl.GuidePiece;

    -- =========================================================================
    -- Warehouse: desactivar posición de inventario
    -- Intento 1 → a nivel de pieza
    -- =========================================================================
    UPDATE w
    SET w.Active = 0,
        w.UserUpdated = @Token,
        w.DateUpdated = GETDATE()
    FROM [DeliveryBackOffice].[dbo].[Warehouse] w
        INNER JOIN #GuidesTmpRoute gl
            ON w.Guide_Serie = gl.GuideSerie
               AND w.Guide_Number = gl.GuideNumber
               AND w.Guide_Piece = gl.GuidePiece;


    -- ... (continúa: FDD-942 ServiceManagement, respuesta y cierre de transacción)
    -- =========================================================================
    -- Poblar @ResponseTable para todas las guías del TVP
    -- =========================================================================
    DECLARE @ResponseTable TABLE
    (
        IdRoutePreparation INT,
        GuideSerie NVARCHAR(2),
        GuideNumber INT,
        GuidePiece INT,
        GuidePieceType BIT,
        GuidePieces INT,
        GuideDryPieces INT,
        GuideColdPieces INT,
        GuideReceiverFirstName NVARCHAR(100),
        GuideReceiverLastName NVARCHAR(100),
        GuideReceiverIdTownShip NVARCHAR(100),
        GuideReceiverDepartment NVARCHAR(100),
        GuideReceiverTown NVARCHAR(100),
        GuideReceiverAddress NVARCHAR(600),
        GuideReceiverPhone NVARCHAR(100),
        GuideSenderFirstName NVARCHAR(100),
        GuideSenderLastName NVARCHAR(100),
        GuideSenderDepartment NVARCHAR(100),
        GuideSenderIdTownship INT,
        GuideSenderPhone NVARCHAR(100),
        GuideSenderAddress NVARCHAR(600),
        GUidePriceShippmment DECIMAL(14, 2),
        GuideCOD DECIMAL(14, 2),
        SenderId INT,
        ReceiverId INT,
        Ticket_Number NVARCHAR(150)
    );
    DECLARE @IsReturn AS BIT = 0;
    DECLARE @AmountToPay AS DECIMAL(18, 2);
    DECLARE @AmountToPayCOD AS DECIMAL(18, 2);
    DECLARE @IdServiceManagement AS INT;
    DECLARE @subtypeservicemanagment AS INT;
    DECLARE @RouteAssigmentId AS INT = NULL;
    DECLARE @ServiceManagementDetailId AS INT = NULL;
    DECLARE @FirstPieceEntered AS BIT = 1;

    INSERT INTO @ResponseTable
    (
        [IdRoutePreparation],
        [GuideSerie],
        [GuideNumber],
        [GuidePiece],
        [GuidePieceType],
        [GuidePieces],
        [GuideDryPieces],
        [GuideColdPieces],
        [GuideReceiverDepartment],
        [GuideReceiverTown],
        [GuideReceiverAddress],
        [GuideReceiverIdTownShip],
        [GuideReceiverPhone],
        [GuideSenderDepartment],
        [GuideSenderIdTownship],
        [GuideSenderPhone],
        [GuideSenderAddress],
        [GUidePriceShippmment],
        [GuideCOD],
        [GuideSenderFirstName],
        [GuideSenderLastName],
        [GuideReceiverFirstName],
        [GuideReceiverLastName],
        [SenderId],
        [ReceiverId],
        [Ticket_Number]
    )
    SELECT rpm.IdRoutePreparation,
           gl.GuideSerie,
           gl.GuideNumber,
           gl.GuidePiece,
           @GuidePieceType,
           (ISNULL(DO.Pieces_Dry, 0) + ISNULL(DO.Pieces_Cold, 0)),
           ISNULL(DO.Pieces_Dry, 0),
           ISNULL(DO.Pieces_Cold, 0),
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.Sender_Department
               ELSE
                   DO.Receiver_Department
           END,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.Sender_Town
               ELSE
                   DO.Receiver_Town
           END,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.Sender_Address
               ELSE
                   DO.Receiver_Address
           END,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.SenderIdTownship
               ELSE
                   DO.ReceiverIdTownship
           END,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.Sender_Phone
               ELSE
                   DO.Receiver_Phone
           END,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.Receiver_Department
               ELSE
                   DO.Sender_Department
           END,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.ReceiverIdTownship
               ELSE
                   DO.SenderIdTownship
           END,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.Receiver_Phone
               ELSE
                   DO.Sender_Phone
           END,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.Receiver_Address
               ELSE
                   DO.Sender_Address
           END,
           DO.PriceShippment,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   0
               ELSE
                   DO.Collect_OnDelivery
           END,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.Receiver_FirstName
               ELSE
                   DO.Sender_FirstName
           END,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.Receiver_LastName
               ELSE
                   DO.Sender_LastName
           END,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.Sender_FirstName
               ELSE
                   DO.Receiver_FirstName
           END,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.Sender_LastName
               ELSE
                   DO.Receiver_LastName
           END,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.Receiver_ID
               ELSE
                   DO.Sender_ID
           END,
           CASE
               WHEN DO.IsLastMileReturn = 1 THEN
                   DO.Sender_ID
               ELSE
                   DO.Receiver_ID
           END,
           ISNULL(DO.Ticket_Number, '0')
    FROM #GuidesTmpRoute gl
        INNER JOIN @RoutePreparationMap rpm
            ON gl.IdRoute = rpm.IdRoute
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
            ON DO.Guide_Serie = gl.GuideSerie
               AND DO.Guide_Number = gl.GuideNumber;

    -- =========================================================================
    -- FDD-942: Unificación de rutero en preparación de entrega (set-based)
    -- =========================================================================
    --- Tabla de trabajo: una fila por guía distinta, solo las que no tienen SMD vinculado
    DECLARE @GuideServiceData TABLE
    (
        IdRoute INT,
        IdRoutePrep INT,
        IdRPDetail INT,
        GuideSerie NVARCHAR(2),
        GuideNumber INT,
        IsReturn BIT,
        SubTypeId INT,
        ProvinceId INT,
        TownshipId INT,
        ServiceAddress NVARCHAR(600),
        ServicePhone NVARCHAR(100),
        FirstName NVARCHAR(100),
        LastName NVARCHAR(100),
        CodeOfReference INT,
        AmountToPay DECIMAL(18, 2),
        --- GUidePriceShippmment de @ResponseTable
        AmountToPayCOD DECIMAL(18, 2),
        --- GuideCOD de @ResponseTable (ya 0 para devoluciones)
        ResolvedSmdId INT NULL
    );

    INSERT INTO @GuideServiceData
    (
        IdRoute,
        IdRoutePrep,
        IdRPDetail,
        GuideSerie,
        GuideNumber,
        IsReturn,
        SubTypeId,
        ProvinceId,
        TownshipId,
        ServiceAddress,
        ServicePhone,
        FirstName,
        LastName,
        CodeOfReference,
        AmountToPay,
        AmountToPayCOD
    )
    SELECT rpm.IdRoute,
           rpm.IdRoutePreparation,
           rpd.IdRoutePreparationDetail,
           gl.GuideSerie,
           gl.GuideNumber,
           ISNULL(do.IsLastMileReturn, 0),
           st.IdSubTypeServiceManagment,
           IIF(ISNULL(do.IsLastMileReturn, 0) = 1, twn_s.IdProvince, twn_r.IdProvince),
           IIF(ISNULL(do.IsLastMileReturn, 0) = 1, RT.GuideSenderIdTownship, RT.GuideReceiverIdTownShip),
           IIF(ISNULL(do.IsLastMileReturn, 0) = 1, RT.GuideSenderAddress, RT.GuideReceiverAddress),
           IIF(ISNULL(do.IsLastMileReturn, 0) = 1, RT.GuideSenderPhone, RT.GuideReceiverPhone),
           IIF(ISNULL(do.IsLastMileReturn, 0) = 1, RT.GuideSenderFirstName, RT.GuideReceiverFirstName),
           IIF(ISNULL(do.IsLastMileReturn, 0) = 1, RT.GuideSenderLastName, RT.GuideReceiverLastName),
           IIF(ISNULL(do.IsLastMileReturn, 0) = 1, RT.SenderId, RT.ReceiverId),
           RT.GUidePriceShippmment,
           RT.GuideCOD
    FROM
    (
        SELECT DISTINCT
            GuideSerie,
            GuideNumber,
            IdRoute
        FROM #GuidesTmpRoute
    ) gl
        INNER JOIN @RoutePreparationMap rpm
            ON gl.IdRoute = rpm.IdRoute
        INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] rpd WITH (NOLOCK)
            ON rpd.RoutePreparationId = rpm.IdRoutePreparation
               AND rpd.Guide_Serie = gl.GuideSerie
               AND rpd.Guide_Number = gl.GuideNumber
               AND rpd.RowStatus = 1
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH (NOLOCK)
            ON do.Guide_Serie = gl.GuideSerie
               AND do.Guide_Number = gl.GuideNumber
        INNER JOIN
        (
            SELECT DISTINCT
                GuideSerie,
                GuideNumber,
                MAX(GuideReceiverIdTownShip) AS GuideReceiverIdTownShip,
                MAX(GuideSenderIdTownship) AS GuideSenderIdTownship,
                MAX(GuideSenderAddress) AS GuideSenderAddress,
                MAX(GuideReceiverAddress) AS GuideReceiverAddress,
                MAX(GuideSenderPhone) AS GuideSenderPhone,
                MAX(GuideReceiverPhone) AS GuideReceiverPhone,
                MAX(GuideSenderFirstName) AS GuideSenderFirstName,
                MAX(GuideReceiverFirstName) AS GuideReceiverFirstName,
                MAX(GuideSenderLastName) AS GuideSenderLastName,
                MAX(GuideReceiverLastName) AS GuideReceiverLastName,
                MAX(SenderId) AS SenderId,
                MAX(ReceiverId) AS ReceiverId,
                MAX(GUidePriceShippmment) AS GUidePriceShippmment,
                MAX(GuideCOD) AS GuideCOD
            FROM @ResponseTable
            GROUP BY GuideSerie,
                     GuideNumber
        ) RT
            ON RT.GuideSerie = gl.GuideSerie
               AND RT.GuideNumber = gl.GuideNumber
        INNER JOIN dbo.SubTypeServiceManagment st WITH (NOLOCK)
            ON st.Name = IIF(ISNULL(do.IsLastMileReturn, 0) = 1, 'Devolución', 'Entrega')
        LEFT JOIN dbo.Township twn_r WITH (NOLOCK)
            ON twn_r.IdTownship = RT.GuideReceiverIdTownShip
        LEFT JOIN dbo.Township twn_s WITH (NOLOCK)
            ON twn_s.IdTownship = RT.GuideSenderIdTownship
    WHERE rpd.ServiceManagementDetailId IS NULL;

    --- Fallback: resolver ProvinceId desde Township si viene NULL
    UPDATE gsd
    SET gsd.ProvinceId = twn.IdProvince
    FROM @GuideServiceData gsd
        INNER JOIN dbo.Township twn WITH (NOLOCK)
            ON twn.IdTownship = gsd.TownshipId
    WHERE gsd.ProvinceId IS NULL;

    --- Paso 1: resolver SMDs ya existentes en esta ruta con el mismo destino
    UPDATE gsd
    SET gsd.ResolvedSmdId = SMD.IdServiceManagementDetail
    FROM @GuideServiceData gsd
        INNER JOIN dbo.ServiceManagementDetail SMD WITH (NOLOCK)
            ON CONVERT(DATE, SMD.ServiceStartDate) = @Date
               AND SMD.ProvinceId = gsd.ProvinceId
               AND SMD.TownshipId = gsd.TownshipId
               AND SMD.ServiceAddress = gsd.ServiceAddress
               AND SMD.ServicePhone = gsd.ServicePhone
               AND SMD.SubTypeServiceManagmentId = gsd.SubTypeId
               AND SMD.RowStatus = 1
        INNER JOIN dbo.RoutePreparationDetail RPD WITH (NOLOCK)
            ON SMD.IdServiceManagementDetail = RPD.ServiceManagementDetailId
               AND RPD.RowStatus = 1
        INNER JOIN dbo.RoutePreparation RP WITH (NOLOCK)
            ON RPD.RoutePreparationId = RP.IdRoutePreparation
               AND RP.CatRouteId = gsd.IdRoute
               AND RP.DateRoutePreparation = @Date
               AND RP.RowStatus = 1;

    --- Paso 2: crear cadena RouteAssigment → ServiceManagement → ServiceManagementDetail
    ---         solo para guías que no tienen SMD resuelto aún
    IF EXISTS (SELECT 1 FROM @GuideServiceData WHERE ResolvedSmdId IS NULL)
    BEGIN
        --- RouteAssigment: obtener existentes o crear los que faltan
        DECLARE @RouteAssigmentMap TABLE
        (
            IdRoute INT,
            IdRouteAssigment INT
        );

        INSERT INTO @RouteAssigmentMap
        (
            IdRoute,
            IdRouteAssigment
        )
        SELECT gsd.IdRoute,
               MAX(ra.IdRouteAssigment)
        FROM @GuideServiceData gsd
            INNER JOIN dbo.RouteAssigment ra WITH (NOLOCK)
                ON ra.IdRoute = gsd.IdRoute
                   AND ra.DateOfRoute = @Date
        WHERE gsd.ResolvedSmdId IS NULL
        GROUP BY gsd.IdRoute;

        INSERT INTO [dbo].[RouteAssigment]
        (
            [IdRoute],
            [IdCurrierMan],
            [IdVehicle],
            [DateOfRoute],
            [RowStatus],
            [TokenCreated],
            [DateCreated],
            [TokenUpdated],
            [DateUpdated]
        )
        OUTPUT inserted.IdRoute,
               inserted.IdRouteAssigment
        INTO @RouteAssigmentMap
        SELECT DISTINCT
            gsd.IdRoute,
            NULL,
            NULL,
            @Date,
            1,
            @Token,
            GETDATE(),
            NULL,
            NULL
        FROM @GuideServiceData gsd
        WHERE gsd.ResolvedSmdId IS NULL
              AND gsd.IdRoute NOT IN (
                                         SELECT IdRoute FROM @RouteAssigmentMap
                                     );


        --- ServiceManagement: uno por (IdRoute, SubTypeId)
        DECLARE @SmOutputTemp TABLE
        (
            IdRouteAssigment INT,
            SubTypeId INT,
            IdServiceManagement INT
        );

        INSERT INTO [dbo].[ServiceManagement]
        (
            [IdPuCourrier],
            [IdDlCourrier],
            [CiPuDate],
            [CoPuDate],
            [CiDlDate],
            [CoDlDate],
            [IdPuRouteAssigment],
            [IdDlRouteAssigment],
            [IdSchedulePickup],
            [IdProofOnDelivery],
            [RowStatus],
            [TokenCreated],
            [DateCreated],
            [TokenUpdated],
            [DateUpdated],
            [ServiceStatusId],
            [PuSignaturePath],
            [DiSignaturePath],
            [SubTypeServiceManagmentId],
            [IdHubDestination],
            [Order],
            [Amount],
            [CatPaymentTimeId]
        )
        OUTPUT inserted.IdPuRouteAssigment,
               inserted.SubTypeServiceManagmentId,
               inserted.IdServiceManagement
        INTO @SmOutputTemp
        (
            IdRouteAssigment,
            SubTypeId,
            IdServiceManagement
        )
        SELECT DISTINCT
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            ram.IdRouteAssigment,
            NULL,
            NULL,
            NULL,
            1,
            @Token,
            GETDATE(),
            NULL,
            NULL,
            (
                SELECT TOP 1
                    IdServiceStatus
                FROM dbo.CatServiceStatus WITH (NOLOCK)
                WHERE Name = 'Creado'
            ),
            NULL,
            NULL,
            gsd.SubTypeId,
            NULL,
            1,
            0,
            NULL
        FROM @GuideServiceData gsd
            INNER JOIN @RouteAssigmentMap ram
                ON ram.IdRoute = gsd.IdRoute
        WHERE gsd.ResolvedSmdId IS NULL;

        --- Mapear (IdRoute, SubTypeId) → IdServiceManagement usando IdRouteAssigment como puente
        DECLARE @SmMap TABLE
        (
            IdRoute INT,
            SubTypeId INT,
            IdServiceManagement INT
        );

        INSERT INTO @SmMap
        (
            IdRoute,
            SubTypeId,
            IdServiceManagement
        )
        SELECT ram.IdRoute,
               sot.SubTypeId,
               sot.IdServiceManagement
        FROM @SmOutputTemp sot
            INNER JOIN @RouteAssigmentMap ram
                ON ram.IdRouteAssigment = sot.IdRouteAssigment;

        --- ServiceManagementDetail: uno por grupo de destino (IdRoute, SubTypeId, Provincia, etc.)
        DECLARE @SmdOutputTemp TABLE
        (
            IdServiceManagement INT,
            ProvinceId INT,
            TownshipId INT,
            ServiceAddress NVARCHAR(500),
            ServicePhone NVARCHAR(20),
            SubTypeId INT,
            IdSMD INT
        );

        INSERT INTO [dbo].[ServiceManagementDetail]
        (
            [ServiceManagement],
            [ServiceStartDate],
            [ServiceEndDate],
            [ServiceVisitPointId],
            [ServiceVisitPointPortfolioId],
            [ServiceCustomerName],
            [ProvinceId],
            [TownshipId],
            [SettlementId],
            [ServiceAddress],
            [ServiceSpecialInstructions],
            [ServicePhone],
            [HubLogisticsId],
            [ServiceAmount],
            [ServiceExtraAmount],
            [TypeVehicleId],
            [SubTypeServiceManagmentId],
            [RowStatus],
            [TokenCreated],
            [DateCreated],
            [TokenUpdated],
            [DateUpdated]
        )
        OUTPUT inserted.ServiceManagement,
               inserted.ProvinceId,
               inserted.TownshipId,
               inserted.ServiceAddress,
               inserted.ServicePhone,
               inserted.SubTypeServiceManagmentId,
               inserted.IdServiceManagementDetail
        INTO @SmdOutputTemp
        (
            IdServiceManagement,
            ProvinceId,
            TownshipId,
            ServiceAddress,
            ServicePhone,
            SubTypeId,
            IdSMD
        )
        SELECT smm.IdServiceManagement,
               GETDATE(),
               DATEADD(hh, 20, CAST(CONVERT(DATE, GETDATE()) AS DATETIME)),
               ng.CodeOfReference,
               NULL,
               CAST(CONCAT(ng.FirstName, ' ', ng.LastName) AS NVARCHAR(100)),
               ISNULL(ng.ProvinceId, 7),
               ISNULL(ng.TownshipId, 73),
               NULL,
               CAST(ng.ServiceAddress AS NVARCHAR(500)),
               NULL,
               CAST(ng.ServicePhone AS NVARCHAR(20)),
               NULL,
               0,
               0,
               NULL,
               ng.SubTypeId,
               1,
               CAST(@Token AS NVARCHAR(50)),
               GETDATE(),
               NULL,
               NULL
        FROM
        (
            SELECT IdRoute,
                   SubTypeId,
                   ISNULL(ProvinceId, 7) AS ProvinceId,
                   ISNULL(TownshipId, 73) AS TownshipId,
                   ServiceAddress,
                   ServicePhone,
                   MAX(FirstName) AS FirstName,
                   MAX(LastName) AS LastName,
                   MAX(CodeOfReference) AS CodeOfReference
            FROM @GuideServiceData
            WHERE ResolvedSmdId IS NULL
            GROUP BY IdRoute,
                     SubTypeId,
                     ProvinceId,
                     TownshipId,
                     ServiceAddress,
                     ServicePhone
        ) ng
            INNER JOIN @SmMap smm
                ON smm.IdRoute = ng.IdRoute
                   AND smm.SubTypeId = ng.SubTypeId;

        --- Resolver el SMD recién creado de vuelta a cada guía
        UPDATE gsd
        SET gsd.ResolvedSmdId = sot.IdSMD
        FROM @GuideServiceData gsd
            INNER JOIN @SmMap smm
                ON smm.IdRoute = gsd.IdRoute
                   AND smm.SubTypeId = gsd.SubTypeId
            INNER JOIN @SmdOutputTemp sot
                ON sot.IdServiceManagement = smm.IdServiceManagement
                   AND sot.ProvinceId = ISNULL(gsd.ProvinceId, 7)
                   AND sot.TownshipId = ISNULL(gsd.TownshipId, 73)
                   AND sot.ServiceAddress = gsd.ServiceAddress
                   AND sot.ServicePhone = gsd.ServicePhone
        WHERE gsd.ResolvedSmdId IS NULL;
    END;
	        IF COALESCE(@@ROWCOUNT, 0) > 0
            SET @RModified = @RModified + 1;

    --- Vincular SMD resuelto al detalle de la preparación
    UPDATE rpd
    SET rpd.ServiceManagementDetailId = gsd.ResolvedSmdId
    FROM [dbo].[RoutePreparationDetail] rpd
        INNER JOIN @GuideServiceData gsd
            ON gsd.IdRPDetail = rpd.IdRoutePreparationDetail
    WHERE gsd.ResolvedSmdId IS NOT NULL;

    --- Actualizar montos acumulados por SMD
    UPDATE smd
    SET smd.ServiceAmount = smd.ServiceAmount + IIF(agg.IsReturn = 1, 0, agg.TotalAmount),
        smd.ServiceExtraAmount = IIF(agg.IsReturn = 1, 0, smd.ServiceExtraAmount + agg.TotalCOD),
        smd.TokenUpdated = @Token,
        smd.DateUpdated = GETDATE()
    FROM dbo.ServiceManagementDetail smd
        INNER JOIN
        (
            SELECT ResolvedSmdId,
                   MAX(CAST(IsReturn AS INT)) AS IsReturn,
                   SUM(ISNULL(AmountToPay, 0)) AS TotalAmount,
                   SUM(ISNULL(AmountToPayCOD, 0)) AS TotalCOD
            FROM @GuideServiceData
            WHERE ResolvedSmdId IS NOT NULL
            GROUP BY ResolvedSmdId
        ) agg
            ON smd.IdServiceManagementDetail = agg.ResolvedSmdId;


    IF OBJECT_ID('tempdb..#GuidesTmp') IS NOT NULL
        DROP TABLE #GuidesTmp;

    IF OBJECT_ID('tempdb..#GuidesTmpRoute') IS NOT NULL
        DROP TABLE #GuidesTmpRoute;

	END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        INSERT INTO [dbo].[RoutePreparationLogError]
        (
            [ErrorDescription], [ErrorNumber], [ErrorProcedure],
            [ErrorLine], [GuideSerie], [GuideNumber], [TokenCreated], [DateCreated]
        )
        SELECT DISTINCT
            CAST(ERROR_MESSAGE()   AS VARCHAR(300)),
            ERROR_NUMBER(),
            CAST(ERROR_PROCEDURE() AS VARCHAR(100)),
            ERROR_LINE(),
            gl.GuideSerie,
            gl.GuideNumber,
            @Token,
            GETDATE()
        FROM #GuidesTmpRoute gl;

        SELECT 0                  AS 'StatusCode',
               ERROR_MESSAGE()    AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               ERROR_LINE()       AS 'ErrorLine';

    END CATCH;

    IF (@@TRANCOUNT > 0)
    BEGIN
        IF (@RModified > 0)
        BEGIN
            SELECT 200                                  AS 'StatusCode',
                   'Preparacion generada correctamente' AS 'Description',
                   @@TRANCOUNT                          AS 'NumTransferID';

            SELECT
                RT.GuideSerie          AS 'Guide_Serie',
                RT.GuideNumber         AS 'Guide_Number',
                RT.GuidePiece          AS 'Guide_Piece',
                RT.GuidePieces         AS 'Pieces',
                RT.GuideReceiverDepartment AS 'Department',
                RT.GuideReceiverTown   AS 'Town',
                RT.GuideReceiverAddress AS 'Address',
                RT.GuideDryPieces      AS 'Pieces_Dry',
                RT.GuideColdPieces     AS 'Pieces_Cold',
                RT.GuidePieceType      AS 'Piece_Type',
                NULL                   AS 'GuideOrder',
                RT.IdRoutePreparation  AS 'NewRoutePreparation',
                RT.Ticket_Number
            FROM @ResponseTable RT;

           COMMIT TRANSACTION;
        END;
        ELSE
        BEGIN
            SELECT 0                        AS 'StatusCode',
                   'Registros no guardados' AS 'Description',
                   0                        AS 'NumTransferID';

            ROLLBACK TRANSACTION;
        END;
    END;
    ELSE
    BEGIN
        SELECT 0                  AS 'StatusCode',
               ERROR_MESSAGE()    AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               ERROR_LINE()       AS 'ErrorLine';
    END;
END;
