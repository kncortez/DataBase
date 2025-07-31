
create procedure TORRE_DE_CONTROL_RECOLECCIONES_V1

as 
begin
-- TORRE DE CONTROL RECOLECCIONES V.1 DATAWAREHOUSE (septiembre 03)

DECLARE @StartDate DATE = '2024-08-01'
DECLARE @EndDate DATE = convert(DATE, GETDATE() - 0) -- incluye esta fecha

SELECT DISTINCT 
    -- Fecha despacho (Primer inicio de sesión del día, sin hora)
    --CAST(ra.DateOfRoute AS DATE)                                                                          
       COALESCE(ltp.DateCreated, '') AS DateOfRoute,
       --País Origen (relacionado con el servicio) Si sale antes de multipaís se deja quemado GT luego considerarlo para multipaís
       'GT' AS Country,
       --Número de servicio (ID del servicio) Formato de ODR, similar al formato definido en reporte de Dispatch Track PREGUNTAR A LA OPERACIÓN SI ESTE FORMATO ES VÁLIDO Y NO SOLO SE VA TENER PARA REPORTERÍA 
       IIF(sp.IsScheduled = 0, CONCAT('RDG', sm.IdServiceManagement), CONCAT('RPG', sm.IdServiceManagement)) ServiceManagementNumber,
       --Nombre del cliente
       sp.SenderName AS ClientName,
       --Punto de visita
       vpc.DescriptionOfClient AS VisitPoint,
       --Hub (de la dirección del servicio), Tomar en cuenta servicios por garantía que debería guardar al hacer el servicio por garantía en punto de recolección que corresponde
       ISNULL(IIF(hl.HubAbbreviation IS NOT NULL, hl.HubAbbreviation, hlbts.HubName), BHC.HubAbbreviation) AS HubName, -- si el servicio no tiene hub poner el hub del pilot CRAS
       --Región
       IIF(cre.RegionName IS NOT NULL, cre.RegionName, hlbts.RegionName) AS RegionName,
       --DPI Courier
       sr.CUI CourierDPI,
       --Nombre Courier
       CONCAT(sr.First_Name, ' ', sr.Last_Name) AS CurrierName,
       --Puesto Courier
       ctsr.TypeName AS CourierJobName,
       --Ruta
       cr.CodeRoute AS Route,
       --Unidad
       cv.UnitNumber AS Vehicle,
       --Manifiesto (route assignment)
       ra.IdRouteAssigment AS Manifest,
       --Hora del despacho (Primer inicio de sesión del día)
       ltp.TimeCreated AS DispatchTime,
       --Hora de liquidación
       CAST(sbp.DateCreated AS TIME(0)) AS SettlementTime,
       --Tipo de servicio (A demanda/Programado)
       IIF(sp.IsScheduled = 0, 'A demanda', 'Programado') AS ServiceType,
       --Estado del servicio
       css.Name AS ServicesStatus,
       --Servicio se ejecutó en tiempo (validar ventana horaria, que pasa si se ejecuta antes? si se pone en tiempo)
       smt.DateCreated,
       sp.StartDate,
       sp.EndDate,
       IIF(smt.DateCreated IS NOT NULL,
           IIF(CAST(smt.DateCreated AS TIME) <= IIF(sp.EndDate IS NOT NULL, CAST(sp.EndDate AS TIME), '19:00:00.0000000'),
               'Si',
               'No'),
           '') AS ServiceOntime,
       --Hora inicio (que corresponde al servicio)
       CAST(sp.StartDate AS TIME(0)) AS StartTime,
       --Hora fin (que corresponde al servicio)
       IIF(sp.EndDate IS NOT NULL, CAST(sp.EndDate AS TIME(0)), '19:00:00') AS EndTime,
       --Piezas recolectadas (recolectan en POD, lo que liquidaron en recos, en la liquidación no asocia los servicios, tomarlo en cuenta y validarlo con C. Valdes si fuera necesario)
       smt.cold_count AS ColdNumberOfItems,
       smt.dry_count AS DryNumberOfItems,
       ISNULL(smt.dry_count, 0) + ISNULL(smt.cold_count, 0) AS TotalNumberOfItems,
       --Nombre de incidencia (Que incidencia reportó)	
       ins.DescriptionIncidence AS IncidenceName
FROM [DeliveryBackOffice].[dbo].[ServiceManagement] sm WITH (NOLOCK)
    INNER JOIN DeliveryBackOffice.dbo.SchedulePickup sp WITH (NOLOCK)
        ON sp.SchedulePickupId = sm.IdSchedulePickup
    INNER JOIN DeliveryBackOffice.dbo.CatServiceStatus css WITH (NOLOCK)
        ON sm.ServiceStatusId = css.IdServiceStatus
    INNER JOIN [DeliveryBackOffice].dbo.VisitPointClient vpc WITH (NOLOCK)
        ON vpc.CodeOfReference = sp.SenderId
    LEFT JOIN [DeliveryBackOffice].dbo.[HubLogistics] hl WITH (NOLOCK)
        ON hl.IdHubLogistic = sp.IdHubLogistics
    LEFT JOIN [DeliveryBackOffice].dbo.[HubByRegion] hbr WITH (NOLOCK)
        ON hl.IdHubLogistic = hbr.HubLogisticId
    LEFT JOIN [DeliveryBackOffice].dbo.[CatRegion] cre WITH (NOLOCK)
        ON cre.IdCatRegion = hbr.RegionId
    LEFT JOIN [DeliveryBackOffice].dbo.[SenderReceiver] sr WITH (NOLOCK)
        ON sr.ID = sm.IdPuCourrier
    LEFT JOIN dbo.HubLogistics BHC WITH (NOLOCK)
        ON BHC.IdHubLogistic = sr.HubLogisticId
    LEFT JOIN [DeliveryBackOffice].dbo.CatTypeSenderReceiver ctsr WITH (NOLOCK)
        ON sr.CatTypeSenderReceiverId = ctsr.IdCatTypeSenderReceiver
    LEFT JOIN [DeliveryBackOffice].dbo.RouteAssigment ra WITH (NOLOCK)
        ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
    LEFT JOIN [DeliveryBackOffice].dbo.[CatVehicle] cv WITH (NOLOCK)
        ON cv.IdVehicle = ra.IdVehicle
    LEFT JOIN [DeliveryBackOffice].dbo.[CatRoute] cr WITH (NOLOCK)
        ON cr.IdRoute = ra.IdRoute
    LEFT JOIN [DeliveryBackOffice].dbo.CatTypeVehicle ctv WITH (NOLOCK)
        ON cv.IdTypeVehicle = ctv.IdTypeVehicle
    LEFT JOIN
    (
        SELECT ltpod.IdCourierman,
               CAST(ltpod.DateCreated AS DATE) AS DateCreated,
               CAST(MIN(ltpod.DateCreated) AS TIME(0)) AS TimeCreated
        FROM LogTokenPOD ltpod WITH (NOLOCK)
        GROUP BY ltpod.IdCourierman,
                 CAST(ltpod.DateCreated AS DATE)
    ) AS ltp
        ON ltp.IdCourierman = sm.IdPuCourrier
           AND ltp.DateCreated = CAST(sp.StartDate AS DATE)
    LEFT JOIN
    (
        SELECT dop.IdHeaderRecolection,
               SUM(ISNULL(dor.Pieces_Cold, 0)) AS cold_count,
               SUM(ISNULL(dor.Pieces_Dry, 0)) AS dry_count,
               MIN(dop.DateCreated) AS DateCreated
        FROM [dbo].[DeliveryOrderPaymentDetail] AS dop WITH (NOLOCK)
            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] AS dor WITH (NOLOCK)
                ON dor.Guide_Number = dop.GuideNumber
                   AND dor.Guide_Serie = dop.GuideSerie
        GROUP BY dop.IdHeaderRecolection
    ) smt
        ON smt.IdHeaderRecolection = sp.SchedulePickupId
    OUTER APPLY
(
    SELECT TOP 1
           A2.Hub HubName, --tbhl.IdTownship
           --, hl.HubAbbreviation  HubName -- COLOCAR ABREVIATURA DE HUB CRAS
           A5.RegionName RegionName
    FROM DeliveryBackOffice.dbo.Township A1 WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.DumpServiceCoverage A2 WITH (NOLOCK)
            ON A2.HeaderCode = A1.HeaderCode
        INNER JOIN DeliveryBackOffice.dbo.HubLogistics A3 WITH (NOLOCK)
            ON A3.HubAbbreviation = A2.Hub
        LEFT JOIN DeliveryBackOffice.dbo.HubByRegion A4 WITH (NOLOCK)
            ON A4.HubLogisticId = A3.IdHubLogistic
        LEFT JOIN DeliveryBackOffice.dbo.CatRegion A5
            ON A4.RegionId = A5.IdCatRegion
    WHERE A1.IdTownship = sp.TownshipId
          AND A2.RowStatus = 1
          AND A3.HubStatus = 1
          AND A4.RowStatus = 1
          AND A5.RowStatus = 1
    ORDER BY A1.IdTownship ASC
--DeliveryBackOffice.dbo.DumpServiceCoverage AS tbhl WITH (NOLOCK)					  
--   --[DeliveryBackOffice].dbo.TownshipByHubLogistic    AS tbhl WITH (NOLOCK)                 
--INNER JOIN [DeliveryBackOffice].[dbo].HubLogistics AS hl WITH (NOLOCK)
--                   ON  tbhl.IdHublogistic = hl.IdHubLogistic
--               INNER JOIN [DeliveryBackOffice].dbo.[HubByRegion]  hbr WITH (NOLOCK)
--                   ON hl.IdHubLogistic = hbr.HubLogisticId
--               INNER JOIN [DeliveryBackOffice].dbo.[CatRegion]    cre WITH (NOLOCK)
--                   ON cre.IdCatRegion = hbr.RegionId
--           WHERE tbhl.StatusTownshipHub = 1
--                 AND hl.HubStatus = 1
) AS hlbts
    LEFT JOIN [DeliveryBackOffice].[dbo].[IncidenceServices] AS ins WITH (NOLOCK)
        ON ins.ServiceManagementId = sm.IdServiceManagement
    LEFT JOIN [DeliveryBackOffice].[dbo].SettlementByPickup AS sbp WITH (NOLOCK)
        ON sbp.RouteAssigmentId = sm.IdPuRouteAssigment
WHERE sm.RowStatus = 1
      AND CAST(sp.StartDate AS DATE) >= @StartDate
      AND CAST(sp.EndDate AS DATE) <= @EndDate;
end