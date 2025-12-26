/* =================================================
   SP:        sps_set_status_order_by_guide
   Propósito: Cambiar el estado de una lista de guías
   Autor:     Carlos Cano
   Historia:  ---
   Fecha:     2020-06-10
=== CHANGELOG ============================

2024-06-05 | Historia/épica: ---           | Autor: Cristian Suazo |
2025-12-12 | Historia/épica: FDAPI-4733    | Autor: Cristian Suazo |

=========================================== */

CREATE PROCEDURE [dbo].[sps_set_status_order_by_guide]
    @Guide_Serie AS NVARCHAR(2),         -- same guide for all numbers provided
    @Guide_Number AS NVARCHAR(MAX),      -- a list of guides separated by comma
    @StatusId AS INT,                   -- status from StatusOrder
    @TokenId AS NVARCHAR(50),
    @DateOfStatus DATETIME,             -- datetime of event
    @Observations AS NVARCHAR(200) = '', --Observations by checkpoint
    @Temperature_Celsius AS DECIMAL(5, 2),
    @courierName AS NVARCHAR(200) = '',
    @iduser AS INT = NULL,
    @username NVARCHAR(50) = NULL,
	@IdCountry NVARCHAR(2) = 'GT',
	@StationId INT = NULL
AS
BEGIN
    DECLARE @ValidateOperation BIGINT = 0;
    DECLARE @RowUpdated INT;
    DECLARE @ItemsTable AS TABLE
    (
        Guide_Number INT,
		Guide_Serie NVARCHAR(2)
    );
    -- control de guía a iterar
    DECLARE @GuideNumber INT;
    --DECLARE @GuideSerie varchar(2) 
    -- CourierId de la guía a iterar
    DECLARE @CourierId INT;
    -- CatModuleId del modulo
    DECLARE @CatModuleId INT;
	---Pertenece al pais?-----
	DECLARE @BelongConuntry BIT;

    IF OBJECT_ID('tempdb..#TempData') IS NOT NULL
        DROP TABLE #TempData;

    CREATE TABLE #TempData
    (
     IdProcessedGuideCOD INT,
     GuideSerie          NVARCHAR(2),
     GuideNumber         INT,
    );
    CREATE NONCLUSTERED INDEX INDX_sps_set_status_order_by_guide_Temp ON #TempData (GuideSerie, GuideNumber);

    BEGIN TRANSACTION;

    BEGIN TRY

	    -- Convertir la lista de guías separadas por coma en una tabla que permita adicionar columnas
    INSERT @ItemsTable
    SELECT CAST(Item AS INT), @Guide_Serie
    FROM DeliveryBackOffice.dbo.SplitUnlimited(@Guide_Number, ',');

	SELECT @BelongConuntry = MAX(X.Number)
	FROM (
		SELECT CASE
				WHEN SenderCountryId = @IdCountry
					OR ReceiverCountryId = @IdCountry THEN
					1
				ELSE
					0
			END AS Number
		FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
		WHERE Guide_Serie = @Guide_Serie
		AND Guide_Number IN (SELECT
								Guide_Number
							FROM @ItemsTable)
	) AS X

	IF @BelongConuntry = 0
	BEGIN
		SELECT 0 AS 'StatusCode',
           'La guia pertenece a otro pais' AS 'Description'
	END
	ELSE
	BEGIN 

        -- Actualizar registro de guía a último estado 
		UPDATE DeliveryBackOffice.dbo.DeliveryOrder
		SET StatusOrderId = @StatusId
		WHERE Guide_Serie = @Guide_Serie
		AND Guide_Number IN (SELECT
				Guide_Number
			FROM @ItemsTable);

        SET @RowUpdated = @@ROWCOUNT;

        IF (@RowUpdated > 0)
        BEGIN
            -- Activar bandera de proceso de SMS
            IF (@StatusId = 11) -- En ruta | (11) Arribó a instalaciones
                IF (
                   (
                       SELECT TOP 1
                              ue.UpdateStatus
                       FROM [DeliveryBackOffice].[dbo].[SMS_UpdatedElements] ue WITH (NOLOCK)
                       WHERE ue.RowStatus = 1
                             AND ue.ElementId = 1001
                   ) = 0
                   )
                BEGIN
                    UPDATE [DeliveryBackOffice].[dbo].[SMS_UpdatedElements]
                    SET UpdateStatus = 1,
                        UpdateDateTime = GETDATE()
                    WHERE RowStatus = 1
                          AND ElementId = 1001;
                END;

            -- Insertar nuevo estado de guía en tabla histórica
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
				[StationId]
            )
            SELECT @Guide_Serie,
                   it.Guide_Number,
                   @StatusId,
                   @TokenId,
                   @DateOfStatus,
                   GETDATE(),
                   @Observations,
                   @Temperature_Celsius,
				   @StationId
            FROM @ItemsTable it;
            SET @ValidateOperation = COALESCE(@@ROWCOUNT, 0);
            -----------------------------
            IF
            (
                SELECT OrderDescription
                FROM DeliveryBackOffice.dbo.StatusOrder WITH (NOLOCK)
                WHERE StatusOrderId = @StatusId
            ) = 'En ruta'
            BEGIN
                ----------------
                --INICIO --CREANDO ALERTA POR CADA GUÍA QUE HAYA SIDO PUESTO EN RUTA 2 O MAS VECES Y QUE NO POSEAN ALERTA				
                DECLARE @GuidesTableWithoutFailRetries AS TABLE
                (
                    Guide_Serie NVARCHAR(MAX),
                    Guide_Number INT,
                    StatusOrderId INT,
                    StatusCount INT
                );
                DECLARE @IDSTATUSINROUTE INT =
                        (
                            SELECT StatusOrderId
                            FROM DeliveryBackOffice.dbo.StatusOrder WITH (NOLOCK)
                            WHERE StatusOrderId = 4 --'En ruta'
                        );
                DECLARE @IDSTATUSFAILEDDELIVERY INT =
                        (
                            SELECT StatusOrderId
                            FROM DeliveryBackOffice.dbo.StatusOrder WITH (NOLOCK)
                            WHERE StatusOrderId = 12 -- 'Intento de entrega fallida'
                        );
                --Obtiene la lista de guías que ya salieron a ruta 2 o mas veces y que tienen 0 intentos de entrega fallida
                INSERT INTO @GuidesTableWithoutFailRetries
                SELECT @Guide_Serie,
                       LG.Guide_Number,
                       (DORD.StatusOrderId),
                       COUNT(DORD.StatusOrderId)
                FROM @ItemsTable LG
                    LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
                        ON DOR.Guide_Serie = @Guide_Serie
                           AND LG.Guide_Number = DOR.Guide_Number
                    LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DORD WITH (NOLOCK)
                        ON DOR.Guide_Serie = DORD.Guide_Serie
                           AND DOR.Guide_Number = DORD.Guide_Number					
                GROUP BY LG.Guide_Number,
                         DORD.StatusOrderId
                HAVING (
                           DORD.StatusOrderId = @IDSTATUSINROUTE
                           AND COUNT(DORD.StatusOrderId) >= 2
                       ) --CUANDO YA SALIERON A RUTA 2 O MAS VECES
                       OR
                       (
                           DORD.StatusOrderId = @IDSTATUSFAILEDDELIVERY
                           AND COUNT(DORD.StatusOrderId) = 0
                       ); -- CUANDO TIENEN 0 INTENTOS DE ENTREGA FALLIDA



                IF
                (
                    SELECT COUNT(*)FROM @GuidesTableWithoutFailRetries
                ) > 0
                AND @iduser IS NOT NULL
                BEGIN
                    --Obreniendo lista de guias con el numero de veces que salieron a ruta
                    DECLARE @GuidesTableWithRetriesDispatch AS TABLE
                    (
                        Guide_Number INT,
                        RretriesMade INT
                    );
                    INSERT INTO @GuidesTableWithRetriesDispatch
                    SELECT GTA.Guide_Number,
                           GTA.StatusCount
                    FROM @GuidesTableWithoutFailRetries GTA
                    WHERE GTA.StatusOrderId = @IDSTATUSINROUTE;

                    --CREANDO ALERTA DE GUÍAS QUE NO POSEEN ALERTA Y QUE TIENEN MAS DE DOS SALIDAS A RUTA
                    DECLARE @SERVICETYPE NVARCHAR(MAX) =
                            (
                                SELECT IdTypeServiceManagment
                                FROM DeliveryBackOffice.dbo.TypeServiceManagment WITH (NOLOCK)
                                WHERE IdTypeServiceManagment = 2 -- 'Entrega'
                            );
                    INSERT INTO dbo.DeliveryOrderAlert
                    (
                        GuideSerie,
                        GuideNumber,
                        ServiceTypeId,
                        AlertDescription,
                        AlertTypeId,
                        RowStatus,
                        TokenCreated,
                        DateCreated,
                        TokenUpdated,
                        DateUpdated
                    )
                    SELECT @Guide_Serie,
                           GTWRD.Guide_Number,
                           @SERVICETYPE,
                           'El paquete ha salido a ruta 2 o mas veces',
                           (
                               SELECT IdCatTypeAlert
                               FROM DeliveryBackOffice.dbo.CatTypeAlert WITH (NOLOCK)
                               WHERE IdCatTypeAlert = 1 -- 'Prioritario'
                           ),
                           1,
                           @TokenId,
                           GETDATE(),
                           NULL,
                           NULL
                    FROM @GuidesTableWithRetriesDispatch GTWRD
                        LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderAlert DOA WITH (NOLOCK)
                            ON DOA.GuideSerie = @Guide_Serie
                               AND DOA.GuideNumber = GTWRD.Guide_Number
                    WHERE DOA.IdDeliveryOrderAlert IS NULL;

                    INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderAlertDetail
                    (
                        author,
                        username,
                        comment,
                        DeliveryOrderAlertId,
                        RowStatus,
                        TokenCreated,
                        DateCreated,
                        TokenUpdated,
                        DateUpdated
                    )
                    SELECT @iduser,
                           @username,
                           'ALERTA: El paquete ya ha salido a ruta ' + CONVERT(NVARCHAR, GTWRD.RretriesMade)
                           + ' veces sin intentos de entrega',
                           DOA.IdDeliveryOrderAlert,
                           1,
                           @TokenId,
                           GETDATE(),
                           NULL,
                           NULL
                    FROM @GuidesTableWithRetriesDispatch GTWRD
                        LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderAlert DOA WITH (NOLOCK)
                            ON DOA.GuideSerie = @Guide_Serie
                               AND DOA.GuideNumber = GTWRD.Guide_Number;
                END;
            --FIN --CREANDO ALERTA POR CADA GUÍA QUE HAYA SIDO PUESTO EN RUTA 2 O MAS VECES Y QUE NO POSEAN ALERTA				
            ------------------------------------------------------------------------
            END;
        -----------------------------
        END;

        IF @StatusId = 4
        BEGIN
			UPDATE DeliveryBackOffice.dbo.DeliveryOrder
			SET Courier_Name = @courierName
			   ,Dispatched_Date = GETDATE()
			WHERE Guide_Serie = @Guide_Serie
			AND Guide_Number IN (SELECT
					Guide_Number
				FROM @ItemsTable);
        END;

        --Se marca como recolectado el servicio
        IF @StatusId = 11
        BEGIN
            UPDATE sm 
            SET ServiceStatusId = 3
                ,TokenUpdated = @TokenId
                ,DateUpdated = GETDATE()
            FROM DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
                ON dopd.IdHeaderRecolection = sm.IdSchedulePickup
            INNER JOIN @ItemsTable it
                ON dopd.GuideSerie = it.Guide_Serie 
				AND dopd.GuideNumber = it.Guide_Number				
            WHERE dopd.GuideSerie = @Guide_Serie
        END



        ----------------------- PROCESSGUIDECOD- SE REGISTRA RECOLECCIÓN . INI ----------------------	
        IF @StatusId = 11
        BEGIN
            --Buscar ID modulo liquidación Recolecciones
            SET @CatModuleId = ISNULL(
                               (
                                   SELECT ModIdModule
                                   FROM DeliveryBackOffice.dbo.CatModule WITH (NOLOCK)
                                   WHERE ModIdModule = 30 -- 'Liquidación COD'
                               ),
                               0
                                     );

            SELECT *
            INTO #listGuidesTemp
            FROM @ItemsTable;
            -- mientras la tabla no este vacía
            WHILE EXISTS (SELECT * FROM #listGuidesTemp)
            BEGIN
                -- se obtiene la guía a iterar
                SELECT TOP 1
                       @GuideNumber = Guide_Number
                FROM #listGuidesTemp;

                -- se obtiene el id del courierman
                SELECT TOP 1
                       @CourierId = ID_Courier
                FROM [dbo].[DeliveryAttempt] WITH (NOLOCK)
                WHERE [Guide_Serie] = @Guide_Serie
                      AND [Guide_Number] = @GuideNumber
				ORDER BY [Date_Created] DESC;

                -- se verifica que no exita en las guías procesadas
                IF NOT EXISTS
                (
                    SELECT 1
                    FROM [DeliveryBackOffice].[dbo].[ProcessedGuideCOD] WITH (NOLOCK)
                    WHERE [GuideSerie] = @Guide_Serie 
                          AND [GuideNumber] = @GuideNumber
                )
                BEGIN
                    INSERT INTO [DeliveryBackOffice].[dbo].[ProcessedGuideCOD]
                    (
                        [GuideSerie],
                        [GuideNumber],
                        [CourierManId],
                        [Date],
                        [BatchCODId],
                        [BatchCODIdCommission],
                        [DataOriginId],
                        [Notificated],
                        [Token],
                        CustomerId
                    )
                    OUTPUT inserted.IdProcessedGuideCOD,
                           inserted.GuideSerie,
                           inserted.GuideNumber
                      INTO #TempData
                    SELECT do.[Guide_Serie],
                           do.[Guide_Number],
                           @CourierId,
                           GETDATE(),
                           NULL,
                           NULL,
                           @CatModuleId,
                           0,
                           @TokenId,
                           cus.IdCustomer
                    FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH (NOLOCK)
                        LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vp WITH (NOLOCK)
                            ON vp.CodeOfReference = do.Sender_ID
                        LEFT JOIN DeliveryBackOffice.dbo.Customer cus WITH (NOLOCK)
                            ON cus.IdCustomer = ISNULL(do.IdCustomer, vp.CustomerID)
                        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
                            ON do.Guide_Serie = DOP.GuideSerie
                               AND do.Guide_Number = DOP.GuideNumber
                    WHERE do.[Guide_Serie] = @Guide_Serie
                          AND do.[Guide_Number] = @GuideNumber
                          AND
                          (
                              do.IsCollect = 'false'
                              AND DOP.PayTypeId = 1
                              AND
                              (
                                  DOP.TimePlaId = 1
                                  OR DOP.TimePlaId = 2
                              )
                              AND DOP.TypeofInOutMoneyId = 1
                          ) --AND ( cus.IdCustomerType IN(2,3)
                          AND do.Collect_OnDelivery = 0
                          AND NOT EXISTS
                    (
                        SELECT 1
                        FROM DeliveryBackOffice.dbo.Cost C WITH (NOLOCK)
                            INNER JOIN DeliveryBackOffice.dbo.CostDetail CD WITH (NOLOCK)
                                ON CD.IdCost = C.IdCost                                  
                        WHERE C.GuideSerie = do.Guide_Serie
						  AND C.GuideNumber = do.Guide_Number
						  AND CD.IdTypeOfMoney IN ( 2, 6 )
                    );
                END;

                DELETE #listGuidesTemp
                WHERE Guide_Number = @GuideNumber;
            END;
        END;
    ----------------------- PROCESSGUIDECOD- SE REGISTRA RECOLECCIÓN . FIN ----------------------	
	--Actualizar estado de las piezas
	UPDATE DeliveryBackOffice.dbo.DeliveryOrderPiece
	SET StatusOrderId = @StatusId
	WHERE GuideSerie = @Guide_Serie
	AND GuideNumber IN (SELECT
			Guide_Number
		FROM @ItemsTable);


    -------------------WEBHOOK.INI--------------------------------------------------------------------------------------------
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
                                        WHERE WT.WebhookName = 'GuideStatusChange'
                                              AND WT.RowStatus = 1
                                    );

                          
                                SELECT TOP 1
                                             @WebhookCustomerId =  ISNULL(DO.IdCustomer,-1),
											 @GuideCurrentStatus = ISNULL(DO.StatusOrderId,-1)
                                    FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                                      WHERE DO.Guide_Serie = @Guide_Serie AND DO.Guide_Number = @Guide_Number

                            SET @CustomerEndpointId
                                = ISNULL(
                                  (
                                      SELECT TOP 1
                                             WE.IdWebhookEndpoint
                                      FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH (NOLOCK)
                                      WHERE WE.CustomerId = @WebhookCustomerId
                                            AND WE.WebhookTypeId = @GuideStatusChangeWebhook
                                  ),
                                  -1
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
								FROM DeliveryBackOffice.dbo.WebhookEndpoint wh WITH(NOLOCK)
								INNER JOIN DeliveryBackOffice.dbo.WebhookCatTypeConnection wc WITH(NOLOCK)
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
                                (@Guide_Serie, @Guide_Number, @WebhookCustomerId, @GuideCurrentStatus,
                                 @CustomerEndpointId, 0, @TokenId, GETDATE());

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
											FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
											INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
												ON do.Guide_Serie = dop.GuideSerie
                                                AND do.Guide_Number = dop.GuideNumber 
                                            INNER JOIN DeliveryBackOffice.dbo.WebhookEndpoint WHE WITH(NOLOCK)
                                                ON do.IdCustomer = WHE.CustomerId
                                            WHERE do.Guide_Serie = @Guide_Serie 
                                                AND do.Guide_Number = @Guide_Number
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
											FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
											INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
												ON do.Guide_Serie = dop.GuideSerie
                                                AND do.Guide_Number = dop.GuideNumber
                                            INNER JOIN DeliveryBackOffice.dbo.WebhookEndpoint WHE WITH(NOLOCK)
                                                ON do.IdCustomer = WHE.CustomerId
                                            WHERE do.Guide_Serie = @Guide_Serie
                                                AND do.Guide_Number = @Guide_Number
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
												dop.GuideSerie,
												dop.GuideNumber, 
												dop.GuidePiece, 
												do.Ticket_Number,
												dop.ExternalPieceId, 
												@GuideCurrentStatus, 1 AS RowStatus, 
												GETDATE()AS DateCreated,
												@TokenId AS TokenCreated
										FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
										INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
											ON dop.GuideSerie = do.Guide_Serie 
                                            AND dop.GuideNumber = do.Guide_Number
										INNER JOIN DeliveryBackOffice.dbo.WebhookEndpoint WHE WITH(NOLOCK)
										    ON do.IdCustomer = WHE.CustomerId
										INNER JOIN @GuidePiecesTable gpt
										    ON dop.GuideSerie = gpt.GuideSerie 
                                            AND dop.GuideNumber = gpt.GuideNumber
										INNER JOIN @PiecesGuideRelatedTable pgt
										    ON gpt.GuideSerie = pgt.GuideSerie
                                            AND gpt.GuideNumber = pgt.GuideNumber
											AND gpt.NumberPieces = pgt.NumberRelatedPieces
										WHERE WHE.TypeConnectionId = 2

								END

                            END;

                        END TRY
                        BEGIN CATCH

                        END CATCH;

                    -------------------WEBHOOK.INI FIN----------------------------------------------------------------------------------------	
	END;

    END TRY
    BEGIN CATCH
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID';
        ROLLBACK TRANSACTION;
    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        IF (@ValidateOperation > 0)
        BEGIN
            SELECT 1 AS 'StatusCode',
                   'Registros guardados correctamente' AS 'Description',
                   @ValidateOperation AS 'NumTransferID';

			SELECT
				Guide_Serie + CAST(Guide_Number AS VARCHAR) Guide
			   ,Ticket_Number Ticket
			   ,Receiver_FirstName + ' ' + Receiver_LastName Name
			   ,Courier_Route Route
			   ,CONVERT(VARCHAR, Dispatched_Date, 103) RouteDate
			FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
			WHERE Guide_Serie = @Guide_Serie
			AND Guide_Number IN (SELECT
					Guide_Number
				FROM @ItemsTable);
        END;
        ELSE
        BEGIN
            SELECT 0 AS 'StatusCode',
                   'El registro no existe' AS 'Description',
                   @ValidateOperation AS 'NumTransferID';
        END;
        COMMIT TRANSACTION;

        UPDATE pgd 
           SET pgd.IsCompleted = 1
          FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pgd WITH(NOLOCK)
               INNER JOIN #TempData tmp
                    ON pgd.GuideSerie   = tmp.GuideSerie
                    AND pgd.GuideNumber = tmp.GuideNumber
                    AND pgd.IdProcessedGuideCOD = tmp.IdProcessedGuideCOD;

        IF OBJECT_ID('tempdb..#TempData') IS NOT NULL
            DROP TABLE #TempData;
    END;
END;
