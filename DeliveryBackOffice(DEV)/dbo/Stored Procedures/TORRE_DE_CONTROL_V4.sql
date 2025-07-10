CREATE procedure  [dbo].[TORRE_DE_CONTROL_V4]  
  
as   
begin  
  
 DECLARE @StartDate DATE = CONVERT(DATE, GETDATE() - 1)  
 DECLARE @EndDate DATE = convert(DATE, GETDATE() + 1)  
  
 --select @startdate, @enddate  
  
 DECLARE @IdCountry VARCHAR(3)='GT'  
 DECLARE @StartDateTime AS DATETIME;  
 DECLARE @EndDateTime AS DATETIME;  
  
 SET @StartDateTime = CAST(@StartDate AS DATETIME) + '00:00:00'; -- Añadimos el tiempo para incluir toda la fecha del primer día  
 SET @EndDateTime = CAST(@EndDate AS DATETIME) + '23:59:59';   
  
  
  
 -- CTE para Incidents  
 WITH Incidents AS (  
  SELECT  
   MAX(DA.ID_DeliveryOrderBySettlement) ID,  
   COUNT(DISTINCT DA.Guide_Number) AS UnvalidatedIncidentCount  
    
  FROM   
   [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)  
  INNER JOIN   
   [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)  
   ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement  
  INNER JOIN   
   [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)  
     ON DA.ID_DeliveryOrderBySettlement = DSD.ID_DeliveryOrderBySettlement  
  INNER JOIN   
   [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)  
   ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence  
    
  WHERE  
          
    DOBS.Date_Dispatched BETWEEN @StartDateTime AND @EndDateTime  
   AND DA.Date_Created BETWEEN @StartDateTime AND @EndDateTime  
   AND ISNULL(COI.IdConfirmationOfIncidence,0)>1  
   AND COI.IsConfirmed = 0   
   AND COI.IsDenied = 0   
   AND COI.RowStatus = 1   
   AND COI.StatusOrderId = 45  
  GROUP BY   
  DA.ID_DeliveryOrderBySettlement  
 ),  
  
 -- CTE para IncidentsReal  
 IncidentsReal AS (  
  SELECT  
   MAX(DA.ID_DeliveryOrderBySettlement) ID,  
   COUNT(DISTINCT DA.Guide_Number) AS RealIncidentsCount  
    
  FROM   
   [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)  
  INNER JOIN   
   [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)  
   ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement  
  INNER JOIN   
   [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)  
     ON DA.ID_DeliveryOrderBySettlement = DSD.ID_DeliveryOrderBySettlement  
  INNER JOIN   
   [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)  
   ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence  
    
  WHERE  
          
    DOBS.Date_Dispatched BETWEEN @StartDateTime AND @EndDateTime  
   AND DA.Date_Created BETWEEN @StartDateTime AND @EndDateTime  
   AND ISNULL(COI.IdConfirmationOfIncidence,0)>1  
   AND COI.IsConfirmed = 1   
   AND COI.IsDenied = 0   
   AND COI.RowStatus = 1   
   AND COI.StatusOrderId = 50  
  GROUP BY   
  DA.ID_DeliveryOrderBySettlement  
 ),  
 -- CTE para IncidentsFalse  
 IncidentsFalse AS (  
  SELECT  
   MAX(DA.ID_DeliveryOrderBySettlement) ID,  
   COUNT(DISTINCT DA.Guide_Number) AS FalseIncidentsCount  
    
  FROM   
   [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)  
  INNER JOIN   
   [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)  
   ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement  
  INNER JOIN   
   [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)  
     ON DA.ID_DeliveryOrderBySettlement = DSD.ID_DeliveryOrderBySettlement  
  INNER JOIN   
   [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)  
   ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence  
    
  WHERE  
          
    DOBS.Date_Dispatched BETWEEN @StartDateTime AND @EndDateTime  
   AND DA.Date_Created BETWEEN @StartDateTime AND @EndDateTime  
   AND ISNULL(COI.IdConfirmationOfIncidence,0)>1  
   AND COI.IsConfirmed = 1   
   AND COI.IsDenied = 1   
   AND COI.RowStatus = 1   
   AND COI.StatusOrderId = 50  
  GROUP BY   
  DA.ID_DeliveryOrderBySettlement  
 ),--CTE Incidencia en ruta  
 IncidentsInRoute AS (  
  SELECT  
     MAX(DA.ID_DeliveryOrderBySettlement) ID,  
    COUNT(DISTINCT DA.Guide_Number) AS [IncidentsCount]  
      
  FROM   
   [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)  
  INNER JOIN   
   [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)  
   ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement  
  INNER JOIN   
   [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)  
   ON DA.ID_DeliveryOrderBySettlement =  DSD.ID_DeliveryOrderBySettlement  
  INNER JOIN   
   [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)  
   ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence  
  INNER JOIN   
   [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH (NOLOCK)  
   ON DOP.GuideNumber = DA.Guide_Number  
  WHERE  
         
    COI.RowStatus = 1   
    AND DOBS.Date_Dispatched BETWEEN @StartDateTime AND @EndDateTime  
    AND DA.Date_Created BETWEEN @StartDateTime AND @EndDateTime  
    AND COI.DateCreated BETWEEN @StartDateTime AND @EndDateTime  
    AND ISNULL(ConfirmationOfIncidenceId,0)>1  
  GROUP BY   
    DOBS.ID   
 )  
  
  
  
 -- Consulta principal  
 SELECT   
  MAX(DOBS.ID) [Settlement_ID],  
  MAX(HBL.HubAbbreviation) AS Hub,  
  MAX(DOBS.Date_Dispatched) AS Date_Dispatched,  
  MAX(DOBS.StartingKilometers) AS Out_KM,  
  MAX(DOBS.Date_Dispatched) AS Time_Dispatched,  
  MAX(DOBS.Route_Received) AS Time_Settlement,  
  MAX(SRE.First_Name) + ' ' + MAX(SRE.Last_Name) AS Courierman_Name,  
  MAX(CRT.CodeRoute) AS Route_Name,  
  MAX(SRE.CUI) AS Courierman_Id,  
  MAX(TYSRE.TypeName) AS Driver_Type,  
  MAX(CVH.UnitNumber) AS Vehicle,  
  MAX(CR.RegionName) AS Region,  
  MAX(DOBS.Guides_Dispatched) AS Dispatched_Guides,  
  MAX(DOBS.Pieces_Dry_Dispatched) + MAX(DOBS.Pieces_Cold_Dispatched) AS Dispatched_Pieces,  
  
     
  
  SUM(CASE WHEN DSD.StatusOrderId = 5 THEN 1 ELSE 0 END) AS Delivered_Guides_Checkpoint,  
  SUM(CASE WHEN DSD.StatusOrderId = 5 THEN DOP.NoPiece ELSE 0 END) AS Delivered_Pieces_Checkpoint,  
  
  SUM(CASE WHEN DSD.StatusOrderId = 14 THEN 1 ELSE 0 END) AS Returned_Guides_Checkpoint,  
  SUM(CASE WHEN DSD.StatusOrderId = 14 THEN DOP.NoPiece ELSE 0 END) AS Returned_Pieces_Checkpoint,  
  
  SUM(CASE WHEN DSD.StatusOrderId = 8    THEN 1 ELSE 0 END) AS Returned_Guides,  
  SUM(CASE WHEN DSD.StatusOrderId = 8    THEN DOP.NoPiece ELSE 0 END) AS Returned_Pieces,  
  
  SUM(CASE WHEN DSD.StatusOrderId = 20 THEN 1 ELSE 0 END) AS Transfer_Guides_Checkpoint,  
  SUM(CASE WHEN DSD.StatusOrderId = 20 THEN DOP.NoPiece ELSE 0 END) AS Transfer_Pieces_Checkpoint,  
  
  SUM(CASE WHEN ISNULL(DSD.StatusOrderId,0) = 0  THEN 1 ELSE 0 END) AS NonOperatedGuides,  
  SUM(CASE WHEN ISNULL(DSD.StatusOrderId,0) = 0  THEN DOP.NoPiece ELSE 0 END) AS NonOperatedGuidesPiece,  
  
  
  (SUM(CASE WHEN DSD.StatusOrderId = 5 THEN DOP.NoPiece ELSE 0 END) * 100 / NULLIF(MAX(ISNULL(DOBS.Pieces_Dry_Dispatched,0)) + MAX(ISNULL(DOBS.Pieces_Cold_Dispatched,0)), 0))   
   AS Delivery_effectiveness,  
   
  --(SUM(CASE WHEN DSD.StatusOrderId = 5 THEN DOP.NoPiece ELSE 0 END) * 100 / MAX(ISNULL(DOBS.Pieces_Dry_Dispatched,0)) + MAX(ISNULL(DOBS.Pieces_Cold_Dispatched,0)))  AS Delivery_effectiveness,  
    CONVERT(  
   CHAR(8),  
   DATEADD(  
    SECOND,  
    DATEDIFF(SECOND, MAX(DOBS.Date_Dispatched ), MAX(DOBS.Route_Received)),  
    0  
   ),  
   108  
  ) AS Time_on_route,  
   
  MAX(ISNULL(IIR.IncidentsCount, 0)) AS  IncidenceInRoute,  
  
  MAX(ISNULL(I.UnvalidatedIncidentCount, 0)) AS UnvalidatedIncident,  
  
  
  MAX(ISNULL(IR.RealIncidentsCount, 0)) AS RealIncidents,  
   
  
  MAX(ISNULL(FI.FalseIncidentsCount, 0)) AS FalseIncidents,  
  
      
  MAX(ISNULL(FI.FalseIncidentsCount, 0)) + MAX(ISNULL(IR.RealIncidentsCount, 0)) AS OperatedIncidence   
   
 FROM   
  [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)  
 INNER JOIN   
  [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)  
  ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement  
 INNER JOIN   
  [DeliveryBackOffice].[dbo].[SenderReceiver] SRE WITH (NOLOCK)  
  ON SRE.ID = DOBS.ID_Courier  
 INNER JOIN   
  [DeliveryBackOffice].[dbo].[HubLogistics] HBL WITH (NOLOCK)  
  ON HBL.IdHubLogistic = SRE.HubLogisticId   
 INNER JOIN     [DeliveryBackOffice].[dbo].[HubByRegion] HBR WITH (NOLOCK)  
  ON SRE.HubLogisticId = HBR.HubLogisticId  
 INNER JOIN   
  [DeliveryBackOffice].[dbo].[CatRegion] CR WITH (NOLOCK)  
  ON HBR.RegionId = CR.IdCatRegion  
 INNER JOIN   
  [DeliveryBackOffice].[dbo].[CatRoute] CRT WITH (NOLOCK)  
  ON DOBS.CatRouteId = CRT.IdRoute  
 INNER JOIN   
  [DeliveryBackOffice].[dbo].[CatVehicle] CVH WITH (NOLOCK)  
  ON DOBS.CatVehicleId = CVH.IdVehicle  
 INNER JOIN   
  [DeliveryBackOffice].[dbo].[CatTypeSenderReceiver] TYSRE WITH (NOLOCK)  
  ON SRE.CatTypeSenderReceiverId = TYSRE.IdCatTypeSenderReceiver  
 LEFT JOIN   
  Incidents I WITH (NOLOCK)  
  ON I.ID = DSD.ID_DeliveryOrderBySettlement  
 LEFT JOIN   
  IncidentsReal IR WITH (NOLOCK)  
  ON  IR.ID =  DSD.ID_DeliveryOrderBySettlement  
 LEFT JOIN   
  IncidentsFalse FI WITH (NOLOCK)  
  ON   FI.ID =  DSD.ID_DeliveryOrderBySettlement  
 LEFT JOIN IncidentsInRoute IIR WITH (NOLOCK)  
  ON    IIR.ID = DSD.ID_DeliveryOrderBySettlement    
 OUTER APPLY (  
  SELECT TOP 1 COUNT(DOP1.GuidePiece) AS NoPiece  
  FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP1 WITH (NOLOCK)  
  WHERE   DOP1.GuideSerie = DSD.Guide_Serie AND  DOP1.GuideNumber = DSD.Guide_Number  
     
 ) DOP  
  
 WHERE   
  DOBS.Date_Dispatched BETWEEN @StartDateTime AND @EndDateTime  
  AND   HBL.IdCountry = ISNULL(@IdCountry,'GT')  
 GROUP BY DOBS.ID  
  
end  