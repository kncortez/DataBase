/* =================================================
   SP:        sps_set_Return_of_delivery
   Propósito: Devolución entrega de guía
   Autor:     Josselyn Hernandez
   Historia:  ---
   Fecha:     2020-09-15

=== CHANGELOG ============================

2024-05-28 | Historia/épica: ---         | Autor: Brandon Pedroza  | Se agrega parámetro para filtrar por país de origen
2024-12-18 | Historia/épica: ---         | Autor: Tito Garcia      | Optimización según recomendaciones del DBA
2025-12-23 | Historia/épica: FDAPI-4750  | Autor: Brandon Pedroza  | Almacena idstation al confirmar devolución en desktop
2026-03-26 | Historia/épica: FDAPI-5867  | Autor: Mario Herrarte   | Agregar estado de arribo a instalaciones si no existe.

=========================================== */
CREATE PROCEDURE [dbo].[sps_set_Return_of_delivery]
    @Guide_Serie AS NVARCHAR(2),  --guide serie
    @Guide_Number AS INT,        --guide number
    @DateOfDelivery NVARCHAR(50), --Date of delivery
    @TokenId AS NVARCHAR(50),      --token user
	@IdCountry AS NVARCHAR(2) = 'GT',	 --id country
    @StationId AS INT = NULL
AS
BEGIN
    DECLARE @StatusId TINYINT =
            (
                SELECT StatusOrderId
                FROM StatusOrder WITH (NOLOCK)
                WHERE OrderDescription = 'Devuelto'
                      AND RowStatus = 1
            ); --Status of returned 
    DECLARE @ValidateOperation BIGINT;
    DECLARE @Times INT; -- cantidad de veces que se encuentra el registro con estado de entregado
    DECLARE @Datetime DATETIME; -- Fecha y hora del último checkpoint
    
    DECLARE @factor DECIMAL(10,6)= CAST((2.00/24.00) AS DECIMAL(10,6));

    IF OBJECT_ID('tempdb..#TempDataClient', 'U') IS NOT NULL
    BEGIN
        DROP TABLE #TempDataClient;
    END

    CREATE TABLE  #TempDataClient
    (
       IdCustomer INT NOT NULL,
       PortfolioId INT NOT NULL,
       --CONSTRAINT PK_TempDataClient PRIMARY KEY (IdCustomer, PortfolioId)
    );

    CREATE NONCLUSTERED INDEX IDX_PK_TempDataClient
    ON #TempDataClient (
                         IdCustomer
                       , PortfolioId
                       );

    DECLARE @IsLastMileReturn BIT = ISNULL(
                                    (
                                        SELECT TOP 1
                                               DO.[IsLastMileReturn]
                                        FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
                                        WHERE DO.Guide_Serie = @Guide_Serie
                                              AND DO.Guide_Number = @Guide_Number
                                    ),
                                    0
                                          );

    DECLARE @StatusDescription NVARCHAR(200) =
            (
                SELECT SO.OrderDescription
                FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
                    INNER JOIN [dbo].[StatusOrder] SO WITH (NOLOCK)
                        ON DO.StatusOrderId = SO.StatusOrderId
                WHERE DO.Guide_Serie = @Guide_Serie
                      AND DO.Guide_Number = @Guide_Number
            );
    DECLARE @IsStatusTerminal INT = ISNULL(
                                    (
                                        SELECT 1
                                        FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
                                        WHERE DO.Guide_Serie = @Guide_Serie
                                              AND DO.Guide_Number = @Guide_Number
                                              AND DO.StatusOrderId IN
                                                  (
                                                      SELECT SO.[StatusOrderId]
                                                      FROM [dbo].[StatusOrder] SO WITH (NOLOCK)
                                                      WHERE [CatCheckpointTypeId] = 3
                                                            AND SO.RowStatus = 1
                                                  )
                                    ),
                                    0
                                          );

    DECLARE @TimesByCountry INT; -- cantidad de veces que se encuentra el registro con estado de entregado

    BEGIN TRANSACTION;
    BEGIN TRY

        DECLARE @CurrentStatus INT;

        SELECT @CurrentStatus = dr.StatusOrderId
        FROM dbo.DeliveryOrder dr WITH (NOLOCK)
        WHERE dr.Guide_Serie = @Guide_Serie
              AND dr.Guide_Number = @Guide_Number;

        --cantidad de registros de la guia consultada del pais de origen recibido en el parametro
		DECLARE @TimeByCountry INT;
        SET @TimeByCountry =
                (
                    SELECT COUNT(Guide_Number)
                    FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
                    WHERE Guide_Serie = @Guide_Serie
                          AND Guide_Number = @Guide_Number
                          AND SenderCountryId = @IdCountry
                          
                );

        IF(@TimeByCountry <>0)--valida que existan registros de la guia consultada con el pais de origien recibido
		BEGIN
        IF (@IsStatusTerminal = 0)
        BEGIN

            IF (@IsLastMileReturn = 1)
            BEGIN
                -- Buscar si la guía ya cuenta con estado de entrega previa, en caso que exista no se procede a registrar transacción para evitar registro duplicado
                SET @Times =
                (
                    SELECT COUNT(Guide_Number)
                    FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH (NOLOCK)
                    WHERE Guide_Serie = @Guide_Serie
                          AND Guide_Number = @Guide_Number
                          AND
                          (
                              StatusOrderId = @StatusId
                              OR StatusOrderId = 5
                          )
                );

                IF (@Times = 0)
                BEGIN

                    SET @Datetime =
                    (
                        SELECT TOP 1
                               DateCreated
                        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH (NOLOCK)
                        WHERE Guide_Serie = @Guide_Serie
                              AND Guide_Number = @Guide_Number
                        ORDER BY DateCreated DESC
                    );

                    IF (@DateOfDelivery > @Datetime)
                    BEGIN

                        --al momento de finalizar el proceso de devolución se debe realizar update en la tabla warehouse al campo Rack_Position, colocarlo como NULL
                        UPDATE dbo.Warehouse
                        SET Active = 0,
                            UserUpdated = @TokenId,
                            DateUpdated = GETDATE()
                        WHERE Guide_Serie = @Guide_Serie
                              AND Guide_Number = @Guide_Number
                              AND Active = 1;

                        -- Actualizar registro de guía a último estado 
                        UPDATE DeliveryBackOffice.dbo.DeliveryOrder
                        SET StatusOrderId = @StatusId, --Status of delivery 			
                            Collect_OnDelivery = 0     -- establecer valor a cobrar en cero cuando la guía es una devolución (solicitado por Van Ardón)
                        WHERE Guide_Serie = @Guide_Serie
                              AND Guide_Number = @Guide_Number;

                        -- Registro de Arribo a instalaciones si este aun no existe --
                        INSERT INTO DeliveryOrderDetail
                            (
                             Guide_Serie,
                             Guide_Number,
                             StatusOrderId,
                             UserCreated,
                             DateCreated,
                             DateCreatedInSystem,
                             StationId
                            )
                        SELECT 
                            @Guide_Serie,
                            @Guide_Number,
                            11,
                            @TokenId,
                            CASE
						        WHEN DODF.StatusOrderId IN (4,5,22) THEN
							        CASE 
							           WHEN CAST(DODF.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
									        THEN DATEADD(SECOND, -1, DODF.DateCreated)
							           WHEN CAST(DATEDIFF(DAY,DO.DateCreated,(DODF.DateCreatedInSystem)) AS INT) = 1
								           THEN CONVERT(NVARCHAR,DO.DateCreated + @factor,20)
							           ELSE CONVERT(NVARCHAR,(DO.DateCreated + DATEDIFF(DAY,DO.DateCreated,(DODF.DateCreatedInSystem))) - 1,20)
							        END
						        WHEN DODF.StatusOrderId IN (1,15) 
							        AND CAST(DODF.DateCreated AS DATE) = CAST(GETDATE() AS DATE) 
							        THEN 
								        DATEADD(SECOND, 1, DODF.DateCreated)
						        ELSE 
							        CASE 
							           WHEN CAST(DATEDIFF(DAY,DO.DateCreated,(GETDATE())) AS INT) = 1
								           THEN CONVERT(NVARCHAR,DO.DateCreated + @factor,20)
							           ELSE CONVERT(NVARCHAR,(DO.DateCreated + DATEDIFF(DAY,DO.DateCreated,(GETDATE()))) - 1,20)
							        END
					        END,
                            GETDATE(),
                            @StationId
                        FROM (
						    SELECT
	    				        Guide_Serie,
	    				        Guide_Number,
	    				        CASE
	    					        WHEN DATEPART(MILLISECOND, DateCreated) >= 500
	    						        THEN DATEADD(SECOND, 1, DateCreated)
	    					        ELSE DATEADD(MILLISECOND, -DATEPART(MILLISECOND, DateCreated), DateCreated)
	    					        END DateCreated
						        FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
						        WHERE Guide_Serie = @Guide_Serie
							        AND Guide_Number = @Guide_Number
					    ) DO
					    OUTER APPLY (
					        SELECT TOP 1
						         D.DateCreatedInSystem
						        ,D.StatusOrderId
						        ,D.DateCreated
					        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail D WITH(NOLOCK)
					        WHERE D.Guide_Serie = @Guide_Serie
					          AND D.Guide_Number = @Guide_Number
					        ORDER BY 
						        CASE 
							        WHEN D.StatusOrderId IN (4,5,22) THEN 0
							        ELSE 1
						        END,
						        D.DateCreated ASC
					    ) DODF
					    WHERE NOT EXISTS (
						    SELECT 1
						    FROM DeliveryOrderDetail DOD WITH(NOLOCK)
						    WHERE DOD.Guide_Serie = @Guide_Serie
							    AND DOD.Guide_Number = @Guide_Number
							    AND DOD.StatusOrderId = 11
						);

                        -- Insertar nuevo estado de guía en tabla histórica
                        INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
                        (
                            [Guide_Serie],
                            [Guide_Number],
                            [StatusOrderId],
                            [UserCreated],
                            [DateCreated],
                            [DateCreatedInSystem],
                            [StationId]
                        )
                        SELECT @Guide_Serie,
                               @Guide_Number,
                               @StatusId,
                               @TokenId,
                               CONVERT(DATETIME, @DateOfDelivery, 120),
                               GETDATE(),
                               @StationId
                        WHERE EXISTS
                        (
                            SELECT 1
                            FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
                            WHERE Guide_Serie = @Guide_Serie
                                  AND Guide_Number = @Guide_Number
                        );
                        SET @ValidateOperation = COALESCE(@@ROWCOUNT, 0);

                        UPDATE acodh 
                           SET acodh.AgaintsBalance = ISNULL(acodh.AgaintsBalance,0) + ISNULL(bdcod.Amount,0),
                               acodh.CustomerId = acodh.CustomerId,
                               acodh.PortfolioId = acodh.PortfolioId
                        OUTPUT inserted.CustomerId,
                               ISNULL(inserted.PortfolioId,0) AS PortfolioId
                          INTO #TempDataClient
                          FROM DeliveryOrderDetail dod WITH(NOLOCK)
                               INNER JOIN AnticipatedCODDetail acodd WITH(NOLOCK)
                                       ON dod.Guide_Serie = acodd.GuideSerie
                                      AND dod.Guide_Number = acodd.GuideNumber
                               INNER JOIN AnticipatedCODHeader acodh WITH(NOLOCK)
                                       ON acodh.IdAnticipatedCODHeader = acodd.AnticipatedCODHeaderId
                               INNER JOIN BatchDetailCOD bdcod WITH(NOLOCK)
                                       ON bdcod.GuideSerie = dod.Guide_Serie
                                      AND bdcod.GuideNumber = dod.Guide_Number
                         WHERE dod.Guide_Serie = @Guide_Serie
                           AND dod.Guide_Number = @Guide_Number
                           AND dod.StatusOrderId = 14
                           AND bdcod.Excluded = 0
                           AND bdcod.CatConceptCODId = 2
                           AND acodd.RowStatus = 1;

                        UPDATE acodd
                           SET acodd.BalanceStatus = 'DEVOLUCION',
						       acodd.DateUpdated = GETDATE(),
							   acodd.TokenUpdated = @TokenId,
							   acodd.IsAgaintsBalancePaid = 1,
							   acodd.AgaintsBalanceAmount = bdcod.Amount,
							   acodd.AgaintsBalancePaid = bdcod.Amount
                          FROM DeliveryOrderDetail dod WITH(NOLOCK)
                               INNER JOIN AnticipatedCODDetail acodd WITH(NOLOCK)
                                       ON dod.Guide_Serie = acodd.GuideSerie
                                      AND dod.Guide_Number = acodd.GuideNumber
                               INNER JOIN AnticipatedCODHeader acodh WITH(NOLOCK)
                                       ON acodh.IdAnticipatedCODHeader = acodd.AnticipatedCODHeaderId
                               INNER JOIN BatchDetailCOD bdcod WITH(NOLOCK)
                                       ON bdcod.GuideSerie = dod.Guide_Serie
                                      AND bdcod.GuideNumber = dod.Guide_Number
                         WHERE dod.Guide_Serie = @Guide_Serie
                           AND dod.Guide_Number = @Guide_Number
                           AND dod.StatusOrderId = 14
                           AND bdcod.Excluded = 0
                           AND bdcod.CatConceptCODId = 2
                           AND acodd.RowStatus = 1;

                        DECLARE @AnticipatedCODDetail AS TblAnticipatedCODCustomerBalance

                        INSERT INTO @AnticipatedCODDetail
                        SELECT DISTINCT IdCustomer, PortfolioId
                          FROM #TempDataClient

                        EXEC spUpdateBalanceByIdClient @AnticipatedCODDetail


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
                                        WHERE WT.WebhookName = 'GuideStatusChange' AND WT.RowStatus = 1
                                    );

                            SET @WebhookCustomerId
                                = ISNULL(
                                  (
                                      SELECT TOP 1
                                             DO.IdCustomer
                                      FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                                      WHERE DO.Guide_Serie = @Guide_Serie 
                                            AND DO.Guide_Number = @Guide_Number
                                  ),
                                  -1
                                        );
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

                            SET @GuideCurrentStatus =
                            (
                                SELECT TOP 1
                                       DO.StatusOrderId
                                FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                                WHERE DO.Guide_Serie = @Guide_Serie 
                                      AND DO.Guide_Number = @Guide_Number
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
								FROM WebhookEndpoint wh
								INNER JOIN WebhookCatTypeConnection wc
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
											FROM DeliveryOrder do WITH(NOLOCK)
											INNER JOIN DeliveryOrderPiece dop WITH(NOLOCK)
												ON do.Guide_Serie = dop.GuideSerie
												AND do.Guide_Number = dop.GuideNumber
                                            INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
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
											FROM DeliveryOrder do WITH(NOLOCK)
											INNER JOIN DeliveryOrderPiece dop WITH(NOLOCK)
												ON do.Guide_Serie = dop.GuideSerie
												AND do.Guide_Number = dop.GuideNumber
                                            INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
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
										dop.GuideSerie,dop.GuideNumber, dop.GuidePiece, do.Ticket_Number,dop.ExternalPieceId, 
										@GuideCurrentStatus, 1 AS RowStatus, GETDATE()AS DateCreated,@TokenId AS TokenCreated
										FROM DeliveryOrderPiece dop WITH(NOLOCK)
										INNER JOIN DeliveryOrder do WITH(NOLOCK)
											ON dop.GuideSerie = do.Guide_Serie
											AND dop.GuideNumber = do.Guide_Number
										INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
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
                    ELSE
                        SET @ValidateOperation = -2;
                END;
                -- registro existente
                ELSE
                    SET @ValidateOperation = -1;
            END;
            ELSE
                SET @ValidateOperation = -3;
        END;
        ELSE
            SET @ValidateOperation = -4;
        END;
        ELSE
            SET @ValidateOperation = -5;
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

            SELECT TOP 10
                   Guide_Serie + CAST(Guide_Number AS VARCHAR) Guide,
                   Ticket_Number Ticket,
                   Courier_Route Route,
                   CONVERT(VARCHAR, Dispatched_Date, 103) RouteDate
            FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
            WHERE Guide_Serie = @Guide_Serie
                  AND Guide_Number = @Guide_Number;

            PRINT 'REGISTER EXISTS ' + CAST(COALESCE(@ValidateOperation, 0) AS VARCHAR);
        END;
        ELSE IF (@ValidateOperation = -1)
        BEGIN
            SELECT -1 AS 'StatusCode',
                   'Registro duplicado' AS 'Description',
                   @ValidateOperation AS 'NumTransferID';
        END;
        ELSE IF (@ValidateOperation = -2)
        BEGIN
            SELECT -2 AS 'StatusCode',
                   'Fecha y hora incorrecta' AS 'Description',
                   @ValidateOperation AS 'NumTransferID';
        END;
        ELSE IF (@ValidateOperation = -3)
        BEGIN
            SELECT -3 AS 'StatusCode',
                   'Para operar una guia en este módulo debe estar declarada para devolución' AS 'Description',
                   @ValidateOperation AS 'NumTransferID';
        END;
        ELSE IF (@ValidateOperation = -4)
        BEGIN
            SELECT -4 AS 'StatusCode',
                   'Para operar una guia en este módulo no debe estar en  estado : [' + @StatusDescription
                   + '] por ser estado Terminal.' AS 'Description',
                   @ValidateOperation AS 'NumTransferID';
        END;
        ELSE IF (@ValidateOperation = -5)
        BEGIN
            SELECT -5 AS 'StatusCode',
                   'La guia que se intenta operar no pertenece al país actual' AS 'Description',
                   @ValidateOperation AS 'NumTransferID';
        END;
        ELSE
        BEGIN
            SELECT 0 AS 'StatusCode',
                   'El registro no existe' AS 'Description',
                   @ValidateOperation AS 'NumTransferID';
            PRINT 'REGISTER NOT EXISTS ' + CAST(COALESCE(@ValidateOperation, 0) AS VARCHAR);
        END;
        COMMIT TRANSACTION;
    END;
END;
