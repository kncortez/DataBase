
-- =============================================
-- Author:		<Cristian Azurdia>
-- Create date: <2024-04-25>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_daily_route]
    @Token VARCHAR(200) = '',
    @IdCourier BIGINT,
    @DateRoute DATE
AS
BEGIN

    SET NOCOUNT ON;

	DECLARE @TokenAct INT = 1;
    DECLARE @hourtoken INT = 5;

	/******************************************************************************************************************************
	****************************************************** OBTENER TIPOS DE ALERTAS ***********************************************
	*******************************************************************************************************************************/
    
    DECLARE @PickUpTypeId BIGINT =
            (
                SELECT	TOP 1 STSM.IdSubTypeServiceManagment
                FROM	[DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH (NOLOCK)
                WHERE	STSM.Name = 'Recolección'
					AND STSM.RowStatus = 1
            );
    DECLARE @DeliveryTypeId BIGINT =
            (
                SELECT	TOP 1 STSM.IdSubTypeServiceManagment
                FROM	[DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH (NOLOCK)
                WHERE	STSM.Name = 'Entrega'
					AND STSM.RowStatus = 1
            );
    DECLARE @ReturnTypeId BIGINT =
            (
                SELECT	TOP 1 STSM.IdSubTypeServiceManagment
                FROM	[DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH (NOLOCK)
                WHERE	STSM.Name = 'Devolución'
					AND STSM.RowStatus = 1
            );

	DECLARE @IdDeliveryOption INT =
        (
            SELECT TOP 1 IdDeliveryOption
            FROM [DeliveryBackOffice].[dbo].[CatDeliveryOptions] WITH (NOLOCK)
            WHERE [Name] = 'Express Center'
        ); 

	--CONSULTA PARA PODER VER LOS IDS DE LOS TIPOS DE ALERTAS
	--SELECT @PickUpTypeId [PickUpTypeId], @DeliveryTypeId [DeliveryTypeId], @ReturnTypeId [ReturnTypeId], @IdDeliveryOption [IdDeliveryOption]

	/******************************************************************************************************************************
	************************************************* TABLA TEMPORAL CON LAS ALERTAS OBTENIDAS ************************************
	***************************************************** POR RECOLECCION, ENTREGA, OTROS *****************************************
	*******************************************************************************************************************************/

	DROP TABLE IF EXISTS #TmpAlertList;

    CREATE TABLE #TmpAlertList
    (
		ServiceManagementId INT,
		TypeAlert INT,
        DescriptionAlert NVARCHAR(500),
        DateCreated NVARCHAR (22),
    );

    CREATE NONCLUSTERED INDEX tempSCheduledpickupid
    ON #TmpAlertList (ServiceManagementId);

	INSERT INTO #TmpAlertList
    (
		ServiceManagementId,
		TypeAlert,
        DescriptionAlert,
		DateCreated
    )
	SELECT TAL.[ServiceManagementId],
		   TAL.[AlertTypeId],
		   TAL.[AlertDescription],
		   CONCAT(CONVERT(VARCHAR, TAL.[DateCreated], 24), ' - ', CONVERT(VARCHAR, TAL.[DateCreated], 103))[DateCreated]
	FROM(
		-- ALERTAS EN GENERAL
		SELECT	DOA.[ServiceManagementId],
				DOA.AlertTypeId,
				DOA.AlertDescription,
				DOA.DateCreated
		FROM	[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] doa WITH (NOLOCK)
        WHERE   CONVERT( DATE, doa.DateCreated ) = @DateRoute
			AND DOA.RowStatus = 1
			AND DOA.ServiceManagementId IS NOT NULL
		UNION ALL
		-- ALERTAS PARA GUÍAS EN RUTA
		SELECT  VPC.CodeOfReference	[ServiceManagementId],
				DOA.AlertTypeId,
				DOA.AlertDescription,
				DOA.DateCreated
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA WITH (NOLOCK)
		LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH (NOLOCK)
			ON DO.Guide_Serie = DOA.GuideSerie
			AND DO.Guide_Number = DOA.GuideNumber
		LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
			ON VPC.CodeOfReference = DO.Sender_Id
		WHERE  doa.ServiceTypeId IN (@PickUpTypeId)
				AND CAST( doa.DateCreated AS DATE) = @DateRoute
				AND DOA.RowStatus = 1
				AND DOA.ServiceManagementId IS NULL
		UNION ALL
		-- ALERTAS PARA RECOLECCIONES
		SELECT	DOA.GuideNumber [ServiceManagementId],
				DOA.AlertTypeId,
				DOA.AlertDescription,
				DOA.DateCreated
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA WITH (NOLOCK)
		LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH (NOLOCK)
			ON DO.Guide_Serie = DOA.GuideSerie
			AND DO.Guide_Number = DOA.GuideNumber
		WHERE  DOA.ServiceTypeId IN (@ReturnTypeId, @DeliveryTypeId)
		   AND CONVERT(DATE, DOA.DateCreated) = @DateRoute
		   AND DOA.RowStatus = 1
		   AND DOA.ServiceManagementId IS NULL
    ) AS TAL
	ORDER BY TAL.DateCreated DESC

	
	/******************************************************************************************************************************
	****************************************** TABLA TEMPORAL QUE ALMACENA LAS DEVOLUCIONES ***************************************
	*******************************************************************************************************************************/

	DROP TABLE IF EXISTS #GuideReturnService;

	 CREATE TABLE #GuideReturnService
    (
        GuideSerie NVARCHAR(2),
        GuideNumber INT
    );
    CREATE NONCLUSTERED INDEX IDX_TMP_GuideReturnService_Guide
    ON #GuideReturnService (
                               GuideSerie,
                               GuideNumber
                           );

    INSERT INTO #GuideReturnService
    (
        GuideSerie,
        GuideNumber
    )
   SELECT
           DAT.Guide_Serie,
           DAT.Guide_Number
    FROM
    (
        SELECT  MAX(ID_DeliveryOrderBySettlement) ID_DeliveryOrderBySettlement,
				Guide_Serie,
				Guide_Number,
				ID_Courier
        FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] WITH (NOLOCK)
        WHERE	CAST(Date_Created AS DATE) = @DateRoute
			AND ID_Courier = @IdCourier 
			AND Guide_Piece = 1
		GROUP BY	
				Guide_Serie,
				Guide_Number,
				ID_Courier
    )                                                               DAT
	LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder]           DOR WITH (NOLOCK)
        ON DAT.Guide_Serie = DOR.Guide_Serie
        AND DAT.Guide_Number = DOR.Guide_Number
        AND DOR.IsLastMileReturn = 1
		--En ruta|entregado|Intento de entrega fallida|Devuelto|Traslado a Express Center|COD pagado|Incidencia en ruta
        AND DOR.StatusOrderId IN ( 4, 5, 12,  14, 20, 25, 45, 50 ) 
	LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]  DSD WITH (NOLOCK)
        ON DSD.Guide_Serie = DAT.Guide_Serie
        AND DSD.Guide_Number = DAT.Guide_Number
        AND DSD.RowStatus = 1
    LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOS WITH (NOLOCK)
        ON DOS.ID = DSD.ID_DeliveryOrderBySettlement
        AND DOS.ID_Courier = DAT.ID_Courier
    WHERE DAT.ID_Courier = @IdCourier;
    
	/******************************************************************************************************************************
	****************************************** TABLA TEMPORAL QUE ALMACENA GUIAS PENDIENTES ***************************************
	********************************************************* DE PAGO *************************************************************
	*******************************************************************************************************************************/

	DECLARE @ConcatReturnGuides NVARCHAR(MAX) =
            (
                SELECT STUFF((
                                 SELECT ',' + CONCAT(GuideSerie, GuideNumber)
                                 FROM #GuideReturnService
                                 FOR XML PATH('')
                             )
                           , 1
                           , 1
                           , ''
                            )
            );

	DECLARE @TempReturnPrice AS TABLE
    (
        GuideSerie NVARCHAR(25) NULL
      , GuideNumber NVARCHAR(25) NULL
      , IsCollect NVARCHAR(25) NULL
      , Price DECIMAL(14, 2) NULL
      , COD DECIMAL(14, 2) NULL
      , AmountPaid DECIMAL(14, 2) NULL
      , CODPaid DECIMAL(14, 2) NULL
      , CODIsPaid DECIMAL(14, 2) NULL
      , PaymentTime INT NULL
      , TimeSequence INT NULL
      , FelNumber NVARCHAR(50) NULL
      , IsPaid INT NULL
      , IsCustomer INT NULL
      , ConditionPayment NVARCHAR(200) NULL
      , HaveCredit NVARCHAR(50) NULL
      , CollectCOD NVARCHAR(50) NULL
      , ReturnRate DECIMAL(14, 2) NULL
      , AmountToPay DECIMAL(14, 2) NULL
      , CODAmount DECIMAL(14, 2) NULL
      , ReturnRates DECIMAL(14, 2) NULL
    );
    INSERT INTO @TempReturnPrice
    (
        GuideSerie
      , GuideNumber
      , IsCollect
      , Price
      , COD
      , AmountPaid
      , CODPaid
      , CODIsPaid
      , PaymentTime
      , TimeSequence
      , FelNumber
      , IsPaid
      , IsCustomer
      , ConditionPayment
      , HaveCredit
      , CollectCOD
      , ReturnRate
      , AmountToPay
      , CODAmount
      , ReturnRates
    )
    EXEC [dbo].[spws_get_guide_pending_payment] @InGuides = @ConcatReturnGuides    -- Guías
                                              , @InTime = 3                        -- Entrega
                                              , @IsReturn = 1                      -- Devolución
                                              , @CodeApp = 'SIFDCECOM300720201459' -- CodeApp
                                              , @IdModule = 1
                                              , @Token = @Token;

    IF (@TokenAct = 1 AND @hourtoken <= 8)
    BEGIN

        /*****************************************************************************************************************************************
		************************************** CONSULTA PARA DESPLEGAR LAS RECOLECCIONES Y SUS ALERTAS *******************************************
		******************************************************************************************************************************************/

        SELECT 'Pickup' [ServiceType],
				ISNULL(vpc.CodeOfReference, 0) [CodeOfReference],
				ISNULL(spk.SchedulePickupId, '-1') [Id],
				ISNULL(sma.IdServiceManagement, -1) [ServiceManagementId],
				ISNULL(cpt.TimePlaName, 'N/A') [ServicePaymentTime],
				dbo.fnt_String_Escape(ISNULL(ISNULL(spk.SenderName, vpc.DescriptionOfClient), 'N/A'),'json') [Sender],
				dbo.fnt_String_Escape(
				CONCAT( ISNULL(spk.AddressPickup, vpc.[Address]), ', ',
						CASE WHEN  spk.AddressPickup IS NOT NULL AND spk.TownshipId IS NOT NULL THEN t.TownshipName ELSE vpc.Town  END, ', ',
						CASE WHEN  spk.AddressPickup IS NOT NULL AND spk.TownshipId IS NOT NULL THEN p.ProvinceName ELSE vpc.Department END
					  ),'json' ) [Address],
				ISNULL(ISNULL(spk.SenderPhone, vpc.Phone), 'N/A') [Phone],
				ISNULL(
                                                    (
                                                        SELECT IIF(SUM(ISNULL(ord.Pieces_Dry, 0)) = 0
                                                                 , (ISNULL(SUM(sc.QuantityOverDimensionedPackage), 0)
                                                                    + ISNULL(SUM(sc.QuantityRegularPackages), 0)
                                                                   )
                                                                 , SUM(ISNULL(ord.Pieces_Dry, 0))) pieces
                                                        FROM dbo.DeliveryOrderPaymentDetail pay WITH (NOLOCK)
                                                            LEFT JOIN dbo.DeliveryOrder     ord WITH (NOLOCK)
                                                                ON ord.Guide_Serie = pay.GuideSerie
                                                                   AND ord.Guide_Number = pay.GuideNumber
                                                            LEFT JOIN dbo.SchedulePickup    sc WITH (NOLOCK)
                                                                ON sc.SchedulePickupId = pay.IdHeaderRecolection
                                                        WHERE pay.IdHeaderRecolection = spk.SchedulePickupId
                                                    )
                                                  , 0
                                                          ) [PiecesDry],
														ISNULL((
                                                               SELECT SUM(ISNULL(ord.Pieces_Cold, 0)) pieces
                                                               FROM dbo.DeliveryOrderPaymentDetail pay WITH (NOLOCK)
                                                                   LEFT JOIN dbo.DeliveryOrder     ord WITH (NOLOCK)
                                                                       ON ord.Guide_Serie = pay.GuideSerie
                                                                          AND ord.Guide_Number = pay.GuideNumber
                                                               WHERE pay.IdHeaderRecolection = spk.SchedulePickupId
                                                           )
                                                         , 0
                                                          )[PiecesCold],
				SUBSTRING(CONVERT(VARCHAR, spk.StartDate, 8), 0, 6) [ScheduleStart],
				SUBSTRING(CONVERT(VARCHAR, ISNULL(spk.EndDate, DATEADD( HOUR, 19, CAST(CAST(spk.StartDate AS DATE) AS DATETIME) ) ),8 ), 0, 6) [ScheduleEnd'],
				ISNULL((
                                                    SELECT TOP 1
                                                           vpi.PathImage
                                                    FROM dbo.ImagesByVisitPoint vpi WITH (NOLOCK)
                                                    WHERE vpi.CodeOfReference = vpc.CodeOfReference
                                                    ORDER BY DateCreated DESC
                                                )
                                              , '#'
                                               ) [Photo],
				ISNULL(vpc.Latitude, 0)  [Latitude],
				ISNULL(vpc.Longitude, 0) [Longitude],
				ISNULL(vpc.Accuracy, 0) [Precision],
				0 [Price],
				0 [Pickup],
				'' [customerName],
				'' [alterName],  
				IIF(
					(
						SELECT ISNULL( COUNT(doa2.GuideNumber) , 0 )						
						FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA2 WITH (NOLOCK)
						LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO2  WITH (NOLOCK)
							ON DO2.Guide_Serie = DOA2.GuideSerie
							AND DO2.Guide_Number = DOA2.GuideNumber
						LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH (NOLOCK)
							ON VPC2.CodeOfReference = DO2.Sender_Id
						WHERE  CAST( doa2.DateCreated AS DATE) = @DateRoute
								AND doa2.ServiceTypeId IN (@PickUpTypeId)
								AND VPC2.CodeOfReference = vpc.CodeOfReference
								AND DOA2.RowStatus = 1
								AND DOA2.ServiceManagementId IS NULL
					) > 0
					, 1
					, 0
				   ) [HighPriority],
				'' [Alerts],
				 CONVERT(VARCHAR, ISNULL(sma.ServiceStatusId, 1)) [Status]
            FROM dbo.RouteAssigment             ras WITH (NOLOCK)
                INNER JOIN dbo.ServiceManagement sma WITH (NOLOCK)
                    ON sma.IdPuRouteAssigment = ras.IdRouteAssigment
                INNER JOIN dbo.SchedulePickup    spk WITH (NOLOCK)
                    ON spk.SchedulePickupId = sma.IdSchedulePickup
                LEFT JOIN dbo.VisitPointClient  vpc WITH (NOLOCK)
                    ON vpc.CodeOfReference = spk.SenderId
                LEFT JOIN dbo.CatPaymentTime    cpt WITH (NOLOCK)
                    ON sma.CatPaymentTimeId = cpt.TimePlaId
                LEFT JOIN dbo.Township t WITH (NOLOCK)
									    ON  spk.TownshipId = t.IdTownship
									LEFT JOIN dbo.Province p WITH (NOLOCK)
									    ON t.IdProvince =p.IdProvince
            WHERE ras.IdCurrierMan = @IdCourier
                    AND (ras.DateOfRoute = @DateRoute
                        --- OR ras.DateOfRoute = '2023-06-25'
                        )
					AND ISNULL(sma.SubTypeServiceManagmentId,1)=1
		

		/*****************************************************************************************************************************************
		**************************************** CONSULTA PARA DESPLEGAR LAS ENTREGAS Y SUS ALERTAS **********************************************
		******************************************************************************************************************************************/
       
		SELECT	'Delivery' [ServiceType],
				CONVERT(VARCHAR, ISNULL(VPC.CodeOfReference, 0))	[CodeOfReference],
				ISNULL(
					CASE
					WHEN ISNULL([DOR].[IsLastMileReturn], 0) = 0 
					THEN DOR.IdDeliveryOption
					ELSE 1
					END	
				 ,0)
				 [DeliveryOption],
				 CONVERT(tinyint, ISNULL([DOR].[IsLastMileReturn], 0)) [IsLastMileReturn],
				 ISNULL( CONVERT( VARCHAR, DOR.Guide_Serie + CONVERT(VARCHAR, DOR.Guide_Number) ), '-1' )[Id], 
				 0 [ServiceManagementId],
				 ISNULL(
					ISNULL(
							COALESCE(
										IIF(
												DOR.IsLastMileReturn = 1,
												dbo.fnt_String_Escape(DOR.Receiver_FirstName, 'json'),
												dbo.fnt_String_Escape(DOR.Sender_FirstName, 'json')
											) , ''
									) + ' '
							+ 
							COALESCE(
										IIF(
												DOR.IsLastMileReturn = 1,
												dbo.fnt_String_Escape(DOR.Receiver_FirstName, 'json'),
												dbo.fnt_String_Escape(DOR.Sender_FirstName, 'json')
											) , ''
									   )
							, dbo.fnt_String_Escape(VPC.DescriptionOfClient, 'json')
							) , 'N/A'
					)[Sender],
				IIF(
					kvp.KindOfVPName = 'Express Center',
					dbo.fnt_String_Escape(ISNULL(VPr.[Address], ''),'json'),
					ISNULL
					(
						ISNULL(
									IIF(
											DOR.IsLastMileReturn = 1,
											dbo.fnt_String_Escape(DOR.Sender_Address,'json'),
											dbo.fnt_String_Escape(DOR.Receiver_Address,'json')
										)
									, 
									IIF(
										DOR.IsLastMileReturn = 1
										, VPC.Address
										, VPr.Address
									   )
							   ),
						'N/A'
					)	
				   ) [Address],
				CASE
				WHEN ISNULL([DOR].[IsLastMileReturn], 0) = 0 
				THEN [DOR].[Sender_Phone]
				ELSE ''
				END [Sender_Phone],				
				ISNULL(
						IIF(DOR.IsLastMileReturn = 1
						, ISNULL(DOR.Sender_Phone, 'N/A')
						, ISNULL(
									DOR.Receiver_Phone
									, DOR.Receiver_Alternant_Phone
								)
							), 'N/A'
					  ) [Phone],
				ISNULL(
						(
							SELECT (SUM(ISNULL(DOR2.Pieces_Dry, 0))) pieces
							FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DOR2 WITH (NOLOCK)
							WHERE DOR2.Guide_Serie = DAT.Guide_Serie
							  AND DOR2.Guide_Number = DAT.Guide_Number
						), 0
					  ) [PiecesDry],
				ISNULL(
						(
							SELECT (SUM(ISNULL(DOR2.Pieces_Cold, 0))) pieces
							FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DOR2 WITH (NOLOCK)
							WHERE DOR2.Guide_Serie = DAT.Guide_Serie
							  AND DOR2.Guide_Number = DAT.Guide_Number
						), 0
					  ) [PiecesCold],
				'' [ScheduleStart],
				'' [ScheduleEnd],
				ISNULL(
						(
							SELECT TOP 1 vpi.PathImage
							FROM [DeliveryBackOffice].[dbo].[ImagesByVisitPoint] vpi WITH (NOLOCK)
							WHERE vpi.CodeOfReference = VPC.CodeOfReference
							ORDER BY DateCreated DESC
						)
						, '#'
					  )[Photo],
				CONVERT(
						VARCHAR,
                            (CASE
								WHEN ISNULL(DOR.Receiver_Lat, '0') <> '' THEN
										ISNULL(DOR.Receiver_Lat, '0')
                                WHEN ISNULL(DFG.Latitude, 0) != 0
                                        AND ISNULL(DFG.Longitude, 0) != 0 THEN
                                    CONVERT(VARCHAR, ISNULL(DFG.Latitude, 0))
                                WHEN ISNULL(EPS.Latitude, 0) != 0
                                        AND ISNULL(EPS.Longitude, 0) != 0 THEN
                                    CONVERT(VARCHAR, ISNULL(EPS.Latitude, 0))
                                WHEN ISNULL(VPC.Longitude, '0') <> ''
                                        AND DOR.IsLastMileReturn = 1 THEN
                                    ISNULL(VPC.Longitude, '0')
                                WHEN ISNULL(VPr.Latitude, '0') <> ''
                                        AND DOR.IsLastMileReturn = 0 THEN
                                    ISNULL(VPr.Latitude, '0')
                                ELSE
                                    '0'
                            END
                            )
                        ) [Latitude],
				CASE
					WHEN ISNULL(DOR.Receiver_Lng, '0') <> '' 
					THEN ISNULL(DOR.Receiver_Lng, '0')
					WHEN ISNULL(DFG.Latitude, 0) != 0
					 AND ISNULL(DFG.Longitude, 0) != 0 
					THEN CONVERT(VARCHAR, ISNULL(DFG.Longitude, 0))
					WHEN ISNULL(EPS.Latitude, 0) != 0
					 AND ISNULL(EPS.Longitude, 0) != 0 
					THEN CONVERT(VARCHAR, ISNULL(EPS.Longitude, 0))
					ELSE ISNULL(VPC.Longitude, '0')
				END [Longitude],
				CONVERT(VARCHAR, ISNULL(VPC.Accuracy, 0)) [Precision],
				CASE
					WHEN DOR.IdDeliveryOption = @IdDeliveryOption 
					THEN 0
					ELSE
						 IIF(
								kvp.KindOfVPName = 'Express Center', 
								'0', 
								IIF(
									DOR.IsLastMileReturn = 1, 
									0 , 
									ISNULL( DOR.Collect_OnDelivery, 0 )
									)
							  )
				END [Price_COD],
				CASE
					WHEN DOR.IdDeliveryOption = @IdDeliveryOption 
					THEN 0
					ELSE
						IIF(
								kvp.KindOfVPName = 'Express Center', 
								'0', 
								IIF(
										DOR.IsLastMileReturn = 1, 
										TRPreturns.AmountToPay , 
										IIF(
												ISNULL(DOR.IsCollect, 0) = 1, 
												ISNULL( DOR.PriceShippment, 0), 
												0
											)
								   )
							 )
				END [Price],
				CASE
					WHEN DOR.IdDeliveryOption = @IdDeliveryOption 
					THEN 0
					ELSE 
						ISNULL(
								(
									SELECT TOP 1
										IIF(ISNULL(dp.TimePlaId, 0) = 3,
											sc.AmountPickup,
											0)
									FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] dp WITH (NOLOCK)
									LEFT JOIN [DeliveryBackOffice].[dbo].[SchedulePickup]    sc WITH (NOLOCK)
										   ON sc.SchedulePickupId = dp.IdHeaderRecolection
									WHERE dp.GuideNumber = DOR.Guide_Number
									  AND dp.GuideSerie = DOR.Guide_Serie
								), 0
							  )
				END [Pickup],
				dbo.fnt_String_Escape(
					IIF(
							DOR.IsLastMileReturn = 1, 
							IIF(
									kvpori.KindOfVPName = 'Express Center' ,
									ISNULL( VPC.DescriptionOfClient , '' ),
									ISNULL( DOR.Sender_FirstName , 'N/A' )
									
								), 
							IIF(
									kvp.KindOfVPName = 'Express Center',
									ISNULL( VPr.DescriptionOfClient , '' ),
									ISNULL( DOR.Receiver_FirstName , 'N/A' )
									
								)
						)
					, 'json' ) [customerName],
				dbo.fnt_String_Escape(
					IIF(
							DOR.IsLastMileReturn = 1, 
							'N/A', 
							ISNULL(
									ISNULL( DOR.Receiver_Alternant_FullName, ''), 
									ISNULL( DOR.Receiver_FirstName, 'N/A')
								   )
							) 
						,'json') [alterName],
				IIF(
						(
							SELECT NumImgEvidence AS num
							FROM Customer WITH (NOLOCK)
							WHERE IdCustomer = DOR.IdCustomer
						) IS NOT NULL , 
						(
							SELECT NumImgEvidence AS num
							FROM Customer
							WHERE IdCustomer = DOR.IdCustomer
						), 1
					) [NumImageEvidence],
				ISNULL(   
						CASE
							WHEN DOR.StatusOrderId in (45,50) 
							THEN 12
							ELSE DOR.StatusOrderId
						END
						, 4
					   ) [Status]
				,IIF(
					(
						SELECT ISNULL( COUNT(doa.GuideNumber) , 0 )
						FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAlert] doa WITH (NOLOCK)
						WHERE doa.GuideNumber = DOR.Guide_Number
							AND doa.GuideSerie = DOR.Guide_Serie
							AND doa.RowStatus = 1
							AND doa.ServiceTypeId = IIF(
														DOR.IsLastMileReturn = 1, 
														@ReturnTypeId , 
														@DeliveryTypeId
													   )
					) > 0
					, 1
					, 0
				   ) [HighPriority],
		'' [Alerts]
		FROM
		(
			SELECT  MAX(ID_DeliveryOrderBySettlement) ID_DeliveryOrderBySettlement,
					Guide_Serie,
					Guide_Number,
					ID_Courier
			FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] WITH (NOLOCK)
			WHERE	CAST(Date_Created AS DATE) = @DateRoute
				AND ID_Courier = @IdCourier 
				AND Guide_Piece = 1
			GROUP BY	
					Guide_Serie,
					Guide_Number,
					ID_Courier
		)                                                               DAT	
		INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder]            DOR WITH (NOLOCK)
			ON	DOR.Guide_Serie = DAT.Guide_Serie
			AND	DOR.Guide_Number = DAT.Guide_Number
			-- En ruta|entregado|Intento de entrega fallida|Devuelto|Traslado a Express Center|COD pagado|Declarado para Devolución|Incidencia en ruta|Guía revertida para entrega
			AND DOR.StatusOrderId IN ( 4, 5, 12, 14, 20, 25, 32, 45, 48, 50 )
		INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]  DSD WITH (NOLOCK)
			ON DSD.Guide_Serie = DAT.Guide_Serie
			AND DSD.Guide_Number = DAT.Guide_Number
			AND DSD.RowStatus = 1
		INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOS WITH (NOLOCK)
			ON DOS.ID = DSD.ID_DeliveryOrderBySettlement
			AND DOS.ID_Courier = DAT.ID_Courier
		LEFT JOIN @TempReturnPrice										TRPreturns
			ON DOR.Guide_Serie = TRPreturns.GuideSerie
			AND DOR.Guide_Number = TRPreturns.GuideNumber
		LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]			VPC WITH (NOLOCK)
			ON VPC.CodeOfReference = DOR.Sender_ID
        LEFT JOIN
        (
            SELECT EPSA.GuideSerie
                    , EPSA.GuideNumber
                    , EPS.Latitude
                    , EPS.Longitude
            FROM DeliveryBackOffice.dbo.ExtPlatformService EPS WITH (NOLOCK)
                INNER JOIN
                (
                    SELECT EPSRWG.GuideSerie
                            , EPSRWG.GuideNumber
                            , MAX(EPS.IdService) 'LastService'
                    FROM DeliveryBackOffice.dbo.ExtPlatServiceRelationshipWithGuide EPSRWG WITH (NOLOCK)
                        LEFT JOIN DeliveryBackOffice.dbo.ExtPlatformService         EPS WITH (NOLOCK)
                            ON EPSRWG.ExtPlatServiceId = EPS.IdExtPlatformService
                    GROUP BY EPSRWG.GuideSerie
                            , EPSRWG.GuideNumber
                )                                          EPSA
                    ON EPS.IdService = EPSA.LastService
            WHERE CAST(EPS.EstimatedTimeArrival AS DATE) = CAST(@DateRoute AS DATE)
        )                                                           EPS
			ON	DAT.Guide_Serie = EPS.GuideSerie
			AND DAT.Guide_Number = EPS.GuideNumber


		LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VPr WITH (NOLOCK)
			ON VPr.CodeOfReference = DOR.Receiver_ID
		LEFT JOIN [DeliveryBackOffice].[dbo].[KindOfVPClient] kvpori WITH (NOLOCK)
			ON kvpori.IdKindOfVPClient = VPC.IdKindOfVPClient
		LEFT JOIN [DeliveryBackOffice].[dbo].[KindOfVPClient] kvp WITH (NOLOCK)
			ON kvp.IdKindOfVPClient = VPr.IdKindOfVPClient
		
		OUTER APPLY(
			SELECT TOP 1 vpi.PathImage
			FROM [DeliveryBackOffice].[dbo].[ImagesByVisitPoint]	vpi WITH (NOLOCK)
			WHERE vpi.CodeOfReference = VPC.CodeOfReference
			ORDER BY DateCreated DESC
		) IVP

		OUTER APPLY
		(
			SELECT MAX(ISNULL(SDFG.Latitude, 0))  'Latitude'
					, MAX(ISNULL(SDFG.Longitude, 0)) 'Longitude'
			FROM [DeliveryBackOffice].[dbo].[ServiceDataForGuide] SDFG WITH (NOLOCK)
			WHERE DOR.Guide_Serie   =	SDFG.GuideSerie
			  AND DOR.Guide_Number	=	SDFG.GuideNumber
			  AND SDFG.IsDelivery	= 1
			GROUP BY SDFG.GuideSerie,
					 SDFG.GuideNumber
		) DFG
		WHERE	CAST(DSD.DateCreated AS DATE) = @DateRoute
				AND DSD.RowStatus = 1

		/******************************************************************************************************************************
		****************************************** CONSULTA PARA MOSTRAR LAS ALERTAS DISPONIBLES **************************************
		*******************************************************************************************************************************/

		SELECT 
				TMAP.ServiceManagementId,
				TMAP.TypeAlert,
				dbo.fnt_String_Escape(TMAP.DescriptionAlert,'json') DescriptionAlert,
				TMAP.DateCreated
		FROM	#TmpAlertList TMAP

		SELECT 200 [IdResult], 'Se encontraron registros' [Message];

	END
	ELSE IF (@TokenAct = 0 OR @TokenAct IS NULL OR @hourtoken > 8)
	BEGIN
       
		SELECT '403' [IdResult], 'Token Inválido' [DescriptionError];
        
	END;
END;





