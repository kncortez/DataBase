
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================

-- =============================================
-- Modiff:		<Hugo,Gomez>
-- Create date: <2021-05-13>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================

-- =============================================
-- Modiff:		<Marco,Jiménez>
-- Create date: <2021-09-16>
-- Description:	<Se agregan validaciones para no cobrar el servicio ni COD en la courierapp cuando la entrega sea en un Express Center>
-- Hotfix: FDAPI-337
-- =============================================

-- =============================================
-- Modiff:		<Andres,Ruiz>
-- Create date: <2021-12-13>
-- Description:	< Adición de campos para alertas de servicios >
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_daily_route]
    @Token VARCHAR(200) = '',
    @IdCourier BIGINT,
    @DateRoute DATE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @jsonResult NVARCHAR(MAX);
    DECLARE @jsonResult2 NVARCHAR(MAX);
    DECLARE @jsonResult3 NVARCHAR(MAX);
    DECLARE @jsonResultErrror NVARCHAR(MAX);

    DECLARE @jsonToken NVARCHAR(MAX);
    DECLARE @TokenAct INT = 1; 
    DECLARE @hourtoken INT = 5; 
    DECLARE @IdDeliveryOption AS INT; --FDAPI-337

    -- PARA VALIDAR TIPO DE SERVICIO PARA ALERTAS
    DECLARE @PickUpTypeId BIGINT =
            (
                SELECT TOP 1
                       STSM.IdSubTypeServiceManagment
                FROM [DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH (NOLOCK)
                WHERE STSM.Name = 'Recolección' COLLATE Latin1_General_CI_AI
            );
    DECLARE @DeliveryTypeId BIGINT =
            (
                SELECT TOP 1
                       STSM.IdSubTypeServiceManagment
                FROM [DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH (NOLOCK)
                WHERE STSM.Name = 'Entrega' COLLATE Latin1_General_CI_AI
            );
    DECLARE @ReturnTypeId BIGINT =
            (
                SELECT TOP 1
                       STSM.IdSubTypeServiceManagment
                FROM [DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH (NOLOCK)
                WHERE STSM.Name = 'Devolución' COLLATE Latin1_General_CI_AI
            );

    --Flujo Recolecciones
    IF OBJECT_ID('tempdb.dbo.#TmpAlertList', 'U') IS NOT NULL
        DROP TABLE #TmpAlertList;

    CREATE TABLE #TmpAlertList
    (
        AlertDescription NVARCHAR(500),
        AlertTypeId INT,
        DateCreated DATETIME,
        SchedulePickupId BIGINT
    );
    CREATE NONCLUSTERED INDEX tempSCheduledpickupid ON #TmpAlertList (SchedulePickupId);


    INSERT INTO #TmpAlertList
    (
        AlertDescription,
        AlertTypeId,
        DateCreated,
        SchedulePickupId
    )
	SELECT DOA.AlertDescription,
           DOA.AlertTypeId,
           DOA.DateCreated,
           SP.SchedulePickupId 
    FROM [DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.ServiceManagement SMA WITH (NOLOCK)
            ON SMA.IdSchedulePickup = SP.SchedulePickupId
        INNER JOIN dbo.RouteAssigment ROA WITH (NOLOCK)
            ON ROA.IdCurrierMan = SMA.IdPuCourrier
               AND ROA.IdRouteAssigment = SMA.IdPuRouteAssigment
               AND ROA.DateOfRoute = @DateRoute
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
            ON SP.SchedulePickupId = DOPD.IdHeaderRecolection
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA WITH (NOLOCK)
            ON DOPD.GuideSerie = DOA.GuideSerie
               AND DOPD.GuideNumber = DOA.GuideNumber
               AND DOA.ServiceTypeId = @PickUpTypeId
               AND DOA.RowStatus = 1
        INNER JOIN DeliveryBackOffice.dbo.CatRoute CAR WITH (NOLOCK)
            ON CAR.IdRoute = ROA.IdRoute
               AND CAR.RowStatus = 1
               AND CAR.IdTypeRoute = 1
    WHERE SMA.IdPuCourrier = @IdCourier;
    --Fin flujo recolecciones
	--Flujo nuevo devoluciones
    IF OBJECT_ID('tempdb.dbo.#GuideReturnService', 'U') IS NOT NULL
        DROP TABLE #GuideReturnService;

    CREATE TABLE #GuideReturnService
    (
        GuideSerie NVARCHAR(2),
        GuideNumber INT
    );
    CREATE NONCLUSTERED INDEX IDX_TMP_GuideReturnService_Guide ON #GuideReturnService (GuideSerie, GuideNumber);

    INSERT INTO #GuideReturnService
    (
        GuideSerie,
        GuideNumber
    )
	SELECT 
		DISTINCT
			DAT.Guide_Serie,
			DAT.Guide_Number
    FROM 
		(
			SELECT DISTINCT
					Guide_Serie,
					Guide_Number,
					ID_Courier
			FROM dbo.DeliveryAttempt WITH (NOLOCK)
			WHERE CAST(Date_Created AS DATE) = CAST(@DateRoute AS DATE)
		) DAT
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
            ON DAT.Guide_Serie = DOR.Guide_Serie
                AND DAT.Guide_Number = DOR.Guide_Number
				AND DOR.IsLastMileReturn = 1
                AND DOR.StatusOrderId IN ( 4, 5, 14, 12, 20, 25, 45 ) --En ruta|entregado|Intento de entrega fallida(incidencia)|Devolución
        INNER JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail DSD WITH (NOLOCK)
            ON DSD.Guide_Serie = DAT.Guide_Serie
                AND DSD.Guide_Number = DAT.Guide_Number
                AND DSD.RowStatus = 1
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOS WITH (NOLOCK)
            ON DOS.ID = DSD.ID_DeliveryOrderBySettlement
                AND DOS.ID_Courier = DAT.ID_Courier
    WHERE DAT.ID_Courier = @IdCourier

    DECLARE @ConcatReturnGuides NVARCHAR(MAX) = (
        SELECT STUFF
		(
            (
                SELECT ',' + CONCAT(GuideSerie, GuideNumber)
                FROM #GuideReturnService
                FOR XML PATH('')
            ),
            1,
            1,
            ''
        )
    );

    DECLARE @TempReturnPrice AS TABLE
    (
        GuideSerie NVARCHAR(25) NULL,
        GuideNumber NVARCHAR(25) NULL,
        IsCollect NVARCHAR(25) NULL,
        Price DECIMAL(14, 2) NULL,
        COD DECIMAL(14, 2) NULL,
        AmountPaid DECIMAL(14, 2) NULL,
        CODPaid DECIMAL(14, 2) NULL,
        CODIsPaid DECIMAL(14, 2) NULL,
        PaymentTime INT NULL,
        TimeSequence INT NULL,
        FelNumber NVARCHAR(50) NULL,
        IsPaid INT NULL,
        IsCustomer INT NULL,
        ConditionPayment NVARCHAR(200) NULL,
        HaveCredit NVARCHAR(50) NULL,
        CollectCOD NVARCHAR(50) NULL,
        ReturnRate DECIMAL(14, 2) NULL,
        AmountToPay DECIMAL(14, 2) NULL,
        CODAmount DECIMAL(14, 2) NULL,
        ReturnRates DECIMAL(14, 2) NULL
    );
    INSERT INTO @TempReturnPrice
    (
        GuideSerie,
        GuideNumber,
        IsCollect,
        Price,
        COD,
        AmountPaid,
        CODPaid,
        CODIsPaid,
        PaymentTime,
        TimeSequence,
        FelNumber,
        IsPaid,
        IsCustomer,
        ConditionPayment,
        HaveCredit,
        CollectCOD,
        ReturnRate,
        AmountToPay,
        CODAmount,
        ReturnRates
    )
    EXEC [dbo].[spws_get_guide_pending_payment] @InGuides = @ConcatReturnGuides,		-- Guías
                                                @InTime = 3,							-- Entrega
                                                @IsReturn = 1,							-- Devolución
                                                @CodeApp = 'SIFDCECOM300720201459',		-- CodeApp
                                                @IdModule = 1,
                                                @Token = @Token;
		
	IF OBJECT_ID('tempdb.dbo.#GuideReturnService', 'U') IS NOT NULL
		DROP TABLE #GuideReturnService;

	--Fin flujo devoluciones

	PRINT 'validando token'

    IF (@TokenAct = 1 AND @hourtoken <= 8)
    BEGIN

        SET @IdDeliveryOption =
        (
            SELECT IdDeliveryOption
            FROM dbo.CatDeliveryOptions WITH (NOLOCK)
            WHERE Name = 'Express Center'
        ); --FDAPI-337

		PRINT 'construyendo json result'
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',
									{									
                                    "ServiceType":"' + 'Pickup' + '",' + '"CodeOfReference":"'
                                       + CONVERT(VARCHAR, ISNULL(vpc.CodeOfReference, 0)) + '",' + '"Id":"'
                                       + ISNULL(CONVERT(VARCHAR, spk.SchedulePickupId), '-1') + '",'
                                       + '"ServiceManagementId":"'
                                       + ISNULL(CONVERT(VARCHAR, sma.IdServiceManagement), 'N/A') + '",'
                                       + '"ServicePaymentTime":"' + CONVERT(VARCHAR, ISNULL(cpt.TimePlaName, 'N/A'))
                                       + '",' + '"Sender":"'
                                       + ISNULL(ISNULL(spk.SenderName, vpc.DescriptionOfClient), 'N/A') + '",'
                                       + '"Address":"'
                                       + dbo.fnt_String_Escape(
                                                                  CONCAT(
                                                                            ISNULL(
                                                                                      ISNULL(
                                                                                                REPLACE(
                                                                                                           REPLACE(
                                                                                                                      spk.AddressPickup,
                                                                                                                      CHAR(0),
                                                                                                                      ''
                                                                                                                  ),
                                                                                                           '"',
                                                                                                           ''
                                                                                                       ),
                                                                                                REPLACE(
                                                                                                           vpc.Address,
                                                                                                           '"',
                                                                                                           ''
                                                                                                       )
                                                                                            ),
                                                                                      'N/A'
                                                                                  ),
                                                                            ' ',
                                                                            vpc.Town,
                                                                            ' ',
                                                                            vpc.Department
                                                                        ),
                                                                  'json'
                                                              ) + '",' + '"Phone":"'
                                       + ISNULL(ISNULL(spk.SenderPhone, vpc.Phone), 'N/A') + '",' + '"PiecesDry":"'
                                       + CONVERT(
                                                    VARCHAR,
                                                    ISNULL(
                                                    (
                                                        SELECT IIF(SUM(ISNULL(ord.Pieces_Dry, 0)) = 0,
                                                                   (ISNULL(SUM(sc.QuantityOverDimensionedPackage), 0)
                                                                    + ISNULL(SUM(sc.QuantityRegularPackages), 0)
                                                                   ),
                                                                   SUM(ISNULL(ord.Pieces_Dry, 0))) pieces
                                                        FROM dbo.DeliveryOrderPaymentDetail pay WITH (NOLOCK)
                                                            LEFT JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
                                                                ON ord.Guide_Serie = pay.GuideSerie
                                                                   AND ord.Guide_Number = pay.GuideNumber
                                                            LEFT JOIN dbo.SchedulePickup sc WITH (NOLOCK)
                                                                ON sc.SchedulePickupId = pay.IdHeaderRecolection
                                                        WHERE pay.IdHeaderRecolection = spk.SchedulePickupId
                                                    ),
                                                    0
                                                          )
                                                ) + '",' + '"PiecesCold":"'
                                       + CONVERT(
                                                    VARCHAR,
                                                    ISNULL(
                                                    (
                                                        SELECT SUM(ISNULL(ord.Pieces_Cold, 0)) pieces
                                                        FROM dbo.DeliveryOrderPaymentDetail pay WITH (NOLOCK)
                                                            LEFT JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
                                                                ON ord.Guide_Serie = pay.GuideSerie
                                                                   AND ord.Guide_Number = pay.GuideNumber
                                                        WHERE pay.IdHeaderRecolection = spk.SchedulePickupId
                                                    ),
                                                    0
                                                          )
                                                ) + '",' + '"ScheduleStart":"'
                                       + SUBSTRING(CONVERT(VARCHAR, spk.StartDate, 8), 0, 6) + '",' + '"ScheduleEnd":"'
                                       + SUBSTRING(CONVERT(VARCHAR, ISNULL(spk.EndDate, DATEADD(HOUR, 19, CAST(CAST(spk.StartDate AS DATE) AS DATETIME))), 8), 0, 6) + '",' + '"Photo":"'
                                       + ISNULL(
                                         (
                                             SELECT TOP 1
                                                    vpi.PathImage
                                             FROM dbo.ImagesByVisitPoint vpi WITH (NOLOCK)
                                             WHERE vpi.CodeOfReference = vpc.CodeOfReference
                                             ORDER BY DateCreated DESC
                                         ),
                                         '#'
                                               ) + '",' + '"Latitude":"' + CONVERT(VARCHAR, ISNULL(vpc.Latitude, 0))
                                       + '",' + '"Longitude":"' + CONVERT(VARCHAR, ISNULL(vpc.Longitude, 0)) + '",'
                                       + '"Precision":"' + CONVERT(VARCHAR, ISNULL(vpc.Accuracy, 0)) + '",'
                                       + '"Price":"' + '0' + '",' + '"Pickup":"' + '0' + '",' + '"customerName":"'
                                       + ' ' + '",' + '"alterName":"' + ' ' + '",' + '"HighPriority":' + Convert(varchar, IIF((SELECT
															COUNT(1)
														FROM DeliveryOrderAlert doa WITH (NOLOCK)
														WHERE doa.ServiceManagementId = sma.IdServiceManagement
														AND doa.RowStatus = 1)
													> 0, 'true','false'))+ ',' + 
									
									'"Alerts":[' + IIF((SELECT
															COUNT(1)
														FROM DeliveryOrderAlert doa WITH (NOLOCK)
														WHERE doa.ServiceManagementId = sma.IdServiceManagement
														AND doa.RowStatus = 1)
													> 0, (SELECT
															STUFF((SELECT TOP 1
																	',{"TypeAlert":' + CONVERT(VARCHAR, doa.AlertTypeId) + ',' +
																	'"DescriptionAlert":"' + dbo.fnt_String_Escape(dbo.fn_replace_special_characters(doa.AlertDescription), 'json') + '",' +
																	'"DateCreated":"' + (CONVERT(VARCHAR, doa.DateCreated, 24)) + ' - ' + (CONVERT(VARCHAR, doa.DateCreated, 103)) + '"}'
																FROM DeliveryOrderAlert doa WITH (NOLOCK)
																WHERE doa.ServiceManagementId = sma.IdServiceManagement
																AND doa.RowStatus = 1
																ORDER BY DOA.DateCreated DESC
																FOR XML PATH (''))
															, 1, 1, ''))
													, '') 
										+
									'],' + '"Status":"'
                                       + CONVERT(VARCHAR, ISNULL(sma.ServiceStatusId, 1)) + +'"}'
                                FROM dbo.RouteAssigment ras WITH (NOLOCK)
                                    LEFT JOIN dbo.ServiceManagement sma WITH (NOLOCK)
                                        ON sma.IdPuRouteAssigment = ras.IdRouteAssigment
                                    LEFT JOIN dbo.SchedulePickup spk WITH (NOLOCK)
                                        ON spk.SchedulePickupId = sma.IdSchedulePickup
                                    LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
                                        ON vpc.CodeOfReference = spk.SenderId
                                    LEFT JOIN dbo.CatPaymentTime cpt WITH (NOLOCK)
                                        ON sma.CatPaymentTimeId = cpt.TimePlaId
                                WHERE ras.IdCurrierMan = @IdCourier
                                      AND 
									  (ras.DateOfRoute = @DateRoute
									 --- OR ras.DateOfRoute = '2023-06-25'
									  )

                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
        IF OBJECT_ID('tempdb.dbo.#TmpAlertList', 'U') IS NOT NULL
            DROP TABLE #TmpAlertList;


		PRINT 'construyendo jrsult 2'
        SET @jsonResult2 =
        (
            SELECT STUFF(
                            (
                                SELECT JDRS2.JsonDataRow
                                FROM
                                (
                                    SELECT DISTINCT
                                           JDRS.JsonDataRow,
                                           MIN(ISNULL(JDRS.ShownOrder, 999)) topOrder
                                    FROM
                                    (
                                        SELECT TOP 100 PERCENT
                                               REPLACE(
                                                          ',
									{									
                                    "ServiceType":"'
                                                          + 'Delivery' + '",' + '"CodeOfReference":"'
                                                          + CONVERT(VARCHAR, ISNULL(VPr.CodeOfReference, 0)) + '",'
														  + '"DeliveryOption":"' 
														  + CONVERT( VARCHAR,ISNULL((CASE WHEN ISNULL([DOR].[IsLastMileReturn], 0) = 0 THEN DOR.IdDeliveryOption ELSE 1 END),0))  + '",' +
														  + '"IsLastMileReturn":"' 
														  + CONVERT( VARCHAR,ISNULL([DOR].[IsLastMileReturn],0))  + '",' +
                                                          + '"Id":"'
                                                          + ISNULL(
                                                                      CONVERT(
                                                                                 VARCHAR,
                                                                                 DOR.Guide_Serie
                                                                                 + CONVERT(VARCHAR, DOR.Guide_Number)
                                                                             ),
                                                                      '-1'
                                                                  ) + '",' + '"ServiceManagementId":"'
                                                          + ISNULL(CONVERT(VARCHAR, 0), 'N/A') + '",' + '"Sender":"'
                                                          + ISNULL(
                                                                      ISNULL(
                                                                                COALESCE(
                                                                                            dbo.fn_ReplaceSpecialCharsForJSON(IIF(dor.IsLastMileReturn = 1, dor.Receiver_FirstName, DOR.Sender_FirstName)),
                                                                                            ''
                                                                                        ) + ' '
                                                                                + COALESCE(
                                                                                              dbo.fn_ReplaceSpecialCharsForJSON(IIF(dor.IsLastMileReturn = 1, dor.Receiver_FirstName, DOR.Sender_FirstName)),
                                                                                              ''
                                                                                          ),
                                                                                dbo.fn_ReplaceSpecialCharsForJSON(VPC.DescriptionOfClient)
                                                                            ),
                                                                      'N/A'
                                                                  ) + '",' 
														  + '"SenderPhone":"' + 
														  (
															CASE
																WHEN ISNULL([DOR].[IsLastMileReturn], 0) = 0 THEN [DOR].[Sender_Phone]
																ELSE ''
															END
														  )
														  + '",'
														  + '"Address":"'
                                                          + IIF(kvp.KindOfVPName = 'Express Center',
                                                                ISNULL(dbo.fn_ReplaceSpecialCharsForJSON(VPr.Address), ''),
                                                                dbo.fnt_String_Escape(/*concat(*/
                                                                                         ISNULL(ISNULL(REPLACE(dbo.fn_ReplaceSpecialCharsForJSON(IIF(dor.IsLastMileReturn = 1, dor.Sender_Address, DOR.Receiver_Address)), '"', ''), REPLACE(dbo.fn_ReplaceSpecialCharsForJSON(IIF(dor.IsLastMileReturn = 1, VPC.Address, VPr.Address)), '"', '')), 'N/A'), /*, ' ' , vpc.Town , ' ' , vpc.Department)*/
                                                                                         'json'
                                                                                     )) + '",' 
														  + '"SenderPhone":"' + 
														  (
															CASE
																WHEN ISNULL([DOR].[IsLastMileReturn], 0) = 0 THEN [DOR].[Sender_Phone]
																ELSE ''
															END
														  )
														  + '",'
														  + '"Phone":"'
                                                          + ISNULL(
																	IIF(
																		DOR.IsLastMileReturn = 1,
																		  ISNULL(
																					DOR.Sender_Phone,
																					'N/A'
																				),
																		  ISNULL(
																					DOR.Receiver_Phone,
																					DOR.Receiver_Alternant_Phone
																				)
																		),
                                                                      'N/A'
                                                                  ) + '",' + '"PiecesDry":"'
                                                          + CONVERT(
                                                                       VARCHAR,
                                                                       ISNULL(
                                                                       (
                                                                           SELECT (SUM(ISNULL(DOR2.Pieces_Dry, 0))) pieces
                                                                           FROM DeliveryBackOffice.dbo.DeliveryOrder DOR2 WITH (NOLOCK)
                                                                           WHERE DOR2.Guide_Serie = DAT.Guide_Serie
                                                                                 AND DOR2.Guide_Number = DAT.Guide_Number
                                                                       ),
                                                                       0
                                                                             )
                                                                   ) + '",' + '"PiecesCold":"'
                                                          + CONVERT(
                                                                       VARCHAR,
                                                                       ISNULL(
                                                                       (
                                                                           SELECT (SUM(ISNULL(DOR2.Pieces_Cold, 0))) pieces
                                                                           FROM DeliveryBackOffice.dbo.DeliveryOrder DOR2 WITH (NOLOCK)
                                                                           WHERE DOR2.Guide_Serie = DAT.Guide_Serie
                                                                                 AND DOR2.Guide_Number = DAT.Guide_Number
                                                                       ),
                                                                       0
                                                                             )
                                                                   ) + '",' + '"ScheduleStart":"' + '' + '",'
                                                          + '"ScheduleEnd":"' + '' + '",' + '"Photo":"'
                                                          + ISNULL(
                                                            (
                                                                SELECT TOP 1
                                                                       vpi.PathImage
                                                                FROM dbo.ImagesByVisitPoint vpi WITH (NOLOCK)
                                                                WHERE vpi.CodeOfReference = VPC.CodeOfReference
                                                                ORDER BY DateCreated DESC
                                                            ),
                                                            '#'
                                                                  ) + '",' + '"Latitude":"'
                                                          + CONVERT(
                                                                       VARCHAR,
                                                                       (CASE
																	        WHEN ISNULL(DOR.Receiver_Lat, '0') <> '' THEN
																			      ISNULL(DOR.Receiver_Lat, '0')
                                                                            WHEN ISNULL(SDFG.Latitude, 0) != 0
                                                                                 AND ISNULL(SDFG.Longitude, 0) != 0 THEN
                                                                                CONVERT(VARCHAR, ISNULL(SDFG.Latitude, 0))
                                                                            WHEN ISNULL(EPS.Latitude, 0) != 0
                                                                                 AND ISNULL(EPS.Longitude, 0) != 0 THEN
                                                                                CONVERT(VARCHAR, ISNULL(EPS.Latitude, 0))
                                                                            WHEN ISNULL(VPC.Longitude, '0') <> '' AND DOR.IsLastMileReturn = 1 THEN
                                                                                ISNULL(VPC.Longitude, '0')
                                                                            WHEN ISNULL(VPr.Latitude, '0') <> '' AND DOR.IsLastMileReturn = 0 THEN
                                                                                ISNULL(VPr.Latitude, '0')
                                                                            ELSE
                                                                                '0'
                                                                        END
                                                                       )
                                                                   ) + '",' + '"Longitude":"'
                                                          + CONVERT(
                                                                       VARCHAR,
                                                                       (CASE
																	        WHEN ISNULL(DOR.Receiver_Lng, '0') <> '' THEN
																			      ISNULL(DOR.Receiver_Lng, '0')
                                                                            WHEN ISNULL(SDFG.Latitude, 0) != 0
                                                                                 AND ISNULL(SDFG.Longitude, 0) != 0 THEN
                                                                                CONVERT(VARCHAR, ISNULL(SDFG.Longitude, 0))
                                                                            WHEN ISNULL(EPS.Latitude, 0) != 0
                                                                                 AND ISNULL(EPS.Longitude, 0) != 0 THEN
                                                                                CONVERT(VARCHAR, ISNULL(EPS.Longitude, 0))
                                                                            WHEN ISNULL(VPC.Longitude, '0') <> '' AND DOR.IsLastMileReturn = 1 THEN
                                                                                ISNULL(VPC.Longitude, '0')
                                                                            WHEN ISNULL(VPr.Longitude, '0') <> '' AND DOR.IsLastMileReturn = 0 THEN
                                                                                ISNULL(VPr.Longitude, '0')
                                                                            ELSE
                                                                                '0'
                                                                        END
                                                                       )
                                                                   ) + '",'
                                                          + IIF(
                                                         ISNULL(SDFG.Latitude, 0) != 0 AND ISNULL(SDFG.Longitude, 0) != 0,
                                                             '"LocationConfirmed":1,',
                                                             '') + '"Precision":"'
                                                          + CONVERT(VARCHAR, ISNULL(VPC.Accuracy, 0)) + '",'
                                                          + CASE
                                                                WHEN DOR.IdDeliveryOption = @IdDeliveryOption THEN
                                                                    '"Price_COD":"0",'
                                                                ELSE
                                                                    '"Price_COD":"'
                                                                    + IIF(kvp.KindOfVPName = 'Express Center',
                                                                       '0',
                                                                       CONVERT(
                                                                              VARCHAR,
                                                                              IIF(dor.IsLastMileReturn = 1, 0, ISNULL(DOR.Collect_OnDelivery, 0))
                                                                              )) + '",'
                                                            END
                                                          + CASE
                                                                WHEN DOR.IdDeliveryOption = @IdDeliveryOption THEN
                                                                    '"Price":"0",'
                                                                ELSE
                                                                    '"Price":"'
                                                                    + IIF(kvp.KindOfVPName = 'Express Center',
                                                                          '0',
                                                                          CONVERT(
                                                                                     VARCHAR,
																					 IIF(
																						DOR.IsLastMileReturn = 1,
																						TRPreturns.AmountToPay,
																						 IIF(ISNULL(DOR.IsCollect, 0) = 1,
																						  ISNULL(DOR.PriceShippment, 0),
																						  0)
                                                                                 ))) + '",'
                                                            END
                                                          + CASE
                                                                WHEN DOR.IdDeliveryOption = @IdDeliveryOption THEN
                                                                    '"Pickup":"0",'
                                                                ELSE
                                                                    '"Pickup":"'
                                                                    + CONVERT(
                                                                                 VARCHAR,
                                                                                 ISNULL(
                                                                                 (
                                                                                     SELECT TOP 1
                                                                                            IIF(ISNULL(dp.TimePlaId, 0) = 3,
                                                                                          sc.AmountPickup,
                                                                                          0)
                                                                                     FROM dbo.DeliveryOrderPaymentDetail dp WITH (NOLOCK)
                                                                                         LEFT JOIN dbo.SchedulePickup sc WITH (NOLOCK)
                                                                                             ON sc.SchedulePickupId = dp.IdHeaderRecolection
                                                                                     WHERE dp.GuideNumber = DOR.Guide_Number
                                                                                           AND dp.GuideSerie = DOR.Guide_Serie
                                                                                 ),
                                                                                 0
                                                                                       )
                                                                             ) + '",'
                                                            END + '"customerName":"'
                                                          + IIF(DOR.IsLastMileReturn = 1,
															  IIF(kvpori.KindOfVPName = 'Express Center',
																	ISNULL(
																			  dbo.fn_ReplaceSpecialCharsForJSON(VPC.DescriptionOfClient),
																			  ''
																		  ),
																	ISNULL(
																			  REPLACE(
																						 dbo.fn_ReplaceSpecialCharsForJSON(DOR.Sender_FirstName),
																						 '"',
																						 ''
																					 ),
																			  'N/A'
																		  )),
															IIF(kvp.KindOfVPName = 'Express Center',
                                                                ISNULL(
                                                                          dbo.fn_ReplaceSpecialCharsForJSON(VPr.DescriptionOfClient),
                                                                          ''
                                                                      ),
                                                                ISNULL(
                                                                          REPLACE(
                                                                                     dbo.fn_ReplaceSpecialCharsForJSON(DOR.Receiver_FirstName),
                                                                                     '"',
                                                                                     ''
                                                                                 ),
                                                                          'N/A'
                                                                      ))) + '",' + '"alterName":"'
                                                          + IIF(DOR.IsLastMileReturn = 1 , 'N/A',ISNULL(
                                                                      ISNULL(
                                                                                REPLACE(
                                                                                           dbo.fn_ReplaceSpecialCharsForJSON(DOR.Receiver_Alternant_FullName),
                                                                                           '"',
                                                                                           ''
                                                                                       ),
                                                                                REPLACE(
                                                                                           dbo.fn_ReplaceSpecialCharsForJSON(DOR.Receiver_FirstName),
                                                                                           '"',
                                                                                           ''
                                                                                       )
                                                                            ),
                                                                      'N/A'
                                                                  )) + '",'+ '"NumImageEvidence":"'
                                                          + CONVERT(VARCHAR,(IIF((SELECT NumImgEvidence as num FROM Customer WITH (NOLOCK) WHERE IdCustomer = DOR.IdCustomer)IS NOT NULL,(SELECT NumImgEvidence as num FROM Customer WHERE IdCustomer = DOR.IdCustomer),1)))+ '",' + '"Status":"'
                                                          + CONVERT(VARCHAR,ISNULL(CASE WHEN DOR.StatusOrderId = 45 THEN 12 ELSE DOR.StatusOrderId END,4)) + '"'
                                                          + IIF((doadel.GuideNumber IS NOT NULL AND DOR.IsLastMileReturn = 0) OR (doaret.GuideNumber IS NOT NULL AND DOR.IsLastMileReturn = 1) ,
                                                                ',"HighPriority":'
                                                                + CONVERT(
                                                                             VARCHAR,
                                                                             IIF(
                                                                                (
                                                                                    SELECT ISNULL(
                                                                                                     COUNT(doa.GuideNumber),
                                                                                                     0
                                                                                                 )
                                                                                    FROM DeliveryOrderAlert doa WITH (NOLOCK)
                                                                                    WHERE doa.GuideNumber = DOR.Guide_Number
                                                                                          AND doa.GuideSerie = DOR.Guide_Serie
                                                                                          AND doa.RowStatus = 1
                                                                                          AND doa.ServiceTypeId = IIF(DOR.IsLastMileReturn = 1, @ReturnTypeId, @DeliveryTypeId)
                                                                                ) > 0,
                                                                                'true',
                                                                                'false')
                                                                         ) + ',' + '"Alerts": [ '
                                                                +
                                                                (
                                                                    SELECT STUFF(
                                                                           (
                                                                               SELECT TOP 1
                                                                                      ' { "TypeAlert": '
                                                                                      + CONVERT(VARCHAR, doa.AlertTypeId)
                                                                                      + ', ' + '"DescriptionAlert": "'
                                                                                      + dbo.fnt_String_Escape(
                                                                                                                 dbo.fn_replace_special_characters(doa.AlertDescription),
                                                                                                                 'json'
                                                                                                             ) + '", '
                                                                                      + '"DateCreated": "'
                                                                                      +
                                                                                      (
                                                                                          SELECT TOP 1 CONVERT(
                                                                                                        VARCHAR,
                                                                                                        doa.DateCreated,
                                                                                                        24
                                                                                                        )
                                                                                      ) + ' - '
                                                                                      +
                                                                                      (
                                                                                          SELECT TOP 1 CONVERT(
                                                                                                        VARCHAR,
                                                                                                        doa.DateCreated,
                                                                                                        103
                                                                                                        )
                                                                                      ) + '" }, '
                                                                               FROM DeliveryOrderAlert doa WITH (NOLOCK)
                                                                               WHERE doa.GuideNumber = DOR.Guide_Number
                                                                                     AND doa.GuideSerie = DOR.Guide_Serie
                                                                                     AND doa.RowStatus = 1
                                                                                     AND doa.ServiceTypeId = IIF(DOR.IsLastMileReturn = 1, @ReturnTypeId, @DeliveryTypeId)
                                                                               ORDER BY doa.DateCreated DESC
                                                                               FOR XML PATH('')
                                                                           ),
                                                                           1,
                                                                           1,
                                                                           ''
                                                                                )
                                                                ) + '],',
                                                                '') + '}',
                                                          CHAR(31),
                                                          ''
                                                      ) JsonDataRow,
                                               ISNULL(DSD.GuideOrder, 999) 'ShownOrder'
                                        FROM
                                        (
                                            SELECT DISTINCT
                                                   Guide_Serie,
                                                   Guide_Number,
                                                   ID_Courier
                                            FROM dbo.DeliveryAttempt WITH (NOLOCK)
                                            WHERE CAST(Date_Created AS DATE) = CAST(@DateRoute AS DATE)
                                        ) DAT
                                            INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
                                                ON DAT.Guide_Serie = DOR.Guide_Serie
                                                   AND DAT.Guide_Number = DOR.Guide_Number
                                                   AND DOR.StatusOrderId IN ( 4, 5, 14, 12, 20, 25, 45, 48, 32 ) --En ruta|entregado|Intento de entrega fallida(incidencia)|Devolución
                                            INNER JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail DSD WITH (NOLOCK)
                                                ON DSD.Guide_Serie = DAT.Guide_Serie
                                                   AND DSD.Guide_Number = DAT.Guide_Number
                                                   AND DSD.RowStatus = 1
                                            INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOS WITH (NOLOCK)
                                                ON DOS.ID = DSD.ID_DeliveryOrderBySettlement
                                                   AND DOS.ID_Courier = DAT.ID_Courier
											LEFT JOIN @TempReturnPrice TRPreturns
												ON DOR.Guide_Serie = TRPreturns.GuideSerie
												AND DOR.Guide_Number = TRPreturns.GuideNumber
                                            LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
                                                ON VPC.CodeOfReference = DOR.Sender_ID
                                            LEFT JOIN
                                            (
                                                SELECT EPSA.GuideSerie,
                                                       EPSA.GuideNumber,
                                                       EPS.Latitude,
                                                       EPS.Longitude
                                                FROM DeliveryBackOffice.dbo.ExtPlatformService EPS WITH (NOLOCK)
                                                    INNER JOIN
                                                    (
                                                        SELECT EPSRWG.GuideSerie,
                                                               EPSRWG.GuideNumber,
                                                               MAX(EPS.IdService) 'LastService'
                                                        FROM DeliveryBackOffice.dbo.ExtPlatServiceRelationshipWithGuide EPSRWG WITH (NOLOCK)
                                                            LEFT JOIN DeliveryBackOffice.dbo.ExtPlatformService EPS WITH (NOLOCK)
                                                                ON EPSRWG.ExtPlatServiceId = EPS.IdExtPlatformService
                                                        GROUP BY EPSRWG.GuideSerie,
                                                                 EPSRWG.GuideNumber
                                                    ) EPSA
                                                        ON EPS.IdService = EPSA.LastService
                                                WHERE CAST(EPS.EstimatedTimeArrival AS DATE) = CAST(@DateRoute AS DATE)
                                            ) EPS
                                                ON DAT.Guide_Serie = EPS.GuideSerie
                                                   AND DAT.Guide_Number = EPS.GuideNumber
                                            LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPr WITH (NOLOCK)
                                                ON VPr.CodeOfReference = DOR.Receiver_ID
                                            LEFT JOIN dbo.KindOfVPClient kvpori WITH (NOLOCK)
                                                ON kvpori.IdKindOfVPClient = VPC.IdKindOfVPClient
                                            LEFT JOIN dbo.KindOfVPClient kvp WITH (NOLOCK)
                                                ON kvp.IdKindOfVPClient = VPr.IdKindOfVPClient
                                            LEFT JOIN dbo.DeliveryOrderAlert doadel WITH (NOLOCK)
                                                ON doadel.GuideNumber = DAT.Guide_Number
                                                   AND doadel.GuideSerie = DAT.Guide_Serie
                                                   AND doadel.RowStatus = 1
                                                   AND doadel.ServiceTypeId = @DeliveryTypeId
                                            LEFT JOIN dbo.DeliveryOrderAlert doaret WITH (NOLOCK)
                                                ON doaret.GuideNumber = DAT.Guide_Number
                                                   AND doaret.GuideSerie = DAT.Guide_Serie
                                                   AND doaret.RowStatus = 1
                                                   AND doaret.ServiceTypeId = @ReturnTypeId
											OUTER APPLY (
												SELECT
													MAX(ISNULL(SDFG.Latitude, 0)) 'Latitude',
													MAX(ISNULL(SDFG.Longitude, 0)) 'Longitude'
												FROM
													DeliveryBackOffice.dbo.ServiceDataForGuide SDFG WITH (NOLOCK)
												WHERE DOR.Guide_Serie = SDFG.GuideSerie
                                                   AND DOR.Guide_Number = SDFG.GuideNumber
                                                   AND SDFG.IsDelivery = 1
												GROUP BY
													SDFG.GuideSerie
													,SDFG.GuideNumber
											) SDFG
                                        WHERE DAT.ID_Courier = @IdCourier
                                        ORDER BY ISNULL('ShownOrder', 999) ASC
                                    ) JDRS
                                    GROUP BY JDRS.JsonDataRow
                                ) JDRS2
                                ORDER BY topOrder ASC
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
        
		PRINT 'construido jrsult 2'
		PRINT CONCAT('@jsonResult2', @jsonResult2);
		
        -------------------------------Start Sumary, ListGuides Return----------------------------------------------

        IF OBJECT_ID('tempdb.dbo.#GuideService', 'U') IS NOT NULL
            DROP TABLE #GuideService;

        CREATE TABLE #GuideService
        (
            IdServiceManagement INT,
            GuideSerie NVARCHAR(2),
            GuideNumber INT,
            ServiceStatusId INT,
            IdPuCourrier INT
        );
        CREATE NONCLUSTERED INDEX tempSerie ON #GuideService (GuideSerie, GuideNumber);

        INSERT INTO #GuideService
        (
            IdServiceManagement,
            GuideSerie,
            GuideNumber,
            ServiceStatusId,
            IdPuCourrier
        )
		SELECT SMG.IdServiceManagement,
               dpc.GuideSerie,
               dpc.GuideNumber,
               SMG.ServiceStatusId,
               @IdCourier IdPuCourrier
        FROM dbo.SettlementByPickup stp WITH (NOLOCK)
            INNER JOIN dbo.SettlementByPickupDetail std WITH (NOLOCK)
                ON std.SettlementByPickupId = stp.Id
            INNER JOIN dbo.DeliveryOrderPiece dpc WITH (NOLOCK)
                ON dpc.GuideSerie = std.GuideSerie
                   AND dpc.GuideNumber = std.GuideNumber
            INNER JOIN dbo.PieceByService pbs WITH (NOLOCK)
                ON pbs.GuidePieceId = dpc.GuidePiece
            INNER JOIN dbo.ServiceManagement SMG WITH (NOLOCK)
                ON SMG.IdServiceManagement = pbs.ServiceManagmentId
        WHERE stp.IdCourier = @IdCourier
              AND CONVERT(DATE, stp.DateCreated) = CONVERT(DATE, @DateRoute)
              AND SMG.SubTypeServiceManagmentId = 3; --Solo filtro devoluciones

        DECLARE @guides NVARCHAR(MAX) =
                (
                    SELECT STUFF(
                           (
                               SELECT ',' + CONCAT(GuideSerie, GuideNumber)
                               FROM #GuideService
                               FOR XML PATH('')
                           ),
                           1,
                           1,
                           ''
                                )
                );

        PRINT CONCAT('GUIDES', @guides);

        DECLARE @Temp AS TABLE
        (
            GuideSerie NVARCHAR(25) NULL,
            GuideNumber NVARCHAR(25) NULL,
            IsCollect NVARCHAR(25) NULL,
            Price DECIMAL(14, 2) NULL,
            COD DECIMAL(14, 2) NULL,
            AmountPaid DECIMAL(14, 2) NULL,
            CODPaid DECIMAL(14, 2) NULL,
            CODIsPaid DECIMAL(14, 2) NULL,
            PaymentTime INT NULL,
            TimeSequence INT NULL,
            FelNumber NVARCHAR(50) NULL,
            IsPaid INT NULL,
            IsCustomer INT NULL,
            ConditionPayment NVARCHAR(200) NULL,
            HaveCredit NVARCHAR(50) NULL,
            CollectCOD NVARCHAR(50) NULL,
            ReturnRate DECIMAL(14, 2) NULL,
            AmountToPay DECIMAL(14, 2) NULL,
            CODAmount DECIMAL(14, 2) NULL,
            ReturnRates DECIMAL(14, 2) NULL
        );
        INSERT INTO @Temp
        (
            GuideSerie,
            GuideNumber,
            IsCollect,
            Price,
            COD,
            AmountPaid,
            CODPaid,
            CODIsPaid,
            PaymentTime,
            TimeSequence,
            FelNumber,
            IsPaid,
            IsCustomer,
            ConditionPayment,
            HaveCredit,
            CollectCOD,
            ReturnRate,
            AmountToPay,
            CODAmount,
            ReturnRates
        )
        EXEC [dbo].[spws_get_guide_pending_payment] @InGuides = @guides,
                                                    @InTime = 3,
                                                    @IsReturn = 1,
                                                    @CodeApp = 'SIFDCECOM300720201459',
                                                    @IdModule = 1,
                                                    @Token = @Token;

        PRINT 'guias devolucion';
        PRINT @guides;

        ----------------------------------End Sumary,ListGuides Return----------------------------------------------------------------------


        -------------------------Start Retuns Services ---------------------------------------------
        SET @jsonResult3 =
        (
            SELECT STUFF(
                            (
                                SELECT DISTINCT
                                       ',
									{									
                                       "ServiceType":"' + 'Return' + '",' + '"CodeOfReference":"'
                                       + CONVERT(VARCHAR, ISNULL(VPC.CodeOfReference, 0)) + '",'
                                       + '"ServiceManagementId":"'
                                       + ISNULL(CONVERT(VARCHAR, gs.IdServiceManagement, 0), 'N/A') + '",' + '"Sender":"'
                                       + ISNULL(
                                                   ISNULL(
                                                             COALESCE(
                                                                         dbo.fn_ReplaceSpecialCharsForJSON(do.Sender_FirstName),
                                                                         ''
                                                                     ) + ' '
                                                             + COALESCE(
                                                                           dbo.fn_ReplaceSpecialCharsForJSON(do.Sender_LastName),
                                                                           ''
                                                                       ),
                                                             COALESCE(
                                                                         dbo.fn_ReplaceSpecialCharsForJSON(VPC.DescriptionOfClient),
                                                                         ''
                                                                     )
                                                         ),
                                                   'N/A'
                                               ) + '",' + '"Address":"'
                                       + dbo.fnt_String_Escape(
                                                                  CONCAT(
                                                                            ISNULL(
                                                                                      REPLACE(
                                                                                                 dbo.fn_ReplaceSpecialCharsForJSON(do.Sender_Address),
                                                                                                 '"',
                                                                                                 ''
                                                                                             ),
                                                                                      ' '
                                                                                  ),
                                                                            ISNULL(
                                                                                      dbo.fn_ReplaceSpecialCharsForJSON(do.Sender_Address),
                                                                                      REPLACE(
                                                                                                 dbo.fn_ReplaceSpecialCharsForJSON(VPC.Address),
                                                                                                 '"',
                                                                                                 ''
                                                                                             )
                                                                                  ),
                                                                            ' ',
                                                                            ISNULL(
                                                                                      dbo.fn_ReplaceSpecialCharsForJSON(do.Sender_Town),
                                                                                      ''
                                                                                  ),
                                                                            ' ',
                                                                            ISNULL(
                                                                                      dbo.fn_ReplaceSpecialCharsForJSON(do.Sender_Department),
                                                                                      ''
                                                                                  )
                                                                        ),
                                                                  'json'
                                                              ) + '",' + '"Phone":"'
                                       + ISNULL(ISNULL(do.Sender_Phone, ''), 'N/A') + '",' + '"ScheduleStart":"' + ''
                                       + '",' + '"ScheduleEnd":"' + '' + '",' + '"Photo":"'
                                       + ISNULL(
                                         (
                                             SELECT TOP 1
                                                    vpi.PathImage
                                             FROM dbo.ImagesByVisitPoint vpi WITH (NOLOCK)
                                             WHERE vpi.CodeOfReference = VPC.CodeOfReference
                                             ORDER BY DateCreated DESC
                                         ),
                                         '#'
                                               ) + '",' + '"Latitude":"' + CONVERT(VARCHAR, ISNULL(VPC.Latitude, 0))
                                       + '",' + '"Longitude":"' + CONVERT(VARCHAR, ISNULL(VPC.Longitude, 0)) + '",'
                                       + '"Precision":"' + CONVERT(VARCHAR, ISNULL(VPC.Accuracy, 0)) + '",' + '"Status":"'
                                       + CONVERT(VARCHAR, ISNULL(gs.ServiceStatusId, 7)) + '",' + '"CurrencySymbol":"'
                                       + 'Q.' + '",'
                                       + CASE
                                             WHEN do.IdDeliveryOption = @IdDeliveryOption THEN
                                                 '"TotalServiceAmount":"0",'
                                             ELSE
                                                 '"TotalServiceAmount":"' + CONVERT(VARCHAR, ISNULL(gt.AmountToPay, 0))
                                                 + '",'
                                         END
                                       + CASE
                                             WHEN do.IdDeliveryOption = @IdDeliveryOption THEN
                                                 '"TotalReturnAmount":"0",'
                                             ELSE
                                                 '"TotalReturnAmount":"' + CONVERT(VARCHAR, ISNULL(gt.ReturnRates, 0))
                                                 + '",'
                                         END
                                       + CASE
                                             WHEN do.IdDeliveryOption = @IdDeliveryOption THEN
                                                 '"TotalAmount":"0",'
                                             ELSE
                                                 '"TotalAmount":"'
                                                 + CONVERT(VARCHAR, ISNULL(gt.AmountToPay + gt.ReturnRates, 0)) + '",'
                                         END + '"PiecesList":['
                                       +
                                       (
                                           SELECT STUFF(
                                                  (
                                                      SELECT ',' + '"'
                                                             + ISNULL(
                                                                         CONCAT(
                                                                                   ISNULL(CONVERT(VARCHAR, dop.GuideSerie), 'N/A'),
                                                                                   ISNULL(CONVERT(VARCHAR, dop.GuideNumber), 'N/A'),
                                                                                   '-',
                                                                                   ISNULL(CONVERT(VARCHAR, dop.NoPiece), 'N/A')
                                                                               ),
                                                                         'N/A'
                                                                     ) + '"'
                                                      FROM dbo.ServiceManagement sm WITH (NOLOCK)
                                                          INNER JOIN dbo.SenderReceiver sr WITH (NOLOCK)
                                                              ON (sr.ID = sm.IdPuCourrier)
                                                          INNER JOIN dbo.PieceByService ps WITH (NOLOCK)
                                                              ON (ps.ServiceManagmentId = sm.IdServiceManagement)
                                                          INNER JOIN dbo.DeliveryOrderPiece dop WITH (NOLOCK)
                                                              ON (dop.GuidePiece = ps.GuidePieceId)
                                                      WHERE sm.ServiceStatusId IN ( 1, 4, 7, 8 )
                                                            AND sm.IdPuCourrier = @IdCourier
                                                            AND CONVERT(VARCHAR, sm.DateCreated, 103) = CONVERT(VARCHAR, GETDATE(), 103)
                                                            AND sm.IdServiceManagement = gs.IdServiceManagement
                                                      FOR XML PATH('')
                                                  )                                   ,
                                                  1                                   ,
                                                  1                                   ,
                                                  ''
                                                       )
                                       )                                   + ']' + +'}'
                                FROM #GuideService gs
                                    LEFT JOIN @Temp gt
                                        ON gt.GuideSerie = gs.GuideSerie
                                           AND gt.GuideNumber = gs.GuideNumber
                                    INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                                        ON do.Guide_Serie = gs.GuideSerie
                                           AND do.Guide_Number = gs.GuideNumber
                                    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
                                        ON VPC.CodeOfReference = do.Sender_ID
                                GROUP BY gs.IdServiceManagement,
                                         do.Sender_Address,
                                         VPC.CodeOfReference,
                                         do.Sender_FirstName,
                                         do.Sender_LastName,
                                         VPC.DescriptionOfClient,
                                         VPC.Address,
                                         do.Sender_Town,
                                         do.Sender_Department,
                                         do.Sender_Phone,
                                         VPC.Latitude,
                                         VPC.Longitude,
                                         VPC.Accuracy,
                                         gs.ServiceStatusId,
                                         gt.AmountToPay,
                                         gt.ReturnRates,
                                         do.IdDeliveryOption
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
        ---------------------------------------------End Retuns Services --------------------------------------------------		


        PRINT CONCAT('@jsonResult3', ISNULL(@jsonResult3, 'hay un valor null'));
        IF @jsonResult IS NULL
           AND @jsonResult2 IS NULL
           AND @jsonResult3 IS NULL
        BEGIN
            SET @jsonResultErrror =
            (
                SELECT STUFF(
                                (
                                    SELECT '{{"IdResult":500,' + '"Message":" No se encontraron registros"}'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
        END;



        SELECT ('[' + COALESCE(@jsonResultErrror, '') + CASE
                                                            WHEN @jsonResult IS NOT NULL
                                                                 AND @jsonResult2 IS NULL
                                                                 AND @jsonResult3 IS NULL THEN
                                                                CONCAT(@jsonResult, '')
                                                            ELSE
                                                                ''
                                                        END + CASE
                                                                  WHEN @jsonResult IS NOT NULL
                                                                       AND
                                                                       (
                                                                           @jsonResult2 IS NOT NULL
                                                                           OR @jsonResult3 IS NOT NULL
                                                                       ) THEN
                                                                      CONCAT(@jsonResult, ',')
                                                                  ELSE
                                                                      ''
                                                              END + CASE
                                                                        WHEN @jsonResult2 IS NOT NULL
                                                                             AND @jsonResult3 IS NULL THEN
                                                                            CONCAT(@jsonResult2, '')
                                                                        ELSE
                                                                            ''
                                                                    END + CASE
                                                                              WHEN @jsonResult2 IS NOT NULL
                                                                                   AND @jsonResult3 IS NOT NULL THEN
                                                                                  CONCAT(@jsonResult2, ',')
                                                                              ELSE
                                                                                  ''
                                                                          END + COALESCE(@jsonResult3, '') + ']'
               ) jsonResult;

        IF OBJECT_ID('tempdb.dbo.#GuideService', 'U') IS NOT NULL
            DROP TABLE #GuideService;


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
END;





