
/* =================================================
   SP:        AssignPieceToRoutePreparation
   Propósito: Asignación por pieza a RoutePreparation
   Autor:     Andres Ruiz
   Historia:  ---
   Fecha:     2022-01-18

=== CHANGELOG ============================

2026-05-25 | Historia/épica: FDAPI-6115   | Autor: Caleb Loarca    | Hacer actualización de estado de guía hasta validar que todas las piezas han sido escaneadas.
2025-12-18 | Historia/épica: FDAPI-4740   | Autor: Brandon Pedroza | Guardar estación a pieza al prepara ruta
2025-01-17 | Historia/épica: ---          | Autor: Edelman Vásquez | Proceso de preparación cuando se agrega una referencia
2024-10-01 | Historia/épica: ---          | Autor: Tito Garcia     | Permitir asociar varios manifiestos a una ruta para ser liquidados en un mismo proceso

=========================================== */
CREATE PROCEDURE [dbo].[AssignPieceToRoutePreparation]
    @IdRoute INT,
    @Date DATE,
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
    @GuidePiece INT,
    @GuidePieceType BIT = 1, --- 1 = Pieza seca | 0 = Pieza fría
    @Token NVARCHAR(50),
    @IsReference BIT = 0,
	@StationId INT = NULL
AS
BEGIN

    SET ARITHABORT ON;
    --- Conteo para verificar cantidad correcta de validaciones
    DECLARE @RModified INT = 0;

    --- Variables para manejo de preparación de ruta
    DECLARE @IdManifest INT;
    DECLARE @IdRoutePreparation INT;
    DECLARE @IdRoutePreparationDetail INT;
    DECLARE @IdRoutePreparationDetailPiece INT;

    --- Variables para manejo de piezas
    DECLARE @GuidePieceExists BIT;
    DECLARE @CountPieceGuideAdd INT;
	DECLARE @MaxPieceGuide INT

    --- Variables para despliegue de errores
    DECLARE @GuidePieceDoesntExist BIT = 0;
    DECLARE @GuidePieceAlreadyExists BIT = 0;
    DECLARE @FatalError INT = 0;

    --- Variable para devolución de datos ingresados
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
        GUidePriceShippment DECIMAL(14, 2),
        GuideCOD DECIMAL(14, 2),
        SenderId INT,
        ReceiverId INT,
        Ticket_Number NVARCHAR(150)
    );

    ------Variables para proceso de generación de datos de servicio marcados como devolución
    DECLARE @IsReturn AS BIT = 0; --bandera de dvolución
    DECLARE @AmountToPay AS DECIMAL(18, 2);
    DECLARE @AmountToPayCOD AS DECIMAL(18, 2);
    DECLARE @IdServiceManagement AS INT;
    DECLARE @subtypeservicemanagment AS INT;

    ------Variables para unificación de rutero 
    DECLARE @RouteAssigmentId AS INT = NULL;
    DECLARE @ServiceManagementDetailId AS INT = NULL;
    DECLARE @FirstPieceEntered AS BIT = 1;

    BEGIN TRANSACTION;
    BEGIN TRY
        -- FDD-1321  Se valida si la ruta ya tiene asignado un manifiesto para esta fecha
        DECLARE @ForceNewRoutePreparation AS TINYINT = 0;
        DECLARE @RoutePreparationID AS BIGINT;
        DECLARE @DeliveryOrderBySettlementId AS BIGINT;

        SELECT TOP 1
               @RoutePreparationID = rp.IdRoutePreparation,
               @DeliveryOrderBySettlementId = rp.DeliveryOrderBySettlementId
        FROM RoutePreparation rp WITH (NOLOCK)
            LEFT JOIN DeliveryOrderBySettlement dobs WITH (NOLOCK)
                ON rp.DeliveryOrderBySettlementId = dobs.ID
        WHERE rp.CatRouteId = @IdRoute
              AND rp.DateRoutePreparation = @Date
              AND rp.RowStatus = 1
        ORDER BY rp.IdRoutePreparation DESC;

        IF (
               @RoutePreparationID IS NOT NULL
               AND @DeliveryOrderBySettlementId IS NOT NULL
           )
        BEGIN
            SET @ForceNewRoutePreparation = 1;
        END;
        -- FDD-1321 FINALIZA

        ------------------------------------------------------------------------------------
        ------FDD-949--proceso de generación de datos de servicio marcados como devolución
        SELECT TOP 1
               @IsReturn = 1
        FROM dbo.DeliveryOrder do WITH (NOLOCK)
        WHERE do.IsLastMileReturn = 1
              AND do.Guide_Serie = @GuideSerie
              AND do.Guide_Number = @GuideNumber;
        ------FDD-949--proceso de generación de datos de servicio marcados como devolución
        ------------------------------------------------------------------------------------

        --- Se obtiene el tipo de ruta debido a la nueva columna IsAutoFinished de la RoutePreparation
		--- esta indica si una ruta con preparacion automatica ya fue finalizada
		--- aplica solo para rutas de ultima milla
		DECLARE @IsFinished BIT = 1;
		DECLARE @RouteTypeID INT = 0;
		DECLARE @LastMileRouteTypeID INT;
		
		SELECT @RouteTypeID = RT.IdTypeRoute
		FROM DeliveryBackOffice.dbo.CatRoute R WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.CatTypeRoute RT WITH (NOLOCK)
			ON RT.IdTypeRoute = R.IdTypeRoute
		WHERE R.IdRoute = @IdRoute;

		-- LAST MILE ROUTE TYPE ID = 4
		SET @LastMileRouteTypeID = (
			SELECT TOP 1 CTR.IdTypeRoute
            FROM DeliveryBackOffice.dbo.CatTypeRoute CTR WITH (NOLOCK)
            WHERE CTR.Name = 'Ultima Milla');

		IF @RouteTypeID = @LastMileRouteTypeID
		BEGIN
			SET @IsFinished = 0
		END

        --- Verificar si existe la preparación de ruta y si ya fue despachada
        SELECT TOP 1
               @IdRoutePreparation = ISNULL(RP.IdRoutePreparation, 0)
        FROM [DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH (NOLOCK)
        WHERE RP.CatRouteId = @IdRoute
              AND RP.DateRoutePreparation = @Date
              AND RP.RowStatus = 1
        ORDER BY IdRoutePreparation DESC;


        --- Verificar si existe la preparación de ruta
        IF (
               @IdRoutePreparation IS NULL
               OR @IdRoutePreparation = 0
               OR @ForceNewRoutePreparation = 1
           )
        BEGIN

            --- No existe la preparación de ruta y debe ser generado
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
                [DateUpdated],
				[IsAutoFinished]
            )
            VALUES
            (@IdRoute, @Date, 1, IIF(@GuidePieceType = 1, 1, 0), IIF(@GuidePieceType = 0, 1, 0), 1, @Token, GETDATE(),
             NULL, NULL, @IsFinished);

            SET @IdRoutePreparation = SCOPE_IDENTITY();

            IF COALESCE(@@ROWCOUNT, 0) > 0
                SET @RModified = @RModified + 1;
        END;
        ELSE
        BEGIN

            --- Actualizar preparación de ruta con nueva guía
            UPDATE [DeliveryBackOffice].[dbo].[RoutePreparation]
            SET GuidesQuantity = GuidesQuantity + 1,
                PiecesDry = PiecesDry + IIF(@GuidePieceType = 1, 1, 0),
                PiecesCold = PiecesCold + IIF(@GuidePieceType = 0, 1, 0),
                TokenUpdated = @Token,
                DateUpdated = GETDATE(),
				IsAutoFinished = @IsFinished
            WHERE IdRoutePreparation = @IdRoutePreparation;
        END;

        --- Verificar la preparación de ruta
        IF (@IdRoutePreparation > 0)
        BEGIN

            -- Verificar si existe la guía en el detalle de la preparación de ruta
            SELECT @IdRoutePreparationDetail = ISNULL(RPD.IdRoutePreparationDetail, 0),
                   @FirstPieceEntered = IIF(RPD.IdRoutePreparationDetail IS NULL, 1, 0)
            FROM [DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH (NOLOCK)
                    ON RP.IdRoutePreparation = RPD.RoutePreparationId
                OUTER APPLY
            (
                SELECT RPDP.RoutePreparationDetailId,
                       ISNULL(COUNT(1), NULL) 'PieceCount'
                FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP WITH (NOLOCK)
                WHERE RPDP.RoutePreparationDetailId = RPD.IdRoutePreparationDetail
                GROUP BY RPDP.RoutePreparationDetailId
            ) RPDP
            WHERE RPD.Guide_Serie = @GuideSerie
                  AND RPD.Guide_Number = @GuideNumber
                  AND RP.RowStatus = 1
                  AND RP.CatRouteId = @IdRoute
                  AND RP.DateRoutePreparation = @Date
                  AND RPD.RowStatus = 1;

            -- Verificar si existe la guía dentro del detalle de la preparación de la ruta
            IF (@IdRoutePreparationDetail IS NULL OR @IdRoutePreparationDetail = 0)
            BEGIN

                --- No existe la guía dentro del detalle de la ruta

                -- Generar nuevo detalle de preparación de ruta
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
                VALUES
                (@IdRoutePreparation, @GuideSerie, @GuideNumber, 1, @Token, GETDATE(), NULL, NULL);

                IF COALESCE(@@ROWCOUNT, 0) > 0
                    SET @RModified = @RModified + 1;

                SET @IdRoutePreparationDetail = SCOPE_IDENTITY();
            END;
            ---ELSE No existe data que actualizar en el detalle de la preparacón de ruta
            --- Verificar el detalle de la preparación de ruta
            IF (@IdRoutePreparationDetail > 0)
            BEGIN

                --- Verificar si la pieza es real
                SELECT @GuidePieceExists = 1
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH (NOLOCK)
                WHERE DOP.GuideSerie = @GuideSerie
                      AND DOP.GuideNumber = @GuideNumber
                      AND DOP.NoPiece = @GuidePiece;

                --- Verificar si la pieza de la guía si existe
                IF (@GuidePieceExists = 1)
                BEGIN

                    --- La pieza es real


                    --- Verificar si existe la pieza de la guía dentro del detalle de la preparación de la ruta
                    SELECT @IdRoutePreparationDetailPiece = RPDP.PieceNumber
                    FROM [DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH (NOLOCK)
                        INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH (NOLOCK)
                            ON RP.IdRoutePreparation = RPD.RoutePreparationId
                        INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP WITH (NOLOCK)
                            ON RPD.IdRoutePreparationDetail = RPDP.RoutePreparationDetailId
                    WHERE RPDP.PieceNumber = @GuidePiece
                          AND RPDP.RowStatus = 1
                          AND RPD.Guide_Serie = @GuideSerie
                          AND RPD.Guide_Number = @GuideNumber
                          AND RPD.RowStatus = 1
                          AND RP.CatRouteId = @IdRoute
                          AND RP.DateRoutePreparation = @Date
                          AND RP.RowStatus = 1;



                    --- Verificar si la pieza de la guía ya existe dentro de las piezas registradas en la preparación de ruta
                    IF (
                           @IdRoutePreparationDetailPiece IS NULL
                           OR @IdRoutePreparationDetailPiece = 0
                       )
                    BEGIN


                        IF (@IsReference = 1)
                        BEGIN

                            ---Asignar todas las piezas de la guía segun la referencia
                            INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece]
                            (
                                [RoutePreparationDetailId],
                                [PieceNumber],
                                [PieceType],
                                [RowStatus],
                                [TokenCreated],
                                [DateCreated]
                            )
                            SELECT @IdRoutePreparationDetail,
                                   NoPiece,
                                   IIF(@GuidePieceType = 1, 1, 0),
                                   1,
                                   @Token,
                                   GETDATE()
                            FROM dbo.DeliveryOrderPiece WITH (NOLOCK)
                            WHERE GuideSerie = @GuideSerie
                            AND GuideNumber = @GuideNumber;

                            --- Actualziar el estado de las piezas
                            UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece]
                            SET StatusOrderId = 3 --- Programado para entrega
                            WHERE GuideSerie = @GuideSerie
                                  AND GuideNumber = @GuideNumber;



                        END;
                        ELSE
                        BEGIN
                            --- La pieza de la guía no existe dentro de las piezas registradas en la preparación de ruta
                            INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece]
                            (
                                [RoutePreparationDetailId],
                                [PieceNumber],
                                [PieceType],
                                [RowStatus],
                                [TokenCreated],
                                [DateCreated]
                            )
                            VALUES
                            (@IdRoutePreparationDetail, @GuidePiece, IIF(@GuidePieceType = 1, 1, 0), 1, @Token,
                             GETDATE());
                        END;
                        IF COALESCE(@@ROWCOUNT, 0) > 0
                            SET @RModified = @RModified + 1;
                        --- Ingresar datos a tabla para retornar datos
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
                            [GUidePriceShippment],
                            [GuideCOD],
                            [GuideSenderFirstName],
                            [GuideSenderLastName],
                            [GuideReceiverFirstName],
                            [GuideReceiverLastName],
                            [SenderId],
                            [ReceiverId],
                            [Ticket_Number]
                        )
                        SELECT @IdRoutePreparation,
                               @GuideSerie,
                               @GuideNumber,
                               @GuidePiece,
                               @GuidePieceType,
                               (ISNULL(DO.Pieces_Dry, 0) + ISNULL(DO.Pieces_Cold, 0)),
                               ISNULL(DO.Pieces_Dry, 0),
                               ISNULL(DO.Pieces_Cold, 0),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.[Sender_Department]
                                    ELSE
                                        DO.Receiver_Department
                                END
                               ),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.[Sender_Town]
                                    ELSE
                                        DO.Receiver_Town
                                END
                               ),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.[Sender_Address]
                                    ELSE
                                        DO.Receiver_Address
                                END
                               ),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.[SenderIdTownship]
                                    ELSE
                                        DO.ReceiverIdTownship
                                END
                               ),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.[Sender_Phone]
                                    ELSE
                                        DO.Receiver_Phone
                                END
                               ),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.[Receiver_Department]
                                    ELSE
                                        DO.Sender_Department
                                END
                               ),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.[ReceiverIdTownship]
                                    ELSE
                                        DO.SenderIdTownship
                                END
                               ),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.[Receiver_Phone]
                                    ELSE
                                        DO.Sender_Phone
                                END
                               ),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.[Receiver_Address]
                                    ELSE
                                        DO.Sender_Address
                                END
                               ),
                               DO.PriceShippment,
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        0
                                    ELSE
                                        DO.Collect_OnDelivery
                                END
                               ),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.Receiver_FirstName
                                    ELSE
                                        DO.Sender_FirstName
                                END
                               ),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.Receiver_LastName
                                    ELSE
                                        DO.Sender_LastName
                                END
                               ),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.Sender_FirstName
                                    ELSE
                                        DO.Receiver_FirstName
                                END
                               ),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.Sender_LastName
                                    ELSE
                                        DO.Receiver_LastName
                                END
                               ),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.Receiver_ID
                                    ELSE
                                        DO.Sender_ID
                                END
                               ),
                               (CASE
                                    WHEN DO.[IsLastMileReturn] = 1 THEN
                                        DO.Sender_ID
                                    ELSE
                                        DO.Receiver_ID
                                END
                               ),
                               ISNULL(DO.[Ticket_Number], '0')
                        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                        WHERE DO.Guide_Serie = @GuideSerie
                              AND DO.Guide_Number = @GuideNumber;


                        --- Extraer todas las piezas de la guía de las piezas registradas de otras preparaciones
                        UPDATE RPDP
                        SET RPDP.RowStatus = 0,
                            RPDP.TokenUpdated = @Token,
                            RPDP.DateUpdated = GETDATE()
                        FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP WITH (NOLOCK)
                            INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH (NOLOCK)
                                ON RPDP.RoutePreparationDetailId = RPD.IdRoutePreparationDetail
                            INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH (NOLOCK)
                                ON RPD.RoutePreparationId = RP.IdRoutePreparation
                        WHERE RPDP.RowStatus = 1
                              AND RPD.RowStatus = 1
                              AND RP.RowStatus = 1
                              AND RPD.Guide_Serie = @GuideSerie
                              AND RPD.Guide_Number = @GuideNumber
                              AND RP.IdRoutePreparation <> @IdRoutePreparation
                              AND RP.DateRoutePreparation = @Date;

                        --- Extraer de los demas detalles la guía ingresada
                        UPDATE RPD
                        SET RPD.RowStatus = 0,
                            RPD.TokenUpdated = @Token,
                            RPD.DateUpdated = GETDATE()
                        FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH (NOLOCK)
                            INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH (NOLOCK)
                                ON RPD.RoutePreparationId = RP.IdRoutePreparation
                        WHERE RPD.RowStatus = 1
                              AND RPD.Guide_Serie = @GuideSerie
                              AND RPD.Guide_Number = @GuideNumber
                              AND RP.IdRoutePreparation <> @IdRoutePreparation
                              AND RP.DateRoutePreparation = @Date
                              AND RP.RowStatus = 1;

                        --- Validar que todas las piezas de la guía hayan sido escaneadas antes de actualizar el estado
                       
                         SELECT  
							@CountPieceGuideAdd = COUNT(*) 
						FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP WITH (NOLOCK)
                            INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH (NOLOCK)
                                ON RPDP.RoutePreparationDetailId = RPD.IdRoutePreparationDetail
                        WHERE RPD.Guide_Serie = @GuideSerie
                              AND RPD.Guide_Number = @GuideNumber
                              AND RPD.RoutePreparationId = @IdRoutePreparation
                              AND RPDP.RowStatus = 1
                              AND RPD.RowStatus = 1;
								
								

						 SELECT 
							@MaxPieceGuide = MAX(NoPiece) 	
                            FROM dbo.DeliveryOrderPiece WITH (NOLOCK)
                            WHERE GuideSerie = @GuideSerie
                            AND GuideNumber =  @GuideNumber;

						IF (@CountPieceGuideAdd = @MaxPieceGuide)
                        BEGIN
                            --- Actualizar el estado de la guía
                            UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder]
                            SET StatusOrderId = 3 --- Programado para entrega
                            WHERE Guide_Serie = @GuideSerie
                                  AND Guide_Number = @GuideNumber;
                        END;


                        --- Insertar el nuevo estado a bitácora
                        INSERT [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
                        (
                            [Guide_Serie],
                            [Guide_Number],
                            [StatusOrderId],
                            [UserCreated],
                            [DateCreated],
                            [DateCreatedInSystem],
                            [StationId]
                        )
                        SELECT @GuideSerie,
                               @GuideNumber,
                               3,
                               @Token,
                               GETDATE(),
                               GETDATE(),
                               @StationId
                        WHERE EXISTS
                        (
                            SELECT 1
                            FROM RoutePreparationDetail WITH (NOLOCK)
                            WHERE RoutePreparationId = @IdRoutePreparation
                                  AND Guide_Serie = @GuideSerie
                                  AND Guide_Number = @GuideNumber
                                  AND CAST(DateCreated AS DATE) = CAST(GETDATE() AS DATE)
                        );

                        --- Actualziar el estado de la pieza
                        UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece]
                        SET StatusOrderId = 3 --- Programado para entrega
                        WHERE GuideSerie = @GuideSerie
                              AND GuideNumber = @GuideNumber
                              AND NoPiece = @GuidePiece;

                        DECLARE @UpdatedWarehouseByPiece INT = 0;

                        --- Actualizar la posición del inventario
                        UPDATE [DeliveryBackOffice].[dbo].[Warehouse]
                        SET Active = 0,
                            UserUpdated = @Token,
                            DateUpdated = GETDATE()
                        WHERE Guide_Serie = @GuideSerie
                              AND Guide_Number = @GuideNumber
                              AND Guide_Piece = @GuidePiece;

                        SET @UpdatedWarehouseByPiece = @@ROWCOUNT;

                        -- verificar si se actualizo a nivel de pieza
                        IF (@UpdatedWarehouseByPiece = 0)
                        BEGIN
                            -- No se actualizo a nivel de pieza, no existe registro en warehouse a nivel de pieza

                            --- Actualizar la posición del inventario a nivel de guía
                            UPDATE [DeliveryBackOffice].[dbo].[Warehouse]
                            SET Active = 0,
                                UserUpdated = @Token,
                                DateUpdated = GETDATE()
                            WHERE Guide_Serie = @GuideSerie
                                  AND Guide_Number = @GuideNumber
                                  AND Active = 1;
                        END;

                    END;
                    ELSE
                    BEGIN

                        --- La pieza de la guía ya esta dentro de las piezas registradas
                        SET @GuidePieceAlreadyExists = 1;
                    END;

                END;
                ELSE
                BEGIN

                    --- La pieza no es real
                    SET @GuidePieceDoesntExist = 1;
                END;


            END;
            ELSE
            BEGIN

                --- No se pudo generar o encontrar el detalle de la preparación de ruta
                SET @FatalError = 1;
            END;

        END;
        ELSE
        BEGIN

            --- No se pudo generar o encontrar la preparación de ruta
            SET @FatalError = 2;
        END;

        ------------------------------------------------------------------------
        ----INICIO-FDD-942 UNIFICACION DE RUTERO EN PREPARACION DE ENTREGA		
        IF @IdRoutePreparationDetail IS NOT NULL --VERIFICACION DE EXISTENCIA DE ROUTE PREPARATION 
           AND @FirstPieceEntered = 1 --VERIFICACIÓN DE PRIMERA PIEZA DE LA GUÍA INGRESADA, ESTO PERMITE QUE SE EJECUTE EL PROCESO POR GUIA Y NO POR PIEZA
        BEGIN
            SET @subtypeservicemanagment =
            (
                SELECT IdSubTypeServiceManagment
                FROM dbo.SubTypeServiceManagment WITH (NOLOCK)
                WHERE Name = 'Entrega'
            );
            --PROCESO PARA SOPORTAR GUIAS CON DEVOLUCIÓN
            IF @IsReturn = 1
            BEGIN

                SET @subtypeservicemanagment =
                (
                    SELECT IdSubTypeServiceManagment
                    FROM dbo.SubTypeServiceManagment WITH (NOLOCK)
                    WHERE Name = 'Devolución'
                );

            END;
            ELSE
            BEGIN

                DECLARE @BrainProcessedGuides AS TABLE
                (
                    GuideSerie NVARCHAR(2),
                    GuideNumber INT,
                    IsCollect BIT,
                    Price DECIMAL(18, 2),
                    COD DECIMAL(18, 2),
                    AmountPaid DECIMAL(18, 2),
                    CODPaid DECIMAL(18, 2),
                    CODIsPaid BIT,
                    PaymentTime INT,
                    TimeSequence INT,
                    FelNumber NVARCHAR(50),
                    IsPaid BIT,
                    IsCustomer INT,
                    ConditionPayment NVARCHAR(200),
                    HaveCredit BIT,
                    CollectCOD BIT,
                    ReturnRate DECIMAL(5, 2),
                    CurrencyPrice_CODCodeISO NVARCHAR(8),
                    CurrencyPrice_CODSymbol NVARCHAR(8),
                    CurrencyPriceCodeISO NVARCHAR(8),
                    CurrencyPriceSymbol NVARCHAR(8),
                    AmountToPay DECIMAL(18, 2),
                    CODAmount DECIMAL(18, 2),
                    ReturnRates DECIMAL(5, 2)
                );
                DECLARE @GUIDECONCAT NVARCHAR(MAX) = CONCAT(@GuideSerie, CONVERT(NVARCHAR(MAX), @GuideNumber));
                INSERT INTO @BrainProcessedGuides
                EXEC [dbo].[spws_get_guide_pending_payment] @GUIDECONCAT, -- Guías recibidas
                                                            3,            -- Tiempo de pago 2 - En recolección
                                                            1,            -- No es ret5orno
                                                            '',           -- Codeapp
                                                            1,            -- Identificador de modulo donde proviene
                                                            @Token;       -- Token de courier
                SELECT @AmountToPay = bpg.AmountToPay,
                       @AmountToPayCOD = bpg.CODAmount
                FROM @BrainProcessedGuides bpg;
            END;


            SELECT @ServiceManagementDetailId = ServiceManagementDetailId
            FROM dbo.RoutePreparationDetail WITH (NOLOCK)
            WHERE RoutePreparationId = @IdRoutePreparationDetail;

            IF @ServiceManagementDetailId IS NULL
            BEGIN
                DECLARE @ProvinceId INT;
                DECLARE @TonwShipId INT;
                DECLARE @ServiceAddress NVARCHAR(600);
                DECLARE @ServicePhone NVARCHAR(100);
                DECLARE @PriceShippment DECIMAL(14, 2);
                DECLARE @GuideCOD DECIMAL(14, 2);
                DECLARE @FirstName NVARCHAR(100);
                DECLARE @LastName NVARCHAR(100);
                DECLARE @CodeOfReference INT;
                SELECT @ProvinceId = IIF(@IsReturn = 1, PRV_Sender.IdProvince, PRV_Receiver.IdProvince),
                       @TonwShipId = IIF(@IsReturn = 1, RT.GuideSenderIdTownship, RT.GuideReceiverIdTownShip),
                       @ServiceAddress = IIF(@IsReturn = 1, GuideSenderAddress, RT.GuideReceiverAddress),
                       @ServicePhone = IIF(@IsReturn = 1, RT.GuideSenderPhone, RT.GuideReceiverPhone),
                       @PriceShippment = RT.GUidePriceShippment,
                       @GuideCOD = RT.GuideCOD,
                       @FirstName = IIF(@IsReturn = 1, RT.GuideSenderFirstName, RT.GuideReceiverFirstName),
                       @LastName = IIF(@IsReturn = 1, RT.GuideSenderLastName, RT.GuideReceiverLastName),
                       @CodeOfReference = IIF(@IsReturn = 1, RT.SenderId, RT.ReceiverId)
                FROM @ResponseTable RT
                    LEFT JOIN dbo.Township PRV_Receiver WITH (NOLOCK)
                        ON RT.GuideReceiverIdTownShip = PRV_Receiver.IdTownship
                    LEFT JOIN dbo.Township PRV_Sender WITH (NOLOCK)
                        ON RT.GuideSenderIdTownship = PRV_Sender.IdTownship;

                SELECT TOP 1
                       @ServiceManagementDetailId = SMD.IdServiceManagementDetail
                FROM DeliveryBackOffice.dbo.ServiceManagementDetail SMD WITH (NOLOCK)
                    LEFT JOIN DeliveryBackOffice.dbo.RoutePreparationDetail RPD WITH (NOLOCK)
                        ON SMD.IdServiceManagementDetail = RPD.ServiceManagementDetailId
                           AND RPD.RowStatus = 1
                    LEFT JOIN DeliveryBackOffice.dbo.RoutePreparation RP WITH (NOLOCK)
                        ON RPD.RoutePreparationId = RP.IdRoutePreparation
                           AND RP.CatRouteId = @IdRoute
                           AND RP.DateRoutePreparation = @Date
                           AND RP.RowStatus = 1
                WHERE CONVERT(DATE, SMD.ServiceStartDate) = @Date
                      AND SMD.ProvinceId = @ProvinceId
                      AND SMD.TownshipId = @TonwShipId
                      AND SMD.ServiceAddress = @ServiceAddress
                      AND SMD.ServicePhone = @ServicePhone
                      AND SMD.SubTypeServiceManagmentId = @subtypeservicemanagment
                      AND SMD.RowStatus = 1
                      AND RP.IdRoutePreparation IS NOT NULL;

                IF (@ProvinceId IS NULL)
                BEGIN

                    SELECT TOP 1
                           @ProvinceId = Twn.IdProvince
                    FROM [DeliveryBackOffice].[dbo].[Township] Twn WITH (NOLOCK)
                    WHERE Twn.IdTownship = @TonwShipId;

                END;

                IF @ServiceManagementDetailId IS NULL
                BEGIN
                    SET @RouteAssigmentId =
                    (
                        SELECT TOP 1
                               IdRouteAssigment
                        FROM dbo.RouteAssigment WITH (NOLOCK)
                        WHERE IdRoute = @IdRoute
                              AND DateOfRoute = @Date
                    );
                    IF @RouteAssigmentId IS NULL
                    BEGIN
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
                        VALUES
                        (@IdRoute, NULL, NULL, @Date, 1, @Token, GETDATE(), NULL, NULL);

                        SET @RouteAssigmentId = SCOPE_IDENTITY();
                    END;

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
                    VALUES
                    (   NULL, NULL, NULL, NULL, NULL, NULL, @RouteAssigmentId, NULL, NULL, NULL, 1, @Token, GETDATE(),
                        NULL, NULL,
                        (
                            SELECT IdServiceStatus FROM dbo.CatServiceStatus WHERE Name = 'Creado'
                        ),                                    --<ServiceStatusId, int,>
                        NULL, NULL, @subtypeservicemanagment, --<SubTypeServiceManagmentId, int,>
                        NULL, 1, 0, NULL);

                    SET @IdServiceManagement = SCOPE_IDENTITY();

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
                    VALUES
                    (   @IdServiceManagement, GETDATE(),
                        DATEADD(hh, 20, CAST(CONVERT(DATE, GETDATE()) AS DATETIME)), --HORA FIN 8PM
                        @CodeOfReference, NULL, CAST(CONCAT(@FirstName, ' ', @LastName) AS NVARCHAR(100)),
                        ISNULL(@ProvinceId, 7), ISNULL(@TonwShipId, 73), NULL, CAST(@ServiceAddress AS NVARCHAR(500)),
                        NULL, CAST(@ServicePhone AS NVARCHAR(20)), NULL, 0, 0, NULL,
                        @subtypeservicemanagment,                                    --<SubTypeServiceManagmentId, bigint,>
                        1, CAST(@Token AS NVARCHAR(50)), GETDATE(), NULL, NULL);

                    SET @ServiceManagementDetailId = SCOPE_IDENTITY();

                    UPDATE RD
                    SET RD.ServiceManagementDetailId = @ServiceManagementDetailId
                    FROM dbo.RoutePreparationDetail RD
                    WHERE IdRoutePreparationDetail = @IdRoutePreparationDetail;
                END;
                ELSE
                BEGIN

                    UPDATE RD
                    SET RD.ServiceManagementDetailId = @ServiceManagementDetailId
                    FROM dbo.RoutePreparationDetail RD
                    WHERE IdRoutePreparationDetail = @IdRoutePreparationDetail;

                END;

                UPDATE ServiceManagementDetail
                SET ServiceAmount = IIF(@IsReturn = 1, ServiceAmount, ServiceAmount + ISNULL(@AmountToPay, 0)),
                    ServiceExtraAmount = IIF(@IsReturn = 1, 0, (ServiceExtraAmount + ISNULL(@AmountToPayCOD, 0))),
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE IdServiceManagementDetail = @ServiceManagementDetailId;
            END;

        END;
    ----FIN-FDD-942 UNIFICACION DE RUTERO EN PREPARACION DE ENTREGAGO
    --------------------------------------------------------------------
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        --Insert en tabla de log
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
        (CAST(ERROR_MESSAGE() AS VARCHAR(300)), ERROR_NUMBER(), CAST(ERROR_PROCEDURE() AS VARCHAR(100)), ERROR_LINE(),
         @GuideSerie, @GuideNumber, @Token, GETDATE());

        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               ERROR_LINE() AS 'ErrorLine';

    END CATCH;
    --- END TRANSACTION

    IF (@@TRANCOUNT > 0)
    BEGIN
        IF (@FatalError > 0)
        BEGIN
            IF (@FatalError = 1)
            BEGIN
                SELECT 0 AS 'StatusCode',
                       'Error al obtener la información del detalle de la preparación de ruta' AS 'Description',
                       0 AS 'NumTransferID';
            END;
            ELSE IF (@FatalError = 2)
            BEGIN
                SELECT 0 AS 'StatusCode',
                       'Error al obtener la información de la preparación de ruta' AS 'Description',
                       0 AS 'NumTransferID';
            END;
            ROLLBACK TRANSACTION;
        END;
        ELSE IF (@GuidePieceDoesntExist = 1)
        BEGIN
            SELECT 0 AS 'StatusCode',
                   CONCAT('Pieza ', @GuidePiece, ' no existe en la guía ', @GuideSerie, @GuideNumber) AS 'Description',
                   0 AS 'NumTransferID';
            ROLLBACK TRANSACTION;
        END;
        ELSE IF (@GuidePieceAlreadyExists = 1)
        BEGIN
            SELECT 0 AS 'StatusCode',
                   CONCAT('Pieza ', @GuidePiece, ' ya fue escaneada para la guía ', @GuideSerie, @GuideNumber) AS 'Description',
                   0 AS 'NumTransferID';
            ROLLBACK TRANSACTION;
        END;
        ELSE IF (@RModified > 0)
        BEGIN
            SELECT 200 AS 'StatusCode',
                   'Registros guardados correctamente' AS 'Description',
                   @@TRANCOUNT AS 'NumTransferID';

            SELECT RT.GuideSerie 'Guide_Serie',
                   RT.GuideNumber 'Guide_Number',
                   RT.GuidePiece 'Guide_Piece',
                   RT.GuidePieces 'Pieces',
                   RT.GuideReceiverDepartment 'Department',
                   RT.GuideReceiverTown 'Town',
                   RT.GuideReceiverAddress 'Address',
                   RT.GuideDryPieces 'Pieces_Dry',
                   RT.GuideColdPieces 'Pieces_Cold',
                   RT.GuidePieceType 'Piece_Type',
                   NULL 'GuideOrder',
                   @IdRoutePreparation 'NewRoutePreparation',
                   RT.Ticket_Number
            FROM @ResponseTable RT;
            COMMIT TRANSACTION;
        END;
        ELSE
        BEGIN
            SELECT 0 AS 'StatusCode',
                   'Registros no guardados' AS 'Description',
                   0 AS 'NumTransferID';
            ROLLBACK TRANSACTION;
        END;
    END;
    ELSE
    BEGIN
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               ERROR_LINE() AS 'ErrorLine';
    END;
END;