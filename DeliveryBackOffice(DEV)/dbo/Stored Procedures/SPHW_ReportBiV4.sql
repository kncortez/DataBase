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
   INNER JOIN Customer cust
        ON vpc.CustomerID = cust.IdCustomer
WHERE cust.IdCustomerType = 1; --corporativo
--and cust.IdCustomer = 24

create nonclustered index temp_visit on #VisitPointsCorporate (CodeOfReference)
create nonclustered index temp_visit_customerid on #VisitPointsCorporate (CustomerID)

DECLARE @IVA DECIMAL (14,2) = 1.12

SELECT 
    --,[Order_Number]
    --(SELECT CONVERT(VARCHAR,[Preparation_Date],103)) AS [Fecha_Preparacion] * -- fecha de arribó a instalaciones (11)
    
	(
        SELECT TOP 1
               CONVERT(VARCHAR, DateCreated, 103)
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod10 WITH (NOLOCK)
        WHERE dod10.Guide_Serie = do.Guide_Serie
				and dod10.Guide_Number = do.Guide_Number
              AND dod10.StatusOrderId = 11
        ORDER BY DateCreated ASC
    ) AS [Fecha_Preparacion],
    --,(SELECT CONVERT(VARCHAR,[Shipping_Date],103)) AS [Fecha_Recoleccion] * -- fecha de despacho a ruta (manifiesto)
    (
        SELECT TOP 1
               dobs.Date_Dispatched
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dobs WITH (NOLOCK)
           INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd WITH (NOLOCK)
                ON dsd.ID_DeliveryOrderBySettlement = dobs.ID
        WHERE dsd.Guide_Serie = do.guide_serie 
				and dsd.Guide_Number = do.Guide_Number
        ORDER BY dobs.ID DESC
    ) AS [Fecha_Recoleccion],
    [Pieces_Dry] AS [Piezas_Secas],
    [Pieces_Cold] AS [Piezas_Frias],
    --,[Consolidated_Number]
    --,[Recipe_Number]
    --,[Sender_ID]
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
    --vpc.DescriptionOfClient as [Sender_Name]
    --,([Sender_FirstName] + ' ' + [Sender_LastName]) AS [Sender_Name]
    [Sender_Address],
    [Sender_Zone],
    [Sender_Town],
    [Sender_Department],
    --,[Receiver_ID]
    (RTRIM(LTRIM(ISNULL([Receiver_FirstName], ''))) + ' ' + RTRIM(LTRIM(ISNULL([Receiver_LastName], '')))) AS [Receiver_Name],
    [Receiver_Address],
    [Receiver_Zone],
    [Receiver_Town],
    [Receiver_Department],
    [Receiver_Phone],
    --,[Receiver_Email]
    --,[Receiver_SocialSecurity_ID]
    --,[Receiver_Alternant_ID]
    --,[Receiver_Alternant_FullName]
    --,[Receiver_Alternant_Address]
    --,[Receiver_Alternant_Zone]
    --,[Receiver_Alternant_Town]
    --,[Receiver_Alternant_Department]
    --,[Receiver_Alternant_Phone]
    --,[Receiver_Alternant_Email]
    --,[Receiver_Alternant_SocialSecurity_ID]
    (
        SELECT CONVERT(VARCHAR, [Delivery_Max_Date], 103)
    ) AS [Fecha_Limite_Entrega],
    --,[printedStatus]
    do.[Guide_Serie] + CAST(do.[Guide_Number] AS VARCHAR) AS [Waybill],
    [Manifest_Serie] + CAST([Manifest_Number] AS VARCHAR) AS [Manifest],
    (
        SELECT CONVERT(VARCHAR, do.[DateCreated], 103)
    ) AS [Fecha_Solicitud],
    do.[StatusOrderId] AS [Last_Checkpoint_Code],
    so.OrderDescription AS [Last_Checkpoint_Name],
    --,[Receiver_CUI]
    [Package_Description],
    --,[Sender_Internal_Code]
    --,[Receiver_Alternant_CUI]
    [Courier_Route],
    --,[Courier_Name] as [Afiliado_Programacion_Ruta]
    --,isnull((SELECT DeliveryBackOffice.dbo.fn_get_last_couriername_attempt(do.Guide_Serie, do.Guide_Number)),'SIN_VALIDACION_POD') Courier_Name
    (
        SELECT Courier_Fullname
        FROM DeliveryBackOffice.dbo.fn_get_last_information_attempt_without_accepted(do.Guide_Serie, do.Guide_Number)
    ) AS Courier_Name,
    --,[Courier_Vehicle_Plate]
    --,(SELECT CONVERT(VARCHAR,[Dispatched_Date],103)) AS [Fecha_Despacho_Ruta]
    (
        SELECT Date_Delivered
        FROM DeliveryBackOffice.dbo.fn_get_last_information_attempt_without_accepted(do.Guide_Serie, do.Guide_Number)
    ) AS [Fecha_Despacho_Ruta],
    --,[Dispatched_Token]
    REPLACE(REPLACE(ISNULL([NameOfReceiver], ''), CHAR(13), ''), CHAR(10), '') [Name_Of_Receiver],
    --,do.Package_Type
    pa.Package_Name,
    (
        SELECT TOP 1
               CONVERT(VARCHAR, DateCreated, 103)
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod1 WITH (NOLOCK)
        WHERE dod1.Guide_Serie = do.Guide_Serie 
		and dod1.Guide_Number = do.Guide_Number
              AND dod1.StatusOrderId = 3
        ORDER BY DateCreated ASC
    ) AS [Primera_Fecha_Programado_Entrega],
    (
        SELECT COUNT(Guide_Number)
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod2 WITH (NOLOCK)
        WHERE dod2.Guide_Serie = do.Guide_Serie 
		and dod2.Guide_Number = do.Guide_Number
              AND dod2.StatusOrderId = 3
    ) AS [Veces_Programado_Entrega],
    (
        SELECT TOP 1
               CONVERT(VARCHAR, DateCreated, 103)
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod3 WITH (NOLOCK)
        WHERE dod3.Guide_Serie = do.Guide_Serie
				and dod3.Guide_Number = do.Guide_Number
              AND dod3.StatusOrderId IN(5,22)
        ORDER BY DateCreated ASC
    ) AS [Primera_Fecha_Entrega],
    (
        SELECT COUNT(Guide_Number)
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod4 WITH (NOLOCK)
        WHERE dod4.Guide_Serie = do.Guide_Serie
			  and dod4.Guide_Number = do.Guide_Number
              AND dod4.StatusOrderId  IN(5,22)
    ) AS [Veces_Entregas_Registradas],
    (
        SELECT (CASE
                    WHEN COUNT(Guide_Number) > 0 THEN
                        1
                    ELSE
                        0
                END
               )
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod5 WITH (NOLOCK)
        WHERE dod5.Guide_Serie = do.Guide_Serie
				and dod5.Guide_Number = do.Guide_Number
              AND dod5.StatusOrderId IN(5,22)
    ) AS [Entregado],
    --,(SELECT TOP 1 DeliveryBackOffice.dbo.fn_get_document_image_url(do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR))) [Ruta_Digitalizado]
    /*(
        SELECT CASE
                   WHEN (
                        (
                            SELECT DeliveryBackOffice.dbo.fn_get_document_image_url(do.Guide_Serie
                                                                                    + CAST(do.Guide_Number AS VARCHAR)
                                                                                   )
                        ) IS NULL
                        ) THEN
                       0
                   ELSE
                       1
               END
    ) AS [Digitalizado],*/
	0 AS [Digitalizado],
    (
        SELECT ISNULL([Collect_OnDelivery], 0)
    ) AS [Monto_A_Cobrar],
    --,(CASE WHEN [Guide_Collected] = 1 THEN 'SI' ELSE 'NO' END) as [Monto_Cobrado]



    --(
    --    SELECT ISNULL(   (CASE
    --                          WHEN do.Guide_Collected = 1 THEN
    --                              Collect_OnDelivery
    --                          ELSE
    --                              0
    --                      END
    --                     ),
    --                     0
    --                 )
    --) AS [Monto_Cobrado],
    
	

	(SELECT (CASE
                    WHEN (
						SELECT COUNT(Guide_Number)
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod51 WITH (NOLOCK)
        WHERE dod51.Guide_Serie = do.Guide_Serie
				and dod51.Guide_Number = do.Guide_Number
              AND dod51.StatusOrderId  IN(5,22)
					) > 0 THEN
                        Collect_OnDelivery
                    ELSE
                        0
                END
	)) AS [Monto_Cobrado],
	
	
	
	
	--,[Rack_Position] as [Ubicacion_Bodega]
    --,(CASE WHEN [Receiver_Updated] = 1 THEN 'SI' ELSE 'NO' END) as [Datos_Modificados]
    (
        SELECT ISNULL([Receiver_Updated], 0)
    ) AS [Datos_Modificados],
    --,(select (CASE WHEN COUNT(Guide_Number) > 0 THEN 1 ELSE 0 END) from DeliveryBackOffice.dbo.DeliveryOrderDetail dod6 with(nolock) where dod6.Guide_Number = do.Guide_Number and dod6.StatusOrderId = 6) AS [Retornado_Origen]
    --,(select (CASE WHEN COUNT(Guide_Number) > 0 THEN 1 ELSE 0 END) from DeliveryBackOffice.dbo.DeliveryOrderDetail dod7 with(nolock) where dod7.Guide_Number = do.Guide_Number and dod7.StatusOrderId = 8) AS [Retornado_Forza]
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
        WHERE dp.Guide_Serie = do.Guide_Serie and dp.Guide_Number = do.Guide_Number
    ) AS [Evidencia_Entrega],
    (
        SELECT TOP 1
               Latitude
        FROM DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
        WHERE da.guide_serie = do.guide_serie and da.Guide_Number = do.Guide_Number
		AND LTRIM(RTRIM(ISNULL(Longitude,''))) <> '' AND LTRIM(RTRIM(ISNULL(Latitude,''))) <> ''
		ORDER BY da.Date_Created DESC
    ) AS Latitude,
    (
        SELECT TOP 1
               Longitude
        FROM DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
        WHERE da.guide_serie = do.guide_serie and da.Guide_Number = do.Guide_Number
		AND LTRIM(RTRIM(ISNULL(Longitude,''))) <> '' AND LTRIM(RTRIM(ISNULL(Latitude,''))) <> ''
		ORDER BY da.Date_Created DESC
    ) AS Longitude,
    (
        SELECT (CASE
                    WHEN COUNT(Guide_Number) > 0 THEN
                        1
                    ELSE
                        0
                END
               )
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod6 WITH (NOLOCK)
        WHERE	dod6.Guide_Serie = do.Guide_Serie
				and dod6.Guide_Number = do.Guide_Number
              AND dod6.StatusOrderId IN (14,23)
    ) AS [Devuelto],
    (
		ISNULL(CONVERT(NUMERIC(10,2), DeliveryBackOffice.dbo.fn_get_diff_minutes_without_holidays_by_country(
			(
                 SELECT TOP 1
                        DateCreatedInSystem
                 FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH (NOLOCK)
                 WHERE Guide_Serie = do.guide_serie and Guide_Number = do.Guide_Number
                                                            AND StatusOrderId IN (2,11)
             )
			,
			(
                 SELECT TOP 1
                        DateCreated
                 FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH (NOLOCK)
                 WHERE Guide_Serie = do.guide_serie and Guide_Number = do.Guide_Number
                                                            AND StatusOrderId IN( 5,22)
             )
			 ,
			 do.ReceiverCountryId
			 ) / CONVERT(NUMERIC(10,2), 1440)),0) -- convierte a días la respuesta de la función que devuelve minutos
    ) AS [Dias_Para_Entrega],
    (ISNULL(
     (
         SELECT TOP 1
             --do.guide_number,
                DATEDIFF(DAY, dod11.DateCreated, GETDATE()) AS fecha
         --from deliverybackoffice.dbo.deliveryorder do
         FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod11 WITH (NOLOCK)
         WHERE do.StatusOrderId NOT IN ( 5, 14, 22, 23 )
               AND dod11.Guide_Serie = do.Guide_Serie
			   AND dod11.Guide_Number = do.Guide_Number 
               AND dod11.StatusOrderId = 11
     ),
     0
           )
    ) AS [Dias_Sin_Entrega],
    /*,CASE WHEN c.[Name] IS NOT NULL THEN
				 c.[Name]
	   ELSE 
	   (
	    select COALESCE(ctm.Name,'') from DeliveryBackOffice.dbo.Customer ctm
		where ctm.IdCustomer = do.IdCustomer
	   )
	   END as Customer_Name*/
    c.[Name],
    do.Sender_ID,
    
	IIF(CTM2.IdCustomer IS NULL,C.IdCustomer,CTM2.IdCustomer) IdCustomer,
	C.IdCustomer 'IdCustomer1',
	CTM2.IdCustomer 'IdCustomer2',


    --,c.[Name] as Customer_Name
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
          ) AS Customer_Name,
    CASE
        WHEN do.IsCollect = 'TRUE' THEN
            1
        ELSE
            0
    END AS IsCollect,
    ISNULL(
		CAST(do.PriceShippment/@IVA AS DECIMAL(14,2))
	, 0) AS PriceShipment,
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
    END IsReturn,
    
	do.[Collect_OnDelivery] [MontoCOD],
    
	--CASE ISNULL(guiapagada.IdStatus, 'false')
    --    WHEN 'true' THEN
    --        'PAGADA'
    --    ELSE
    --        'NO PAGADA'
    --END [EstadoCOD],
	 (
	     SELECT TOP 1 CASE ISNULL(guiapagada.IdStatus,'false') WHEN 'true' THEN 'PAGADA' ELSE 'NO PAGADA' END
		 FROM DeliveryBackOffice.dbo.DeliveryOrderPaid guiapagada  WITH (NOLOCK)
		 WHERE do.Guide_Serie = guiapagada.Guide_Serie 
		   AND do.Guide_Number = guiapagada.Guide_Number 
		   AND guiapagada.IdStatus = 1
	   )[EstadoCOD],
    --guiapagada.DateCreated [FechaPagoDepositoCOD],
	 (
	     SELECT TOP 1 guiapagada.DateCreated
		 FROM DeliveryBackOffice.dbo.DeliveryOrderPaid guiapagada  WITH (NOLOCK)
		 WHERE do.Guide_Serie = guiapagada.Guide_Serie 
		   AND do.Guide_Number = guiapagada.Guide_Number 
		   AND guiapagada.IdStatus = 1
	   ) [FechaPagoDepositoCOD],
    --,guiapagada.Deposit_Number  [NumeroDepositoPagoCOD]
    ISNULL(do.BilledWeight, 0) AS [BilledWeight],
    (
        SELECT TOP 1
               [ID_DeliveryOrderBySettlement]
        FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] da1 WITH (NOLOCK)
        WHERE da1.Guide_Serie = do.Guide_Serie 
				AND da1.Guide_Number = do.Guide_Number  
    ) AS Manifiesto_Despacho,
    (
        SELECT TOP 1
               DateCreated
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod12 WITH (NOLOCK)
        WHERE dod12.Guide_Serie = do.Guide_Serie
				AND dod12.Guide_Number = do.Guide_Number
              AND dod12.StatusOrderId IN(5,22)
    ) AS [Fecha_Entrega_Checkpoint],
    do.[Sender_Phone],
    do.[Sender_Mail],
    [TypeService],
    --,HL.HubName
    --,dsco.Hub AS Hub_Origen
    --,HL2.HubName
    --,dscd.Hub AS Hub_Destino    
	(SELECT TOP 1 CSA.SaleAdvisorCode FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
	 WHERE IIF(C.SaleAdvisorID IS NULL,CTM2.SaleAdvisorID,C.SaleAdvisorID)  = CSA.IdSaleAdvisor
	)SaleAdvisorCode,
	--QUITADO POR BIDCAR
	--CSA.SaleAdvisorCode,

	(
		ISNULL(
			(SELECT TOP 1 
				CAST(BD.Commission AS DECIMAL(14,2))
			FROM [DeliveryBackOffice].[dbo].[BatchDetailCOD] BD WITH (NOLOCK)
			WHERE BD.GuideSerie = DO.Guide_Serie AND BD.GuideNumber = do.Guide_Number
		   --AND BD.Amount = BD.Commission QUITADO POR BIDCAR NO ENTIENDO PARA QUE HACEN ESTA VALIDACION EL MONTO NO ES LO MISMO QUE COMISIÓN
		   )
		,0)
    ) AS Precio_x_Comision,
    (
		ISNULL(
			(SELECT TOP 1 
				CAST(BD.Commission/@IVA AS DECIMAL(14,2))
			FROM [DeliveryBackOffice].[dbo].[BatchDetailCOD] BD WITH (NOLOCK)
			WHERE BD.GuideSerie = DO.Guide_Serie AND BD.GuideNumber = do.Guide_Number
		   --AND BD.Amount = BD.Commission QUITADO POR BIDCAR NO ENTIENDO PARA QUE HACEN ESTA VALIDACION EL MONTO NO ES LO MISMO QUE COMISIÓN
		   )
		,0)
    ) AS Precio_x_ComisionGT,

    --,(
    --SELECT SUM(TotalAmount) FROM [DeliveryBackOffice].[dbo].[Cost] WHERE ProductNumber = CONCAT(DO.Guide_Serie, DO.Guide_Number) GROUP BY ProductNumber
    --) AS TotalAmount
    VPCO.DateStartOperation,
    --CBS.BusinessSegmentName,
    --CBA.BusinessActivityName,
    --CTOB.TypeOfBusinessName,
    --KVPC.KindOfVPName,

	(SELECT TOP 1BusinessSegmentName FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
        WHERE CBS.IdBusinessSegment = IIF(c.BusinessSegmentID IS NULL,CTM2.BusinessSegmentID,c.BusinessSegmentID)) BusinessSegmentName,
	(SELECT TOP 1 BusinessActivityName FROM DeliveryBackOffice.dbo.CatBusinessActivity CBA WITH (NOLOCK)
        WHERE CBA.IdBusinessActivity = IIF(c.BusinessActivityID IS NULL,CTM2.BusinessActivityID,c.BusinessActivityID)) BusinessActivityName,
    (SELECT TOP 1  TypeOfBusinessName FROM DeliveryBackOffice.dbo.CatTypeOfBusiness CTOB WITH (NOLOCK)
        WHERE CTOB.IdTypeOfBusiness = IIF(c.TypeOfBusinessID IS NULL,CTM2.TypeOfBusinessID,c.TypeOfBusinessID)) TypeOfBusinessName,
	COALESCE(
	(SELECT TOP 1 CSC.Description FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) ON VPC2.CustomerID = CTM2.IdCustomer
        WHERE CSC.IdSalesChannel = IIF(VPC.SaleChannelId IS NULL,VPC2.SaleChannelId,VPC.SaleChannelId)),'Portal Web')KindOfVPName,
		
	--LEFT JOIN DeliveryBackOffice.dbo.KindOfVPClient KVPC WITH (NOLOCK)
 --       ON KVPC.IdKindOfVPClient = vpc.IdKindOfVPClient
		--2021
		
    DB.[Name] AS BankName,
    CBAT.BankAccountType
	
	--,HB2.HUB SenderHub,
	 ,(
        SELECT TOP 1 MAX(CV.Hub) HUB
        FROM dbo.DumpServiceCoverage CV  WITH (NOLOCK)
		WHERE CV.HeaderCode = ISNULL(TONW_S.HeaderCode, TONW_S.HeaderCode)
        GROUP BY CV.HeaderCode
    )SenderHub
	--,HB.HUB  ReceiverHub	
    ,(
        SELECT TOP 1 MAX(CV.Hub) HUB
        FROM dbo.DumpServiceCoverage CV  WITH (NOLOCK)
		WHERE CV.HeaderCode = ISNULL(TONW_R.HeaderCode, TONW_R.HeaderCode)
        GROUP BY CV.HeaderCode
    )ReceiverHub

, PRP.IdVisitPointByClientPortfolio
, PRP.FIRSTNAME
,do.[Receiver_SocialSecurity_ID]
,do.[Receiver_Alternant_SocialSecurity_ID]
,do.[Receiver_CUI]
,do.[Receiver_Alternant_CUI]
,(
SELECT CASE 
    WHEN ((
SELECT Guide_Number FROM dbo.DeliveryOrder DOR  WITH (NOLOCK)
	WHERE Guide_Serie = do.guide_serie
	and	Guide_Number = do.Guide_Number
	AND EXISTS
	(
		SELECT 1 FROM dbo.invoiceDetail IND  WITH(NOLOCK)
		Inner JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH(NOLOCK) 
		ON IND.dti_fk_header = INH.inv_pk_id
		
		WHERE 
		DOR.Guide_Serie = IND.dti_fk_orderSerie
		AND DOR.Guide_Number = IND.dti_fk_orderNumber		 
		AND INH.inv_certificationFEL IS NOT NULL
		AND INH.inv_descriptionFEL = 'PROCESO REALIZADO'
		AND INH.inv_creditNote IS NULL
		AND INH.inv_motiveCreditNote IS NULL
	)
	) > 0)
	THEN 1
    ELSE 0
END
) as Facturado,
(SELECT TOP 1 KindOfVPNameBussiness FROM DeliveryBackOffice.dbo.KindOfVPBusiness kob  WITH (NOLOCK) where kob.IdKindOfVPBusiness = vpc.IdKindOfVPBusiness
)KindOfVPNameBussiness,
(SELECT TOP 1 CommercialSegmentName FROM dbo.CatCommercialSegment CCS  WITH (NOLOCK) WHERE CCS.IdCommercialSegment = ISNULL(C.CommercialSegmentID,CTM2.CommercialSegmentID)
)CommercialSegmentName,
(
		SELECT TOP 1 INH.inv_date FROM DeliveryBackOffice.dbo.invoiceDetail IND  WITH(NOLOCK)
		inner JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH(NOLOCK) 
		ON IND.dti_fk_header = INH.inv_pk_id
		WHERE DO.Guide_Serie = IND.dti_fk_orderSerie
		AND DO.Guide_Number = IND.dti_fk_orderNumber
		AND INH.inv_certificationFEL IS NOT NULL
		AND INH.inv_descriptionFEL = 'PROCESO REALIZADO'
		AND INH.inv_creditNote IS NULL
		AND INH.inv_motiveCreditNote IS NULL
		
		ORDER BY INH.inv_date

) as InvoiceDate,
(
	SELECT CASE WHEN (CTMR.RowSatus = 1) THEN
            'ACTIVO'

        ELSE
            'INACTIVO'
    END
	FROM dbo.Customer CTMR WITH (NOLOCK) 
	WHERE CTMR.IdCustomer = vpc.customerId
) as CustomerStatus,
	(
        SELECT TOP 1
               cti.NameIncidence
        FROM DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
		INNER JOIN dbo.CatTypeIncidence cti WITH(NOLOCK) ON cti.IdIncidenceType = da.ID_Incident
        WHERE da.guide_serie = do.guide_serie and da.Guide_Number = do.Guide_Number
		ORDER BY da.Date_Created DESC
    ) AS Incidencia_Entrega,
	ISNULL((
           SELECT TOP 1 bk98.Amount
           FROM dbo.DeliveryOrder do98 WITH (NOLOCK)
               LEFT JOIN dbo.Cost cst98 WITH (NOLOCK)
                   ON cst98.GuideSerie = do.Guide_Serie 
				   AND cst98.GuideNumber = do.Guide_Number
                      AND cst98.RowStatus = 1
               LEFT JOIN dbo.BreakdownOfPayment bk98 WITH (NOLOCK)
                   ON bk98.IdCost = cst98.IdCost
           WHERE bk98.Amount > 0 AND bk98.RowStatus = 1
                 AND bk98.Description = 'Otros cargos'
				 AND do98.Guide_Serie = cst98.GuideSerie
				 AND do98.Guide_Number = cst98.GuideNumber
       ),0) AS 'TC',
	ISNULL((
           SELECT TOP 1 bk99.Amount
           FROM dbo.DeliveryOrder do99 WITH (NOLOCK)
               LEFT JOIN dbo.Cost cst99 WITH (NOLOCK)
                   ON cst99.GuideSerie = do.Guide_Serie 
						AND cst99.GuideNumber = do.Guide_Number
                      AND cst99.RowStatus = 1
               LEFT JOIN dbo.BreakdownOfPayment bk99 WITH (NOLOCK)
                   ON bk99.IdCost = cst99.IdCost
           WHERE bk99.Amount > 0 AND bk99.RowStatus = 1
                 AND bk99.Description = 'Recargo por peso'
				 AND do99.Guide_Serie = cst99.GuideSerie
				 AND do99.Guide_Number = cst99.GuideNumber
       ),0) AS 'Extra Peso',
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
       ),0) AS 'Seguro',
	IIF(do.IsCollect = 'true', 3, 0) 'Collect',
	ISNULL(pc.DiscountAmount, 0) 'Descuento',
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
    'DEPARTAMENTAL'
         ) 'Tipo Destino',
    ISNULL(ch.Description, 'Portal Web') KindOfVpName,
    (
        SELECT SUM(aac.MassWeight - 10)
        FROM dbo.DeliveryOrderPiece dpp WITH (NOLOCK)
            INNER JOIN dbo.ArticleByCustomer aac WITH (NOLOCK)
                ON aac.Code = dpp.ParcelCode                   
        WHERE GuideSerie = do.Guide_Serie
              AND GuideNumber = do.Guide_Number
			  AND aac.AbcId IN ( 531, 532, 533, 534 )
    ) 'recargo',
	ISNULL((
		SELECT MAX(btc.Commission)
		FROM dbo.BatchDetailCOD btc WITH (NOLOCK)
		WHERE btc.GuideSerie = do.Guide_Serie
           AND btc.GuideNumber = do.Guide_Number
           AND btc.CatConceptCODId = 2
	),0) AS 'Comission COD',
	ISNULL((
		SELECT MAX(btc2.CODCommissionPercentage)
		FROM dbo.BatchDetailCOD btc2 WITH (NOLOCK)
		WHERE btc2.GuideSerie = do.Guide_Serie
           AND btc2.GuideNumber = do.Guide_Number
           AND btc2.CatConceptCODId = 2
	),0) AS 'Porcentaje_COD',
	0 AS 'NUEVO PRECIO',
	'N/A' AS 'SERVICIO',
	(
		SELECT TOP 1 DateCreated 
		FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod15 WITH(NOLOCK) 
		WHERE dod15.Guide_Serie = do.Guide_Serie
		and dod15.Guide_Number = do.Guide_Number
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
				and dod53.Guide_Number = do.Guide_Number
              AND dod53.StatusOrderId = 22
    ) AS [Fue_Entregado_EXC],
	(
        SELECT TOP 1 DateCreated
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod33 WITH (NOLOCK)
        WHERE dod33.Guide_Serie = do.Guide_Serie
				and dod33.Guide_Number = do.Guide_Number
              AND dod33.StatusOrderId = 22
        ORDER BY DateCreated ASC
    ) AS [Primer_Fecha_Fue_Entregado_EXC],
	(
        SELECT (CASE
                    WHEN COUNT(Guide_Number) > 0 THEN
                        1
                    ELSE
                        0
                END
               )
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod54 WITH (NOLOCK)
        WHERE     dod54.Guide_Serie  = do.Guide_Serie 
		      AND dod54.Guide_Number = do.Guide_Number
              AND dod54.StatusOrderId IN(20,21)
    ) AS [Fue_Trasladado_Recibido_EXC],
	(
        SELECT TOP 1 DateCreated
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod34 WITH (NOLOCK)
        WHERE dod34.Guide_Serie = do.Guide_Serie
				and dod34.Guide_Number = do.Guide_Number
              AND dod34.StatusOrderId IN (20,21)
        ORDER BY DateCreated ASC
    ) AS [Primer_Fecha_Trasladado_Recibido_EXC],
	do.ReceiverCountryId [Destination_Country],
	do.[Ticket_Number]
   ,  ISNULL(ultimoMov.[TimeSinceLastMovement], 0) AS [TimeSinceLastMovement]
FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH (NOLOCK) -- 1,197,011
    inner JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
        ON so.StatusOrderId = do.StatusOrderId    
	
	--POR SENDER
	LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
        ON vpc.CodeOfReference = do.Sender_ID 
	LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] c WITH (NOLOCK)
        ON c.IdCustomer = vpc.CustomerID
          -- AND c.IdCustomer = do.IdCustomer
	
	--POR CUSTOMER	
	LEFT JOIN DeliveryBackOffice.dbo.Customer CTM2 WITH(NOLOCK)
	ON DO.IdCustomer = CTM2.IdCustomer
	--LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2
	--ON VPC2.CustomerID = CTM2.IdCustomer

    left JOIN DeliveryBackOffice.dbo.Package pa WITH (NOLOCK)
        ON pa.Package_Type = do.Package_Type
 --   LEFT JOIN DeliveryOrderPaid guiapagada WITH (NOLOCK)
 --       ON
 --       /*do.Guide_Serie = guiapagada.Guide_Serie 
	--and*/
 --       do.Guide_Number = guiapagada.Guide_Number
 --       AND guiapagada.IdStatus = 1
    --LEFT JOIN DeliveryBackOffice.dbo.Customer CU WITH(NOLOCK) ON CU.IdCustomer = DO.IdCustomer
    
	--QUITADO POR BIDCAR
	--LEFT JOIN DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH (NOLOCK)
    --    ON CSA.IdSaleAdvisor = c.SaleAdvisorID
    
	--LEFT JOIN DeliveryBackOffice.dbo.HubLogistics HL WITH(NOLOCK) ON HL.IdHubLogistic = DO.HubOriginId
    --LEFT JOIN DeliveryBackOffice.dbo.HubLogistics HL2 WITH(NOLOCK) ON HL2.IdHubLogistic = DO.HubDestinationId
    LEFT JOIN DeliveryBackOffice.dbo.VisitPointConfiguration VPCO WITH (NOLOCK)
        ON VPCO.VisitPointID = do.Sender_ID
    
	--QUITADO POR BIDCAR
	--LEFT JOIN DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
    --    ON CBS.IdBusinessSegment = c.BusinessSegmentID
    --LEFT JOIN DeliveryBackOffice.dbo.CatBusinessActivity CBA WITH (NOLOCK)
    --    ON CBA.IdBusinessActivity = c.BusinessActivityID
    --LEFT JOIN DeliveryBackOffice.dbo.CatTypeOfBusiness CTOB WITH (NOLOCK)
    --    ON CTOB.IdTypeOfBusiness = c.TypeOfBusinessID

    --LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VP WITH(NOLOCK) ON VP.CustomerID = CU.IdCustomer
    
	--LEFT JOIN DeliveryBackOffice.dbo.KindOfVPClient KVPC WITH (NOLOCK)
 --       ON KVPC.IdKindOfVPClient = vpc.IdKindOfVPClient

    left JOIN DeliveryBackOffice.dbo.DeliveryBank DB WITH (NOLOCK)
        ON DB.Id_bank = c.CODAccountBankID
    left JOIN DeliveryBackOffice.dbo.CatBankAccountType CBAT WITH (NOLOCK)
        ON CBAT.IdBankAccountType = c.CODAccountTypeID

	/* left JOIN dbo.Township TONW
        ON TONW.IdTownship = do.ReceiverIdTownship 
		AND tonw.TownshipName = do.Receiver_Town
		*/
    LEFT JOIN dbo.Township  TONW_R ON  TONW_R.IdTownship = DO.ReceiverIdTownship
	--LEFT JOIN dbo.Township TONW2_R ON TONW2_R.TownshipName = DO.Receiver_Town

	LEFT JOIN dbo.Township  TONW_S ON  TONW_S.IdTownship = DO.SenderIdTownship
	--LEFT JOIN dbo.Township TONW2_S ON TONW2_S.TownshipName = DO.Sender_Town

	 /*left JOIN dbo.Township TONW2
        ON TONW2.IdTownship = do.SenderIdTownship 
		AND TONW2.TownshipName = do.Sender_Town
		*/

	LEFT JOIN(
	SELECT MIN(PRF.Email) EMAIL, MIN(PRF.IdVisitPointByClientPortfolio) IdVisitPointByClientPortfolio , MIN(COALESCE(PRF.FirstName,'') + IIF(LEN(PRF.FirstName) = 0,'','') + COALESCE(PRF.SecondName,'') + IIF(LEN(PRF.SecondName)=0,'',' ') + COALESCE(PRF.LastName,'') + IIF(LEN(PRF.LastName) = 0,'',' ') + COALESCE(PRF.SecondLastName,'')) FIRSTNAME , PRF.Phone  
	FROM 
	DBO.VisitPointByClientPortfolio PRF  WITH (NOLOCK)
	GROUP BY PRF.Phone, PRF.Email
	) PRP ON PRP.Email = DO.Sender_Mail AND PRP.Phone = DO.Sender_Phone AND ISNULL(c.IdCustomerType, ctm2.IdCustomerType) =2

 --   LEFT JOIN
 --   (
 --       SELECT TOP 1 CV.HeaderCode,
 --              MAX(CV.Hub) HUB
 --       FROM dbo.DumpServiceCoverage CV
 --       GROUP BY CV.HeaderCode
 --   ) as HB2
	--ON HB2.HeaderCode = ISNULL(TONW2.HeaderCode, TWN2.HeaderCode)

--LEFT JOIN DeliveryBackOffice.dbo.Township towno WITH(NOLOCK) ON towno.IdTownship = do.SenderIdTownship
--LEFT JOIN DeliveryBackOffice.dbo.Township townd WITH(NOLOCK) ON townd.IdTownship = do.ReceiverIdTownship
--LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage dsco WITH(NOLOCK) ON dsco.HeaderCode = towno.HeaderCode
--LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage dscd WITH(NOLOCK) ON dscd.HeaderCode = townd.HeaderCode
	/*LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
        ON vp.CodeOfReference = do.Sender_ID*/
	LEFT JOIN dbo.Cost cst WITH (NOLOCK)
		ON cst.GuideSerie = do.Guide_Serie 
			AND cst.GuideNumber = do.Guide_Number
           AND cst.RowStatus = 1
	/*LEFT JOIN dbo.BreakdownOfPayment bk WITH (NOLOCK)
        ON bk.IdCost = cst.IdCost
           AND bk.RowStatus = 1
           AND bk.Amount > 0*/
	LEFT JOIN dbo.PromoCoupon pc WITH (NOLOCK)
        ON pc.GuideSerieDestination = do.Guide_Serie
           AND pc.GuideNumberDestination = do.Guide_Number
	LEFT JOIN dbo.CatSalesChannel ch WITH (NOLOCK)
        ON ch.IdSalesChannel = vpc.SaleChannelId
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
	  AND do.DateCreated  >= DATEADD(DAY, -35, DATEDIFF(DAY, 0, GETDATE()))
      
	 -- AND do.DateCreated >= '2025-02-01 00:00:00'
	  ;

IF OBJECT_ID('tempdb.dbo.#VisitPointsCorporate', 'U') IS NOT NULL
    DROP TABLE #VisitPointsCorporate;
END