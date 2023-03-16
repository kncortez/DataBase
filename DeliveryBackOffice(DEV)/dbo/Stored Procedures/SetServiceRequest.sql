
--DROP procedure [dbo].[SetServiceRequest]
CREATE PROCEDURE [dbo].[SetServiceRequest]
    @TblServiceRequest AS TblServiceRequest READONLY,
    @TblDeliveryOrders AS TblDeliveryOrders READONLY
AS
BEGIN

    DECLARE @IdTransaction BIGINT = NULL;
    DECLARE @ManifestNumber INT = 0;
    DECLARE @ManifestSerie VARCHAR(2) = 'FM';
    DECLARE @GuideSerie VARCHAR(2) = 'FD';
	DECLARE @GuidePriority INT = 0;
	DECLARE @Priority VARCHAR(1);

    /*********************************************************************************************/
    /******** LLEVA EL CONTROL DE FILAS Y CORRELATIVOS AUTO GENERADOS PARA ESTA SOLICITUD ********/
    /*********************************************************************************************/
    DECLARE @CorrelativeTable AS TABLE
    (
        [Row_Number] [INT] IDENTITY(1, 1), -- no de fila
        [Guide_Number] [INT] NULL          -- correlativo autogenerado
    );
	DECLARE @StatusPackage INT = (SELECT IdCatSalesPackageStatus FROM CatSalesPackageStatus WHERE SalesPackageStatusName = 'Activa')
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
            Guide_Number
        )
        SELECT NEXT VALUE FOR [dbo].[NewGuideNumberSequence]
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
               @GuideSerie AS 'Guide_Serie',
               C.Guide_Number AS 'Guide_Number',
               @ManifestSerie AS Manifest_Serie,
               @ManifestNumber AS Manifest_Number,
               [StatusOrderId],
               [Receiver_CUI],
               [Package_Description],
               [Sender_Internal_Code],
               [Receiver_Alternant_CUI],
               [Collect_OnDelivery],

               -- MODIFICACION 26/01/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
               --[Collect],
               NULL 'SenderIdTownship',
               NULL 'ReceiverIdTownship',
               NULL 'HubOriginId',
               NULL 'HubDestinationId',
               NULL 'SourceSystemId',
               NULL 'CatSystemId',
               NULL 'Segment',
               NULL 'CatModuleId',
               NULL 'IdCustomer',
               NULL 'OrderUserCreated',
               NULL 'SalePipeLineId'
        -- FIN MODIFICACION

        INTO #GuideTable
        FROM @TblDeliveryOrders
            LEFT JOIN @CorrelativeTable C
                ON C.[Row_Number] = RowNumber;

        /**********************************************************************/
        /******** INSERCIÓN DE ÚNICO REGISTRO PARA TABLA DE MANIFIESTO ********/
        /**********************************************************************/
        SET @ManifestNumber = NEXT VALUE FOR [dbo].[NewGuideManifestSequence];
        --(
        --    SELECT MAX([Manifest_Number]) + 1
        --    FROM [DeliveryBackOffice].[dbo].[ServiceRequest] WITH (NOLOCK)
        --);

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

        --SET @IdTransaction = SCOPE_IDENTITY();

        --IF (@IdTransaction IS NOT NULL)
        --BEGIN

        -- MODIFICACION 26/01/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
        ALTER TABLE #GuideTable ALTER COLUMN Segment NVARCHAR(10);
        ALTER TABLE #GuideTable ALTER COLUMN OrderUserCreated VARCHAR(100);

        --Modifica el tipo de los campos que recibirán una cadena

        /*****************************************************************************/
        /* REALIZA LA BÚSQUEDA DE LOS ID'S DE LOS MUNICIPIOS Y LOS AGREGA A LA TABLA */
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
            ReceiverIdTownship =
            (
                SELECT IdTownship
                FROM [DeliveryBackOffice].[dbo].[Township]
                WHERE DeliveryBackOffice.dbo.FnClearString(TownshipName) = DeliveryBackOffice.dbo.FnClearString(t.Receiver_Town)
                      AND IdProvince =
                      (
                          SELECT IdProvince
                          FROM [DeliveryBackOffice].[dbo].[Province]
                          WHERE DeliveryBackOffice.dbo.FnClearString(ProvinceName) = DeliveryBackOffice.dbo.FnClearString(t.Receiver_Department)
                      )
            ),
            SourceSystemId =
            (
                SELECT SysIdSystem
                FROM DeliveryBackOffice.dbo.CatSystem
                WHERE SysNameSystem = 'Parser'
                      AND SysRowStatus = 1
            )
        FROM #GuideTable t;

        /*****************************************************************************/
        /**** REALIZA LA BÚSQUEDA DE LOS ID'S DE LOS HUBS Y LOS AGREGA A LA TABLA ****/
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
                WHERE ModName = 'Parser'
            ),
            IdCustomer =
            (
                SELECT CustomerID
                FROM DeliveryBackOffice.dbo.VisitPointClient
                WHERE CodeOfReference = t.Sender_ID
            ),
            SalePipeLineId =
            (
                SELECT IdSalePipeLine
                FROM DeliveryBackOffice.dbo.CatSalePipelines
                WHERE Name = 'Parser'
            ),
            OrderUserCreated =
            (
                SELECT t.Receiver_Email
            ),
            Segment =
            (
                SELECT DeliveryBackOffice.dbo.fn_get_segment(t.Guide_Serie, t.Guide_Number)
            )
        FROM #GuideTable t;

        -- FIN MODIFICACION


        /**********************************************************************/
        /*********** GUARDAR ÓRDENES ASOCIADAS (GUÍAS ELECTRÓNICAS) ***********/
        /**********************************************************************/
        --PRINT 'Guardar órdenes asociadas'

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
            -- MODIFICACION 26/01/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
            --[IsCollect],

            [SenderIdTownship],
            [ReceiverIdTownship],
            [HubOriginId],
            [HubDestinationId],
            [CatSystemId],
            [CatModuleId],
            [IdCustomer],
            [Segment],
            [OrderUserCreated],
            [SalePipeLineId]
        -- FIN MODIFICACION
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
               CASE WHEN GT.Collect_OnDelivery > 0 THEN 'COD' ELSE 'STD' END,
                                      -- MODIFICACION 26/01/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                                      --,GT.Collect
               GT.SenderIdTownship,
               GT.ReceiverIdTownship,
               GT.HubOriginId,
               GT.HubDestinationId,
               GT.CatSystemId,
               GT.CatModuleId,
               GT.IdCustomer,
               GT.Segment,
               GT.OrderUserCreated,
               GT.SalePipeLineId
        -- FIN MODIFICACION
        FROM #GuideTable GT;

        -- MODIFICACION 17/09/2021 JOSE ANDRES RUIZ PEER
        -- INSERTAR DATA PARA MANEJO DE LANDING PAGE
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
                         RIGHT('00000' + CAST((FLOOR(RAND() * (99999 - 0 + 1)) + 0) AS NVARCHAR), 5)
                     ),
               1,
               1,
               'SYS-HERMESROUTES',
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
        -- FIN DE MODIFICACION

		-- FDAPI-1418 Oscar Morales 2023-02-23
		-- Insertar data para manejo de inténtos de entrega/devolución
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
			   ,'SYSTEM'
			   ,NULL
			   ,NULL
			FROM #GuideTable GT
			INNER JOIN RateByCustomer rc WITH (NOLOCK)
				ON rc.RbcId = (SELECT TOP 1
							rbc.RbcId
						FROM RatebyCustomer rbc WITH (NOLOCK)
						INNER JOIN VisitPointClient vpc WITH (NOLOCK)
							ON GT.Sender_ID = vpc.CodeOfReference
						WHERE ISNULL(GT.IdCustomer, vpc.CustomerID) = rbc.RbcIdCustomer
						AND rbc.RbcRowStatus = 1
						AND (rbc.RbcCodeOfReference = vpc.CodeOfReference
						OR rbc.RbcCodeOfReference IS NULL)
						ORDER BY rbc.RbcCodeOfReference DESC)
			INNER JOIN RateHeader rh WITH (NOLOCK)
				ON rc.RbcIdRate = rh.RheId
        -- Fin FDAPI-1418 Oscar Morales 2023-02-23

        -- INSERTAR CHECKPOINT INICIAL EN TABLA HISTÓRICA
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
               'SYSTEM',
               GETDATE(),
               GETDATE()
        FROM #GuideTable GT;


        DECLARE @Guides AS TABLE
        (
            [RowNumber] [INT] IDENTITY(1, 1),
            [Guide_Serie] NVARCHAR(2) NULL,
            [Guide_Number] [INT] NULL,
            [CountDry] INT,
            [CountCold] INT
        );

        DECLARE @Pieces AS TABLE
        (
            [Guide_Serie] NVARCHAR(2) NULL,
            [Guide_Number] [INT] NULL,
            [PartNumber] INT,
            [IsDry] BIT
        );

        INSERT INTO @Guides
        SELECT Guide_Serie,
               Guide_Number,
               Pieces_Dry,
               Pieces_Cold
        FROM #GuideTable;

        DECLARE @i INT = 0;
        DECLARE @elements INT =
                (
                    SELECT COUNT(1)FROM @Guides
                );
        IF (@elements > 0) --insertar piezas
        BEGIN
            WHILE @i < @elements
            BEGIN
                --piezas secas
                DECLARE @j INT = 0;
                DECLARE @PiecesCount INT =
                        (
                            SELECT CountDry FROM @Guides WHERE RowNumber = @i + 1
                        );
                WHILE @j < @PiecesCount
                BEGIN
                    INSERT INTO @Pieces
                    SELECT Guide_Serie,
                           Guide_Number,
                           @j + 1,
                           1
                    FROM @Guides
                    WHERE RowNumber = @i + 1;
                    SET @j = @j + 1;
                END;

                --piezas frías
                DECLARE @k INT = 0;
                SET @PiecesCount =
                (
                    SELECT CountCold FROM @Guides WHERE RowNumber = @i + 1
                );
                WHILE @k < @PiecesCount
                BEGIN
                    INSERT INTO @Pieces
                    SELECT Guide_Serie,
                           Guide_Number,
                           @k + 1 + @j,
                           0
                    FROM @Guides
                    WHERE RowNumber = @i + 1;
                    SET @k = @k + 1;
                END;

                SET @i = @i + 1;
            END;
        END;

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
            [IsDry]
        )
        SELECT PIC.Guide_Serie,
               PIC.Guide_Number,
               0,
               0,
               0,
               0,
               0,
               NULL,
               'GTQ',
               0,
               GETDATE(),
               NULL,
               NULL,
               NULL,
               NULL,
               PIC.PartNumber,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               1,
               PIC.IsDry
        FROM @Pieces PIC
            INNER JOIN #GuideTable GTB
                ON PIC.Guide_Serie = GTB.Guide_Serie
                   AND PIC.Guide_Number = GTB.Guide_Number;


        DECLARE @idcustomer INT =
                (
                    SELECT TOP 1
                           CustomerID
                    FROM #GuideTable
                        INNER JOIN dbo.VisitPointClient
                            ON CodeOfReference = Sender_ID
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

                PRINT '************************revalue**********************';
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
                                                                        @CodeApp = '',
                                                                        @Format = 'Non',
                                                                        @CalculateTaxes = 'true',
                                                                        @IdModule = 33,
                                                                        @SetUpdate = 'true',
                                                                        @Token = 'SetServiceRequest',
                                                                        @IsReturn = 'false';
                SET @count = @count + 1;


            END;
        END;
		SET @GuidePriority = (SELECT COUNT (do.Guide_Number) FROM DeliveryOrder do
		INNER JOIN @CorrelativeTable ct
		ON do.Guide_Number = ct.Guide_Number
		INNER JOIN Membership mb
		ON do.IdCustomer = mb.CustomerId
		WHERE mb.CatMembershipStatusId = 3
		AND mb.ExpirationDate >= GETDATE()
		AND mb.RowStatus = 1)

        DROP TABLE #GuideTable;

    --END
    END TRY
    BEGIN CATCH
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               ERROR_LINE() AS [ErrorLine];
        ROLLBACK TRANSACTION;
    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        COMMIT TRANSACTION;

		DECLARE @IDCatBusinessB2B INT = (SELECT IdBusinessSegment FROM DBO.CatBusinessSegment WHERE BusinessSegmentName='B2B');


        SELECT 1 AS 'StatusCode',
               'Registros guardados correctamente' AS 'Description',
               --@IdTransaction AS 'NumTransferID'
               @ManifestNumber AS 'NumTransferID';
        SELECT Manifest_Serie AS 'ManifestSerie',
               Manifest_Number AS 'ManifestNumber'
        FROM ServiceRequest WITH (NOLOCK)
        WHERE Manifest_Serie = @ManifestSerie
              AND Manifest_Number = @ManifestNumber;

        SELECT C.[Row_Number] AS 'RowNumber',
               D.Guide_Serie AS 'GuideSerie',
               D.Guide_Number AS 'GuideNumber',
               (
                   SELECT HubAbbreviation
                   FROM [DeliveryBackOffice].[dbo].[HubLogistics]
                   WHERE IdHubLogistic = D.HubOriginId
               ) AS 'HubOrigin',
               (
                   SELECT HubAbbreviation
                   FROM [DeliveryBackOffice].[dbo].[HubLogistics]
                   WHERE IdHubLogistic = D.HubDestinationId
               ) AS 'HubDestination',
               -- MODIFICACION 16/02/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
               (
                   SELECT DeliveryBackOffice.dbo.FnGetCustomerAttempts(D.Sender_ID, D.IdCustomer)
               ) AS 'Attempts',
			   (CASE 
					WHEN MMBSHP.IdMembership IS NOT NULL THEN 'F'
					WHEN ctm.BusinessSegmentID = @IDCatBusinessB2B THEN 'B' 
					ELSE 'E'
					END) 'Priority',

			  -- IIF(D.SalePipeLineId=@IDCatBusinessB2B,'P','E') 'Priority',
			   CONCAT('https://qa.forzadelivery.com/rastreo/',D.Guide_Serie,D.Guide_Number)'QRLink',
			   (CASE
					WHEN 
						(D.IsCollect <> 1 AND D.Collect_OnDelivery>0 )
						or ctm.Abbreviation IN ('IGSS','RENAP')

					THEN
						'D'
					ELSE
						''
					END
				)'Icon'
        --FIN MODIFICACIÓN
        FROM DeliveryOrder D WITH (NOLOCK)
            INNER JOIN @CorrelativeTable C
                ON C.Guide_Number = D.Guide_Number
				AND D.Guide_Serie = @GuideSerie
			LEFT JOIN DeliveryBackOffice.dbo.Customer ctm WITH (NOLOCK)
				ON ctm.IdCustomer = D.IdCustomer
			LEFT JOIN DeliveryBackOffice.dbo.Membership MMBSHP WITH(NOLOCK)
				ON MMBSHP.CustomerId = ctm.IdCustomer
				AND MMBSHP.CatMembershipStatusId = @StatusPackage
			    AND MMBSHP.ExpirationDate >= GETDATE()
				AND MMBSHP.RowStatus = 1
        WHERE D.Guide_Serie = @GuideSerie
              AND D.Guide_Number IN
                  (
                      SELECT CT.Guide_Number FROM @CorrelativeTable CT
                  );
    END;
END;

