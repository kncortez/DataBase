-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <11-08-2022>
-- Description:	<Add a guide into LinehaulRouteSettlementContainerDetail and LinehaulRouteSettlementContainerDetailPiece>
-- =============================================
-- =============================================
-- Author:		<Cristian, Suazo>
-- Create date: <05-11-2025>
-- Description:	<Se quita la restriccion de escanear todas las piezas de una guia>
-- =============================================

CREATE PROCEDURE [dbo].[spHM_addGuideToLinehaulSettlement]
    @LinehaulRouteSettlementId AS INT,
    @LinehaulRoutePreparationId AS INT,
    @LinehaulRouteSettlementContainerId AS INT,
    @ContainerId AS INT,
    @HubId AS INT,
    @GuideSerie AS NVARCHAR(10),
    @GuideNumber AS NVARCHAR(25),
    @GuidePiece AS INT,
    @IsOpenProcess AS INT,
    @GuideReceived AS INT,
    @TknUser AS NVARCHAR(50)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @EXISTING_LRPC AS INT; -- LinehaulRoutePreparationContainer
    DECLARE @EXISTING_LRPCDP AS INT; -- LinehaulRoutePreparationContainerDetailPiece
    DECLARE @EXISTING_PIECE AS INT; -- LinehaulRoutePreparationContainerDetailPiece
    DECLARE @EXISTING_LRSC AS INT; -- LinehaulRouteSettlementContainer;
    DECLARE @EXISTING_LRSCD AS INT; -- LinehaulRouteSettlementContainerDetail
    DECLARE @EXISTING_LRSCD_ACTIVE AS INT; -- LinehaulRouteSettlementContainerDetail
    DECLARE @EXISTING_LRSCDP AS INT; -- LinehaulRouteSettlementContainerDetailPiece
    DECLARE @INSERTED_DOC AS INT; -- Last inserted doc
    DECLARE @COUNT_RECEIVED_PIECES AS INT; -- Update LinehaulRouteSettlementContainerDetail
    DECLARE @COUNT_MISSING_PIECES AS INT; -- Update LinehaulRouteSettlementContainerDetail
    DECLARE @COUNT_GUIDE_QUANTITY AS INT; -- Update LinehaulRouteSettlementContainer
    DECLARE @COUNT_DRY_QUANTITY AS INT; -- Update LinehaulRouteSettlementContainer
    DECLARE @COUNT_COLD_QUANTITY AS INT; -- Update LinehaulRouteSettlementContainer
    DECLARE @COUNT_CONTAINERS_RECEIVED AS INT; -- Update LinehaulRouteSettlement
    DECLARE @COUNT_GUIDES_RECEIVED AS INT; -- Update LinehaulRouteSettlement
    DECLARE @COUNT_PIECES_RECEIVED AS INT; -- Update LinehaulRouteSettlement
    DECLARE @COUNT_PIECES_MISSING AS INT; -- Update LinehaulRouteSettlement
    DECLARE @DOP_PIECES AS INT; -- DeliveryOrderPiece
    DECLARE @GUIDE_IS_OPEN_PROCESS AS INT; -- LinehaulRouteSettlementContainerDetail
    DECLARE @OPEN_PROCESS_TKN AS VARCHAR(50); -- LinehaulRouteSettlementContainerDetail
    DECLARE @OPEN_PROCESS_USER AS VARCHAR(50); -- TokenLog
    DECLARE @IS_OPEN_PROCESS AS INT; -- Configuration
    DECLARE @LIQUIDATED_STATUS_ID AS INT; -- CatLinehaulStatus
    DECLARE @SETTLEMENT_STATUS_ORDER_ID AS INT; -- StatusOrderId
    DECLARE @VBX_ID AS INT; -- Container
    DECLARE @HUB_IN_CONTAINER AS INT; -- LinehaulRoutePreparationContainer
    DECLARE @CONTAINER_ID_BETA AS INT; -- LinehaulRoutePreparationContainerDetail
    DECLARE @ALLOW_UNRST_SETTL AS BIT; -- CatTypeContainer
    DECLARE @SETTL_CONTAINER_ID_BETA AS INT; -- LinehaulRouteSettlementContainer
    DECLARE @DISPT_CONTAINER_ID_BETA AS INT; -- LinehaulRoutePreparationContainer
	DECLARE @ValidStatus INT

    SET @VBX_ID =
    (
        SELECT TOP 1
               [C].[IdContainer]
        FROM [dbo].[Container] C
            INNER JOIN [dbo].[CatTypeContainer] CTC
                ON [C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
                  
        WHERE [C].[RowStatus] = 1  AND [CTC].[TypeContainerSerie] = 'VBX'
    );

    SET @EXISTING_LRPC =
    (
        SELECT COUNT([LRPC].[IdLinehaulRoutePreparationContainer]) AS CONT
        FROM [dbo].[LinehaulRoutePreparationContainer] LRPC
        WHERE [LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
              AND [LRPC].[ContainerId] = @ContainerId
              AND [LRPC].[RowStatus] = 1
    );

    SET @EXISTING_PIECE =
    (
        SELECT COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
        FROM [dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
            INNER JOIN [dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
                ON [LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
                 
            INNER JOIN [dbo].[LinehaulRoutePreparationContainer] LRPC
                ON [LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
                   AND [LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
                   AND [LRPC].[RowStatus] = 1
        WHERE [LRPCDP].[PieceNumber] = @GuidePiece
		  AND [LRPCD].[RowStatus] = 1
                   AND [LRPCD].[GuideSerie] = @GuideSerie
                   AND [LRPCD].[GuideNumber] = @GuideNumber
    );

    SET @EXISTING_LRPCDP =
    (
        SELECT COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
        FROM [dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
            INNER JOIN [dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
                ON [LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
                 
            INNER JOIN [dbo].[LinehaulRoutePreparationContainer] LRPC
                ON [LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
                  
        WHERE [LRPCDP].[PieceNumber] = @GuidePiece 
		  AND [LRPCD].[GuideSerie] = @GuideSerie
                   AND [LRPCD].[GuideNumber] = @GuideNumber
                   AND [LRPCD].[RowStatus] = 1
				    AND [LRPC].[ContainerId] = @ContainerId
                   AND [LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
                   AND [LRPC].[RowStatus] = 1
    );

    SET @DOP_PIECES =
    (
        SELECT COUNT([DOP].[NoPiece]) AS CONT
        FROM [dbo].[DeliveryOrderPiece] DOP WITH (NOLOCK)
        WHERE [DOP].[GuideSerie] = @GuideSerie
              AND [DOP].[GuideNumber] = @GuideNumber
    );


	/****VALIDAMOS QUE NO ESTE EN ESTADO EN REVISADO LA GUIA*****/

	SET @ValidStatus = 
	(
		SELECT StatusOrderId FROM DeliveryOrder WITH (NOLOCK) 
		WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
	)

	IF (@ValidStatus = 13)
	BEGIN
		SELECT 0 [spResult],
               'La guía se encuentra en estado “En revisión”, por lo que, no se puede procesar. Por favor, comunícate con el área de Planning para liberarla.' [errorMessage];
        RETURN;
	END;

    IF (@DOP_PIECES = 0)
    BEGIN
        SELECT 0 [spResult],
               'El código escaneado NO existe en la base de datos, intente nuevamente o comuníquese con soporte técnico.' [errorMessage];
        RETURN;
    END;

    SET @EXISTING_LRSC =
    (
        SELECT COUNT([LRSC].[IdLinehaulRouteSettlementContainer]) AS CONT
        FROM [dbo].[LinehaulRouteSettlementContainer] LRSC
        WHERE [LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
              AND [LRSC].[ContainerId] = @ContainerId
              AND [LRSC].[HubId] = @HubId
              AND [LRSC].[RowStatus] = 1
    );

    SET @LIQUIDATED_STATUS_ID =
    (
        SELECT [CLS].[IdCatLinehaulStatus]
        FROM [dbo].[CatLinehaulStatus] CLS
        WHERE [CLS].[StatusName] = 'LIQUIDATED'
    );

    IF (@EXISTING_PIECE = 0)
    BEGIN
        -- LinehaulRoutePreparationContainer doesn't exist
        SELECT 6 [spResult],
               'La pieza escaneada NO pertenece al manifiesto en liquidación, ¿Desea agregarla de todas formas?' [errorMessage];
        RETURN;
    END;

    IF (@EXISTING_LRPC = 0)
    BEGIN
        -- LinehaulRoutePreparationContainer doesn't exist
        SELECT 0 [spResult],
               'Contenedor NO existe en despacho de ruta' [errorMessage];
        RETURN;
    END;

    IF (@EXISTING_LRSC = 0)
    BEGIN
        -- CONTAINER DOESN'T EXIST IN SETTLEMENT
        SELECT 0 [spResult],
               'Contenedor NO existe en liquidación de ruta' [errorMessage];
        RETURN;
    END;

    IF (@EXISTING_LRPCDP = 0)
    -- PIECE DOESN'T EXIST IN LINEHAUL ROUTE PREPARATION CONTAINER
    BEGIN
        -- Obtener Hub destino y contenedor de la guía
        SELECT @HUB_IN_CONTAINER = [LRPC].[HubDestinyId],
               @CONTAINER_ID_BETA = [LRPC].[ContainerId],
               @ALLOW_UNRST_SETTL = [CTC].[AllowUnrstSettl]
        FROM [dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
            INNER JOIN [dbo].[LinehaulRoutePreparationContainer] LRPC
                ON [LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
                  
            INNER JOIN [dbo].[Container] C
                ON [LRPC].[ContainerId] = [C].[IdContainer]
            INNER JOIN [dbo].[CatTypeContainer] CTC
                ON [C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
        WHERE [LRPCD].[GuideSerie] = @GuideSerie
              AND [LRPCD].[GuideNumber] = @GuideNumber
              AND [LRPCD].[RowStatus] = 1
			   AND [LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
                   AND [LRPC].[RowStatus] = 1

        IF (@HubId = @HUB_IN_CONTAINER AND @ALLOW_UNRST_SETTL = 1)
        BEGIN
            SET @HubId = @HUB_IN_CONTAINER;
            SET @ContainerId = @CONTAINER_ID_BETA;

            SET @DISPT_CONTAINER_ID_BETA =
            (
                SELECT [LRPC].[ContainerId]
                FROM [dbo].[LinehaulRoutePreparationContainer] LRPC
                    INNER JOIN [dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
                        ON [LRPC].[IdLinehaulRoutePreparationContainer] = [LRPCD].[LinehaulRoutePreparationContainerId]
                          
                WHERE [LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
				 AND [LRPCD].[GuideSerie] = @GuideSerie
                           AND [LRPCD].[GuideNumber] = @GuideNumber
                           AND [LRPCD].[RowStatus] = 1
            );

            SET @SETTL_CONTAINER_ID_BETA =
            (
                SELECT COUNT([LRSC].[IdLinehaulRouteSettlementContainer])
                FROM [dbo].[LinehaulRouteSettlementContainer] LRSC
                WHERE [LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
                      AND [LRSC].[ContainerId] = @DISPT_CONTAINER_ID_BETA
            );

            -- INSERT CONTAINER IF IT DOESNT EXIST IN SETTLEMENT
            IF (@SETTL_CONTAINER_ID_BETA = 0)
            BEGIN
                INSERT INTO [dbo].[LinehaulRouteSettlementContainer]
                (
                    [LinehaulRouteSettlementId],
                    [ContainerId],
                    [HubId],
                    [GuideQuantity],
                    [DryPiecesQuantity],
                    [ColdPiecesQuantity],
                    [RowStatus],
                    [TokenCreated],
                    [DateCreated]
                )
                VALUES
                (   @LinehaulRouteSettlementId, @ContainerId, @HubId, 0, -- GuideQuantity
                    0,                                                   -- DryPiecesQuantity
                    0,                                                   -- ColdPiecesQuantity
                    1,                                                   -- RowStatus
                    @TknUser, SYSDATETIME());

                SET @LinehaulRouteSettlementContainerId = SCOPE_IDENTITY();

            END;
            ELSE
            BEGIN
                SET @LinehaulRouteSettlementContainerId =
                (
                    SELECT [LRSC].[IdLinehaulRouteSettlementContainer]
                    FROM [dbo].[LinehaulRouteSettlementContainer] LRSC
                    WHERE [LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
                          AND [LRSC].[ContainerId] = @DISPT_CONTAINER_ID_BETA
                );
            END;

        END;
        ELSE
        BEGIN
            SELECT 0 [spResult],
                   'Pieza NO existe en contenedor seleccionado' [errorMessage];
            RETURN;
        END;
    END;


    -- CHECK IF GUIDE IS IN SETTLEMENT
    SET @EXISTING_LRSCD =
    (
        SELECT COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
        FROM [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
        WHERE [LRSCD].[GuideSerie] = @GuideSerie
              AND [LRSCD].[GuideNumber] = @GuideNumber
              AND [LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
    );

    SET @EXISTING_LRSCD_ACTIVE =
    (
        SELECT COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
        FROM [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
		INNER JOIN LinehaulRouteSettlementContainerDetailPiece PC WITH (NOLOCK)
			ON PC.LinehaulRouteSettlementContainerDetailId = LRSCD.IdLinehaulRouteSettlementContainerDetail
        WHERE [LRSCD].[GuideSerie] = @GuideSerie
              AND [LRSCD].[GuideNumber] = @GuideNumber
			  AND PC.PieceNumber = @GuidePiece
              AND [LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
              AND [LRSCD].[GuideReceived] = 1
              AND [LRSCD].[RowStatus] = 1
    );

    IF (@EXISTING_LRSCD_ACTIVE > 0)
    BEGIN
        SELECT 5 [spResult],
               'Guía ya se ha registrado en el proceso actual' [errorMessage];
        RETURN;
    END;

    -- CONTAINER IS ADDED IN SETTLEMENT
    BEGIN TRANSACTION;
    BEGIN TRY
        -- ADD OR UPDATE CONTAINER DETAIL IN SETTLEMENT
        -- GET STATUS ORDER ID FOR SETTLEMENT
        SET @SETTLEMENT_STATUS_ORDER_ID =
        (
            SELECT [SO].[StatusOrderId]
            FROM [dbo].[StatusOrder] SO
            WHERE [SO].[OrderDescription] = 'Trasladado a Hub'
        );

        -- CHECK IF PIECE EXISTS IN SETTLEMENT
        SET @EXISTING_LRSCDP =
        (
            SELECT COUNT([LRSCDP].[IdLinehaulRouteSettlementContainerDetailPiece]) AS CONT
            FROM [dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
                INNER JOIN [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
                    ON [LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
                      
            WHERE [LRSCDP].[PieceNumber] = @GuidePiece
			 AND [LRSCD].[GuideSerie] = @GuideSerie
                       AND [LRSCD].[GuideNumber] = @GuideNumber
                       AND [LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
        );

        IF (@EXISTING_LRSCD = 0)
        -- CONTAINER DETAIL IN SETTLEMENT DOESN'T EXIST, INSERT
        BEGIN
            SET @IS_OPEN_PROCESS = 0;
            INSERT INTO [LinehaulRouteSettlementContainerDetail]
            (
                [LinehaulRouteSettlementContainerId],
                [GuideSerie],
                [GuideNumber],
                [PiecesReceived],
                [PiecesMissing],
                [GuideReceived],
                [IsOpenProcess],
                [UserProcess],
                [RowStatus],
                [TokenCreated],
                [DateCreated]
            )
            VALUES
            (   @LinehaulRouteSettlementContainerId, @GuideSerie, @GuideNumber, 0, -- PiecesReceived
                0,                                                                 -- PiecesMissing
                @GuideReceived, @IS_OPEN_PROCESS, @TknUser, 1,                     -- RowStatus,
                @TknUser, SYSDATETIME());

            SET @EXISTING_LRSCD = SCOPE_IDENTITY();
        END;

        BEGIN
            BEGIN

                -- ONE PIECE, ADD TO SETTLEMENT
                -- CONTAINER DETAIL IN SETTLEMENT EXISTS, UPDATE
                UPDATE [LinehaulRouteSettlementContainerDetail]
                SET [RowStatus] = 1,
                    [TokenUpdated] = @TknUser,
                    [DateUpdated] = SYSDATETIME(),
                    [IsOpenProcess] = @IsOpenProcess,
                    [GuideReceived] = @GuideReceived,
                    [UserProcess] = @TknUser,
					PiecesMissing = PiecesMissing + 1
                WHERE [GuideSerie] = @GuideSerie
                      AND [GuideNumber] = @GuideNumber
                      AND [LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId;


                IF (@EXISTING_LRSCDP > 0)
                BEGIN
                    -- PIECE EXISTS IN SETTLEMENT, UPDATE
                    UPDATE [LinehaulRouteSettlementContainerDetailPiece]
                    SET [RowStatus] = 1,
                        [TokenUpdated] = @TknUser,
                        [DateUpdated] = SYSDATETIME()
                    WHERE [LinehaulRouteSettlementContainerDetailId] =
                    (
                        SELECT [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
                        FROM [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
                        WHERE [LRSCD].[GuideSerie] = @GuideSerie
                              AND [LRSCD].[GuideNumber] = @GuideNumber
                              AND [LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
                    )
                          AND [PieceNumber] = @GuidePiece;

                    -- UPDATE PIECE IN LINEHAUL ROUTE PREPARATION
                    UPDATE [LinehaulRoutePreparationContainerDetailPiece]
                    SET [CatLinehaulStatusId] = @LIQUIDATED_STATUS_ID
                    FROM [dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
                        INNER JOIN [dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
                            ON [LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
                              
                        INNER JOIN [dbo].[LinehaulRoutePreparationContainer] LRPC
                            ON [LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
                               
                    WHERE [LRPCDP].[PieceNumber] = @GuidePiece
					 AND [LRPCD].[GuideSerie] = @GuideSerie
                               AND [LRPCD].[GuideNumber] = @GuideNumber
                               AND [LRPCD].[RowStatus] = 1
							   AND [LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId

                    -- RETURN DATA
                    SELECT [LRSCD].[GuideSerie],
                           [LRSCD].[GuideNumber],
                           [LRSCD].[UserProcess],
                           [LRSCD].[IsOpenProcess],
                           [LRSCDP].[IdLinehaulRouteSettlementContainerDetailPiece],
                           [LRSCDP].[LinehaulRouteSettlementContainerDetailId],
                           [LRSCDP].[PieceNumber],
                           [LRSCDP].[IsDryPiece],
                           COALESCE([LRSCDP].[ActCode], 0) AS ActCode,
                           [LRSC].[HubId],
                           [HL].[HubAbbreviation],
                           [LRSC].[ContainerId],
                           CONCAT([CTC].[TypeContainerSerie], [C].[ContainerNumber]) AS Container,
                           [LRSC].[IdLinehaulRouteSettlementContainer]
                    FROM [LinehaulRouteSettlementContainerDetailPiece] LRSCDP
                        INNER JOIN [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
                            ON [LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
                               
                        INNER JOIN [dbo].[LinehaulRouteSettlementContainer] LRSC
                            ON [LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
                        INNER JOIN [dbo].[HubLogistics] HL
                            ON [LRSC].[HubId] = [HL].[IdHubLogistic]
                        INNER JOIN [dbo].[Container] C
                            ON [LRSC].[ContainerId] = [C].[IdContainer]
                        INNER JOIN [dbo].[CatTypeContainer] CTC
                            ON [C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
                    WHERE [LRSCDP].[RowStatus] = 1
					AND [LRSCD].[GuideSerie] = @GuideSerie
                               AND [LRSCD].[GuideNumber] = @GuideNumber
                               AND [LRSCD].[UserProcess] = @TknUser
                END;
                ELSE
                BEGIN
                    -- PIECE DOESN'T EXIST IN SETTLEMENT, INSERT
                    INSERT INTO [dbo].[LinehaulRouteSettlementContainerDetailPiece]
                    (
                        [LinehaulRouteSettlementContainerDetailId],
                        [PieceNumber],
                        [IsDryPiece],
                        [RowStatus],
                        [TokenCreated],
                        [DateCreated]
                    )
                    VALUES
                    (
                        (
                            SELECT [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
                            FROM [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
                            WHERE [LRSCD].[GuideSerie] = @GuideSerie
                                  AND [LRSCD].[GuideNumber] = @GuideNumber
                                  AND [LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
                        ), @GuidePiece,
                        (
                            SELECT [LRPCDP].[IsDryPiece]
                            FROM [dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
                                INNER JOIN [dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
                                    ON [LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
                                      
                                INNER JOIN [dbo].[LinehaulRoutePreparationContainer] LRPC
                                    ON [LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
                                       
                            WHERE [LRPCDP].[PieceNumber] = @GuidePiece
							 AND [LRPCD].[GuideSerie] = @GuideSerie
                                       AND [LRPCD].[GuideNumber] = @GuideNumber
                                       AND [LRPCD].[RowStatus] = 1
									   AND [LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
                        ), 1, -- RowStatus
                        @TknUser, SYSDATETIME());

                    SET @INSERTED_DOC = SCOPE_IDENTITY();

                    -- UPDATE PIECE IN LINEHAUL ROUTE PREPARATION
                    UPDATE [LinehaulRoutePreparationContainerDetailPiece]
                    SET [CatLinehaulStatusId] = @LIQUIDATED_STATUS_ID
                    FROM [dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
                        INNER JOIN [dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
                            ON [LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
                             
                        INNER JOIN [dbo].[LinehaulRoutePreparationContainer] LRPC
                            ON [LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
                              
                    WHERE [LRPCDP].[PieceNumber] = @GuidePiece
					  AND [LRPCD].[GuideSerie] = @GuideSerie
                               AND [LRPCD].[GuideNumber] = @GuideNumber
                               AND [LRPCD].[RowStatus] = 1
							    AND [LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId

                    -- UPDATE STATUS IN DELIVERY ORDER
                    UPDATE [DeliveryOrder]
                    SET [StatusOrderId] = @SETTLEMENT_STATUS_ORDER_ID,
                        [TokenUpdated] = @TknUser,
                        [DateUpdated] = SYSDATETIME()
                    WHERE [Guide_Serie] = @GuideSerie
                          AND [Guide_Number] = @GuideNumber;

                    -- INSERT LOG IN DELIVERY ORDER DETAIL
                    INSERT INTO [dbo].[DeliveryOrderDetail]
                    (
                        [Guide_Serie],
                        [Guide_Number],
                        [StatusOrderId],
                        [UserCreated],
                        [DateCreated],
                        [DateCreatedInSystem]
                    )
                    SELECT [LRPCD].[GuideSerie],
                           [LRPCD].[GuideNumber],
                           @SETTLEMENT_STATUS_ORDER_ID,
                           @TknUser,
                           SYSDATETIME(),
                           SYSDATETIME()
                    FROM [dbo].[LinehaulRouteSettlementContainerDetail] LRPCD
                    WHERE [LRPCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
                          AND [LRPCD].[GuideNumber] = @GuideNumber
                          AND [LRPCD].[GuideSerie] = @GuideSerie
                          AND [LRPCD].[RowStatus] = 1;

                    -- RETURN DATA
                    SELECT [LRSCD].[GuideSerie],
                           [LRSCD].[GuideNumber],
                           [LRSCD].[UserProcess],
                           [LRSCD].[IsOpenProcess],
                           [LRSCDP].[IdLinehaulRouteSettlementContainerDetailPiece],
                           [LRSCDP].[LinehaulRouteSettlementContainerDetailId],
                           [LRSCDP].[PieceNumber],
                           [LRSCDP].[IsDryPiece],
                           COALESCE([LRSCDP].[ActCode], 0) AS ActCode,
                           [LRSC].[HubId],
                           [HL].[HubAbbreviation],
                           [LRSC].[ContainerId],
                           CONCAT([CTC].[TypeContainerSerie], [C].[ContainerNumber]) AS Container,
                           [LRSC].[IdLinehaulRouteSettlementContainer]
                    FROM [LinehaulRouteSettlementContainerDetailPiece] LRSCDP
                        INNER JOIN [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
                            ON [LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
                              
                        INNER JOIN [dbo].[LinehaulRouteSettlementContainer] LRSC
                            ON [LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
                        INNER JOIN [dbo].[HubLogistics] HL
                            ON [LRSC].[HubId] = [HL].[IdHubLogistic]
                        INNER JOIN [dbo].[Container] C
                            ON [LRSC].[ContainerId] = [C].[IdContainer]
                        INNER JOIN [dbo].[CatTypeContainer] CTC
                            ON [C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
                    WHERE [LRSCDP].[RowStatus] = 1
					 AND [LRSCD].[GuideSerie] = @GuideSerie
                               AND [LRSCD].[GuideNumber] = @GuideNumber
                               AND [LRSCD].[UserProcess] = @TknUser
                END;
            END;
        END;

        -- UDPATE SETTLEMENT COUNTERS
        BEGIN
            -- UPDATE SETTLEMENT DETAIL COUNTERS
            SET @COUNT_RECEIVED_PIECES =
            (
                SELECT COUNT([LRSCDP].[PieceNumber]) AS CONT
                FROM [dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
                    INNER JOIN [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
                        ON [LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
                         
                WHERE [LRSCDP].[ActCode] IS NULL
                      AND [LRSCDP].[RowStatus] = 1
					    AND [LRSCD].[GuideSerie] = @GuideSerie
                           AND [LRSCD].[GuideNumber] = @GuideNumber
                           AND [LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
                           AND [LRSCD].[RowStatus] = 1
                           AND [LRSCD].[IsOpenProcess] = 0
            );

            SET @COUNT_MISSING_PIECES =
            (
                SELECT COUNT([LRSCDP].[PieceNumber]) AS CONT
                FROM [dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
                    INNER JOIN [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
                        ON [LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
                         
                WHERE [LRSCDP].[RowStatus] = 1
					    AND [LRSCD].[GuideSerie] = @GuideSerie
                           AND [LRSCD].[GuideNumber] = @GuideNumber
                           AND [LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
            );

            UPDATE [LinehaulRouteSettlementContainerDetail]
            SET [PiecesReceived] = @COUNT_RECEIVED_PIECES,
                [PiecesMissing] = @COUNT_MISSING_PIECES
            WHERE [LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
                  AND [GuideSerie] = @GuideSerie
                  AND [GuideNumber] = @GuideNumber;

            -- UPDATE SETTLEMENT CONTAINER COUNTERS
            SET @COUNT_DRY_QUANTITY =
            (
                SELECT COUNT([LRSCDP].[PieceNumber]) AS CONT
                FROM [dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
                    INNER JOIN [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
                        ON [LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
                          
                WHERE [LRSCDP].[IsDryPiece] = 1
                      AND [LRSCDP].[ActCode] IS NULL
                      AND [LRSCDP].[RowStatus] = 1
					   AND [LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
                           AND [LRSCD].[RowStatus] = 1
                           AND [LRSCD].[IsOpenProcess] = 0
            );

            SET @COUNT_COLD_QUANTITY =
            (
                SELECT COUNT([LRSCDP].[PieceNumber]) AS CONT
                FROM [dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
                    INNER JOIN [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
                        ON [LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
                          
                WHERE [LRSCDP].[IsDryPiece] = 0
                      AND [LRSCDP].[ActCode] IS NULL
                      AND [LRSCDP].[RowStatus] = 1
					   AND [LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
                           AND [LRSCD].[RowStatus] = 1
                           AND [LRSCD].[IsOpenProcess] = 0
            );

            SET @COUNT_GUIDE_QUANTITY =
            (
                SELECT COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
                FROM [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
                WHERE [LRSCD].[RowStatus] = 1
                      AND [LRSCD].[IsOpenProcess] = 0
                      AND [LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
            );

            UPDATE [LinehaulRouteSettlementContainer]
            SET [GuideQuantity] = @COUNT_GUIDE_QUANTITY,
                [DryPiecesQuantity] = @COUNT_DRY_QUANTITY,
                [ColdPiecesQuantity] = @COUNT_COLD_QUANTITY
            WHERE [IdLinehaulRouteSettlementContainer] = @LinehaulRouteSettlementContainerId;

            -- UPDATE SETTLEMENT HEADER COUNTERS
            SET @COUNT_CONTAINERS_RECEIVED =
            (
                SELECT COUNT([LRSC].[IdLinehaulRouteSettlementContainer]) AS CONT
                FROM [dbo].[LinehaulRouteSettlementContainer] LRSC
                WHERE [LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
                      AND [LRSC].[ContainerId] != @VBX_ID
                      AND [LRSC].[RowStatus] = 1
            );

            SET @COUNT_GUIDES_RECEIVED =
            (
                SELECT COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
                FROM [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
                    INNER JOIN [dbo].[LinehaulRouteSettlementContainer] LRSC
                        ON [LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
                          
                WHERE [LRSCD].[RowStatus] = 1
				 AND [LRSC].[RowStatus] = 1
                           AND [LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
                           AND [LRSC].[ContainerId] != @VBX_ID
            );

            SET @COUNT_PIECES_RECEIVED =
            (
                SELECT SUM([LRSCD].[PiecesReceived]) AS CONT
                FROM [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
                    INNER JOIN [dbo].[LinehaulRouteSettlementContainer] LRSC
                        ON [LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
                           WHERE [LRSC].[RowStatus] = 1
                           AND [LRSC].[ContainerId] != @VBX_ID
                           AND [LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
            );

            SET @COUNT_PIECES_MISSING =
            (
                SELECT SUM([LRSCD].[PiecesMissing]) AS CONT
                FROM [dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
                    INNER JOIN [dbo].[LinehaulRouteSettlementContainer] LRSC
                        ON [LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
                           WHERE [LRSC].[RowStatus] = 1
                           AND [LRSC].[ContainerId] != @VBX_ID
                           AND [LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
            );

            UPDATE [LinehaulRouteSettlement]
            SET [ContainersReceived] = @COUNT_CONTAINERS_RECEIVED,
                [GuidesReceived] = @COUNT_GUIDES_RECEIVED,
                [GuidePiecesReceived] = @COUNT_PIECES_RECEIVED,
                [GuidePiecesMissing] = @COUNT_PIECES_MISSING
            WHERE [IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId;

        END;

        IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SELECT 0 [spResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

        ROLLBACK TRANSACTION;
    END CATCH;

END;