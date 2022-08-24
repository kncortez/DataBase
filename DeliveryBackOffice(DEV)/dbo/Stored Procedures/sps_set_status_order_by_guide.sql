-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-06-10>
-- Description:	<Cambiar el estado de una lista de guías>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-06-28>
-- Description:	<Validación para saber si se tiene pago con tarjeta o datafono>
-- =============================================
CREATE PROCEDURE [dbo].[sps_set_status_order_by_guide]
    @Guide_Serie AS VARCHAR(2),         -- same guide for all numbers provided
    @Guide_Number AS VARCHAR(MAX),      -- a list of guides separated by comma
    @StatusId AS INT,                   -- status from StatusOrder
    @TokenId AS VARCHAR(50),
    @DateOfStatus DATETIME,             -- datetime of event
    @Observations AS VARCHAR(200) = '', --Observations by checkpoint
    @Temperature_Celsius AS DECIMAL(5, 2),
    @courierName AS VARCHAR(200) = '',
    @iduser AS INT = NULL,
    @username NVARCHAR(50) = NULL
AS
BEGIN
    DECLARE @ValidateOperation BIGINT = 0;
    DECLARE @RowUpdated INT;
    DECLARE @ItemsTable AS TABLE
    (
        Guide_Number INT
    );
    -- control de guía a iterar
    DECLARE @GuideNumber INT;
    --DECLARE @GuideSerie varchar(2) 
    -- CourierId de la guía a iterar
    DECLARE @CourierId INT;
    -- CatModuleId del modulo
    DECLARE @CatModuleId INT;

    BEGIN TRANSACTION;

    BEGIN TRY

        -- Convertir la lista de guías separadas por coma en una tabla que permita adicionar columnas
        INSERT @ItemsTable
        SELECT CAST(Item AS INT)
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@Guide_Number, ',');

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
                [Temperature_Celsius]
            )
            SELECT @Guide_Serie,
                   it.Guide_Number,
                   @StatusId,
                   @TokenId,
                   @DateOfStatus,
                   GETDATE(),
                   @Observations,
                   @Temperature_Celsius
            FROM @ItemsTable it;
            SET @ValidateOperation = COALESCE(@@ROWCOUNT, 0);
            -----------------------------
            IF
            (
                SELECT OrderDescription
                FROM dbo.StatusOrder WITH (NOLOCK)
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
                            FROM dbo.StatusOrder WITH (NOLOCK)
                            WHERE OrderDescription = 'En ruta'
                        );
                DECLARE @IDSTATUSFAILEDDELIVERY INT =
                        (
                            SELECT StatusOrderId
                            FROM dbo.StatusOrder WITH (NOLOCK)
                            WHERE OrderDescription = 'Intento de entrega fallida'
                        );
                --Obtiene la lista de guías que ya salieron a ruta 2 o mas veces y que tienen 0 intentos de entrega fallida
                INSERT INTO @GuidesTableWithoutFailRetries
                SELECT @Guide_Serie,
                       LG.Guide_Number,
                       (DORD.StatusOrderId),
                       COUNT(DORD.StatusOrderId)
                FROM @ItemsTable LG
                    LEFT JOIN DeliveryOrder DOR WITH (NOLOCK)
                        ON DOR.Guide_Serie = @Guide_Serie
                           AND LG.Guide_Number = DOR.Guide_Number
                    LEFT JOIN dbo.DeliveryOrderDetail DORD WITH (NOLOCK)
                        ON DOR.Guide_Serie = DORD.Guide_Serie
                           AND DOR.Guide_Number = DORD.Guide_Number
                --LEFT JOIN DBO.Customer CU ON DOR.IdCustomer=CU.IdCustomer
                --LEFT JOIN DBO.RatebyCustomer RC ON CU.IdCustomer=RC.RbcIdCustomer
                --LEFT JOIN RateHeader RH ON RC.RbcIdRate=RH.RheId						
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
                                FROM dbo.TypeServiceManagment WITH (NOLOCK)
                                WHERE Name = 'Entrega'
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
                               FROM dbo.CatTypeAlert WITH (NOLOCK)
                               WHERE AlertName = 'Prioritario'
                           ),
                           1,
                           @TokenId,
                           GETDATE(),
                           NULL,
                           NULL
                    FROM @GuidesTableWithRetriesDispatch GTWRD
                        LEFT JOIN dbo.DeliveryOrderAlert DOA WITH (NOLOCK)
                            ON DOA.GuideSerie = @Guide_Serie
                               AND DOA.GuideNumber = GTWRD.Guide_Number
                    WHERE DOA.IdDeliveryOrderAlert IS NULL;

                    INSERT INTO dbo.DeliveryOrderAlertDetail
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
                        LEFT JOIN dbo.DeliveryOrderAlert DOA WITH (NOLOCK)
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
            FROM ServiceManagement sm
            INNER JOIN DeliveryOrderPaymentDetail dopd
                ON dopd.IdHeaderRecolection = sm.IdSchedulePickup
            INNER JOIN @ItemsTable it
                ON dopd.GuideNumber = it.Guide_Number
            WHERE dopd.GuideSerie = @Guide_Serie
        END



        ----------------------- PROCESSGUIDECOD- SE REGISTRA RECOLECCIÓN . INI ----------------------	
        IF @StatusId = 11
        BEGIN
            --Buscar ID modulo liquidación Recolecciones
            SET @CatModuleId = ISNULL(
                               (
                                   SELECT ModIdModule
                                   FROM CatModule WITH (NOLOCK)
                                   WHERE ModName = 'Liquidación COD'
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
                    FROM [dbo].[ProcessedGuideCOD] WITH (NOLOCK)
                    WHERE [GuideNumber] = @GuideNumber
                          AND GuideSerie = @Guide_Serie
                )
                BEGIN
                    INSERT INTO [dbo].[ProcessedGuideCOD]
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
                    FROM [dbo].[DeliveryOrder] do WITH (NOLOCK)
                        LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                            ON vp.CodeOfReference = do.Sender_ID
                        LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                            ON cus.IdCustomer = ISNULL(do.IdCustomer, vp.CustomerID)
                        INNER JOIN dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
                            ON do.Guide_Serie = DOP.GuideSerie
                               AND do.Guide_Number = DOP.GuideNumber
                    WHERE do.[Guide_Number] = @GuideNumber
                          AND do.[Guide_Serie] = @Guide_Serie
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
                           INNER JOIN CostDetail CD WITH (NOLOCK)
                                ON CD.IdCost = C.IdCost
                                   AND CD.IdTypeOfMoney IN ( 2, 6 )
                        WHERE C.ProductNumber = CONCAT(do.Guide_Serie, CAST(do.Guide_Number AS VARCHAR(50)))
                    );
                --	AND LG.ItemNumber NOT IN (SELECT GuideNumber
                --FROM [dbo].[ProcessedGuideCOD]
                --WHERE [GuideNumber] = DO.Guide_Number AND GuideSerie = DO.Guide_Serie)
                END;

                DELETE #listGuidesTemp
                WHERE Guide_Number = @GuideNumber;
            END;
        END;
    ----------------------- PROCESSGUIDECOD- SE REGISTRA RECOLECCIÓN . FIN ----------------------		

	--Actualizar estado de las piezas
	UPDATE DeliveryOrderPiece
	SET StatusOrderId = @StatusId
	WHERE GuideSerie = @Guide_Serie
	AND GuideNumber IN (SELECT
			Guide_Number
		FROM @ItemsTable);

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
    END;
END;
