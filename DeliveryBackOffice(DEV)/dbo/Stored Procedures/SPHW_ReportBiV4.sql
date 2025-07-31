-- =============================================  
-- Author:  <Walter Orozco>  
-- Create date: <11-06-2025>  
-- Description: <Reestructuración del procedimiento almacenado completo.>  
-- Create date: <16-07-2025>  
-- Description: <Modificación para obtener Hub origen y destino por guía.>  
-- =============================================  
--Server 3.200  
--PowerBI Delivery LIVE Dashboard v4.AI (04 marzo 2025)  
-- =============================================  
CREATE PROCEDURE [dbo].[SPHW_ReportBiV4]  
AS  
BEGIN  
  
 -- VARIABLE  
 DECLARE @IVA DECIMAL (14,2) = 1.12  
 DECLARE @NowDate DATETIME = GETDATE();  
  
 --================================================================================  
 --=============== Obtener datos filtrados de la tabla principal ==================  
 --================================================================================  
 IF OBJECT_ID('tempdb.dbo.#tmp_FilDeliveryOrder', 'U') IS NOT NULL  
  DROP TABLE #tmp_FilDeliveryOrder;  
  
 SELECT   
    [Ticket_Number]  
      ,[Pieces_Dry]  
      ,[Pieces_Cold]  
      ,[Sender_ID]  
      ,[Sender_Address]  
      ,[Sender_Zone]  
      ,[Sender_Town]  
      ,[Sender_Department]  
      ,[Sender_Phone]  
      ,[Receiver_ID]  
      ,[Receiver_FirstName]  
      ,[Receiver_LastName]  
      ,[Receiver_Address]  
      ,[Receiver_Zone]  
      ,[Receiver_Town]  
      ,[Receiver_Department]  
      ,[Receiver_Phone]  
      ,[Receiver_SocialSecurity_ID]  
   ,[Receiver_Alternant_SocialSecurity_ID]  
      ,[Delivery_Max_Date]  
      ,[Guide_Serie]  
      ,[Guide_Number]  
      ,[Manifest_Serie]  
      ,[Manifest_Number]  
      ,[DateCreated]  
      ,[StatusOrderId]  
      ,[Receiver_CUI]  
      ,[Package_Description]  
      ,[Receiver_Alternant_CUI]  
      ,[Courier_Route]  
      ,[Courier_Name]  
      ,[NameOfReceiver]  
      ,[Package_Type]  
      ,[Receiver_Updated]  
      ,[Collect_OnDelivery]  
      ,[IsCollect]  
      ,[PriceShippment]  
      ,[SenderIdTownship]  
      ,[ReceiverIdTownship]  
      ,[IdCustomer]  
      ,[TypeService]  
      ,[Sender_Mail]  
      ,[BilledWeight]  
      ,[SenderCountryId]  
      ,[ReceiverCountryId]  
   ,[HubOriginId]  
   ,[HubDestinationId]  
   ,[SenderIdSettlement]  
   ,[ReceiverIdSettlement]  
 INTO #tmp_FilDeliveryOrder  
 FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)  
 WHERE   
   StatusOrderId <> 7  -- Anulado  
  AND StatusOrderId <> 15 -- Generado  
  AND DateCreated  >= DATEADD(DAY, -35, DATEDIFF(DAY, 0, @NowDate)); -- Días atrás  
  
 CREATE NONCLUSTERED INDEX tmp_Guides ON #tmp_FilDeliveryOrder (Guide_Serie, Guide_Number)  
  
 --================================================================================  
 --==== Tabla temporal para validar los clientes que son de tipo corporativo ======  
 --================================================================================  
 IF OBJECT_ID('tempdb.dbo.#VisitPointsCorporate', 'U') IS NOT NULL  
  DROP TABLE #VisitPointsCorporate;  
  
 SELECT VPC.CodeOfReference,  
     VPC.CustomerID  
 INTO #VisitPointsCorporate  
 FROM DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)  
 INNER JOIN DeliveryBackOffice.dbo.Customer  C WITH (NOLOCK)  
  ON VPC.CustomerID = C.IdCustomer  
 WHERE C.IdCustomerType = 1; --corporativo  
  
 CREATE NONCLUSTERED INDEX temp_visit_customerid ON #VisitPointsCorporate (CustomerID)  
  
 --================================================================================  
 --======= Tabla temporal para obtener correo y nombre clientes portafolio ========  
 --================================================================================  
 IF OBJECT_ID('tempdb.dbo.#Tmp_VPBCPortfolio', 'U') IS NOT NULL  
  DROP TABLE #Tmp_VPBCPortfolio;  
  
 --observacion: se deberia de filtrar solo por los clientes asociados a las guias de los dias del reporte  
 SELECT   
    MIN(PRF.Email)       AS 'Email'  
  , MIN(PRF.IdVisitPointByClientPortfolio) AS 'IdVisitPointByClientPortfolio'  
  , MIN  
   (  
      COALESCE(PRF.FirstName,'') + IIF(LEN(PRF.FirstName) = 0,'','')   
    + COALESCE(PRF.SecondName,'') + IIF(LEN(PRF.SecondName)=0,'',' ')   
    + COALESCE(PRF.LastName,'') + IIF(LEN(PRF.LastName) = 0,'',' ')   
    + COALESCE(PRF.SecondLastName,'')  
   )          AS 'FIRSTNAME'  
  , PRF.Phone         AS 'Phone'  
 INTO #Tmp_VPBCPortfolio  
 FROM  DeliveryBackOffice.dbo.VisitPointByClientPortfolio PRF  WITH (NOLOCK)  
 GROUP BY PRF.Phone, PRF.Email;  
  
 CREATE NONCLUSTERED INDEX tmp_Email_Phone ON #Tmp_VPBCPortfolio (Email,Phone)  
  
 --================================================================================  
 --======== Obtener campos para query principal tabla DeliveryOrderDetail =========  
 --================================================================================  
 IF OBJECT_ID('tempdb.dbo.#tmp_FiltDODetail', 'U') IS NOT NULL  
  DROP TABLE #tmp_FiltDODetail;  
  
 SELECT  
  DOD.Guide_Serie,  
  DOD.Guide_Number,  
  DOD.StatusOrderId,  
  DOD.DateCreated,  
  DOD.DateCreatedInSystem  
 INTO #tmp_FiltDODetail  
 FROM DeliveryBackOffice.dbo.DeliveryOrderDetail    DOD  WITH (NOLOCK)  
 INNER JOIN #tmp_FilDeliveryOrder       DO  
  ON DO.Guide_Serie = DOD.Guide_Serie AND DO.Guide_Number = DOD.Guide_Number;  
  
 CREATE NONCLUSTERED INDEX idx_tmp_dod ON #tmp_FiltDODetail (Guide_Number, StatusOrderId);  
 CREATE NONCLUSTERED INDEX idx_dod_guide_status_date ON #tmp_FiltDODetail (Guide_Serie, Guide_Number, StatusOrderId, DateCreated);  
  
 --================================================================================  
 --========== Obtener campos para query principal tabla DeliveryAttempt ===========  
 --================================================================================  
 IF OBJECT_ID('tempdb.dbo.#tmp_FiltDeliveryAttempt', 'U') IS NOT NULL  
  DROP TABLE #tmp_FiltDeliveryAttempt;  
  
 SELECT   
  Guide_Serie,  
  Guide_Number,  
  Date_Created,  
  Latitude,  
  Longitude,  
  Delivered,  
  ID_Courier,  
  ID_Incident,  
  ID_DeliveryOrderBySettlement  
 INTO #tmp_FiltDeliveryAttempt  
 FROM DeliveryBackOffice.dbo.DeliveryAttempt WITH (NOLOCK)  
 WHERE EXISTS (  
  SELECT 1  
  FROM #tmp_FilDeliveryOrder DO  
  WHERE DO.Guide_Serie = DeliveryAttempt.Guide_Serie   
    AND DO.Guide_Number = DeliveryAttempt.Guide_Number  
 );  
  
 CREATE NONCLUSTERED INDEX idx_tmp_DA ON #tmp_FiltDeliveryAttempt (Guide_Serie, Guide_Number, Date_Created DESC);  
  
 --================================================================================  
 --============== Obtener campos para query principal Facturacion =================  
 --================================================================================  
 IF OBJECT_ID('tempdb.dbo.#tmp_FiltInvoiceValid', 'U') IS NOT NULL   
  DROP TABLE #tmp_FiltInvoiceValid;  
  
 SELECT  
  IND.dti_fk_orderSerie AS Guide_Serie,  
  IND.dti_fk_orderNumber AS Guide_Number,  
  MIN(INH.inv_date) AS inv_date,  
  1 AS TieneFactura  
 INTO #tmp_FiltInvoiceValid  
 FROM #tmp_FilDeliveryOrder DO  
 INNER JOIN  DeliveryBackOffice.dbo.invoiceDetail IND WITH (NOLOCK)  
  ON DO.Guide_Serie = IND.dti_fk_orderSerie  
  AND DO.Guide_Number = IND.dti_fk_orderNumber  
 INNER JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)  
  ON IND.dti_fk_header = INH.inv_pk_id  
 WHERE   
  INH.inv_certificationFEL IS NOT NULL AND  
  INH.inv_descriptionFEL = 'PROCESO REALIZADO' AND  
  INH.inv_creditNote IS NULL AND  
  INH.inv_motiveCreditNote IS NULL  
 GROUP BY IND.dti_fk_orderSerie, IND.dti_fk_orderNumber;  
  
 CREATE NONCLUSTERED INDEX idx_tmp_invoice ON #tmp_FiltInvoiceValid (Guide_Serie, Guide_Number, inv_date);  
  
 --================================================================================  
 --============== Obtener campos para calculo de Dias_Para_Entrega  ===============  
 --================================================================================  
 IF OBJECT_ID('tempdb.dbo.#tmp_FiltDias_Para_Entrega', 'U') IS NOT NULL   
  DROP TABLE #tmp_FiltDias_Para_Entrega;  
  
 SELECT  
  DOD.Guide_Serie,  
  DOD.Guide_Number,  
  MIN(CASE WHEN DOD.StatusOrderId IN (2, 11) THEN DOD.DateCreatedInSystem END) AS FechaInicio,  
  MIN(CASE WHEN DOD.StatusOrderId IN (5, 22) THEN DOD.DateCreated END) AS FechaEntrega,  
  DO.ReceiverCountryId,  
  CAST(NULL AS NUMERIC(10,2)) AS DiasParaEntrega  
 INTO #tmp_FiltDias_Para_Entrega  
 FROM #tmp_FilDeliveryOrder DO  
 INNER JOIN #tmp_FiltDODetail DOD  
  ON DO.Guide_Serie = DOD.Guide_Serie AND DO.Guide_Number = DOD.Guide_Number  
 WHERE DOD.StatusOrderId IN (2,11,5,22)  
 GROUP BY DOD.Guide_Serie, DOD.Guide_Number, DO.ReceiverCountryId  
  
 CREATE NONCLUSTERED INDEX idx_tmp_DiasEntrega ON #tmp_FiltDias_Para_Entrega (Guide_Serie, Guide_Number);  
  
 UPDATE T  
 SET T.DiasParaEntrega = CEILING(ISNULL(Minutos.ResultMinutes / 1440.0, 0))  
 FROM #tmp_FiltDias_Para_Entrega T  
 OUTER APPLY dbo.fn_get_diff_minutes_tbl(T.FechaInicio, T.FechaEntrega, T.ReceiverCountryId) AS Minutos;  
  
 --================================================================================  
 --==================================== REPORTE ===================================  
 --================================================================================  
  
 SELECT  
    CONVERT(VARCHAR, DOD_PREP.Fecha_Preparacion, 103)   AS [Fecha_Preparacion]  
  , DOBS_DISPATCH.Date_Dispatched        AS [Fecha_Recoleccion]  
  , DO.Pieces_Dry            AS [Piezas_Secas]  
  , DO.Pieces_Cold           AS [Piezas_Frias]  
  , CASE   
   WHEN VPC.CodeOfReference > 0 THEN VPC.DescriptionOfClient  
   ELSE ISNULL(CTM2.[Name], '')  
    END              AS [Sender_Name]  
  , DO.Sender_Address           AS [Sender_Address]  
  , DO.Sender_Zone           AS [Sender_Zone]  
  , DO.Sender_Town           AS [Sender_Town]  
  , DO.Sender_Department          AS [Sender_Department]  
  , ISNULL(DO.Receiver_FirstName, '') + ' ' +   
    ISNULL(DO.Receiver_LastName, '')       AS [Receiver_Name]  
  , DO.Receiver_Address          AS [Receiver_Address]  
  , DO.Receiver_Zone           AS [Receiver_Zone]  
  , DO.Receiver_Town           AS [Receiver_Town]  
  , DO.Receiver_Department         AS [Receiver_Department]  
  , DO.Receiver_Phone           AS [Receiver_Phone]  
  , CONVERT(VARCHAR, DO.Delivery_Max_Date, 103)    AS [Fecha_Limite_Entrega]  
  , DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR)   AS [Waybill]  
  , DO.Manifest_Serie + CAST(DO.Manifest_Number AS VARCHAR) AS [Manifest]  
  , CONVERT(VARCHAR, DO.DateCreated, 103)      AS [Fecha_Solicitud]  
  , DO.StatusOrderId           AS [Last_Checkpoint_Code]  
  , SO.OrderDescription          AS [Last_Checkpoint_Name]  
  , DO.Package_Description         AS [Package_Description]  
  , DO.Courier_Route           AS [Courier_Route]  
  , DA_Courier.Courier_Fullname        AS [Courier_Name]  
  , CONVERT(VARCHAR, DA_Courier.Date_Delivered, 103)   AS [Fecha_Despacho_Ruta]  
  , REPLACE(REPLACE(ISNULL(DO.NameOfReceiver, ''),   
    CHAR(13), ''), CHAR(10), '')        AS [Name_Of_Receiver]  
  , PA.Package_Name           AS [Package_Name]  
  , CONVERT  
    (VARCHAR, DOD_Prog.Primera_Fecha_Programado_Entrega, 103) AS [Primera_Fecha_Programado_Entrega]  
  , DOD_Prog.Veces_Programado_Entrega       AS [Veces_Programado_Entrega]  
  , CONVERT(VARCHAR, DOD_Ent.Primera_Fecha_Entrega, 103)  AS [Primera_Fecha_Entrega]  
  , DOD_Ent.Veces_Entregas_Registradas      AS [Veces_Entregas_Registradas]  
  , DOD_Ent.Entregado           AS [Entregado]  
  , 0               AS [Digitalizado]  
  , ISNULL(DO.Collect_OnDelivery, 0)       AS [Monto_A_Cobrar]  
  , CASE   
   WHEN DOD_Ent.Entregado = 1 THEN DO.Collect_OnDelivery   
   ELSE 0   
    END               AS [Monto_Cobrado]  
  , ISNULL(DO.Receiver_Updated, 0)       AS [Datos_Modificados]  
  , WH_Rack.RackPosition          AS [Ubicacion_Bodega]  
  , ISNULL(DP_Evidence.Evidencia, 0)       AS [Evidencia_Entrega]  
  , DA_Location.Latitude          AS [Latitude]  
  , DA_Location.Longitude          AS [Longitude]  
  , DOD_Devuelto.EsDevuelto         AS [Devuelto]  
  , ISNULL(FPE.DiasParaEntrega,0)        AS [Dias_Para_Entrega]  
  , ISNULL(DOD_SinEntrega.Dias_Sin_Entrega, 0)    AS [Dias_Sin_Entrega]  
  , C.[Name]             AS [Name]  
  , DO.Sender_ID            AS [Sender_ID]  
  , ISNULL(CTM2.IdCustomer ,C.IdCustomer)      AS [IdCustomer]  
  , C.IdCustomer            AS [IdCustomer1]  
  , CTM2.IdCustomer           AS [IdCustomer2]  
  , ISNULL(UPPER(C.[Name] ), UPPER(CTM2.[Name]))    AS [Customer_Name]  
  , DO.IsCollect            AS [IsCollect]  
  , ISNULL(CAST(DO.PriceShippment / @IVA AS DECIMAL(14,2)),0) AS [PriceShipment]  
  , ReturnEval.IsReturn          AS [IsReturn]  
  , DO.Collect_OnDelivery          AS [MontoCOD]  
  , CASE  
   WHEN DOP_COD.EstadoCOD = 1   
   THEN 'PAGADA' ELSE 'NO PAGADA' END      AS [EstadoCOD]  
  , DOP_COD.FechaPagoDepositoCOD        AS [FechaPagoDepositoCOD]  
  , ISNULL(DO.BilledWeight, 0)        AS [BilledWeight]  
  , DA_Manifiesto.Manifiesto_Despacho       AS [Manifiesto_Despacho]  
  , DOD_Ent.Primera_Fecha_Entrega        AS [Fecha_Entrega_Checkpoint]  
  , DO.Sender_Phone           AS [Sender_Phone]  
  , DO.Sender_Mail           AS [Sender_Mail]  
  , DO.TypeService           AS [TypeService]  
  , SA.SaleAdvisorCode          AS [SaleAdvisorCode]  
  , ISNULL(BD_COD.Precio_x_Comision, 0)      AS [Precio_x_Comision]  
  , VPCO.DateStartOperation         AS [DateStartOperation]  
  , CBS.BusinessSegmentName         AS [BusinessSegmentName]  
  , CBA.BusinessActivityName         AS [BusinessActivityName]  
  , CTOB.TypeOfBusinessName         AS [TypeOfBusinessName]  
  , ISNULL(SC.KindOfVPName, 'Portal Web')      AS [KindOfVPName]  
  , DB.[Name]             AS [BankName]  
  , CBAT.BankAccountType          AS [BankAccountType]  
  , HUB_S.SenderHub           AS [SenderHub]  
  , HUB_R.ReceiverHub           AS [ReceiverHub]  
  , PRP.IdVisitPointByClientPortfolio       AS [IdVisitPointByClientPortfolio]  
  , PRP.FIRSTNAME            AS [FIRSTNAME]  
  , DO.Receiver_SocialSecurity_ID        AS [Receiver_SocialSecurity_ID]  
  , DO.Receiver_Alternant_SocialSecurity_ID     AS [Receiver_Alternant_SocialSecurity_ID]  
  , DO.Receiver_CUI           AS [Receiver_CUI]  
  , DO.Receiver_Alternant_CUI         AS [Receiver_Alternant_CUI]  
  , ISNULL(INV.TieneFactura, 0)        AS [Facturado]  
  , KOB.KindOfVPNameBussiness         AS [KindOfVPNameBussiness]  
  , CCS.CommercialSegmentName         AS [CommercialSegmentName]  
  , INV.InvoiceDate           AS [InvoiceDate]  
  , CASE   
   WHEN C.RowSatus = 1 THEN 'ACTIVO' ELSE 'INACTIVO' END  AS [CustomerStatus]  
  , DA_Incidencia.NameIncidence        AS [Incidencia_Entrega]  
  , ISNULL(BK_COSTOS.TC, 0)         AS [TC]  
  , ISNULL(BK_COSTOS.ExtraPeso, 0)       AS [Extra Peso]  
  , ISNULL(BK_COSTOS.Seguro, 0)        AS [Seguro]  
  , CASE WHEN DO.IsCollect = 1 THEN 3 ELSE 0 END    AS [Collect]  
  , ISNULL(PC.DiscountAmount, 0)        AS [Descuento]  
  , ISNULL(DEST.TipoDestino, 'DEPARTAMENTAL')     AS [Tipo Destino]  
  , ISNULL(CH.[Description], 'Portal Web')     AS [KindOfVpName]  
  , ISNULL(CARGO.Recargo, 0)         AS [recargo]  
  , ISNULL(COD.ComisionCOD, 0)        AS [Comission COD]  
  , ISNULL(COD.PorcentajeCOD, 0)        AS [Porcentaje_COD]  
  , 0               AS [NUEVO PRECIO]  
  , 'N/A'              AS [SERVICIO]  
  , LCHK.LastCheckpoint          AS [Last_Checkpoint_Datetime]  
  , ISNULL(DOD_Ent_EXC.Fue_Entregado_EXC, 0)     AS [Fue_Entregado_EXC]  
  , DOD_Ent_EXC.Primer_Fecha_Fue_Entregado_EXC    AS [Primer_Fecha_Fue_Entregado_EXC]  
  , ISNULL(DOD_Tras.Fue_Trasladado_Recibido_EXC, 0)   AS [Fue_Trasladado_Recibido_EXC]  
  , DOD_Tras.Primer_Fecha_Trasladado_Recibido_EXC    AS [Primer_Fecha_Trasladado_Recibido_EXC]  
  , DO.ReceiverCountryId          AS [Destination_Country]  
  , DO.Ticket_Number           AS [Ticket_Number]  
 FROM #tmp_FilDeliveryOrder         DO  WITH (NOLOCK)  
    INNER JOIN DeliveryBackOffice.dbo.StatusOrder    SO  WITH (NOLOCK)  
        ON SO.StatusOrderId = DO.StatusOrderId      
 LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient   VPC  WITH (NOLOCK) --POR SENDER  
        ON VPC.CodeOfReference = DO.Sender_ID   
 LEFT JOIN DeliveryBackOffice.dbo.Customer     C  WITH (NOLOCK)  
   ON C.IdCustomer = VPC.CustomerID  
 LEFT JOIN DeliveryBackOffice.dbo.Customer     CTM2 WITH (NOLOCK) --POR CUSTOMER  
  ON DO.IdCustomer = CTM2.IdCustomer  
    LEFT JOIN DeliveryBackOffice.dbo.Package     PA  WITH (NOLOCK)  
        ON PA.Package_Type = DO.Package_Type  
 LEFT JOIN DeliveryBackOffice.dbo.KindOfVPBusiness   KOB  WITH (NOLOCK)  
  ON KOB.IdKindOfVPBusiness = VPC.IdKindOfVPBusiness  
 LEFT JOIN dbo.CatCommercialSegment       CCS  WITH (NOLOCK)  
  ON CCS.IdCommercialSegment = ISNULL(C.CommercialSegmentID, CTM2.CommercialSegmentID)  
 LEFT JOIN DeliveryBackOffice.dbo.CatBusinessSegment   CBS  WITH (NOLOCK)   
  ON CBS.IdBusinessSegment = ISNULL(C.BusinessSegmentID, CTM2.BusinessSegmentID)  
 LEFT JOIN DeliveryBackOffice.dbo.CatBusinessActivity  CBA  WITH (NOLOCK)   
  ON CBA.IdBusinessActivity = ISNULL(C.BusinessActivityID, CTM2.BusinessActivityID)  
 LEFT JOIN DeliveryBackOffice.dbo.CatTypeOfBusiness   CTOB  WITH (NOLOCK)   
  ON CTOB.IdTypeOfBusiness = ISNULL(C.TypeOfBusinessID, CTM2.TypeOfBusinessID)  
 LEFT JOIN DeliveryBackOffice.dbo.VisitPointConfiguration VPCO WITH (NOLOCK)  
        ON VPCO.VisitPointID = DO.Sender_ID             
    LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank    DB  WITH (NOLOCK)  
        ON DB.Id_bank = C.CODAccountBankID             
    LEFT JOIN DeliveryBackOffice.dbo.CatBankAccountType   CBAT WITH (NOLOCK)  
        ON CBAT.IdBankAccountType = C.CODAccountTypeID          
 LEFT JOIN DeliveryBackOffice.dbo.Cost      CST  WITH (NOLOCK)  
  ON CST.GuideSerie = DO.Guide_Serie   
  AND CST.GuideNumber = DO.Guide_Number  
  AND CST.RowStatus  = 1  --al pasarlo al where quita valores porque aqui acepta valor null  
 LEFT JOIN DeliveryBackOffice.dbo.PromoCoupon    PC  WITH (NOLOCK)  
        ON PC.GuideSerieDestination = DO.Guide_Serie  
        AND PC.GuideNumberDestination = DO.Guide_Number  
 LEFT JOIN DeliveryBackOffice.dbo.CatSalesChannel   CH  WITH (NOLOCK)  
        ON CH.IdSalesChannel = VPC.SaleChannelId  
 LEFT JOIN #tmp_FiltDias_Para_Entrega      FPE  
  ON DO.Guide_Serie = FPE.Guide_Serie AND DO.Guide_Number = FPE.Guide_Number  
 LEFT JOIN #Tmp_VPBCPortfolio        PRP  
  ON  PRP.Email = DO.Sender_Mail  
  AND PRP.Phone = DO.Sender_Phone   
  AND ISNULL(C.IdCustomerType, CTM2.IdCustomerType) = 2 --al pasarlo al where no devuelve los mismos valores  
 OUTER APPLY (  
  SELECT TOP 1 DateCreated AS Fecha_Preparacion  
  FROM #tmp_FiltDODetail DOD  
  WHERE DOD.Guide_Serie = DO.Guide_Serie AND DOD.Guide_Number = DO.Guide_Number AND DOD.StatusOrderId = 11  
  ORDER BY DateCreated ASC  
 ) DOD_PREP  
 OUTER APPLY (  
  SELECT TOP 1 DOBS.Date_Dispatched  
  FROM DeliveryBackOffice.dbo.DeliverySettlementDetail   DSD  WITH (NOLOCK)  
  INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement  DOBS WITH (NOLOCK)  
   ON DSD.ID_DeliveryOrderBySettlement = DOBS.ID  
  WHERE DSD.Guide_Serie = DO.Guide_Serie AND DSD.Guide_Number = DO.Guide_Number  
  ORDER BY DOBS.ID DESC  
 ) AS DOBS_DISPATCH  
 OUTER APPLY (  
  SELECT TOP 1   
   ISNULL(SR.First_Name, '') + ' ' + ISNULL(SR.Last_Name, '') AS Courier_Fullname,  
   DA.Date_Created AS Date_Delivered  
  FROM #tmp_FiltDeliveryAttempt DA  
  LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver  SR WITH (NOLOCK)  
   ON SR.ID = DA.ID_Courier  
  WHERE DA.Guide_Serie = DO.Guide_Serie  
    AND DA.Guide_Number = DO.Guide_Number  
    AND DA.Delivered = 1  
  ORDER BY DA.Date_Created DESC  
 ) AS DA_Courier  
 OUTER APPLY (  
  SELECT   
   MIN(DateCreated) AS Primera_Fecha_Programado_Entrega,  
   COUNT(Guide_Number) AS Veces_Programado_Entrega  
  FROM #tmp_FiltDODetail  
  WHERE Guide_Serie = DO.Guide_Serie AND Guide_Number = DO.Guide_Number  
  AND StatusOrderId = 3  
 ) AS DOD_Prog  
 OUTER APPLY (  
  SELECT   
   MIN(DateCreated)          AS Primera_Fecha_Entrega,  
   COUNT(Guide_Number)          AS Veces_Entregas_Registradas,  
   CASE WHEN COUNT(Guide_Number) > 0 THEN 1 ELSE 0 END  AS Entregado  
  FROM #tmp_FiltDODetail  
  WHERE Guide_Serie = DO.Guide_Serie AND Guide_Number = DO.Guide_Number  
  AND StatusOrderId IN (5, 22)  
 ) AS DOD_Ent  
 OUTER APPLY (  
  SELECT   
   STUFF((  
    SELECT ', ' + Rack_Position  
    FROM (  
     SELECT DISTINCT Rack_Position  
     FROM DeliveryBackOffice.dbo.Warehouse WITH (NOLOCK)  
     WHERE Guide_Serie = DO.Guide_Serie   
       AND Guide_Number = DO.Guide_Number   
       AND Active = 1  
    ) AS sub  
    FOR XML PATH(''), TYPE  
   ).value('.', 'VARCHAR(MAX)'), 1, 2, '') AS RackPosition  
 ) AS WH_Rack  
 OUTER APPLY (  
  SELECT TOP 1 1 AS Evidencia  
  FROM DeliveryBackOffice.dbo.DeliveryProof DP WITH (NOLOCK)  
  WHERE DP.Guide_Serie = DO.Guide_Serie AND DP.Guide_Number = DO.Guide_Number  
 ) AS DP_Evidence  
 OUTER APPLY (  
  SELECT TOP 1  
   DA.Latitude,  
   DA.Longitude  
  FROM #tmp_FiltDeliveryAttempt DA  
  WHERE DA.Guide_Serie = DO.Guide_Serie  
    AND DA.Guide_Number = DO.Guide_Number  
    AND LTRIM(RTRIM(ISNULL(DA.Latitude, ''))) <> ''  
    AND LTRIM(RTRIM(ISNULL(DA.Longitude, ''))) <> ''  
  ORDER BY DA.Date_Created DESC  
 ) AS DA_Location  
 OUTER APPLY (  
  SELECT TOP 1  
   CTI.NameIncidence  
  FROM #tmp_FiltDeliveryAttempt DA  
  INNER JOIN DeliveryBackOffice.dbo.CatTypeIncidence CTI WITH (NOLOCK)  
   ON CTI.IdIncidenceType = DA.ID_Incident  
  WHERE DA.Guide_Serie = DO.Guide_Serie  
  AND DA.Guide_Number = DO.Guide_Number  
  ORDER BY DA.Date_Created DESC  
 ) AS DA_Incidencia  
 OUTER APPLY (  
  SELECT   
   CASE   
    WHEN COUNT(Guide_Number) > 0 THEN 1 ELSE 0   
   END AS EsDevuelto  
  FROM #tmp_FiltDODetail  
  WHERE Guide_Serie = DO.Guide_Serie   
    AND Guide_Number = DO.Guide_Number  
    AND StatusOrderId IN (14, 23)  
 ) AS DOD_Devuelto  
 OUTER APPLY (  
  SELECT   
   CASE   
    WHEN DO.StatusOrderId NOT IN (5, 14, 22, 23)  
     THEN DATEDIFF(DAY,   
      (SELECT TOP 1 DateCreated   
       FROM #tmp_FiltDODetail   
       WHERE Guide_Serie = DO.Guide_Serie   
       AND Guide_Number = DO.Guide_Number   
       AND StatusOrderId = 11   
       ORDER BY DateCreated ASC  
      ), @NowDate)  
    ELSE 0   
   END AS Dias_Sin_Entrega  
 ) AS DOD_SinEntrega  
 OUTER APPLY (  
  SELECT CASE  
   WHEN DO.Receiver_ID > 0  
    AND EXISTS (  
     SELECT 1  
     FROM #VisitPointsCorporate VPCO  
     WHERE VPCO.CustomerID = C.IdCustomer  
     AND VPCO.CodeOfReference = DO.Receiver_ID  
    )  
    AND DO.Sender_ID = DO.Receiver_ID  
   THEN 1  
   ELSE 0  
  END AS IsReturn  
 ) AS ReturnEval  
 OUTER APPLY (  
  SELECT TOP 1   
   1 AS EstadoCOD,  
   DateCreated AS FechaPagoDepositoCOD  
  FROM DeliveryBackOffice.dbo.DeliveryOrderPaid DOP WITH (NOLOCK)  
  WHERE DOP.Guide_Serie = DO.Guide_Serie  
    AND DOP.Guide_Number = DO.Guide_Number  
    AND DOP.IdStatus = 1  
 ) AS DOP_COD  
 OUTER APPLY (  
  SELECT TOP 1   
   ID_DeliveryOrderBySettlement AS Manifiesto_Despacho  
  FROM #tmp_FiltDeliveryAttempt  
  WHERE Guide_Serie = DO.Guide_Serie   
    AND Guide_Number = DO.Guide_Number  
  ORDER BY Date_Created DESC  
 ) AS DA_Manifiesto  
 OUTER APPLY (  
  SELECT TOP 1 CSA.SaleAdvisorCode  
  FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH (NOLOCK)  
  WHERE CSA.IdSaleAdvisor = ISNULL(C.SaleAdvisorID, CTM2.SaleAdvisorID)  
 ) AS SA  
 OUTER APPLY (  
  SELECT TOP 1   
   CAST(BD.Commission / @IVA AS DECIMAL(14,2)) AS Precio_x_Comision  
  FROM DeliveryBackOffice.dbo.BatchDetailCOD BD WITH (NOLOCK)  
  WHERE BD.GuideSerie = DO.Guide_Serie AND BD.GuideNumber = DO.Guide_Number  
 ) AS BD_COD  
 OUTER APPLY (  
  SELECT   
   CSC.[Description] AS KindOfVPName  
  FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)  
  WHERE CSC.IdSalesChannel = ISNULL(  
   VPC.SaleChannelId,  
   (  
    SELECT TOP 1 VPC2.SaleChannelId  
    FROM DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH (NOLOCK)  
    WHERE VPC2.CustomerID = CTM2.IdCustomer  
   )  
  )  
 ) AS SC  
 OUTER APPLY (  
  SELECT TOP 1  
   COALESCE(  
    HL.HubAbbreviation,       -- Forma 1: HubOriginId → HubLogistics  
    DSC1.Hub,                 -- Forma 2: SenderIdSettlement → DumpServiceCoverage  
    DSC2.Hub,                 -- Forma 3: VisitPointClient → DumpServiceCoverage  
    CV.Hub                -- Forma 4: Municipio → DumpServiceCoverage  
   ) AS SenderHub  
  FROM (VALUES(1)) AS x(dummy)  
  LEFT JOIN DeliveryBackOffice.dbo.HubLogistics           HL   WITH(NOLOCK)  
   ON HL.IdHubLogistic    = DO.HubOriginId  
  LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage    DSC1 WITH(NOLOCK)  
   ON DSC1.IdSettlement   = DO.SenderIdSettlement  
  LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient       VPC  WITH(NOLOCK)  
   ON VPC.CodeOfReference = DO.Sender_ID  
  LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage    DSC2 WITH(NOLOCK)  
   ON DSC2.IdSettlement   = VPC.IdSettlement  
  INNER JOIN DeliveryBackOffice.dbo.Township              T    WITH(NOLOCK)  
   ON T.IdTownship       = DO.SenderIdTownship  
  LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage    CV   WITH(NOLOCK)  
   ON CV.HeaderCode      = T.HeaderCode  
 ) AS HUB_S  
 OUTER APPLY (  
  SELECT TOP 1  
   COALESCE(  
    HL.HubAbbreviation,    -- Forma 1: HubOriginId → HubLogistics  
    DSC.Hub,               -- Forma 2: SenderIdSettlement → DumpServiceCoverage  
    CV.Hub                 -- Forma 3: Municipio → DumpServiceCoverage  
   ) AS ReceiverHub  
  FROM (VALUES(1)) AS x(dummy)  
  LEFT JOIN DeliveryBackOffice.dbo.HubLogistics   HL WITH(NOLOCK)  
   ON HL.IdHubLogistic     = DO.HubDestinationId  
  LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage DSC WITH(NOLOCK)  
   ON DSC.IdSettlement     = DO.ReceiverIdSettlement  
  INNER JOIN DeliveryBackOffice.dbo.Township    T WITH(NOLOCK)  
   ON T.IdTownship         = DO.ReceiverIdTownship  
  LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage CV WITH(NOLOCK)  
   ON CV.HeaderCode        = T.HeaderCode  
 ) AS HUB_R  
 OUTER APPLY (  
  SELECT   
   inv_date AS InvoiceDate,  
   1 AS TieneFactura  
  FROM #tmp_FiltInvoiceValid  
  WHERE Guide_Serie = DO.Guide_Serie AND Guide_Number = DO.Guide_Number  
 ) AS INV  
 OUTER APPLY (  
  SELECT  
   MAX(CASE WHEN BK.Description = 'Otros cargos' THEN BK.Amount END) AS TC,  
   MAX(CASE WHEN BK.Description = 'Recargo por peso' THEN BK.Amount END) AS ExtraPeso,  
   MAX(CASE WHEN BK.Description = 'Seguro' THEN BK.Amount END) AS Seguro  
  FROM DeliveryBackOffice.dbo.BreakdownOfPayment BK WITH (NOLOCK)  
  WHERE   
   BK.IdCost = CST.IdCost AND  
   BK.RowStatus = 1 AND  
   BK.Amount > 0 AND  
   BK.Description IN ('Otros cargos', 'Recargo por peso', 'Seguro')  
 ) AS BK_COSTOS  
 OUTER APPLY (  
  SELECT TOP 1 CSS.CrsName AS TipoDestino  
  FROM DeliveryBackOffice.dbo.Township TSenderID WITH (NOLOCK)  
  LEFT JOIN DeliveryBackOffice.dbo.Township TReceiverID WITH (NOLOCK)  
   ON TReceiverID.IdTownship = DO.ReceiverIdTownship  
  INNER JOIN DeliveryBackOffice.dbo.RateTownshipCoverage RTC WITH (NOLOCK)  
   ON RTC.TownshipDestinyId = TReceiverID.IdTownship  
   AND RTC.TownshipSourceId = TSenderID.IdTownship  
  INNER JOIN DeliveryBackOffice.dbo.CatRateSegment CSS WITH (NOLOCK)  
   ON CSS.CrsId = RTC.SegmentTypeId  
  WHERE RTC.RateId = 2285  
 ) AS DEST  
 OUTER APPLY (  
  SELECT SUM(AAC.MassWeight - 10) AS Recargo  
  FROM DeliveryBackOffice.dbo.DeliveryOrderPiece  DPP  WITH (NOLOCK)  
  INNER JOIN DeliveryBackOffice.dbo.ArticleByCustomer AAC  WITH (NOLOCK)  
   ON AAC.Code = DPP.ParcelCode  
  WHERE   
   DPP.GuideSerie = DO.Guide_Serie AND  
   DPP.GuideNumber = DO.Guide_Number AND  
   AAC.AbcId IN (531, 532, 533, 534)  
 ) AS CARGO  
 OUTER APPLY (  
  SELECT   
   MAX(BTC.Commission)     AS ComisionCOD,  
   MAX(BTC.CODCommissionPercentage) AS PorcentajeCOD  
  FROM DeliveryBackOffice.dbo.BatchDetailCOD BTC  WITH (NOLOCK)  
  WHERE   
   BTC.GuideSerie = DO.Guide_Serie AND  
   BTC.GuideNumber = DO.Guide_Number AND  
   BTC.CatConceptCODId = 2  
 ) AS COD  
 OUTER APPLY (  
  SELECT TOP 1 dod.DateCreated AS LastCheckpoint  
  FROM #tmp_FiltDODetail DOD  
  WHERE   
   DOD.Guide_Serie = DO.Guide_Serie AND  
   DOD.Guide_Number = DO.Guide_Number AND  
   DOD.StatusOrderId = DO.StatusOrderId  
  ORDER BY dod.DateCreated DESC  
 ) AS LCHK  
 OUTER APPLY (  
  SELECT   
   CASE WHEN COUNT(Guide_Number) > 0 THEN 1 ELSE 0 END AS Fue_Entregado_EXC,  
   MIN(DateCreated)         AS Primer_Fecha_Fue_Entregado_EXC  
  FROM #tmp_FiltDODetail  
  WHERE   
   Guide_Serie = DO.Guide_Serie AND  
   Guide_Number = DO.Guide_Number AND  
   StatusOrderId = 22  
 ) AS DOD_Ent_EXC  
 OUTER APPLY (  
  SELECT   
   CASE WHEN COUNT(Guide_Number) > 0 THEN 1 ELSE 0 END AS Fue_Trasladado_Recibido_EXC,  
   MIN(DateCreated)         AS Primer_Fecha_Trasladado_Recibido_EXC  
  FROM #tmp_FiltDODetail  
  WHERE   
   Guide_Serie = DO.Guide_Serie AND  
   Guide_Number = DO.Guide_Number AND  
   StatusOrderId IN (20, 21)  
 ) AS DOD_Tras  
 ;  
  
 IF OBJECT_ID('tempdb.dbo.#VisitPointsCorporate', 'U') IS NOT NULL  
  DROP TABLE #VisitPointsCorporate;  
 IF OBJECT_ID('tempdb.dbo.#Tmp_VPBCPortfolio', 'U') IS NOT NULL  
  DROP TABLE #Tmp_VPBCPortfolio;  
 IF OBJECT_ID('tempdb.dbo.#tmp_FilDeliveryOrder', 'U') IS NOT NULL  
  DROP TABLE #tmp_FilDeliveryOrder;  
 IF OBJECT_ID('tempdb.dbo.#tmp_FiltDODetail', 'U') IS NOT NULL  
  DROP TABLE #tmp_FiltDODetail;  
 IF OBJECT_ID('tempdb.dbo.#tmp_FiltDeliveryAttempt', 'U') IS NOT NULL  
  DROP TABLE #tmp_FiltDeliveryAttempt;  
 IF OBJECT_ID('tempdb.dbo.#tmp_FiltInvoiceValid', 'U') IS NOT NULL   
  DROP TABLE #tmp_FiltInvoiceValid;  
 IF OBJECT_ID('tempdb.dbo.#tmp_FiltDias_Para_Entrega', 'U') IS NOT NULL   
  DROP TABLE #tmp_FiltDias_Para_Entrega;  
  
END;