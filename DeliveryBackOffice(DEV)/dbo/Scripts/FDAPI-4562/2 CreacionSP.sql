SET NOCOUNT ON;

BEGIN TRY

    IF NOT EXISTS (SELECT 1 FROM sys.types WHERE name = 'TblDeliveryOrders_AP' AND schema_id = SCHEMA_ID('dbo') AND is_table_type = 1)
    BEGIN
        CREATE TYPE [dbo].[TblDeliveryOrders_AP] AS TABLE (
            [RowNumber]                            INT             NOT NULL,
            [Ticket_Number]                        NVARCHAR (150)  NULL,
            [Order_Number]                         INT             NULL,
            [Preparation_Date]                     DATETIME        NULL,
            [Shipping_Date]                        DATETIME        NULL,
            [Pieces_Dry]                           INT             NULL,
            [Pieces_Cold]                          INT             NULL,
            [Consolidated_Number]                  INT             NULL,
            [Recipe_Number]                        NVARCHAR (1000) NULL,
            [Sender_ID]                            INT             NULL,
            [Sender_FirstName]                     NVARCHAR (100)  NULL,
            [Sender_LastName]                      NVARCHAR (100)  NULL,
            [Sender_Address]                       NVARCHAR (200)  NULL,
            [Sender_Zone]                          NVARCHAR (100)  NULL,
            [Sender_Town]                          NVARCHAR (100)  NULL,
            [Sender_Department]                    NVARCHAR (100)  NULL,
            [Sender_Phone]                         NVARCHAR (50)   NULL,
            [Sender_Email]                         NVARCHAR (100)  NULL,
            [Receiver_ID]                          INT             NULL,
            [Receiver_FirstName]                   NVARCHAR (100)  NULL,
            [Receiver_LastName]                    NVARCHAR (100)  NULL,
            [Receiver_Address]                     NVARCHAR (600)  NULL,
            [Receiver_Zone]                        NVARCHAR (100)  NULL,
            [Receiver_Town]                        NVARCHAR (100)  NULL,
            [Receiver_Department]                  NVARCHAR (100)  NULL,
            [Receiver_Phone]                       NVARCHAR (100)  NULL,
            [Receiver_Email]                       NVARCHAR (200)  NULL,
            [Receiver_SocialSecurity_ID]           NVARCHAR (200)  NULL,
            [Receiver_Alternant_ID]                INT             NULL,
            [Receiver_Alternant_FullName]          NVARCHAR (200)  NULL,
            [Receiver_Alternant_Address]           NVARCHAR (200)  NULL,
            [Receiver_Alternant_Zone]              NVARCHAR (100)  NULL,
            [Receiver_Alternant_Town]              NVARCHAR (100)  NULL,
            [Receiver_Alternant_Department]        NVARCHAR (100)  NULL,
            [Receiver_Alternant_Phone]             NVARCHAR (100)  NULL,
            [Receiver_Alternant_Email]             NVARCHAR (200)  NULL,
            [Receiver_Alternant_SocialSecurity_ID] NVARCHAR (200)  NULL,
            [Delivery_Max_Date]                    DATETIME        NULL,
            [printedStatus]                        TINYINT         NULL,
            [StatusOrderId]                        TINYINT         NOT NULL,
            [Receiver_CUI]                         NVARCHAR (25)   NULL,
            [Package_Description]                  NVARCHAR (200)  NULL,
            [Sender_Internal_Code]                 NVARCHAR (50)   NULL,
            [Receiver_Alternant_CUI]               NVARCHAR (25)   NULL,
            [Collect_OnDelivery]                   DECIMAL (14, 2) NULL,
            [ParcelCode]                           NVARCHAR (1000) NULL,
            [IdCountrySender]                      NVARCHAR (2)    NULL,
            [ReceiverIdSettlement]                 BIGINT          NULL,
            [SenderIdTownship]                     INT             NULL,
            [ReceiverIdTownship]                   INT             NULL,
            [SenderIdSettlement]                   BIGINT          NULL
        );
        
        PRINT 'Tipo de tabla [dbo].[TblDeliveryOrders_AP] creado exitosamente.';
    END
    ELSE
    BEGIN
        PRINT 'El tipo de tabla [dbo].[TblDeliveryOrders_AP] ya existe.';
    END

    IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'SetServiceRequest_AP' AND schema_id = SCHEMA_ID('dbo'))
    BEGIN
        PRINT 'Creando stored procedure [dbo].[SetServiceRequest_AP]...';
        
        EXEC('
    /* =================================================
    SP:        [dbo].[SetServiceRequest_AP]
    Propósito: <SP que crea guías del servicio de Aeropost, se toma como base SetServiceRequest>
    Autor:     <Tito Garcia>
    Historia:  <FDAPI-4562> 
    Fecha:     2025-10-14
    ==============================================
    === CHANGELOG ================================
    =========================================== */
    CREATE PROCEDURE [dbo].[SetServiceRequest_AP]
        @TblServiceRequest AS TblServiceRequest3 READONLY,
        @TblDeliveryOrders AS TblDeliveryOrders_AP READONLY,
        @IsArticle BIT = 0
    AS
    BEGIN
        
        DECLARE @IdTransaction BIGINT = NULL;
        DECLARE @ManifestNumber INT = 0;
        DECLARE @ManifestSerie VARCHAR(2) = ''FM'';
        DECLARE @GuideSerie VARCHAR(2) = ''FD'';
        DECLARE @GuidePriority INT = 0;
        DECLARE @Priority VARCHAR(1);
        DECLARE @IdCountry NVARCHAR(2);

        /*********************************************************************************************/
        /******** LLEVA EL CONTROL DE FILAS Y CORRELATIVOS AUTO GENERADOS PARA ESTA SOLICITUD ********/
        /*********************************************************************************************/
        DECLARE @CorrelativeTable AS TABLE
        (
            Row_Number INT IDENTITY(1, 1), -- no de fila
            Guide_Number INT NULL,          -- correlativo autogenerado
            Guide_Serie VARCHAR(2) NULL
        );
        DECLARE @StatusPackage INT = (SELECT IdCatSalesPackageStatus FROM CatSalesPackageStatus WHERE SalesPackageStatusName = ''Activa'')
        BEGIN TRANSACTION;
        BEGIN TRY
            /*********************************************************************************************/
            /******** AUTO GENERACIÓN DE CORRELATIVOS BASADOS EN LA CANTIDAD DE REGISTOS RECIBIDOS *******/
            /*********************************************************************************************/
            DECLARE @noRecords INT =
                    (
                        SELECT COUNT(RowNumber)FROM @TblDeliveryOrders
                    );
            DECLARE @startnum INT =
                    (
                        SELECT MAX([Guide_Number]) + 1
                        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] WITH (NOLOCK)
                    );
            DECLARE @endnum INT = (@startnum - 1) + @noRecords;
            WITH gen
            AS (SELECT @startnum AS num
                UNION ALL
                SELECT num + 1
                FROM gen
                WHERE num + 1 <= @endnum)
            INSERT INTO @CorrelativeTable
            (
                Guide_Number, Guide_Serie
            )
            SELECT NEXT VALUE FOR [dbo].[NewGuideNumberSequence], @GuideSerie
            FROM gen
            OPTION (MAXRECURSION 10000);

            /*****************************************************************************************************************************/
            /******** TABLA TEMPORAL #GUIDETABLE PARA UNIR REGISTROS RECIBIDOS DE DELIVERYORDERS Y CORRELATIVOS AUTOGENERADOS ************/
            /*****************************************************************************************************************************/
            SELECT [RowNumber],
                [Ticket_Number],
                [Order_Number],
                [Preparation_Date],
                [Shipping_Date],
                [Pieces_Dry],
                [Pieces_Cold],
                [Consolidated_Number],
                [Recipe_Number],
                [Sender_ID],
                [Sender_FirstName],
                [Sender_LastName],
                [Sender_Address],
                [Sender_Zone],
                [Sender_Town],
                [Sender_Department],
                [Sender_Phone],
                [Sender_Email],
                [Receiver_ID],
                [Receiver_FirstName],
                [Receiver_LastName],
                [Receiver_Address],
                [Receiver_Zone],
                [Receiver_Town],
                [Receiver_Department],
                [Receiver_Phone],
                [Receiver_Email],
                [Receiver_SocialSecurity_ID],
                [Receiver_Alternant_ID],
                [Receiver_Alternant_FullName],
                [Receiver_Alternant_Address],
                [Receiver_Alternant_Zone],
                [Receiver_Alternant_Town],
                [Receiver_Alternant_Department],
                [Receiver_Alternant_Phone],
                [Receiver_Alternant_Email],
                [Receiver_Alternant_SocialSecurity_ID],
                [Delivery_Max_Date],
                [printedStatus],
                @GuideSerie AS ''Guide_Serie'',
                C.Guide_Number AS ''Guide_Number'',
                @ManifestSerie AS Manifest_Serie,
                @ManifestNumber AS Manifest_Number,
                [StatusOrderId],
                [Receiver_CUI],
                [Package_Description],
                [Sender_Internal_Code],
                [Receiver_Alternant_CUI],
                [Collect_OnDelivery],
                [ParcelCode],
                [IdCountrySender],
                [SenderIdTownship],
                NULL ''HubOriginId'',
                NULL ''HubDestinationId'',
                NULL ''SourceSystemId'',
                NULL ''CatSystemId'',
                NULL ''Segment'',
                NULL ''CatModuleId'',
                NULL ''IdCustomer'',
                NULL ''OrderUserCreated'',
                NULL ''SalePipeLineId'',
                ''  '' AS ''ReceiverCountryId'',
                [ReceiverIdTownship],
                [ReceiverIdSettlement],
                [SenderIdSettlement]

            INTO #GuideTable
            FROM @TblDeliveryOrders
                LEFT JOIN @CorrelativeTable C
                    ON C.[Row_Number] = RowNumber;

            /**********************************************************************/
            /******** INSERCIÓN DE ÚNICO REGISTRO PARA TABLA DE MANIFIESTO ********/
            /**********************************************************************/
            SET @ManifestNumber = NEXT VALUE FOR [dbo].[NewGuideManifestSequence];

            INSERT INTO DeliveryBackOffice.dbo.ServiceRequest
            (
                [Messageid],
                [Receiver_Name],
                [Receiver_Email],
                [PathReceivedFile],
                [PathSticker],
                [Status],
                [Receiver_Date],
                [DateCreated],
                [Manifest_Serie],
                [Manifest_Number],
                [CustomerID]
            )
            SELECT [Messageid],
                [Receiver_Name],
                [Receiver_Email],
                [PathReceivedFile],
                [PathSticker],
                [Status],
                [Receiver_Date],
                [DateCreated],
                @ManifestSerie,
                @ManifestNumber,
                [CustomerID]
            FROM @TblServiceRequest;

            ALTER TABLE #GuideTable ALTER COLUMN Segment NVARCHAR(10);
            ALTER TABLE #GuideTable ALTER COLUMN OrderUserCreated VARCHAR(100);
            
            /*****************************************************************************/
            /* REALIZA LA BÚSQUEDA DE LOS ID''S DE LOS MUNICIPIOS Y LOS AGREGA A LA TABLA */
            /*****************************************************************************/
            UPDATE #GuideTable
            SET SenderIdTownship =
                (
                    SELECT IdTownship
                    FROM [DeliveryBackOffice].[dbo].[Township]
                    WHERE DeliveryBackOffice.dbo.FnClearString(TownshipName) = DeliveryBackOffice.dbo.FnClearString(t.Sender_Town)
                        AND IdProvince =
                        (
                            SELECT IdProvince
                            FROM [DeliveryBackOffice].[dbo].[Province]
                            WHERE DeliveryBackOffice.dbo.FnClearString(ProvinceName) = DeliveryBackOffice.dbo.FnClearString(t.Sender_Department)
                        )
                ),
                SourceSystemId =
                (
                    SELECT SysIdSystem
                    FROM DeliveryBackOffice.dbo.CatSystem
                    WHERE SysNameSystem = ''Aeropost Service''
                        AND SysRowStatus = 1
                )
            FROM #GuideTable t;

            /*****************************************************************************/
            /**** REALIZA LA BÚSQUEDA DE LOS ID''S DE LOS HUBS Y LOS AGREGA A LA TABLA ****/
            /*****************************************************************************/

            UPDATE #GuideTable
            SET HubOriginId =
                (
                    SELECT [DeliveryBackOffice].[dbo].[FnGetHub](t.SenderIdTownship)
                ),
                HubDestinationId =
                (
                    SELECT [DeliveryBackOffice].[dbo].[FnGetHub](t.ReceiverIdTownship)
                ),
                CatSystemId =
                (
                    SELECT t.SourceSystemId
                ),
                CatModuleId =
                (
                    SELECT ModIdModule
                    FROM DeliveryBackOffice.dbo.CatModule
                    WHERE ModName = ''Aeropost Service''
                ),
                IdCustomer =
                (
                    SELECT CustomerID
                    FROM DeliveryBackOffice.dbo.VisitPointClient WITH (NOLOCK)
                    WHERE CodeOfReference = t.Sender_ID
                ),
                OrderUserCreated =
                (
                    SELECT t.Receiver_Email
                ),
                Segment =
                (
                    SELECT DeliveryBackOffice.dbo.fn_get_segment(t.Guide_Serie, t.Guide_Number)
                ),
                ReceiverCountryId = 
                (
                    SELECT TOP 1 IdCountry
                            FROM [DeliveryBackOffice].[dbo].[Province]
                            WHERE DeliveryBackOffice.dbo.FnClearString(ProvinceName) = DeliveryBackOffice.dbo.FnClearString(t.Receiver_Department)
                )
                ----------------------------------------------

            FROM #GuideTable t;

            /**********************************************************************/
            /*********** GUARDAR ÓRDENES ASOCIADAS (GUÍAS ELECTRÓNICAS) ***********/
            /**********************************************************************/

            INSERT DeliveryBackOffice.dbo.DeliveryOrder
            (
                [Ticket_Number],
                [Order_Number],
                [Preparation_Date],
                [Shipping_Date],
                [Pieces_Dry],
                [Pieces_Cold],
                [Consolidated_Number],
                [Recipe_Number],
                [Sender_ID],
                [Sender_FirstName],
                [Sender_LastName],
                [Sender_Address],
                [Sender_Zone],
                [Sender_Town],
                [Sender_Department],
                [Sender_Phone],
                [Sender_Mail],
                [Receiver_ID],
                [Receiver_FirstName],
                [Receiver_LastName],
                [Receiver_Address],
                [Receiver_Zone],
                [Receiver_Town],
                [Receiver_Department],
                [Receiver_Phone],
                [Receiver_Email],
                [Receiver_SocialSecurity_ID],
                [Receiver_Alternant_ID],
                [Receiver_Alternant_FullName],
                [Receiver_Alternant_Address],
                [Receiver_Alternant_Zone],
                [Receiver_Alternant_Town],
                [Receiver_Alternant_Department],
                [Receiver_Alternant_Phone],
                [Receiver_Alternant_Email],
                [Receiver_Alternant_SocialSecurity_ID],
                [Delivery_Max_Date],
                [printedStatus],
                [Guide_Serie],
                [Guide_Number],
                [Manifest_Serie],
                [Manifest_Number],
                [DateCreated],
                [StatusOrderId],
                [Receiver_CUI],
                [Package_Description],
                [Sender_Internal_Code],
                [Receiver_Alternant_CUI],
                [Courier_Route],
                [Courier_Name],
                [Courier_Vehicle_Plate],
                [Dispatched_Date],
                [Dispatched_Token],
                [Collect_OnDelivery],
                [Guide_Collected],
                [TypeService],
                [SenderIdTownship],
                [ReceiverIdTownship],
                [HubOriginId],
                [HubDestinationId],
                [CatSystemId],
                [CatModuleId],
                [IdCustomer],
                [Segment],
                [OrderUserCreated],
                [SalePipeLineId],
                [SenderCountryId],
                [ReceiverCountryId],
                [GuideType],
                [ReceiverIdSettlement],
                [SenderIdSettlement]
            )
            SELECT GT.[Ticket_Number],
                GT.[Order_Number],
                GT.[Preparation_Date],
                GT.[Shipping_Date],
                GT.[Pieces_Dry],
                GT.[Pieces_Cold],
                GT.[Consolidated_Number],
                GT.[Recipe_Number],
                GT.[Sender_ID],
                GT.[Sender_FirstName],
                GT.[Sender_LastName],
                GT.[Sender_Address],
                GT.[Sender_Zone],
                GT.[Sender_Town],
                GT.[Sender_Department],
                GT.[Sender_Phone],
                GT.[Sender_Email],
                GT.[Receiver_ID],
                GT.[Receiver_FirstName],
                GT.[Receiver_LastName],
                GT.[Receiver_Address],
                GT.[Receiver_Zone],
                GT.[Receiver_Town],
                GT.[Receiver_Department],
                GT.[Receiver_Phone],
                GT.[Receiver_Email],
                GT.[Receiver_SocialSecurity_ID],
                GT.[Receiver_Alternant_ID],
                GT.[Receiver_Alternant_FullName],
                GT.[Receiver_Alternant_Address],
                GT.[Receiver_Alternant_Zone],
                GT.[Receiver_Alternant_Town],
                GT.[Receiver_Alternant_Department],
                GT.[Receiver_Alternant_Phone],
                GT.[Receiver_Alternant_Email],
                GT.[Receiver_Alternant_SocialSecurity_ID],
                GT.[Delivery_Max_Date],
                GT.[printedStatus],
                GT.Guide_Serie,
                GT.Guide_Number,
                @ManifestSerie,
                @ManifestNumber,
                GETDATE(),
                GT.StatusOrderId,
                GT.Receiver_CUI,
                GT.Package_Description,
                GT.Sender_Internal_Code,
                GT.Receiver_Alternant_CUI,
                NULL,                  -- Courier_Route,
                NULL,                  -- Courier_Name,
                NULL,                  -- Courier_Vehicle_Plate,
                NULL,                  -- Dispatched_Date,
                NULL,                  -- Dispatched_Token,
                GT.Collect_OnDelivery, -- Collect_OnDelivery
                0,                     -- Guide_Collected
                CASE WHEN GT.Collect_OnDelivery > 0 THEN ''COD'' ELSE ''STD'' END,
                GT.SenderIdTownship,
                GT.ReceiverIdTownship,
                GT.HubOriginId,
                GT.HubDestinationId,
                GT.CatSystemId,
                GT.CatModuleId,
                GT.IdCustomer,
                GT.Segment,
                GT.OrderUserCreated,
                GT.SalePipeLineId,
                GT.IdCountrySender,
                GT.ReceiverCountryId,
                CASE WHEN GT.IdCountrySender = ReceiverCountryId THEN ''DOM'' ELSE ''INT'' END,
                NULLIF(GT.ReceiverIdSettlement,0),
                GT.SenderIdSettlement
            FROM #GuideTable GT;

            SELECT @IdCountry = IdCountrySender  FROM #GuideTable

            INSERT INTO [DeliveryBackOffice].[dbo].[ServiceDataForGuide]
            (
                [GuideSerie],
                [GuideNumber],
                [GuideToken],
                [IsDelivery],
                [RowStatus],
                [TokenCreated],
                [DateCreated]
            )
            SELECT GT.Guide_Serie,
                GT.Guide_Number,
                CONCAT(
                            GT.Guide_Serie,
                            CAST(GT.Guide_Number AS NVARCHAR),
                            RIGHT(''00000'' + CAST((FLOOR(RAND() * (99999 - 0 + 1)) + 0) AS NVARCHAR), 5)
                        ),
                1,
                1,
                ''SYS-HERMESROUTES'',
                GETDATE()
            FROM #GuideTable GT
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM [DeliveryBackOffice].[dbo].[ServiceDataForGuide] SDFG WITH (NOLOCK)
                WHERE GT.Guide_Serie = SDFG.GuideSerie
                    AND GT.Guide_Number = SDFG.GuideNumber
                    AND SDFG.IsDelivery = 1
            );

            INSERT INTO [dbo].[DeliveryOrderAttemptData] ([GuideSerie]
            , [GuideNumber]
            , [GuideDeliveryAttemptCount]
            , [GuideDeliveryMaxAttemptCount]
            , [GuideReturnAttemptCount]
            , [GuideReturnMaxAttemptCount]
            , [RowStatus]
            , [DateCreated]
            , [TokenCreated]
            , [DateUptaded]
            , [TokenUpdated])
                SELECT
                    GT.Guide_Serie
                ,GT.Guide_Number
                ,0
                ,rh.Attempt
                ,0
                ,rh.AttemptReturn
                ,1
                ,GETDATE()
                ,''Aeropost-Service''
                ,NULL
                ,NULL
                FROM #GuideTable GT
                CROSS APPLY (
                    SELECT TOP 1 RbcId FROM (
                        SELECT TOP 1 rbc.RbcId, 1 AS Priority
                        FROM RatebyCustomer rbc WITH (NOLOCK)
                        INNER JOIN VisitPointClient vpc WITH (NOLOCK)
                            ON GT.Sender_ID = vpc.CodeOfReference
                        WHERE (GT.IdCustomer = rbc.RbcIdCustomer OR (GT.IdCustomer IS NULL AND vpc.CustomerID = rbc.RbcIdCustomer))
                            AND rbc.RbcRowStatus = 1
                            AND rbc.RbcCodeOfReference = vpc.CodeOfReference        
                        UNION ALL        
                        SELECT TOP 1 rbc.RbcId, 2 AS Priority
                        FROM RatebyCustomer rbc WITH (NOLOCK)
                        INNER JOIN VisitPointClient vpc WITH (NOLOCK)
                            ON GT.Sender_ID = vpc.CodeOfReference
                        WHERE (GT.IdCustomer = rbc.RbcIdCustomer OR (GT.IdCustomer IS NULL AND vpc.CustomerID = rbc.RbcIdCustomer))
                            AND rbc.RbcRowStatus = 1
                            AND rbc.RbcCodeOfReference IS NULL
                        ORDER BY rbc.RbcCodeOfReference DESC                           
                    ) AS CombinedResults
                    ORDER BY Priority
                ) AS BestRate
                INNER JOIN RateByCustomer rc WITH (NOLOCK)
                    ON rc.RbcId = BestRate.RbcId
                INNER JOIN RateHeader rh WITH (NOLOCK)
                    ON rc.RbcIdRate = rh.RheId;

            INSERT [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
            (
                [Guide_Serie],
                [Guide_Number],
                [StatusOrderId],
                [UserCreated],
                [DateCreated],
                [DateCreatedInSystem]
            )
            SELECT GT.Guide_Serie,
                GT.Guide_Number,
                GT.StatusOrderId,
                ''Aeropost-Service'',
                GETDATE(),
                GETDATE()
            FROM #GuideTable GT;

            INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderPiece
            (
                [GuideSerie],
                [GuideNumber],
                [PiecePhysicalWeight],
                [PieceHeight],
                [PieceWidth],
                [PieceLength],
                [PieceWeight],
                [Detail],
                [Currency],
                [Amount],
                [DateCreated],
                [PieceUpdated],
                [DateUpdated],
                [fragile],
                [IsPickup],
                [NoPiece],
                [PieceHeightCheck],
                [PieceWidthCheck],
                [PieceLengthCheck],
                [MassWeight],
                [volumetricWeight],
                [CategoryCheck],
                [StatusOrderId],
                [IsDry],
                [ParcelCode]
            )
            SELECT GTB.Guide_Serie,
                GTB.Guide_Number,
                0,
                0,
                0,
                0,
                0,
                NULL,
                CASE 
                    WHEN GTB.IdCountrySender = ''GT'' THEN ''GTQ'' 
                    WHEN GTB.IdCountrySender = ''HN'' THEN ''HNL'' 
                    WHEN GTB.IdCountrySender = ''SV'' THEN ''USD''
                    ELSE ''USD''
                END AS [Currency],
                0,
                GETDATE(),
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                1,
                GTB.Pieces_Dry,
                NULL
            FROM  #GuideTable GTB


            DECLARE @idcustomer INT =
                    (
                        SELECT TOP 1 vpc.CustomerID
                        FROM #GuideTable
                            INNER JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
                                ON vpc.CodeOfReference = Sender_ID
                    );

            IF @idcustomer <> -1
            BEGIN

                CREATE TABLE #RevalueGuides
                (
                    fila INT,
                    Guide_Serie NVARCHAR(2),
                    Guide_Number INT
                );

                CREATE NONCLUSTERED INDEX tempFila ON #RevalueGuides (fila);

                INSERT INTO #RevalueGuides
                (
                    fila,
                    Guide_Serie,
                    Guide_Number
                )
                SELECT ROW_NUMBER() OVER (ORDER BY ord.Guide_Number ASC) AS fila,
                    ord.Guide_Serie,
                    ord.Guide_Number
                FROM #GuideTable lst
                    INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder ord WITH (NOLOCK)
                        ON ord.Guide_Number = lst.Guide_Number
                        AND ord.Guide_Serie = lst.Guide_Serie
                WHERE ISNULL(ord.PriceShippment, 0) = 0;



                DECLARE @count INT = 1;
                DECLARE @RevalueSerie VARCHAR(10);
                DECLARE @RevalueGuide INT;
                DECLARE @IdMax INT =
                        (
                            SELECT MAX(fila)FROM #RevalueGuides
                        );
                DECLARE @RC INT;

                WHILE @count <= @IdMax
                BEGIN

                    PRINT ''************************revalue**********************'';
                    PRINT CONVERT(VARCHAR(100), GETDATE(), 9);
                    PRINT @RevalueSerie;
                    PRINT @RevalueGuide;
                    PRINT @count;
                    SELECT @RevalueSerie = rv.Guide_Serie,
                        @RevalueGuide = rv.Guide_Number
                    FROM #RevalueGuides rv
                    WHERE rv.fila = @count;

                    EXECUTE @RC = DeliveryBackOffice.dbo.spws_revalue_guide @GuideSerie = @RevalueSerie,
                                                                            @GuideNumber = @RevalueGuide,
                                                                            @CodeApp = '''',
                                                                            @Format = ''Non'',
                                                                            @CalculateTaxes = ''true'',
                                                                            @IdModule = 33,
                                                                            @SetUpdate = ''true'',
                                                                            @Token = ''SetServiceRequest_AP'',
                                                                            @IsReturn = ''false'';
                    SET @count = @count + 1;


                END;
            END;
            
            UPDATE
                [DO]
            SET
                [DO].[DeliveryETA] = [DeliveryBackOffice].[dbo].[fn_GetGuideDeliveryETA]
                    (
                        (CASE WHEN LTRIM(RTRIM(ISNULL([DO].[Sender_Department],''''))) <> '''' THEN [DO].[Sender_Department] ELSE [VPC].[Department] END)
                        , (CASE WHEN LTRIM(RTRIM(ISNULL([DO].[Sender_Town],''''))) <> '''' THEN [DO].[Sender_Town] ELSE [VPC].[Town] END)
                        , NULL
                        , [DO].[SenderCountryId] 
                        , [DO].[Receiver_Department]
                        , [DO].[Receiver_Town]
                        , NULL
                        , [DO].[ReceiverCountryId]
                        , [DO].[DateCreated]
                    )
            FROM
                [DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
                INNER JOIN
                    [#GuideTable] GT
                    ON
                        [DO].[Guide_Serie] = [GT].[Guide_Serie]
                        AND
                        [DO].[Guide_Number] = [GT].[Guide_Number]
                INNER JOIN
                    [DeliveryBackOffice].[dbo].[VisitPointClient] VPC  WITH(NOLOCK) 
                    ON
                        [DO].[Sender_ID] = [VPC].[CodeOfReference]
            ------------------------------------------------------

            SET @GuidePriority = (SELECT COUNT (do.Guide_Number) 
                                    FROM DeliveryOrder do WITH (NOLOCK)
                                        INNER JOIN @CorrelativeTable ct
                                            ON do.Guide_Number = ct.Guide_Number
                                            AND do.Guide_Serie = ct.Guide_Serie
                                        INNER JOIN Membership mb
                                            ON do.IdCustomer = mb.CustomerId
                                    WHERE mb.CatMembershipStatusId = 3
                                        AND mb.ExpirationDate >= GETDATE()
                                        AND mb.RowStatus = 1
                                )

            DROP TABLE #GuideTable;

        --END
        END TRY
        BEGIN CATCH
            
            SELECT 0 AS ''StatusCode'',
                ERROR_MESSAGE() AS ''Description'',
                CONVERT(BIGINT, 0) AS ''NumTransferID'',
                ERROR_LINE() AS [ErrorLine];
            ROLLBACK TRANSACTION;

            INSERT INTO dbo.RoutePreparationLogError
            (
                ErrorDescription,
                ErrorNumber,
                ErrorProcedure,
                ErrorLine,
                GuideSerie,
                GuideNumber,
                TokenCreated,
                DateCreated
            )
            VALUES
            (   ERROR_MESSAGE(),     -- ErrorDescription - varchar(300)
                ERROR_NUMBER(),     -- ErrorNumber - int
                ERROR_PROCEDURE(),     -- ErrorProcedure - varchar(100)
                ERROR_LINE(),     -- ErrorLine - int
                '''',     -- GuideSerie - nvarchar(2)
                NULL,     -- GuideNumber - int
                '''',       -- TokenCreated - varchar(50)
                GETDATE() -- DateCreated - datetime
                )

        END CATCH;

        IF @@TRANCOUNT > 0
        BEGIN
            COMMIT TRANSACTION;

            DECLARE @ParserSys INT =
            (
                SELECT TOP 1 [CS].[SysIdSystem]
                FROM [DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
                WHERE [CS].[SysNameSystem] = ''Aeropost Service'' 
            )

            DECLARE @IDCatBusinessB2B INT = (SELECT IdBusinessSegment FROM DBO.CatBusinessSegment WHERE BusinessSegmentName=''B2B'' AND IIF(IdCountry IS NULL , ''GT'', IdCountry) = @IdCountry);

            SELECT 1 AS ''StatusCode'',
                ''Registros guardados correctamente'' AS ''Description'',
                @ManifestNumber AS ''NumTransferID'';
            SELECT Manifest_Serie AS ''ManifestSerie'',
                Manifest_Number AS ''ManifestNumber''
            FROM ServiceRequest WITH (NOLOCK)
            WHERE Manifest_Serie = @ManifestSerie
                AND Manifest_Number = @ManifestNumber;

            SELECT C.[Row_Number] AS ''RowNumber'',
                D.Guide_Serie AS ''GuideSerie'',
                D.Guide_Number AS ''GuideNumber'',
                PrvOri.[ProvinceAbbreviation] AS ''HubOrigin'',
                (
                    SELECT HubAbbreviation
                    FROM [DeliveryBackOffice].[dbo].[HubLogistics]
                    WHERE IdHubLogistic = D.HubDestinationId
                ) AS ''HubDestination'',
                (
                    SELECT DeliveryBackOffice.dbo.FnGetCustomerAttempts(D.Sender_ID, D.IdCustomer)
                ) AS ''Attempts'',
                (CASE 
                        WHEN MMBSHP.IdMembership IS NOT NULL THEN ''F''
                        WHEN ctm.BusinessSegmentID = @IDCatBusinessB2B THEN ''B'' 
                        ELSE ''E''
                        END) ''Priority'',

                CONCAT(''https://forzadelivery.com/rastreo/'',D.Guide_Serie,D.Guide_Number)''QRLink'',
                (CASE
                        WHEN 
                            (D.IsCollect <> 1 AND D.Collect_OnDelivery>0 )
                            or ctm.Abbreviation IN (''IGSS'',''RENAP'')

                        THEN
                            ''D''
                        ELSE
                            ''''
                        END
                    )''Icon''

            , D.TypeService  ''TypeService'',
            (FORMAT(ISNULL([D].[DeliveryETA], DATEADD(DAY,5,GETDATE())), ''ddMM''))''DeliveryETA'',
                    (
                        CASE
                            WHEN [DOPD].[TimePlaId] = 1 THEN ''PREPAGO''
                            WHEN [DOPD].[TimePlaId] = 2 THEN ''PICKUP''
                            WHEN [DOPD].[TimePlaId] = 3 THEN ''COLLECT''
                            WHEN [DOPD].[TimePlaId] = 4 THEN ''CRÉDITO''
                            ELSE ''CRÉDITO''
                        END
                    )''WayToPayDescription'',

                (
                        CASE
                            WHEN D.[CatSystemId] = @ParserSys THEN ''PAR''
                            WHEN D.[CatSystemId] IS NULL THEN ''API''
                            ELSE ''API''
                        END
                )''GuideOrigin'',
                D.ReceiverCountryId,
                IIF(D.InsuranceAmount>800 AND D.IsInsuarance=1,1,0) ''IsInsured'',
                CASE
                                        WHEN DOP.PiecePhysicalWeight > 0 THEN 
                                    IIF(DOP.PiecePhysicalWeight >= DOP.PieceWeight, CAST(ROUND(DOP.PiecePhysicalWeight,0) AS INT),CAST(ROUND(DOP.PieceWeight,0) AS INT))
                                    ELSE 
                                        CAST(ROUND(RH.AdditionalWeightRate,0)AS INT) END 
                                    ''WeightLB'',
                                    CAST(ROUND(RH.WeightLimit,0) AS INT) AS ''WeightOf'',
                ISNULL(DSC.RouteCode,'''') AS ''RouteCode'',
                ISNULL(DSC.RouteCode,'''') AS ''Route_Code'',
                ISNULL(DPF.dpf_SAPcardCode,''0000'') AS ''CardCode'',
                D.Ticket_Number
            FROM DeliveryOrder D WITH (NOLOCK)
                INNER JOIN @CorrelativeTable C
                    ON C.Guide_Number = D.Guide_Number
                    AND C.Guide_Serie = D.Guide_Serie
                LEFT JOIN DeliveryBackOffice.dbo.Customer ctm WITH (NOLOCK)
                    ON ctm.IdCustomer = D.IdCustomer
                LEFT JOIN DeliveryBackOffice.dbo.Membership MMBSHP WITH(NOLOCK)
                    ON MMBSHP.CustomerId = ctm.IdCustomer
                    AND MMBSHP.CatMembershipStatusId = @StatusPackage
                    AND MMBSHP.ExpirationDate >= GETDATE()
                    AND MMBSHP.RowStatus = 1
                LEFT JOIN DeliveryOrderPaymentDetail DOPD WITH (NOLOCK)
                    ON dopd.GuideSerie = d.Guide_Serie and DOPD.GuideNumber = D.Guide_Number
                LEFT JOIN VisitPointClient vpct WITH (NOLOCK)
                    ON vpct.CodeOfReference = D.Sender_ID
                LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpori  WITH(NOLOCK) 
                    ON [vpori].[CodeOfReference] = D.[OriginSenderId]
                LEFT JOIN [DeliveryBackOffice].[dbo].[Province] PrvOri  WITH(NOLOCK) 
                    ON [D].[Receiver_Department] = [PrvOri].[ProvinceName]  COLLATE Latin1_General_CI_AI 
                LEFT JOIN [dbo].[del_ParametrosFactura] DPF WITH(NOLOCK)
                    ON  D.[OriginSenderId] = DPF.dpf_VpCodeOfReference
                LEFT JOIN DumpServiceCoverage DSC WITH(NOLOCK)
                    ON DSC.IdSettlement = D.ReceiverIdSettlement
                LEFT JOIN [dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
                    ON   DOP.GuideSerie = D.Guide_Serie   AND  DOP.GuideNumber  = D.Guide_Number
                LEFT JOIN  dbo.RatebyCustomer RC WITH(NOLOCK)
                ON D.IdCustomer = RC.RbcIdCustomer  AND RbcRowStatus = 1 AND (D.Sender_ID = RC.RbcCodeOfReference OR RC.RbcCodeOfReference IS NULL)
                LEFT JOIN    dbo.RateHeader RH WITH(NOLOCK)
                ON RC.RbcIdRate= RH.RheId
            WHERE D.Guide_Serie = @GuideSerie
                AND D.Guide_Number IN
                    (
                        SELECT CT.Guide_Number FROM @CorrelativeTable CT
                    )
            ORDER BY C.[Row_Number] ,
                CASE 
                    WHEN RbcCodeOfReference = D.Sender_ID THEN 1
                    WHEN RbcCodeOfReference IS NULL THEN 2
                    ELSE 3
                END
                ASC;
        END;
    END;
        ');
        
        PRINT 'Stored procedure [dbo].[SetServiceRequest_AP] creado exitosamente.';
    END
    ELSE
    BEGIN
        PRINT 'El stored procedure [dbo].[SetServiceRequest_AP] ya existe.';
    END
    PRINT 'Creación de SP completada exitosamente.';
END TRY
BEGIN CATCH
    DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
    SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
    RAISERROR('Error ejecutando el script: %s', @ErrSeverity, 1, @ErrMsg);
END CATCH;
