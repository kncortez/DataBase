
--DECLARE @FECHA AS DATETIME = GETDATE();
--EXEC [sps_set_status_order_by_guide_linehauls] 'FD',508075,1,'FD508075-1',19,'MTIzMDYyMDIxMjMxOTMzMzg0MTky',@FECHA,'',NULL,'LGUA01','52',1,0,1,1,'2021-08-09'
-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2022-01-17>
-- Description:	<Modificación para liberar posición de Guía en el Rack.>
-- =============================================
CREATE PROCEDURE [dbo].[sps_set_status_order_by_guide_linehauls]
    @Guide_Serie AS VARCHAR(2),         -- same guide for all numbers provided
    @GuideNumber AS BIGINT,
    @GuidePiece AS INT,
    @Guide_Number AS VARCHAR(MAX),      -- a list of guides separated by comma
    @StatusId AS INT,                   -- status from StatusOrder
    @TokenId AS VARCHAR(50),
    @DateOfStatus DATETIME,             -- datetime of event
    @Observations AS VARCHAR(200) = '', --Observations by checkpoint
    @Temperature_Celsius AS DECIMAL(5, 2) = 0.00,
    @Route AS NVARCHAR(50) = 'Devolución',
    @IdRoute AS NVARCHAR(50) = 99999,
    @PiecesDry SMALLINT = 0,
    @PiecesCold SMALLINT = 0,
    @OPTION AS INT = 2,
    @IsDry AS TINYINT = 1,
    @DateOfRoute DATE
AS
BEGIN
    DECLARE @ValidateOperation BIGINT = 0;
    DECLARE @RowUpdated INT = 0;
    DECLARE @HUB_Destino INT = 0;
    DECLARE @HUB_Origen INT = 0;
    DECLARE @IdRouteASG INT = 0;
    DECLARE @IdServiceManagement INT = 0;
    DECLARE @ItemsTable AS TABLE
    (
        Guide_Number INT
    );
    DECLARE @IdSettlementByPickup INT = 0;
    DECLARE @SubTypeServiceManagmentId INT = 4;
    DECLARE @StatusOrderId INT = 19;
    DECLARE @ExistePiezaPorServicio INT = 0;
    DECLARE @ReceiverIdTownship INT = 0;
	DECLARE @GuideStatus INT;
	DECLARE @TerminalCheckpointType INT;
	SET @TerminalCheckpointType =
	(
		SELECT 
			TOP (1) 
				[CCT].[IdCatCheckpointType] 
		FROM 
			[DeliveryBackOffice].[dbo].[CatCheckpointType] CCT  WITH(NOLOCK) 
		WHERE
			[CCT].[CheckpointTypeDescription] = 'Checkpoint final'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @TerminalCheckpoint TABLE
	(
		StatusOrderId INT
	);
	INSERT INTO @TerminalCheckpoint
	(
	    [StatusOrderId]
	)
	SELECT 
		[SO].[StatusOrderId] 
	FROM
		[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
	WHERE
		[SO].[CatCheckpointTypeId] = @TerminalCheckpointType

	SELECT 
		TOP (1) 
			@GuideStatus = [DO].[StatusOrderId] 
	FROM 
		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
	WHERE
		[DO].[Guide_Serie] = @Guide_Serie
		AND
		[DO].[Guide_Number] = @GuideNumber

	IF ( @GuideStatus IN (SELECT [TC].[StatusOrderId] FROM @TerminalCheckpoint TC) )
	BEGIN
	
		DECLARE @EmptyTable TABLE
		(
			NoId INT NULL
		)

		SELECT 
			TOP (1) 
				[ET].[NoId] 
		FROM 
			@EmptyTable ET
	    
	END
	ELSE
    BEGIN
        
		
    BEGIN TRANSACTION;

    BEGIN TRY

        IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
            DROP TABLE #listGuides;


        --===========SenderIdTownship NULL.INI ===========
        /*
## Se actualiza el SenderIdTownship, de poder obtener por medio del Sender_Town de la DeliveryOrder,
## De no tener coincidencia por el municipio, no se actualiza 
## De no tener coincidencia por la cláusula where, no se actualiza
*/
        UPDATE ord
        SET SenderIdTownship = TW.IdTownship
        FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.Township TW WITH(NOLOCK)
                ON CONVERT(VARCHAR, UPPER(ord.Sender_Town)) = CONVERT(VARCHAR, UPPER(TW.TownshipName))COLLATE SQL_Latin1_General_CP1251_CS_AS
        WHERE ord.Guide_Number = @GuideNumber
              AND ord.Guide_Serie = @Guide_Serie
              AND ord.SenderIdTownship IS NULL
              AND EXISTS
        (
            SELECT COUNT(1)
            FROM DeliveryBackOffice.dbo.Township TW WITH(NOLOCK)
            WHERE UPPER(ord.Sender_Town) = UPPER(TW.TownshipName)
        );
        --===========SenderIdTownship NULL.FIN ===========


        --===========ReceiverIdTownship NULL.INI ===========
        /*
## Se actualiza el ReceiverIdTownship, de poder obtener por medio del Receiver_Town de la DeliveryOrder,
## De no tener coincidencia por el municipio, no se actualiza 
## De no tener coincidencia por la cláusula where, no se actualiza 
*/
        UPDATE ord
        SET ReceiverIdTownship = TW.IdTownship
        FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.Township TW WITH(NOLOCK)
                ON UPPER(ord.Receiver_Town) = UPPER(TW.TownshipName)
        WHERE ord.Guide_Number = @GuideNumber
              AND ord.Guide_Serie = @Guide_Serie
              AND ord.ReceiverIdTownship IS NULL
              AND EXISTS
        (
            SELECT COUNT(1)
            FROM DeliveryBackOffice.dbo.Township TW WITH(NOLOCK)
            WHERE UPPER(ord.Receiver_Town) = UPPER(TW.TownshipName)
        );
        --===========ReceiverIdTownship NULL.FIN ===========



        ---===============ALMACENAR ID HUB DESTINO
        /*
## Se obtiene el id de HUB, de no encontrarlo con el municipio, se busca en el campo HubDestinationId
*/
        SET @HUB_Destino =
        (
            SELECT TOP 1
                   COALESCE(X.ID_HUB_DESTINO, 0)
            FROM
            (
                SELECT COALESCE(hl_destino.IdHubLogistic, serv.HubDestinationId, 0) AS ID_HUB_DESTINO
                FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH(NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.Township tw WITH(NOLOCK)
                        ON (CASE WHEN [serv].[IsLastMileReturn] = 1 THEN [serv].[SenderIdTownship] ELSE serv.ReceiverIdTownship END) = tw.IdTownship
                           AND tw.TownshipStatus = 1
                    INNER JOIN DeliveryBackOffice.dbo.DumpServiceCoverage dsc_destino WITH(NOLOCK)
                        ON tw.HeaderCode = dsc_destino.HeaderCode
                           --AND dsc_destino.IdSettlement = serv.ReceiverIdSettlement
                           AND dsc_destino.RowStatus = 1
                    LEFT JOIN DeliveryBackOffice.dbo.HubLogistics hl_destino WITH(NOLOCK)
                        ON RTRIM(LTRIM(dsc_destino.Hub)) = RTRIM(LTRIM(hl_destino.HubAbbreviation))
                    INNER JOIN DeliveryOrderPiece pc WITH(NOLOCK)
                        ON serv.Guide_Number = pc.GuideNumber
                           AND serv.Guide_Serie = pc.GuideSerie
                WHERE pc.GuideSerie = @Guide_Serie
                      AND pc.GuideNumber = @GuideNumber
                      AND pc.NoPiece = @GuidePiece
                      AND hl_destino.IdHubLogistic IN
                          (
                              SELECT cl.IdHubDestination FROM CatLinehaul cl WITH(NOLOCK) WHERE cl.IdRoute = @IdRoute
                          )
                UNION
                SELECT ISNULL(serv.HubDestinationId, 0) AS ID_HUB_DESTINO
                FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH(NOLOCK)
                    INNER JOIN DeliveryOrderPiece pc WITH(NOLOCK)
                        ON serv.Guide_Number = pc.GuideNumber
                           AND serv.Guide_Serie = pc.GuideSerie
                WHERE pc.GuideSerie = @Guide_Serie
                      AND pc.GuideNumber = @GuideNumber
                      AND pc.NoPiece = @GuidePiece
					AND 
					(
						(
							serv.HubDestinationId IN
							(
								SELECT cl.IdHubDestination FROM CatLinehaul cl WITH(NOLOCK) WHERE cl.IdRoute = @IdRoute
							) 
							AND 
							ISNULL([serv].[IsLastMileReturn], 0) = 0
						)
						OR
						(
							serv.[HubOriginId] IN
							(
								SELECT cl.IdHubDestination FROM CatLinehaul cl WITH(NOLOCK) WHERE cl.IdRoute = @IdRoute
							) 
							AND 
							ISNULL([serv].[IsLastMileReturn], 0) = 1
						)
					)
            ) X
        );


        SET @ReceiverIdTownship =
        (
            SELECT ISNULL((CASE WHEN [serv].[IsLastMileReturn] = 1 THEN [serv].[SenderIdTownship] ELSE serv.ReceiverIdTownship END), 0)
            FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH(NOLOCK)
                INNER JOIN DeliveryOrderPiece pc WITH(NOLOCK)
                    ON serv.Guide_Number = pc.GuideNumber
                       AND serv.Guide_Serie = pc.GuideSerie
            WHERE pc.GuideSerie = @Guide_Serie
                  AND pc.GuideNumber = @GuideNumber
                  AND pc.NoPiece = @GuidePiece
        );

        PRINT 'HUB_Destino';
        PRINT ISNULL(@HUB_Destino, 0);
        IF ISNULL(@HUB_Destino, 0) <> 0
        BEGIN

            SET @IdRouteASG =
            (
                SELECT ra.IdRouteAssigment
                FROM RouteAssigment ra WITH(NOLOCK)
                WHERE ra.IdRoute = @IdRoute
                      AND ra.DateOfRoute = @DateOfRoute
                GROUP BY ra.IdRouteAssigment
            );

            SET @IdServiceManagement =
            (
                SELECT sm.IdServiceManagement
                FROM ServiceManagement sm WITH(NOLOCK)
                    INNER JOIN RouteAssigment ra WITH(NOLOCK)
                        ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
                           AND ra.DateOfRoute = @DateOfRoute
                WHERE sm.IdPuRouteAssigment = @IdRouteASG
                      AND sm.IdHubDestination = @HUB_Destino
                      AND sm.SubTypeServiceManagmentId = @SubTypeServiceManagmentId
            );

            SET @ExistePiezaPorServicio =
            (
                SELECT COUNT(1)
                FROM dbo.PieceByService pbs WITH(NOLOCK)
                    INNER JOIN DeliveryOrderPiece dop WITH(NOLOCK)
                        ON pbs.GuidePieceId = dop.GuidePiece
                WHERE pbs.ServiceManagmentId = @IdServiceManagement
                      AND dop.GuideSerie = @Guide_Serie
                      AND dop.GuideNumber = @GuideNumber
                      AND dop.NoPiece = @GuidePiece
            );
            PRINT '@ExistePiezaPorServicio';
            PRINT @ExistePiezaPorServicio;
            --se busca si existe registro en SettlementByPickup
            SET @IdSettlementByPickup =
            (
                SELECT Id
                FROM SettlementByPickup WITH(NOLOCK)
                WHERE RouteAssigmentId = @IdRouteASG
                      AND ServiceManagmentId = @IdServiceManagement
            );

            IF ISNULL(@IdRouteASG, 0) = 0
            BEGIN
                INSERT INTO RouteAssigment
                (
                    IdRoute,
                    DateOfRoute,
                    RowStatus,
                    TokenCreated,
                    DateCreated
                )
                VALUES
                (@IdRoute, @DateOfRoute, 1, @TokenId, GETDATE());

                SET @IdRouteASG = SCOPE_IDENTITY();
            END;


            IF ISNULL(@IdServiceManagement, 0) = 0
            BEGIN
                INSERT INTO dbo.ServiceManagement
                (
                    IdPuRouteAssigment,
                    RowStatus,
                    TokenCreated,
                    DateCreated,
                    ServiceStatusId,
                    SubTypeServiceManagmentId,
                    IdHubDestination
                )
                SELECT @IdRouteASG,
                       1,
                       @TokenId,
                       GETDATE(),
                       1,
                       @SubTypeServiceManagmentId,
                       @HUB_Destino;

                SET @IdServiceManagement = SCOPE_IDENTITY();
            ---====================================
            END;





            IF @ExistePiezaPorServicio = 0
            BEGIN
                INSERT INTO dbo.PieceByService
                (
                    ServiceManagmentId,
                    GuidePieceId,
                    RowStatus,
                    TokenCreated,
                    DateCreated
                )
                SELECT @IdServiceManagement,
                       dop.GuidePiece,
                       1,
                       @TokenId,
                       GETDATE()
                FROM DeliveryOrderPiece dop WITH(NOLOCK)
                WHERE dop.GuideSerie = @Guide_Serie
                      AND dop.GuideNumber = @GuideNumber
                      AND dop.NoPiece = @GuidePiece;



                PRINT '@IdSettlementByPickup';
                PRINT @IdSettlementByPickup;
                --Si @SettlementByPickupId es NULL lo inserta
                IF ISNULL(@IdSettlementByPickup, 0) = 0
                BEGIN

                    INSERT INTO dbo.SettlementByPickup
                    (
                        RouteAssigmentId,
                        TokenCreated,
                        DateCreated,
                        PiecesDry,
                        PiecesCold,
                        GuidesQuantity,
                        SubTypeServiceManagmentId,
                        ServiceManagmentId
                    )
                    SELECT @IdRouteASG,
                           @TokenId,
                           GETDATE(),
                           IIF(@IsDry = 1, 1, 0),
                           IIF(@IsDry = 1, 0, 1),
                           (
                               SELECT COUNT(A.GuideNumber)
                               FROM
                               (
                                   SELECT dop2.GuideNumber
                                   FROM PieceByService pbs WITH(NOLOCK)
                                       INNER JOIN DeliveryOrderPiece dop2 WITH(NOLOCK)
                                           ON dop2.GuidePiece = pbs.GuidePieceId
                                   WHERE pbs.ServiceManagmentId = @IdServiceManagement
                                   GROUP BY dop2.GuideNumber
                               ) A
                           ),
                           @SubTypeServiceManagmentId,
                           @IdServiceManagement;
                END;
                ELSE
                BEGIN
                    PRINT 'UPDATE SettlementByPickup';
                    PRINT '@PiecesDry';
                    PRINT @PiecesDry;
                    PRINT '@PiecesCold';
                    PRINT @PiecesCold;



                    UPDATE dbo.SettlementByPickup
                    SET TokenUpdated = @TokenId,
                        DateUpdated = GETDATE(),
                        PiecesDry = IIF(@IsDry = 1, PiecesDry + 1, PiecesDry),
                        PiecesCold = IIF(@IsDry = 1, PiecesCold, PiecesCold + 1),
                        GuidesQuantity =
                        (
                            SELECT COUNT(A.GuideNumber)
                            FROM
                            (
                                SELECT dop2.GuideNumber
                                FROM PieceByService pbs WITH(NOLOCK)
                                    INNER JOIN DeliveryOrderPiece dop2 WITH(NOLOCK)
                                        ON dop2.GuidePiece = pbs.GuidePieceId
                                WHERE pbs.ServiceManagmentId = @IdServiceManagement
                                GROUP BY dop2.GuideNumber
                            ) A
                        )
                    WHERE Id = @IdSettlementByPickup;
                END;



                UPDATE dbo.[Warehouse]
                SET Active = 0,
                    UserUpdated = @TokenId,
                    DateUpdated = GETDATE()
                WHERE Guide_Number = @GuideNumber
                      AND Guide_Serie = @Guide_Serie
                      AND Active = 1;





            END;
            ELSE
            BEGIN

                IF @IsDry = 1
                BEGIN
                    SET @PiecesDry = @PiecesDry - 1;
                END;
                ELSE
                BEGIN
                    SET @PiecesCold = @PiecesCold - 1;
                END;
            END;


            -- Convertir la lista de guías separadas por coma en una tabla que permita adicionar columnas
            --SELECT
            --	SUBSTRING(Item, 1, 2) ItemSerie
            --   ,SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(item)), (CHARINDEX('-', Item) - 3))) ItemNumber
            --   ,SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(item)) ItemPiece
            --, 
            --SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
            --CHARINDEX('-',Item) charinde,  
            --len(Item) len
            --INTO #listGuides
            --FROM DeliveryBackOffice.dbo.SplitUnlimited(@Guide_Number, ',')

            -- Actualizar registro de guía a último estado 
            UPDATE DeliveryBackOffice.dbo.DeliveryOrderPiece
            SET StatusOrderId = 19,
                IsDry = IIF(@IsDry = 1, 1, 0)
            WHERE GuideSerie = @Guide_Serie
                  AND GuideNumber = @GuideNumber
                  AND NoPiece = @GuidePiece;


            -- Actualizar registro de guía a último estado 
            UPDATE DeliveryBackOffice.dbo.DeliveryOrder
            SET StatusOrderId = @StatusOrderId,
                Courier_Route = @Route
            --,Courier_Name = @courier
            WHERE Guide_Serie = @Guide_Serie
                  AND Guide_Number = @GuideNumber;

            SET @RowUpdated = @@rowcount;

            IF (@RowUpdated > 0)
            BEGIN

                INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
                (
                    [Guide_Serie],
                    [Guide_Number],
                    [StatusOrderId],
                    [UserCreated],
                    [DateCreated],
                    [DateCreatedInSystem],
                    [Observations],
                    [Temperature_Celsius],
                    [PieceId]
                )
                SELECT @Guide_Serie,
                       @GuideNumber,
                       @StatusOrderId,
                       @TokenId,
                       @DateOfStatus,
                       GETDATE(),
                       @Observations,
                       @Temperature_Celsius,
                       @GuidePiece;




                SET @ValidateOperation = COALESCE(@@rowcount, 0);

            END;
        END;
        ELSE
        BEGIN

            SET @ValidateOperation = 0;
        END;

        PRINT '@IdServiceManagement';
        PRINT @IdServiceManagement;

    END TRY
    BEGIN CATCH
        PRINT 'ERROR';
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID';
        ROLLBACK TRANSACTION;
    END CATCH;

    IF @@trancount > 0
    BEGIN
        PRINT CONCAT('@ValidateOperation ', @ValidateOperation);
        IF (@ValidateOperation > 0)
        BEGIN

            DECLARE @RouteValidator AS INT =
                    (
                        SELECT COUNT(cl.IdHubDestination) AS CANT
                        FROM CatLinehaul cl
                        WHERE cl.IdRoute = @IdRoute
                    );

            IF (@RouteValidator > 0)
            BEGIN
                --===========HUB DESTINATION NOT NULL.INI ===========
                IF (
                   (
                       SELECT COUNT(1)
                       FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH(NOLOCK)
                       WHERE Guide_Serie = @Guide_Serie
                             AND Guide_Number = @GuideNumber
                             AND ord.ReceiverIdTownship IS NULL
                             AND ord.HubDestinationId IS NOT NULL
                   ) > 0
                   )
                BEGIN

                    SELECT CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR)) AS NUMGUIA,
                           CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) GUIA,
                           ISNULL(serv.Ticket_Number, '') AS Ticket_Number,
                           ISNULL(serv.Receiver_FirstName, '') + ' ' + ISNULL(serv.Receiver_LastName, '') NAME,
                           hl_origen.HubAbbreviation AS HUB_ORIGEN,
                           hl_destino.HubAbbreviation AS HUB_DESTINO,
                           (
                               SELECT ISNULL(COUNT(1), 0)
                               FROM dbo.PieceByService pbs WITH(NOLOCK)
                                   INNER JOIN DeliveryOrderPiece pci WITH(NOLOCK)
                                       ON pci.GuidePiece = pbs.GuidePieceId
                               WHERE pci.GuideSerie = @Guide_Serie
                                     AND pci.GuideNumber = @GuideNumber
                                     --AND pci.NoPiece		=  @GuidePiece
                                     AND pbs.ServiceManagmentId = @IdServiceManagement
                           ) PIEZAS_PROCESADAS,
                           CASE
                               WHEN (CAST(
                                     (
                                         SELECT ISNULL(COUNT(1), 0)
                                         FROM dbo.PieceByService pbs WITH(NOLOCK)
                                             INNER JOIN DeliveryOrderPiece pci WITH(NOLOCK)
                                                 ON pci.GuidePiece = pbs.GuidePieceId
                                         WHERE pci.GuideSerie = @Guide_Serie
                                               AND pci.GuideNumber = @GuideNumber
                                               AND pbs.ServiceManagmentId = @IdServiceManagement
                                     ) AS VARCHAR(50)) = CAST(serv.Pieces_Dry + serv.Pieces_Cold AS VARCHAR(50))
                                    ) THEN
                                   1
                               ELSE
                                   0
                           END AS CANT_PIEZAS_TOTAL,
                           CAST(
                           (
                               SELECT ISNULL(COUNT(1), 0)
                               FROM dbo.PieceByService pbs WITH(NOLOCK)
                                   INNER JOIN DeliveryOrderPiece pci WITH(NOLOCK)
                                       ON pci.GuidePiece = pbs.GuidePieceId
                               WHERE pci.GuideSerie = @Guide_Serie
                                     AND pci.GuideNumber = @GuideNumber
                                     --AND pci.NoPiece = @GuidePiece
                                     AND pbs.ServiceManagmentId = @IdServiceManagement
                           ) AS VARCHAR(50)) + ' de ' + CAST(serv.Pieces_Dry + serv.Pieces_Cold AS VARCHAR(50)) AS PIEZAS_PENDIENTES,
                           @PiecesDry PiecesDry,
                           @PiecesCold PiecesCold
                    -- ,1 as RUTA
                    -- ,getdate() as FechaRuta
                    --,200 as StatusCode
                    FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH(NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.HubLogistics hl_origen WITH(NOLOCK)
                            ON IIF([serv].[IsLastMileReturn] = 1, serv.HubDestinationId, serv.HubOriginId) = hl_origen.IdHubLogistic
                        INNER JOIN DeliveryBackOffice.dbo.HubLogistics hl_destino WITH(NOLOCK)
                            ON IIF([serv].[IsLastMileReturn] = 1, serv.HubOriginId, serv.HubDestinationId) = hl_destino.IdHubLogistic
                        INNER JOIN DeliveryOrderPiece pc WITH(NOLOCK)
                            ON serv.Guide_Number = pc.GuideNumber
                               AND serv.Guide_Serie = pc.GuideSerie
                    WHERE pc.GuideSerie = @Guide_Serie
                          AND pc.GuideNumber = @GuideNumber
                          AND pc.NoPiece = @GuidePiece
                          AND hl_destino.IdHubLogistic IN
                              (
                                  SELECT cl.IdHubDestination FROM CatLinehaul cl WITH(NOLOCK) WHERE cl.IdRoute = @IdRoute
                              );
                END;
                ELSE
                BEGIN
                    --===========HUB DESTINATION NOT NULL.FIN ===========

                    SELECT TOP 1
                           CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR)) AS NUMGUIA,
                           CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) GUIA,
                           ISNULL(serv.Ticket_Number, '') AS Ticket_Number,
                           ISNULL(serv.Receiver_FirstName, '') + ' ' + ISNULL(serv.Receiver_LastName, '') NAME,
                           IIF([serv].[IsLastMileReturn] = 1, hl_destino.HubAbbreviation,hl_origen.HubAbbreviation) AS HUB_ORIGEN,
                           IIF([serv].[IsLastMileReturn] = 1, hl_origen.HubAbbreviation,hl_destino.HubAbbreviation) AS HUB_DESTINO,
                           (
                               SELECT ISNULL(COUNT(1), 0)
                               FROM dbo.PieceByService pbs WITH(NOLOCK)
                                   INNER JOIN DeliveryOrderPiece pci WITH(NOLOCK)
                                       ON pci.GuidePiece = pbs.GuidePieceId
                               WHERE pci.GuideSerie = @Guide_Serie
                                     AND pci.GuideNumber = @GuideNumber
                                     AND pbs.ServiceManagmentId = @IdServiceManagement
                           ) PIEZAS_PROCESADAS,
                           CASE
                               WHEN (CAST(
                                     (
                                         SELECT ISNULL(COUNT(1), 0)
                                         FROM dbo.PieceByService pbs WITH(NOLOCK)
                                             INNER JOIN DeliveryOrderPiece pci WITH(NOLOCK)
                                                 ON pci.GuidePiece = pbs.GuidePieceId
                                         WHERE pci.GuideSerie = @Guide_Serie
                                               AND pci.GuideNumber = @GuideNumber
                                               AND pbs.ServiceManagmentId = @IdServiceManagement
                                     ) AS VARCHAR(50)) = CAST(serv.Pieces_Dry + serv.Pieces_Cold AS VARCHAR(50))
                                    ) THEN
                                   1
                               ELSE
                                   0
                           END AS CANT_PIEZAS_TOTAL,
                           CAST(
                           (
                               SELECT ISNULL(COUNT(1), 0)
                               FROM dbo.PieceByService pbs WITH(NOLOCK)
                                   INNER JOIN DeliveryOrderPiece pci WITH(NOLOCK)
                                       ON pci.GuidePiece = pbs.GuidePieceId
                               WHERE pci.GuideSerie = @Guide_Serie
                                     AND pci.GuideNumber = @GuideNumber
                                     AND pbs.ServiceManagmentId = @IdServiceManagement
                           ) AS VARCHAR(50)) + ' de ' + CAST(serv.Pieces_Dry + serv.Pieces_Cold AS VARCHAR(50)) AS PIEZAS_PENDIENTES,
                           @PiecesDry PiecesDry,
                           @PiecesCold PiecesCold
                    -- ,1 as RUTA
                    -- ,getdate() as FechaRuta
                    --,200 as StatusCode
                    FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH(NOLOCK)
                        LEFT JOIN DeliveryBackOffice.dbo.Township tw_origen WITH(NOLOCK)
                            ON serv.SenderIdTownship = tw_origen.IdTownship
                               AND tw_origen.TownshipStatus = 1
                        LEFT JOIN DeliveryBackOffice.dbo.Settlement st_origen WITH(NOLOCK)
                            ON tw_origen.IdTownship = st_origen.IdTownship
                        LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage dsc_origen WITH(NOLOCK)
                            ON tw_origen.HeaderCode = dsc_origen.HeaderCode
                               AND dsc_origen.IdSettlement = st_origen.IdSettlement
                               AND dsc_origen.RowStatus = 1
                        LEFT JOIN DeliveryBackOffice.dbo.Township tw_destino WITH(NOLOCK)
                            ON serv.ReceiverIdTownship = tw_destino.IdTownship
                               AND tw_destino.TownshipStatus = 1
                        LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage dsc_destino WITH(NOLOCK)
                            ON tw_destino.HeaderCode = dsc_destino.HeaderCode
                               --AND dsc_destino.IdSettlement = serv.ReceiverIdSettlement
                               AND dsc_destino.RowStatus = 1
                        INNER JOIN DeliveryBackOffice.dbo.HubLogistics hl_origen WITH(NOLOCK)
                            ON RTRIM(LTRIM(dsc_origen.Hub)) = RTRIM(LTRIM(hl_origen.HubAbbreviation))
                        INNER JOIN DeliveryBackOffice.dbo.HubLogistics hl_destino WITH(NOLOCK)
                            ON RTRIM(LTRIM(dsc_destino.Hub)) = RTRIM(LTRIM(hl_destino.HubAbbreviation))
                        INNER JOIN DeliveryOrderPiece pc WITH(NOLOCK)
                            ON serv.Guide_Number = pc.GuideNumber
                               AND serv.Guide_Serie = pc.GuideSerie
                    WHERE pc.GuideSerie = @Guide_Serie
                          AND pc.GuideNumber = @GuideNumber
                          AND pc.NoPiece = @GuidePiece
						  AND
							(
								(
									hl_destino.IdHubLogistic IN
									(
										SELECT cl.IdHubDestination FROM CatLinehaul cl WITH(NOLOCK) WHERE cl.IdRoute = @IdRoute
									) 
									AND 
									ISNULL([serv].[IsLastMileReturn], 0) = 0
								)
								OR
								(
									hl_origen.IdHubLogistic IN
									(
										SELECT cl.IdHubDestination FROM CatLinehaul cl WITH(NOLOCK) WHERE cl.IdRoute = @IdRoute
									) 
									AND 
									ISNULL([serv].[IsLastMileReturn], 0) = 1
								)
							);
                --AND @ExistePiezaPorServicio = 0
                END;

            END;

        END;
        ELSE IF (ISNULL(@HUB_Destino, 0) = 0)
                AND @ReceiverIdTownship = 0
        BEGIN
            PRINT 'NO TIENE HUB _1';
            PRINT 'GUIA';
            PRINT @Guide_Number;
            SELECT CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR)) AS NUMGUIA,
                   CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) GUIA,
                   ISNULL(serv.Ticket_Number, '') AS Ticket_Number,
                   ISNULL(serv.Receiver_FirstName, '') + ' ' + ISNULL(serv.Receiver_LastName, '') NAME,
                   'N/A' AS HUB_ORIGEN,
                   'N/A' AS HUB_DESTINO,
                   0 AS PIEZAS_PROCESADAS,
                   0 AS CANT_PIEZAS_TOTAL,
                   0 AS PIEZAS_PENDIENTES,
                   @PiecesDry PiecesDry,
                   @PiecesCold PiecesCold
            -- ,1 as RUTA
            -- ,getdate() as FechaRuta
            --,200 as StatusCode
            FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH(NOLOCK)
                INNER JOIN DeliveryOrderPiece pc WITH(NOLOCK)
                    ON serv.Guide_Number = pc.GuideNumber
                       AND serv.Guide_Serie = pc.GuideSerie
            WHERE pc.GuideSerie = @Guide_Serie
                  AND pc.GuideNumber = @GuideNumber
                  AND pc.NoPiece = @GuidePiece;

        END;
        COMMIT TRANSACTION;
    END;
    ELSE IF (ISNULL(@HUB_Destino, 0) = 0)
            AND @ReceiverIdTownship = 0
    BEGIN
        PRINT 'NO TIENE HUB _2';
        SELECT CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR)) AS NUMGUIA,
               CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) GUIA,
               ISNULL(serv.Ticket_Number, '') AS Ticket_Number,
               ISNULL(serv.Receiver_FirstName, '') + ' ' + ISNULL(serv.Receiver_LastName, '') NAME,
               'N/A' AS HUB_ORIGEN,
               'N/A' AS HUB_DESTINO,
               0 AS PIEZAS_PROCESADAS,
               0 AS CANT_PIEZAS_TOTAL,
               0 AS PIEZAS_PENDIENTES,
               @PiecesDry PiecesDry,
               @PiecesCold PiecesCold
        -- ,1 as RUTA
        -- ,getdate() as FechaRuta
        --,200 as StatusCode
        FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH(NOLOCK)
            INNER JOIN DeliveryOrderPiece pc WITH(NOLOCK)
                ON serv.Guide_Number = pc.GuideNumber
                   AND serv.Guide_Serie = pc.GuideSerie
        WHERE pc.GuideSerie = @Guide_Serie
              AND pc.GuideNumber = @GuideNumber
              AND pc.NoPiece = @GuidePiece;

    END;

    END

END;