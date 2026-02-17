/* =================================================
   SP:        [dbo].[SPHW_ReportBiV4]
   Propósito: <Carga informacion del reporte deliveryv4 de Power BI>
   Autor:     <
   Historia:  <>
   Fecha:     
============================================
=== CHANGELOG ================================
-- 2025-12-08 | Historia/épica: FDAPI-5255 | Autor: Tito Garcia |
=========================================== */
CREATE PROCEDURE [dbo].[SPHW_ReportBiV4]
AS
BEGIN
	--Server 3.200
	--PowerBI Delivery LIVE Dashboard v4.AI (04 marzo 2025)

	--tabla temporal para validar los clientes que son de tipo corporativo
	IF OBJECT_ID('tempdb.dbo.#VisitPointsCorporate', 'U') IS NOT NULL
		DROP TABLE #VisitPointsCorporate;

	SELECT vpc.CodeOfReference,
		   vpc.CustomerID
	INTO #VisitPointsCorporate
	FROM VisitPointClient vpc WITH (NOLOCK)
	   INNER JOIN Customer cust WITH (NOLOCK)
			ON vpc.CustomerID = cust.IdCustomer
	WHERE cust.IdCustomerType = 1; --corporativo

	create nonclustered index temp_visit on #VisitPointsCorporate (CodeOfReference)
	create nonclustered index temp_visit_customerid on #VisitPointsCorporate (CustomerID)

	DECLARE @IVA DECIMAL (14,2) = 1.12

	SELECT --TOP 100    
		(
			SELECT TOP 1
				   CONVERT(VARCHAR, DateCreated, 103)
			FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod10 WITH (NOLOCK)
			WHERE dod10.Guide_Serie = do.Guide_Serie
				AND dod10.Guide_Number = do.Guide_Number
				AND dod10.StatusOrderId = 11
			ORDER BY DateCreated ASC
		) AS [Fecha_Preparacion],
		(
			SELECT TOP 1
				   dobs.Date_Dispatched
			FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dobs WITH (NOLOCK)
			   INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd WITH (NOLOCK)
					ON dsd.ID_DeliveryOrderBySettlement = dobs.ID
			WHERE dsd.Guide_Serie = do.Guide_Serie 
				AND dsd.Guide_Number = do.Guide_Number
			ORDER BY dobs.ID DESC
		) AS [Fecha_Recoleccion],
		do.Pieces_Dry AS [Piezas_Secas],
		do.Pieces_Cold AS [Piezas_Frias],
		CASE
			WHEN vpc.CodeOfReference > 0 THEN
				vpc.DescriptionOfClient
			ELSE
			(
				SELECT COALESCE(ctm.Name, '')
				FROM DeliveryBackOffice.dbo.Customer ctm WITH (NOLOCK)
				WHERE ctm.IdCustomer = do.IdCustomer
			)
		END AS [Sender_Name],
		[Sender_Address],
		[Sender_Zone],
		[Sender_Town],
		[Sender_Department],
		(RTRIM(LTRIM(ISNULL([Receiver_FirstName], ''))) + ' ' + RTRIM(LTRIM(ISNULL([Receiver_LastName], '')))) AS [Receiver_Name],
		[Receiver_Address],
		[Receiver_Zone],
		[Receiver_Town],
		[Receiver_Department],
		[Receiver_Phone],
		(
			SELECT CONVERT(VARCHAR, [Delivery_Max_Date], 103)
		) AS [Fecha_Limite_Entrega],
		do.[Guide_Serie] + CAST(do.[Guide_Number] AS VARCHAR) AS [Waybill],
		do.[Manifest_Serie] + CAST(do.[Manifest_Number] AS VARCHAR) AS [Manifest],
		(
			SELECT CONVERT(VARCHAR, do.[DateCreated], 103)
		) AS [Fecha_Solicitud],
		do.[StatusOrderId] AS [Last_Checkpoint_Code],
		so.OrderDescription AS [Last_Checkpoint_Name],
		[Package_Description],
		[Courier_Route],
		(
			SELECT Courier_Fullname
			FROM DeliveryBackOffice.dbo.fn_get_last_information_attempt_without_accepted(do.Guide_Serie, do.Guide_Number)
		) AS Courier_Name,
		(
			SELECT Date_Delivered
			FROM DeliveryBackOffice.dbo.fn_get_last_information_attempt_without_accepted(do.Guide_Serie, do.Guide_Number)
		) AS [Fecha_Despacho_Ruta],
		REPLACE(REPLACE(ISNULL([NameOfReceiver], ''), CHAR(13), ''), CHAR(10), '') AS [Name_Of_Receiver],
		pa.Package_Name,
		(
			SELECT TOP 1
				   CONVERT(VARCHAR, DateCreated, 103)
			FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod1 WITH (NOLOCK)
			WHERE dod1.Guide_Serie = do.Guide_Serie
				AND dod1.Guide_Number = do.Guide_Number
				AND dod1.StatusOrderId = 3
			ORDER BY DateCreated ASC
		) AS [Primera_Fecha_Programado_Entrega],
		(
			SELECT COUNT(dod2.Guide_Number)
			FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod2 WITH (NOLOCK)
			WHERE dod2.Guide_Serie = do.Guide_Serie
				AND dod2.Guide_Number = do.Guide_Number
				AND dod2.StatusOrderId = 3
		) AS [Veces_Programado_Entrega],
		(
			SELECT TOP 1
				   CONVERT(VARCHAR, DateCreated, 103)
			FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod3 WITH (NOLOCK)
			WHERE dod3.Guide_Serie = do.Guide_Serie 
				AND dod3.Guide_Number = do.Guide_Number
				AND dod3.StatusOrderId IN(5,22)
			ORDER BY DateCreatedInSystem ASC
		) AS [Primera_Fecha_Entrega],
		(
			SELECT COUNT(dod4.Guide_Number)
			FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod4 WITH (NOLOCK)
			WHERE dod4.Guide_Serie = do.Guide_Serie
				AND dod4.Guide_Number = do.Guide_Number
				AND dod4.StatusOrderId  IN(5,22)
		) AS [Veces_Entregas_Registradas],
		(
			SELECT (CASE
						WHEN COUNT(dod5.Guide_Number) > 0 THEN
							1
						ELSE
							0
					END
				   )
			FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod5 WITH (NOLOCK)
			WHERE dod5.Guide_Serie = do.Guide_Serie
				AND dod5.Guide_Number = do.Guide_Number
				AND dod5.StatusOrderId IN(5,22)
		) AS [Entregado],
		0 AS [Digitalizado],
		(
			SELECT ISNULL([Collect_OnDelivery], 0)
		) AS [Monto_A_Cobrar], 
		(SELECT (CASE
						WHEN (
							SELECT COUNT(dod51.Guide_Number)
							FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod51 WITH (NOLOCK)
							WHERE dod51.Guide_Serie = do.Guide_Serie
								AND dod51.Guide_Number = do.Guide_Number
								AND dod51.StatusOrderId  IN(5,22)
						) > 0 THEN
							Collect_OnDelivery
						ELSE
							0
					END
		)) AS [Monto_Cobrado],
		(
			SELECT ISNULL([Receiver_Updated], 0)
		) AS [Datos_Modificados],
		(
			SELECT DeliveryBackOffice.dbo.fn_get_rackposition(do.Guide_Serie, do.Guide_Number)
		) AS [Ubicacion_Bodega],
		(
			SELECT TOP 1
				   (CASE
						WHEN dp.ID > 0 THEN
							1
						ELSE
							0
					END
				   )
			FROM DeliveryBackOffice.dbo.DeliveryProof dp WITH (NOLOCK)
			WHERE dp.Guide_Serie = do.Guide_Serie 
				AND dp.Guide_Number = do.Guide_Number
		) AS [Evidencia_Entrega],
		(
			SELECT TOP 1
				   Latitude
			FROM DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
			WHERE da.guide_serie = do.guide_serie 
				AND da.Guide_Number = do.Guide_Number
				AND LTRIM(RTRIM(ISNULL(Longitude,''))) <> '' AND LTRIM(RTRIM(ISNULL(Latitude,''))) <> ''
			ORDER BY da.Date_Created DESC
		) AS [Latitude],
		(
			SELECT TOP 1
				   Longitude
			FROM DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
			WHERE da.guide_serie = do.guide_serie 
				AND da.Guide_Number = do.Guide_Number
				AND LTRIM(RTRIM(ISNULL(Longitude,''))) <> '' 
				AND LTRIM(RTRIM(ISNULL(Latitude,''))) <> ''
			ORDER BY da.Date_Created DESC
		) AS Longitude,
		(
			SELECT (CASE
						WHEN COUNT(dod6.Guide_Number) > 0 THEN
							1
						ELSE
							0
					END
				   )
			FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod6 WITH (NOLOCK)
			WHERE dod6.Guide_Serie = do.Guide_Serie
				AND dod6.Guide_Number = do.Guide_Number
				  AND dod6.StatusOrderId IN (14,23)
		) AS [Devuelto],
		(
		ISNULL(CONVERT(NUMERIC(10,2), DeliveryBackOffice.dbo.fn_get_diff_minutes_without_holidays_by_country(
			(
                 SELECT TOP 1
                        DateCreatedInSystem
                 FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH (NOLOCK)
                 WHERE Guide_Serie = do.guide_serie
					        AND Guide_Number = do.Guide_Number
                  AND StatusOrderId IN (2,11)
             )
			,
			(
                 SELECT TOP 1
                        DateCreated
                 FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH (NOLOCK)
                 WHERE Guide_Serie = do.guide_serie 
					          AND Guide_Number = do.Guide_Number
                    AND StatusOrderId IN( 5,22)
             )
			 ,
			 do.ReceiverCountryId
			 ) / CONVERT(NUMERIC(10,2), 1440)),0) -- convierte a días la respuesta de la función que devuelve minutos
    ) AS [Dias_Para_Entrega],
    (ISNULL(
     (
         SELECT TOP 1
                DATEDIFF(DAY, dod11.DateCreated, GETDATE()) AS fecha
         FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod11 WITH (NOLOCK)
         WHERE do.StatusOrderId NOT IN ( 5, 14, 22, 23 )
			AND dod11.Guide_Serie = do.Guide_Serie
            AND dod11.Guide_Number = do.Guide_Number
            AND dod11.StatusOrderId = 11
     ),
     0
           )
    ) AS [Dias_Sin_Entrega],
    c.[Name],
    do.Sender_ID,
	IIF(CTM2.IdCustomer IS NULL,C.IdCustomer,CTM2.IdCustomer) AS [IdCustomer],
	C.IdCustomer AS [IdCustomer1],
	CTM2.IdCustomer AS [IdCustomer2],
    ISNULL(UPPER(c.[Name]),
           (ISNULL(
            (
                SELECT TOP 1
                       UPPER(custome.[Name])
                FROM DeliveryBackOffice.dbo.Customer custome WITH (NOLOCK)
                WHERE custome.IdCustomer = do.IdCustomer
            ),
            (
                SELECT TOP 1
                       UPPER(tomer.[Name])
                FROM [DeliveryBackOffice].[dbo].[VisitPointClient] visit WITH (NOLOCK)
                    LEFT JOIN DeliveryBackOffice.dbo.Customer tomer WITH (NOLOCK)
                        ON tomer.IdCustomer = visit.CustomerID
                WHERE visit.CodeOfReference = do.[Sender_ID]
            )
                  )
           )
          ) AS [Customer_Name],
    CASE
        WHEN do.IsCollect = 'TRUE' THEN
            1
        ELSE
            0
    END AS [IsCollect],
    ISNULL(
		CAST(do.PriceShippment/@IVA AS DECIMAL(14,2))
	, 0) AS [PriceShipment],
    CASE
        WHEN do.Receiver_ID > 0
             AND do.Receiver_ID IN
                 (
                     SELECT vpco.CodeOfReference
                     FROM #VisitPointsCorporate vpco
                     WHERE vpco.CustomerID = c.IdCustomer
                 )
             AND do.Sender_ID = do.Receiver_ID --esta condicion se interpreta como una devolucion
    THEN
            1
        ELSE
            0
    END AS [IsReturn],    
	do.[Collect_OnDelivery] AS [MontoCOD],
	 (
	     SELECT TOP 1 CASE ISNULL(guiapagada.IdStatus,'false') WHEN 'true' THEN 'PAGADA' ELSE 'NO PAGADA' END
		 FROM DeliveryBackOffice.dbo.DeliveryOrderPaid guiapagada  WITH (NOLOCK)
		 WHERE do.Guide_Serie = guiapagada.Guide_Serie 
		   AND do.Guide_Number = guiapagada.Guide_Number 
		   AND guiapagada.IdStatus = 1
	   ) AS [EstadoCOD],
	 (
	     SELECT TOP 1 guiapagada.DateCreated
		 FROM DeliveryBackOffice.dbo.DeliveryOrderPaid guiapagada  WITH (NOLOCK)
		 WHERE do.Guide_Serie = guiapagada.Guide_Serie 
		   AND do.Guide_Number = guiapagada.Guide_Number 
		   AND guiapagada.IdStatus = 1
	   ) AS [FechaPagoDepositoCOD],
    ISNULL(do.BilledWeight, 0) AS [BilledWeight],
    (
        SELECT TOP 1
               [ID_DeliveryOrderBySettlement]
        FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] da1 WITH (NOLOCK)
        WHERE da1.Guide_Serie = do.Guide_Serie
          AND da1.Guide_Number = do.Guide_Number
    ) AS [Manifiesto_Despacho],
    (
        SELECT TOP 1
               DateCreated
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod12 WITH (NOLOCK)
        WHERE dod12.guide_serie = do.Guide_Serie
          AND dod12.Guide_Number = do.Guide_Number
          AND dod12.StatusOrderId IN(5,22)
    ) AS [Fecha_Entrega_Checkpoint],
    do.[Sender_Phone],
    do.[Sender_Mail],
    [TypeService],   
	(
		SELECT TOP 1 CSA.SaleAdvisorCode 
		FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
		WHERE IIF(C.SaleAdvisorID IS NULL,CTM2.SaleAdvisorID,C.SaleAdvisorID)  = CSA.IdSaleAdvisor
	) AS [SaleAdvisorCode],
	(
		ISNULL(
			(SELECT TOP 1 
				CAST(BD.Commission/@IVA AS DECIMAL(14,2))
			FROM [DeliveryBackOffice].[dbo].[BatchDetailCOD] BD WITH (NOLOCK)
			WHERE BD.GuideSerie = DO.Guide_Serie 
				AND BD.GuideNumber = do.Guide_Number
		   )
		,0)
    ) AS [Precio_x_Comision],
    VPCO.DateStartOperation,
	(SELECT TOP 1BusinessSegmentName FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
        WHERE CBS.IdBusinessSegment = IIF(c.BusinessSegmentID IS NULL,CTM2.BusinessSegmentID,c.BusinessSegmentID)) AS BusinessSegmentName,
	(SELECT TOP 1 BusinessActivityName FROM DeliveryBackOffice.dbo.CatBusinessActivity CBA WITH (NOLOCK)
        WHERE CBA.IdBusinessActivity = IIF(c.BusinessActivityID IS NULL,CTM2.BusinessActivityID,c.BusinessActivityID)) AS BusinessActivityName,
    (SELECT TOP 1  TypeOfBusinessName FROM DeliveryBackOffice.dbo.CatTypeOfBusiness CTOB WITH (NOLOCK)
        WHERE CTOB.IdTypeOfBusiness = IIF(c.TypeOfBusinessID IS NULL,CTM2.TypeOfBusinessID,c.TypeOfBusinessID)) AS TypeOfBusinessName,
	COALESCE(
	(SELECT TOP 1 CSC.Description FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
			ON VPC2.CustomerID = CTM2.IdCustomer
        WHERE CSC.IdSalesChannel = IIF(VPC.SaleChannelId IS NULL,VPC2.SaleChannelId,VPC.SaleChannelId)),'Portal Web') AS KindOfVPName,
    DB.[Name] AS BankName,
    CBAT.BankAccountType
	 ,(
        SELECT TOP 1 MAX(CV.Hub) HUB
        FROM dbo.DumpServiceCoverage CV  WITH (NOLOCK)
		WHERE CV.HeaderCode = ISNULL(TONW_S.HeaderCode, TONW_S.HeaderCode)
        GROUP BY CV.HeaderCode
    )SenderHub
    ,(
        SELECT TOP 1 MAX(CV.Hub) HUB
        FROM dbo.DumpServiceCoverage CV  WITH (NOLOCK)
		WHERE CV.HeaderCode = ISNULL(TONW_R.HeaderCode, TONW_R.HeaderCode)
        GROUP BY CV.HeaderCode
    )ReceiverHub,

	 PRP.IdVisitPointByClientPortfolio
	, PRP.FIRSTNAME
	,do.[Receiver_SocialSecurity_ID]
	,do.[Receiver_Alternant_SocialSecurity_ID]
	,do.[Receiver_CUI]
	,do.[Receiver_Alternant_CUI],
	(
	SELECT CASE 
		WHEN ((
			SELECT DOR.Guide_Number 
			FROM dbo.DeliveryOrder DOR  WITH (NOLOCK)
			WHERE DOR.Guide_Serie = do.Guide_Serie
				AND DOR.Guide_Number = do.Guide_Number
				AND EXISTS
				(
					SELECT 1 FROM dbo.invoiceDetail IND  WITH(NOLOCK)
					INNER JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH(NOLOCK) 
						ON IND.dti_fk_header = INH.inv_pk_id
							AND INH.inv_certificationFEL IS NOT NULL
							AND INH.inv_descriptionFEL = 'PROCESO REALIZADO'
							AND INH.inv_creditNote IS NULL
							AND INH.inv_motiveCreditNote IS NULL
					WHERE DOR.Guide_Serie = IND.dti_fk_orderSerie
						AND DOR.Guide_Number = IND.dti_fk_orderNumber
				)
				) > 0)
		THEN 1
		ELSE 0
	END
	) AS [Facturado],
	(SELECT TOP 1 KindOfVPNameBussiness FROM DeliveryBackOffice.dbo.KindOfVPBusiness kob  WITH (NOLOCK) WHERE kob.IdKindOfVPBusiness = vpc.IdKindOfVPBusiness
	) AS KindOfVPNameBussiness,
	(SELECT TOP 1 CommercialSegmentName FROM dbo.CatCommercialSegment CCS  WITH (NOLOCK) WHERE CCS.IdCommercialSegment = ISNULL(C.CommercialSegmentID,CTM2.CommercialSegmentID)
	) AS CommercialSegmentName,
	(
		SELECT TOP 1 INH.inv_date 
		FROM DeliveryBackOffice.dbo.invoiceDetail IND  WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH(NOLOCK) 
				ON IND.dti_fk_header = INH.inv_pk_id
			AND INH.inv_certificationFEL IS NOT NULL
			AND INH.inv_descriptionFEL = 'PROCESO REALIZADO'
			AND INH.inv_creditNote IS NULL
			AND INH.inv_motiveCreditNote IS NULL
		WHERE DO.Guide_Serie = IND.dti_fk_orderSerie
			AND DO.Guide_Number = IND.dti_fk_orderNumber
		ORDER BY INH.inv_date
	) AS [InvoiceDate],
	(
		SELECT CASE WHEN (CTMR.RowSatus = 1) THEN
				'ACTIVO'

			ELSE
				'INACTIVO'
		END
		FROM dbo.Customer CTMR WITH (NOLOCK) 
		WHERE CTMR.IdCustomer = vpc.customerId
	) AS [CustomerStatus],
	(
        SELECT TOP 1
               cti.NameIncidence
        FROM DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
		INNER JOIN dbo.CatTypeIncidence cti WITH(NOLOCK) 
			ON cti.IdIncidenceType = da.ID_Incident
        WHERE da.guide_serie = do.guide_serie 
			AND da.Guide_Number = do.Guide_Number
		ORDER BY da.Date_Created DESC
    ) AS [Incidencia_Entrega],
	ISNULL((
			SELECT TOP 1 bk98.Amount
			FROM dbo.DeliveryOrder do98 WITH (NOLOCK)
				LEFT JOIN dbo.Cost cst98 WITH (NOLOCK)
					ON cst98.GuideSerie = do98.Guide_Serie 
						AND cst98.GuideNumber = do98.Guide_Number
					    AND cst98.RowStatus = 1
               LEFT JOIN dbo.BreakdownOfPayment bk98 WITH (NOLOCK)
                   ON bk98.IdCost = cst98.IdCost
           WHERE bk98.Amount > 0 AND bk98.RowStatus = 1
                 AND bk98.Description = 'Otros cargos'
				 AND cst98.GuideSerie = do.Guide_Serie
				 AND cst98.GuideNumber = do.Guide_Number
       ),0) AS [TC],
	ISNULL((
           SELECT TOP 1 bk99.Amount
           FROM dbo.DeliveryOrder do99 WITH (NOLOCK)
               LEFT JOIN dbo.Cost cst99 WITH (NOLOCK)
                   ON cst99.GuideSerie = do99.Guide_Serie 
					  AND cst99.GuideNumber = do99.Guide_Number
                      AND cst99.RowStatus = 1
               LEFT JOIN dbo.BreakdownOfPayment bk99 WITH (NOLOCK)
                   ON bk99.IdCost = cst99.IdCost
           WHERE bk99.Amount > 0 AND bk99.RowStatus = 1
                 AND bk99.Description = 'Recargo por peso'
				 AND cst99.GuideSerie = do.Guide_Serie 
				 AND cst99.GuideNumber = do.Guide_Number
       ),0) AS [Extra Peso],
	ISNULL((
           SELECT TOP 1 bk97.Amount
           FROM dbo.DeliveryOrder do97 WITH (NOLOCK)
               LEFT JOIN dbo.Cost cst97 WITH (NOLOCK)
                   ON cst97.GuideSerie = do.Guide_Serie 
					AND cst97.GuideNumber = do.Guide_Number
                    AND cst97.RowStatus = 1
               LEFT JOIN dbo.BreakdownOfPayment bk97 WITH (NOLOCK)
                   ON bk97.IdCost = cst97.IdCost
           WHERE bk97.Amount > 0 AND bk97.RowStatus = 1
                 AND bk97.Description = 'Seguro'
				 AND do97.Guide_Serie = cst97.GuideSerie
				 AND do97.Guide_Number = cst97.GuideNumber
       ),0) AS [Seguro],
	IIF(do.IsCollect = 'true', 3, 0) AS [Collect],
	ISNULL(pc.DiscountAmount, 0) AS [Descuento],
	ISNULL(
    (
        SELECT TOP 1
               css.CrsName
        FROM dbo.DeliveryOrder oor WITH (NOLOCK)
            LEFT JOIN dbo.Township ttw WITH (NOLOCK)
                ON ttw.IdTownship = oor.SenderIdTownship
            LEFT JOIN dbo.Township ttt WITH (NOLOCK)
                ON ttt.TownshipName = REPLACE(
                                                 REPLACE(
                                                            REPLACE(
                                                                       REPLACE(
                                                                                  REPLACE(oor.Sender_Town, 'á', 'a'),
                                                                                  'é',
                                                                                  'e'
                                                                              ),
                                                                       'í',
                                                                       'i'
                                                                   ),
                                                            'ó',
                                                            'o'
                                                        ),
                                                 'ú',
                                                 'u'
                                             )
            LEFT JOIN dbo.Township tto WITH (NOLOCK)
                ON tto.IdTownship = oor.ReceiverIdTownship
            LEFT JOIN dbo.Township too WITH (NOLOCK)
                ON too.TownshipName = REPLACE(
                                                 REPLACE(
                                                            REPLACE(
                                                                       REPLACE(
                                                                                  REPLACE(oor.Receiver_Town, 'á', 'a'),
                                                                                  'é',
                                                                                  'e'
                                                                              ),
                                                                       'í',
                                                                       'i'
                                                                   ),
                                                            'ó',
                                                            'o'
                                                        ),
                                                 'ú',
                                                 'u'
                                             )
            INNER JOIN dbo.RateTownshipCoverage rtc WITH (NOLOCK)
                ON rtc.TownshipDestinyId = ISNULL(too.IdTownship, tto.IdTownship)
                   AND rtc.TownshipSourceId = ISNULL(ttt.IdTownship, ttw.IdTownship)                   
            INNER JOIN dbo.CatRateSegment css WITH (NOLOCK)
                ON css.CrsId = rtc.SegmentTypeId
        WHERE oor.Guide_Serie = do.Guide_Serie
              AND oor.Guide_Number = do.Guide_Number
			  AND rtc.RateId = 2285
    ),
    'DEPARTAMENTAL') AS [Tipo Destino],
    ISNULL(ch.Description, 'Portal Web') As [KindOfVpName],
	0 AS [Recargo],
	ISNULL((
		SELECT MAX(btc.Commission)
		FROM dbo.BatchDetailCOD btc WITH (NOLOCK)
		WHERE btc.GuideSerie = do.Guide_Serie
           AND btc.GuideNumber = do.Guide_Number
           AND btc.CatConceptCODId = 2
	),0) AS [Comission COD],
	ISNULL((
		SELECT MAX(btc2.CODCommissionPercentage)
		FROM dbo.BatchDetailCOD btc2 WITH (NOLOCK)
		WHERE btc2.GuideSerie = do.Guide_Serie
           AND btc2.GuideNumber = do.Guide_Number
           AND btc2.CatConceptCODId = 2
	),0) AS [Porcentaje_COD],
	0 AS 'NUEVO PRECIO',
	'N/A' AS 'SERVICIO',
	(
		SELECT TOP 1 DateCreated 
		FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod15 WITH(NOLOCK) 
		WHERE dod15.Guide_Serie = do.Guide_Serie
			AND dod15.Guide_Number = do.Guide_Number
			AND dod15.StatusOrderId = do.[StatusOrderId]
		ORDER BY dod15.DateCreated DESC
	) AS [Last_Checkpoint_Datetime],
	(
        SELECT (CASE
                    WHEN COUNT(Guide_Number) > 0 THEN
                        1
                    ELSE
                        0
                END
               )
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod53 WITH (NOLOCK)
        WHERE dod53.Guide_Serie = do.Guide_Serie
			AND dod53.Guide_Number = do.Guide_Number
            AND dod53.StatusOrderId = 22
    ) AS [Fue_Entregado_EXC],
	(
        SELECT TOP 1 DateCreated
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod33 WITH (NOLOCK)
        WHERE dod33.Guide_Serie = do.Guide_Serie
			AND dod33.Guide_Number = do.Guide_Number
            AND dod33.StatusOrderId = 22
        ORDER BY DateCreated ASC
    ) AS [Primer_Fecha_Fue_Entregado_EXC],
    ISNULL(traslado.[Fue_Trasladado_Recibido_EXC], 0) AS [Fue_Trasladado_Recibido_EXC],
    traslado.[Primer_Fecha_Trasladado_Recibido_EXC],
	do.ReceiverCountryId [Destination_Country],
	do.[Ticket_Number],
    ISNULL(ultimoMov.[TimeSinceLastMovement], 0) AS [TimeSinceLastMovement]
FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH (NOLOCK) -- 1,197,011
    INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
        ON so.StatusOrderId = do.StatusOrderId  	
	LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
        ON vpc.CodeOfReference = do.Sender_ID 
	LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] c WITH (NOLOCK)
        ON c.IdCustomer = vpc.CustomerID
	LEFT JOIN DeliveryBackOffice.dbo.Customer CTM2 WITH(NOLOCK)
		ON DO.IdCustomer = CTM2.IdCustomer
    LEFT JOIN DeliveryBackOffice.dbo.Package pa WITH (NOLOCK)
        ON pa.Package_Type = do.Package_Type
    LEFT JOIN DeliveryBackOffice.dbo.VisitPointConfiguration VPCO WITH (NOLOCK)
        ON VPCO.VisitPointID = do.Sender_ID
    LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank DB WITH (NOLOCK)
        ON DB.Id_bank = c.CODAccountBankID
    LEFT JOIN DeliveryBackOffice.dbo.CatBankAccountType CBAT WITH (NOLOCK)
        ON CBAT.IdBankAccountType = c.CODAccountTypeID
    LEFT JOIN dbo.Township  TONW_R WITH (NOLOCK)
		ON  TONW_R.IdTownship = DO.ReceiverIdTownship
	LEFT JOIN dbo.Township  TONW_S WITH (NOLOCK)
		ON  TONW_S.IdTownship = DO.SenderIdTownship
	LEFT JOIN(
		SELECT MIN(PRF.Email) EMAIL, MIN(PRF.IdVisitPointByClientPortfolio) IdVisitPointByClientPortfolio , MIN(COALESCE(PRF.FirstName,'') + IIF(LEN(PRF.FirstName) = 0,'','') + COALESCE(PRF.SecondName,'') + IIF(LEN(PRF.SecondName)=0,'',' ') + COALESCE(PRF.LastName,'') + IIF(LEN(PRF.LastName) = 0,'',' ') + COALESCE(PRF.SecondLastName,'')) FIRSTNAME , PRF.Phone  
		FROM DBO.VisitPointByClientPortfolio PRF  WITH (NOLOCK)
		GROUP BY PRF.Phone, PRF.Email
		) PRP ON PRP.Email = DO.Sender_Mail AND PRP.Phone = DO.Sender_Phone AND ISNULL(c.IdCustomerType, ctm2.IdCustomerType) =2
	LEFT JOIN dbo.Cost cst WITH (NOLOCK)
		ON cst.GuideSerie = do.Guide_Serie 
			AND cst.GuideNumber = do.Guide_Number
			AND cst.RowStatus = 1
	LEFT JOIN dbo.PromoCoupon pc WITH (NOLOCK)
        ON pc.GuideSerieDestination = do.Guide_Serie
           AND pc.GuideNumberDestination = do.Guide_Number
	LEFT JOIN dbo.CatSalesChannel ch WITH (NOLOCK)
        ON ch.IdSalesChannel = vpc.SaleChannelId
    OUTER APPLY (
        SELECT 
            CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS [Fue_Trasladado_Recibido_EXC],
            MIN(DateCreated) AS [Primer_Fecha_Trasladado_Recibido_EXC]
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WITH (NOLOCK)
        WHERE dod.Guide_Serie = do.Guide_Serie
            AND dod.Guide_Number = do.Guide_Number
            AND dod.StatusOrderId IN (20,21)
    ) traslado
    OUTER APPLY (
        SELECT TOP 1 
            CASE 
                WHEN Statusorderid IN (5, 22, 14, 23) THEN 0
                ELSE DATEDIFF(HOUR, DateCreated, GETDATE())
            END AS [TimeSinceLastMovement]
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WITH (NOLOCK)
        WHERE dod.Guide_Serie = do.Guide_Serie
            AND dod.Guide_Number = do.Guide_Number
        ORDER BY dod.DateCreated DESC
    ) ultimoMov
    WHERE do.Guide_Number > 2301
        AND do.StatusOrderId <> 7
        AND do.StatusOrderId <> 15
        AND do.DateCreated  >= DATEADD(DAY, -45, DATEDIFF(DAY, 0, GETDATE()));
        --AND do.DateCreated >= '2025-10-20 00:00:00'; -- Para pruebas

IF OBJECT_ID('tempdb.dbo.#VisitPointsCorporate', 'U') IS NOT NULL
    DROP TABLE #VisitPointsCorporate;
END
