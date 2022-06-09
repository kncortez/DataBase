
-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-06>
-- Description:	<Finaliza el proceso de recoleccion insertando informacion en las tablas de costos>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-01-27>
-- Description:	< Actualización de logica para registro de pagos en efectivo desde CourierApp >
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-02-10>
-- Description:	< Manejo correcto de voucher y registro de pago >
-- =============================================
-- ===============================================================================================================
-- Author:		<Marco,Jiménez>
-- Mod. date:   <2022-03-29>
-- Story:       <HW-98>
-- Description:	< Se agregan los filtros al insert en la ProcessedGuideCOD, para poder evitar que se procesen 
--                en un lote los pagos realizados con tarjeta crédito o débito, sin alterar la estructura de BD >
-- ===============================================================================================================


CREATE PROCEDURE [dbo].[SetFinishPickUp_temp]
    -- Add the parameters for the stored procedure here
    @InGuides NVARCHAR(MAX) = 'FD22221,FD22361,FD22223,FD22359,FD22226',
    @IdPickup INT = 2,
    @TypeofInOutMoneyId INT = 1,
    --	@IdStatusPickup int = 3,
    @Token VARCHAR(200) = NULL,
    @Observations VARCHAR(200) = NULL,
    @Amount DECIMAL(12, 2) = 0,
    @Voucher NVARCHAR(200) = ' ',
    @PuSignaturePath NVARCHAR(250) = ' '
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @jsonResult NVARCHAR(MAX);
    DECLARE @jsonResult1 NVARCHAR(MAX);
    DECLARE @jsonResult2 NVARCHAR(MAX);
    DECLARE @jsonError NVARCHAR(MAX);
    DECLARE @jsonToken NVARCHAR(MAX);


    PRINT 'validar token';
    -- insertar en tabla temporal posbibles mensajes de respuesta
    --IF OBJECT_ID('tempdb.dbo.#UpdateNow', 'U') IS NOT NULL DROP TABLE #UpdateNow;
    IF OBJECT_ID('tempdb.dbo.#NowInsert', 'U') IS NOT NULL
        DROP TABLE #NowInsert;
    IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL
        DROP TABLE #responsemessage;
    IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
        DROP TABLE #Temp;
    SELECT *
    INTO #responsemessage
    FROM
    (
        SELECT 200 AS IdResult,
               'Estado  cambiado correctamente' AS Message,
               'OK' AS Id
        UNION
        SELECT 500 AS IdResult,
               'Error faltal intente de nuevo mas tarde' AS Message,
               'Transac' AS Id
    ) AS errror;

    DECLARE @TokenAct INT =
            (
                SELECT TOP 1
                       RowStatus
                FROM LogTokenPOD
                WHERE LogTokenPOD LIKE '%' + @Token + '%'
                ORDER BY DateCreated DESC
            );
    DECLARE @hourtoken INT =
            (
                SELECT TOP 1
                       DATEDIFF(HOUR, DateCreated, GETDATE()) AS horas
                FROM LogTokenPOD
                WHERE LogTokenPOD LIKE '%' + @Token + '%'
            );

    PRINT 'validando token';
    IF ((@TokenAct = 1 AND @hourtoken <= 8) OR 1 = 1)
    BEGIN
        PRINT '@TokenAct';
        PRINT @TokenAct;
        PRINT 'token valido';
        PRINT '@hourtoken';
        PRINT @hourtoken;

        CREATE TABLE #Temp
        (
            Guide VARCHAR(255),
            Message VARCHAR(255),
        );

        --select * from #Temp
        --DECLARE @Tabla1 TABLE(id INT, nombreVARCHAR(20), telefonoVARCHAR(12));


        INSERT INTO #Temp
        (
            Guide,
            Message
        )
        EXEC [dbo].[spws_get_validate_guides_pickup]
            -- Add the parameters for the stored procedure here
            @InGuides = @InGuides,
            @IdPickup = @IdPickup,
            @Token = @Token;
        --if (SELECT  count(*) FROM #Temp)=0



        DECLARE @test INT =
                (
                    SELECT COUNT(*)FROM #Temp
                );

        PRINT 'clavo token valido';


        IF (@test = 0)
        BEGIN
            BEGIN TRANSACTION;
            BEGIN TRY

                --IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL DROP TABLE #Temp;
                IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
                    DROP TABLE #listGuides;

                SELECT SUBSTRING(Item, 1, 2) ItemSerie,
                       SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber --, 
                INTO #listGuides
                FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides, ',');

                ---SELECT * FROM #listGuides


                ---declare @IdCustomer int = (select IdCustomer from Account where AccIdAccount = @IdAccount)

                PRINT 'token valido1';
                --------------------------------inserta en una tabla temporal, los campos requeridos para insertar en DeliveryPaymentDetail las guias no generadas en el portal--------------------------------------

                PRINT 'tarifa recoleccion';



                DECLARE @AmountPickup DECIMAL(14, 2) =
                        (
                            SELECT CONVERT(DECIMAL(14, 2), Value)
                            FROM CatToCharge
                            WHERE IdToCharge = 1
                        );

                --	print 'tarifa recoleccion1'  + @AmountPickup

                --	select Guide_Number, Guide_Serie, PriceShippment from DeliveryOrder
                --	where Guide_Number = 198915			

                SELECT [Guide_Number],
                       [Guide_Serie],
                       [PriceShippment],
                       [recolect],
                       [IsCollect]
                INTO #NowInsert
                FROM
                (
                    SELECT ord.Guide_Number,
                           ord.Guide_Serie,
                           ord.PriceShippment,
                           (@AmountPickup) AS recolect,
                           ord.IsCollect
                    FROM DeliveryOrder ord WITH (NOLOCK)
                        LEFT JOIN DeliveryOrderPaymentDetail dop WITH (NOLOCK)
                            ON (
                                   ord.Guide_Number = dop.GuideNumber
                                   AND ord.Guide_Serie = dop.GuideSerie
                               )
                        INNER JOIN #listGuides ls
                            ON (
                                   ord.Guide_Number = ls.ItemNumber
                                   AND ord.Guide_Serie = ls.ItemSerie
                               )
                    WHERE ord.Guide_Number IN
                          (
                              SELECT ItemNumber FROM #listGuides
                          )
                          AND ord.StatusOrderId IN ( 15, 1, 16 )
                          AND dop.GuideNumber IS NULL
                ) AS Table1;

                --	declare @AmountPickup decimal (18,2) = (select  Convert(decimal(18,2),Value) from ConfigParams where ConfigParamsId = 15)



                ----------------------------------------------Inserta en la tabla DeliveryOrderPaymentDetail los datos de la tabla temporal ----------------------------------
                PRINT 'Inserta en la tabla DeliveryOrderPaymentDetail los datos de la tabla temporal ';
                INSERT INTO dbo.DeliveryOrderPaymentDetail
                (
                    [GuideNumber],
                    [GuideSerie],
                    [PayTypeId],
                    [TypeofInOutMoneyId],
                    [TimePlaId],
                    [amount],
                    [TokenCreated],
                    [DateCreated],
                    [TokenUpdated],
                    [DateUpdated],
                    [PaymentRecollections],
                    [PaymentNow],
                    [PaymentDelivery],
                    [StartDate],
                    [EndDate],
                    [ShipmentCompleted],
                    [RecollectionCompleted],
                    [PaidGuide],
                    [TransaccionFAC],
                    [IdHeaderRecolection],
                    [RecolectNow],
                    [RecolectDelivery],
                    [RecolectPayment]
                )
                SELECT DISTINCT
                       ls.Guide_Number,
                       ls.Guide_Serie,
                       1,
                       @TypeofInOutMoneyId,
                       IIF(ls.IsCollect = 'true', 3, 4),
                       NULL,
                       @Token,
                       GETDATE(),
                       NULL,
                       NULL,
                       NULL,
                       0.00,
                       0.00,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       @IdPickup,
                       0.00,
                       0.00,
                       @AmountPickup
                FROM #NowInsert ls;


                --------------------------------------------- Registra en la tabla DeliveryOrderDetail la recoleccion de la guia  ---------------------------------
                PRINT 'Registra en la tabla DeliveryOrderDetail la recoleccion de la guia';
                INSERT INTO DeliveryOrderDetail
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
                SELECT ni.ItemSerie,
                       ni.ItemNumber,
                       2,
                       @Token,
                       GETDATE(),
                       GETDATE(),
                       NULL,
                       NULL
                FROM #listGuides ni;


                --- UPDATE PARA MANEJO DE ENVIO DE MENSAJITOS EN HORA DE RECOLECCION
                /*
				update [DeliveryBackOffice].[dbo].[SMS_UpdatedElements]
				set UpdateStatus=1
				where ElementId=1002
			*/
                --- FIN MODIFICACION

                -------------------------- Drop la tabla temporal -------------------------------------------------------------------

                --DROP TABLE #UpdateNow
                DROP TABLE #NowInsert;


                ---------------------------------Obtner los datos a actualizar del encabezado del lote de guias -------------------------------------
                PRINT 'Obtner los datos a actualizar del encabezado del lote de guias';
                DECLARE @SenderId INT =
                        (
                            SELECT TOP 1
                                   ord.Sender_ID
                            FROM #listGuides ls
                                JOIN DeliveryOrder ord
                                    ON (
                                           ord.Guide_Number = ls.ItemNumber
                                           AND ord.Guide_Serie = ls.ItemSerie
                                       )
                            WHERE ord.Guide_Number IN
                                  (
                                      SELECT ItemNumber FROM #listGuides
                                  )
                        );

                DECLARE @CustomerId INT =
                        (
                            SELECT TOP 1
                                   ISNULL(ord.IdCustomer, 6)
                            FROM #listGuides ls
                                JOIN DeliveryOrder ord WITH (NOLOCK)
                                    ON (
                                           ord.Guide_Number = ls.ItemNumber
                                           AND ord.Guide_Serie = ls.ItemSerie
                                       )
                            WHERE ord.Guide_Number IN
                                  (
                                      SELECT ItemNumber FROM #listGuides
                                  )
                        );

                DECLARE @SenderName VARCHAR(50) =
                        (
                            SELECT TOP 1
                                   CONCAT(ord.Sender_FirstName, ord.Sender_LastName) AS SenderName
                            FROM #listGuides ls
                                JOIN DeliveryOrder ord WITH (NOLOCK)
                                    ON (
                                           ord.Guide_Number = ls.ItemNumber
                                           AND ord.Guide_Serie = ls.ItemSerie
                                       )
                            WHERE ord.Guide_Number IN
                                  (
                                      SELECT ItemNumber FROM #listGuides
                                  )
                        );

                DECLARE @Sender_Phone VARCHAR(20) =
                        (
                            SELECT TOP 1
                                   ord.Sender_Phone
                            FROM #listGuides ls
                                JOIN DeliveryOrder ord WITH (NOLOCK)
                                    ON (
                                           ord.Guide_Number = ls.ItemNumber
                                           AND ord.Guide_Serie = ls.ItemSerie
                                       )
                            WHERE ord.Guide_Number IN
                                  (
                                      SELECT ItemNumber FROM #listGuides
                                  )
                        );


                DECLARE @IdHublogistic INT =
                        (
                            SELECT TOP 1
                                   thb.IdHublogistic
                            FROM #listGuides ls
                                JOIN DeliveryOrder ord WITH (NOLOCK)
                                    ON (
                                           ord.Guide_Number = ls.ItemNumber
                                           AND ord.Guide_Serie = ls.ItemSerie
                                       )
                                INNER JOIN TownshipByHubLogistic thb WITH (NOLOCK)
                                    ON (ord.SenderIdTownship = thb.IdTownship)
                                INNER JOIN DeliveryOrderPaymentDetail dop WITH (NOLOCK)
                                    ON (
                                           dop.GuideNumber = ord.Guide_Number
                                           AND dop.GuideSerie = ord.Guide_Serie
                                       )
                            WHERE ord.Guide_Number IN
                                  (
                                      SELECT ItemNumber FROM #listGuides
                                  )
                        );


                DECLARE @Sender_Address VARCHAR(200) =
                        (
                            SELECT TOP 1
                                   ord.Sender_Address
                            FROM #listGuides ls
                                JOIN DeliveryOrder ord WITH (NOLOCK)
                                    ON (
                                           ord.Guide_Number = ls.ItemNumber
                                           AND ord.Guide_Serie = ls.ItemSerie
                                       )
                            WHERE ord.Guide_Number IN
                                  (
                                      SELECT ItemNumber FROM #listGuides
                                  )
                        );

                DECLARE @Sender_Email VARCHAR(200) =
                        (
                            SELECT TOP 1
                                   ISNULL(REPLACE(REPLACE(cus.RegexEmail, '$', ''), '^', ''), ' ')
                            FROM #listGuides ls
                                JOIN DeliveryOrder ord WITH (NOLOCK)
                                    ON (
                                           ord.Guide_Number = ls.ItemNumber
                                           AND ord.Guide_Serie = ls.ItemSerie
                                       )
                                LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                                    ON cus.IdCustomer = ord.IdCustomer
                        );


                -----------------------------------------------------Actualiza los datos obtenidos anteriormente para la tabla SchedulePickup-----------------------------------------------------------

                UPDATE dbo.SchedulePickup
                SET SenderId = @SenderId,
                    SenderName = @SenderName,
                    SenderPhone = @Sender_Phone,
                    IdHubLogistics = @IdHublogistic,
                    AddressPickup = @Sender_Address,
                    AmountPickup = @AmountPickup
                WHERE SchedulePickupId = @IdPickup;

                ---------------------------------------------------------Agrupa el lote de guias a una sola transaccion ------------------------------------------------------------------------------

                UPDATE DeliveryOrderPaymentDetail
                SET IdHeaderRecolection = @IdPickup
                FROM DeliveryOrderPaymentDetail dop
                    INNER JOIN DeliveryOrder ord
                        ON (
                               ord.Guide_Number = dop.GuideNumber
                               AND ord.Guide_Serie = dop.GuideSerie
                           )
                WHERE GuideNumber IN
                      (
                          SELECT ItemNumber FROM #listGuides
                      )
                      AND ord.StatusOrderId IN ( 15, 1, 16 )
                      AND
                      (
                          dop.IdHeaderRecolection = @IdPickup
                          OR dop.IdHeaderRecolection IS NULL
                      );

                ------------------------------------------------- Actualiza su StatusId a 2 = Recoleccion todas las guias del lote -------------------------------------

                UPDATE DeliveryOrder
                SET StatusOrderId = 2
                FROM DeliveryOrder
                WHERE Guide_Number IN
                      (
                          SELECT ItemNumber FROM #listGuides
                      )
                      AND Guide_Serie IN
                          (
                              SELECT ItemSerie FROM #listGuides
                          );
                /*
						
						-------------------WEBHOOK.INI-----------------------			
			IF ( SELECT ISNULL(WebhookEndpointId,0) 
		FROM WebhookEndpoint wep
		WHERE wep.IdCustomer  IN (
							select od.IdCustomer
							from  #listGuides ls
								  INNER JOIN  dbo.DeliveryOrder od on od.Guide_Serie =  ls.ItemSerie AND od.Guide_Number = ls.ItemNumber
								)
		) > 0
	BEGIN 
						INSERT INTO [dbo].[WebhookTrackingQueue]
						       ([Guide_Serie]
						       ,[Guide_Number]
						       ,[IdCustomer]
						       ,[Status]
						       ,[WebhookEndpointId]
						       ,[HasNotified]
						       ,[ChangedDate])
						SELECT  od.[Guide_Serie]
						       ,od.[Guide_Number]
						       ,od.[IdCustomer]
						       ,od.[StatusOrderId]
						       ,(SELECT WebhookEndpointId FROM WebhookEndpoint WHERE IdCustomer = od.IdCustomer)
						       ,0
						       ,GETDATE()
						FROM   #listGuides ls
							   INNER JOIN  dbo.DeliveryOrder od on od.Guide_Serie =  ls.ItemSerie AND od.Guide_Number = ls.ItemNumber
		END
						-------------------WEBHOOK.FIN------------------------------	
	*/
                ---------------------------------------------- Coloca true a IsPickup para que se entienda que es Recoleccion o fue escaneada la guia --------------------


                UPDATE DeliveryOrderPiece
                SET IsPickup = 1
                FROM DeliveryOrderPiece
                WHERE GuideNumber IN
                      (
                          SELECT ItemNumber FROM #listGuides
                      )
                      AND GuideSerie IN
                          (
                              SELECT ItemSerie FROM #listGuides
                          );

                ---------------------------------------------- Actualiza el Status del Servicio  -------------------------------------------------------------------------

                DECLARE @Status INT =
                        (
                            SELECT IdServiceStatus FROM CatServiceStatus WHERE IdServiceStatus = 3
                        );

                UPDATE ServiceManagement
                SET ServiceStatusId = @Status,
                    PuSignaturePath = @PuSignaturePath
                FROM ServiceManagement
                WHERE IdSchedulePickup = @IdPickup;

                DECLARE @transac INT =
                        (
                            SELECT TOP 1
                                   IdServiceManagement
                            FROM ServiceManagement
                            WHERE IdSchedulePickup = @IdPickup
                        );

                ---------------------------------------------- Inserta en EventService el comportamiento del Pickup  -------------------------------------------------------------------------	

                INSERT INTO EventService
                (
                    ServiceManagementId,
                    ServiceStatusId,
                    RowStauts,
                    TokenCreated,
                    DateCreated,
                    Observations
                )
                VALUES
                (@transac, @Status, 1, @Token, GETDATE(), @Observations);

                -----------------------------------------Registrar pago ---------------------------------------------------------------------------


                -- Revisar la existencia de un service management para ruta de Rabbit
                IF (EXISTS
                (
                    SELECT TOP 1
                           1
                    FROM [DeliveryBackOffice].[dbo].[SettlementPickupStationDetail] SPSD WITH (NOLOCK)
                    WHERE SPSD.ServiceManagementId = @transac
                          AND SPSD.RowStatus = 1
                          AND CAST(SPSD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
                          AND SPSD.SettlementDate IS NULL
                )
                   )
                BEGIN

                    UPDATE SPSD
                    SET SPSD.Price = @Amount
                    FROM [DeliveryBackOffice].[dbo].[SettlementPickupStationDetail] SPSD WITH (NOLOCK)
                    WHERE SPSD.ServiceManagementId = @transac
                          AND SPSD.RowStatus = 1
                          AND CAST(SPSD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
                          AND SPSD.SettlementDate IS NULL;

                END;

                DECLARE @fecha AS DATE = GETDATE();
                IF @Amount > 0
                BEGIN

                    DECLARE @PaymentUpdated AS TABLE
                    (
                        CostId INT,
                        GuideSerie NVARCHAR(2),
                        GuideNumber INT
                    );

                    --- REGISTRO DE PAGO DE LAS GUÍAS RECOLECTADAS
                    UPDATE C
                    SET C.TotalAmountPaid = C.TotalAmount,
                        C.PaymentDate = @fecha,
                        C.TokenUpdated = @Token,
                        C.DateUpdated = GETDATE()
                    OUTPUT INSERTED.IdCost,
                           LG.ItemSerie,
                           LG.ItemNumber
                    INTO @PaymentUpdated
                    (
                        CostId,
                        GuideSerie,
                        GuideNumber
                    ) -- Control de guías pagadas
                    FROM [DeliveryBackOffice].[dbo].[Cost] C
                        JOIN #listGuides LG
                            ON C.ProductNumber = CONCAT(LG.ItemSerie, LG.ItemNumber)
                        LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
                            ON LG.ItemSerie = DOPD.GuideSerie
                               AND LG.ItemNumber = DOPD.GuideNumber
                    WHERE DOPD.TimePlaId = 2 -- Guías cuyo pago sea solo en la recolección
                          AND C.TotalAmountPaid IS NULL;

                    --- REGISTRO DEL DETALLE DEL PAGO DE LAS GUÍAS RECOLECTADAS
                    INSERT INTO dbo.CostDetail
                    (
                        IdCost,
                        IdTypeOfMoney,
                        Amount,
                        Voucher,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    SELECT C.IdCost,
                           @TypeofInOutMoneyId,
                           C.TotalAmountPaid,
                           CAST(CONCAT('HR', PU.GuideNumber) AS NVARCHAR(10)),
                           1,
                           @Token,
                           GETDATE()
                    FROM [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
                        JOIN @PaymentUpdated PU
                            ON C.IdCost = PU.CostId
                        LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
                            ON C.IdCost = CD.IdCost
                    WHERE CD.IdCostDetail IS NULL; -- Que no se haya generado aun su detalle de pago

                END;


                DECLARE @mail VARCHAR(200) =
                        (
                            SELECT TOP 1
                                   RegexEmail
                            FROM Customer ct
                                INNER JOIN DeliveryOrder ord WITH (NOLOCK)
                                    ON (ord.IdCustomer = ct.IdCustomer)
                            WHERE ord.Guide_Number IN
                                  (
                                      SELECT ItemNumber FROM #listGuides
                                  )
                        );




                -----------------------------------------Registrar Manifiesto ---------------------------------------------------------------------------
                PRINT 'insertando manifiesto';
                DECLARE @ManifestNumber AS INT =
                        (
                            SELECT MAX([Manifest_Number]) + 1
                            FROM [DeliveryBackOffice].[dbo].[ServiceRequest] WITH (NOLOCK)
                        );
                PRINT 'Manifest number';
                PRINT @ManifestNumber;

                DECLARE @ManifestSerie AS NVARCHAR(5) =
                        (
                            SELECT TOP 1
                                   Value
                            FROM dbo.ConfigParams WITH (NOLOCK)
                            WHERE Name = 'ManifestSerie'
                        );

                PRINT '[Receiver_Name]';
                PRINT @SenderName;

                PRINT '[Receiver_Email]';
                PRINT @Sender_Email;

                PRINT '[CustomerID] ';
                PRINT @CustomerId;

                PRINT 'Manifest serie';
                PRINT @ManifestSerie;

                INSERT INTO DeliveryBackOffice.dbo.ServiceRequest
                (
                    [Receiver_Name],
                    [Receiver_Email],
                    [Status],
                    [Receiver_Date],
                    [DateCreated],
                    [Manifest_Serie],
                    [Manifest_Number],
                    [CustomerID]
                )
                VALUES
                (@SenderName, @Sender_Email, '', GETDATE(), GETDATE(), @ManifestSerie, @ManifestNumber, @CustomerId);
                --select * from #listGuides
                --update dbo.DeliveryOrder set Manifest_Serie = @ManifestSerie , Manifest_Number = @ManifestNumber
                --from 
                --#listGuides ls
                -- join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)

                --------------PROCESSGUIDECOD.INI
                --HW-67
                -- variable para obtener el módulo de origen de los datos
                DECLARE @DataOriginId INT;
                -- variable para asignar el nombre del módulo del cuál se desea obtener su id
                DECLARE @ModName NVARCHAR(50);
                -- asignar valor a la variable ModName
                SET @ModName = N'Courier App';

                SELECT @DataOriginId = cm.ModIdModule
                FROM DeliveryBackOffice.dbo.CatModule cm WITH (NOLOCK)
                WHERE cm.ModName = @ModName;

                INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD
                (
                    GuideSerie,
                    GuideNumber,
                    CourierManId,
                    DataOriginId,
                    Token,
                    CustomerId
                )
                SELECT DISTINCT
                       lge.ItemSerie GuideSerie,
                       lge.ItemNumber GuideNumber,
                       (
                           SELECT IdCourierman
                           FROM DeliveryBackOffice.dbo.LogTokenPOD
                           WHERE LogTokenPOD = @Token
                       ) AS 'CourierManId',
                       @DataOriginId AS 'DataOriginId',
                       @Token UserCreated,
                       cus.IdCustomer CustomerId
                FROM #listGuides lge
                    INNER JOIN dbo.DeliveryOrder dlo WITH (NOLOCK)
                        ON lge.ItemSerie = dlo.Guide_Serie
                           AND lge.ItemNumber = dlo.Guide_Number
                    INNER JOIN dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
                        ON dlo.Guide_Serie = DOP.GuideSerie
                           AND dlo.Guide_Number = DOP.GuideNumber
                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                        ON vp.CodeOfReference = dlo.Sender_ID
                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                        ON cus.IdCustomer = ISNULL(dlo.IdCustomer, vp.CustomerID)
                    LEFT JOIN ProcessedGuideCOD pcd WITH (NOLOCK)
                        ON pcd.GuideSerie = dlo.Guide_Serie
                           AND pcd.GuideNumber = dlo.Guide_Number
                WHERE --HW-98.INI
                    (
                        dlo.Collect_OnDelivery = 0
                        AND dlo.IsCollect = 'false'
                        AND DOP.PayTypeId = 1
                        AND
                        (
                            DOP.TimePlaId = 1
                            OR DOP.TimePlaId = 2
                        )
                        AND DOP.TypeofInOutMoneyId = 1
                    )
                    AND NOT EXISTS
                (
                    SELECT 1
                    FROM DeliveryBackOffice.dbo.Cost C WITH (NOLOCK)
                        JOIN CostDetail CD WITH (NOLOCK)
                            ON CD.IdCost = C.IdCost
                               AND CD.IdTypeOfMoney IN ( 2, 6 )
                    WHERE C.ProductNumber = CONCAT(dlo.Guide_Serie, CAST(dlo.Guide_Number AS VARCHAR(50)))
                )
                    AND pcd.IdProcessedGuideCOD IS NULL;
                --HW-98.FIN
                --------------PROCESSGUIDECOD.FIN

                PRINT 'exito';

            -- retornar resultado en formato json

            END TRY
            BEGIN CATCH
                PRINT 'hago rollback';
                ROLLBACK TRANSACTION;
                SELECT ERROR_MESSAGE();
                -- retornar mensaje de error
                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"Message":"'
                                               + CONVERT(NVARCHAR(MAX), ERROR_MESSAGE()) + '"}'
                                        FROM #responsemessage
                                        WHERE Id = 'Invalid'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );
            END CATCH;
            IF @@trancount > 0
            BEGIN
                COMMIT TRANSACTION;

                PRINT 'hago commit';

                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT ',{"Message":"Cambios realizados exitosamente"}'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );


                PRINT 'succesfull';
                PRINT @jsonResult;
            END;

            SELECT ('[' + @jsonResult + ']') jsonResult;
            PRINT @jsonResult;
            SELECT @mail;
        --print @mail
        END;

        ELSE IF (@test > 0)
        BEGIN
            SET @jsonResult1 =
            (
                SELECT STUFF(
                                (
                                    SELECT ',{"Error":"' + ISNULL(CONVERT(VARCHAR, Guide), 'N/A') + +'"}'
                                    FROM #Temp
                                    WHERE Guide IN
                                          (
                                              SELECT Guide FROM #Temp
                                          )
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );

            PRINT @jsonResult1;

            SET @jsonResult2 =
            (
                SELECT STUFF(
                                (
                                    SELECT ',{"Message":"' + ISNULL(CONVERT(NVARCHAR(MAX), Message), 'N/A') + +'"}'
                                    FROM #Temp
                                    WHERE Guide IN
                                          (
                                              SELECT Guide FROM #Temp
                                          )
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );

            PRINT @jsonResult2;
            SET @jsonError =
            (
                SELECT STUFF(
                                (
                                    SELECT '{"IdResult":412' + ',' + '"Guides":[' + @jsonResult1 + '],' + '"Messege":['
                                           + @jsonResult2 + ']' + ''
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
            PRINT @jsonError;

            SELECT ('{' + @jsonError + '}') jsonError;

        END;



    END;
    ELSE IF (@TokenAct = 0 OR @TokenAct IS NULL OR @hourtoken > 8)
    BEGIN
        PRINT 'token inválido';
        SET @jsonToken =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"IdResult":' + '403' + ',' + '"DescriptionError":"' + 'Token inválido' + '"'
                                       + '}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
        SELECT '[' + @jsonToken + ']' jsonToken;

        RETURN;
    END;


    --		DROP TABLE #Temp

    -- destruir tablas temporales
    PRINT 'destruyendo tablas';
    IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
        DROP TABLE #listGuides;
    IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL
        DROP TABLE #responsemessage;
    IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
        DROP TABLE #Temp;
    PRINT 'tablas destruidas';
-- retornar resultado en formato json



END;