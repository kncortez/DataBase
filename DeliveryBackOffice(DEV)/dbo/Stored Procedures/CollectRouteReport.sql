-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-08-26>
-- Description: <Se agrega SP para reporte de monitoreo de servicios de recolección>
-- =============================================
CREATE PROCEDURE CollectRouteReport
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN	
	SET NOCOUNT ON;
	
	BEGIN TRY
        SELECT 
            -- Fecha despacho (Primer inicio de sesión del día, sin hora)
            CAST(ra.DateOfRoute AS DATE) AS DateOfRoute,
            --País Origen (relacionado con el servicio) Si sale antes de multipaís se deja quemado GT luego considerarlo para multipaís
            'GT' AS Country,
            --Número de servicio (ID del servicio) Formato de ODR, similar al formato definido en reporte de Dispatch Track PREGUNTAR A LA OPERACIÓN SI ESTE FORMATO ES VÁLIDO Y NO SOLO SE VA TENER PARA REPORTERÍA 
            IIF(sp.IsScheduled = 0, CONCAT('RDG', sm.IdServiceManagement), CONCAT('RPG', sm.IdServiceManagement) ) ServiceManagementNumber,
            --Nombre del cliente
            sp.SenderName AS ClientName,
            --Punto de visita
            vpc.CodeOfReference AS VisitPoint,
            --Hub (de la dirección del servicio), Tomar en cuenta servicios por garantía que debería guardar al hacer el servicio por garantía en punto de recolección que corresponde
            IIF(hl.HubName IS NOT NULL, hl.HubName,hlbts.HubName) AS HubName,
            --Región
            IIF(cre.RegionName IS NOT NULL, cre.RegionName,hlbts.RegionName) AS RegionName,
            --DPI Courier
            sr.CUI CourierDPI,
            --Nombre Courier
            CONCAT(sr.First_Name,' ',sr.Last_Name) as CurrierName,
            --Puesto Courier
            ctsr.TypeName AS CourierJobName,
            --Ruta
            cr.CodeRoute AS Route,
            --Unidad
            CONCAT(ctv.Name,'  ',cv.plate) AS Vehicle,
            --Manifiesto (route assignment)
            ra.IdRouteAssigment AS Manifest,
            --Hora del despacho (Primer inicio de sesión del día)
            ltp.TimeCreated AS DispatchTime,
            --Hora de liquidación
            CAST(sbp.DateCreated AS TIME) AS SettlementTime,
            --Tipo de servicio (A demanda/Programado)
            IIF(sp.IsScheduled = 0, 'A demanda', 'Programado') AS ServiceType,
            --Estado del servicio
            css.Name AS ServicesStatus,
            --Servicio se ejecutó en tiempo (validar ventana horaria, que pasa si se ejecuta antes? si se pone en tiempo)
            smt.DateCreated, 
            sp.StartDate,
            sp.EndDate,
            IIF(smt.DateCreated IS NOT NULL,IIF(CAST(smt.DateCreated AS TIME) <= IIF(sp.EndDate IS NOT NULL, CAST(sp.EndDate AS TIME), '19:00:00.0000000') , 'Si','No'),'Pendiente') AS ServiceOntime,
            --Hora inicio (que corresponde al servicio)
            CAST(sp.StartDate AS TIME) AS StartTime,
            --Hora fin (que corresponde al servicio)
            IIF(sp.EndDate IS NOT NULL, CAST(sp.EndDate AS TIME), '19:00:00.0000000') AS EndTime,
            --Piezas recolectadas (recolectan en POD, lo que liquidaron en recos, en la liquidación no asocia los servicios, tomarlo en cuenta y validarlo con C. Valdes si fuera necesario)
            smt.cold_count AS ColdNumberOfItems,
            smt.dry_count AS DryNumberOfItems,
            --Nombre de incidencia (Que incidencia reportó)	
            ins.DescriptionIncidence AS IncidenceName
        FROM [DeliveryBackOffice].[dbo].[ServiceManagement] sm WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.SchedulePickup sp WITH(NOLOCK) 
                ON sp.SchedulePickupId = sm.IdSchedulePickup
            INNER JOIN DeliveryBackOffice.dbo.CatServiceStatus css WITH(NOLOCK) 
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
                ON sr.Id = sm.IdPuCourrier
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
            LEFT JOIN (
                        SELECT ltpod.IdCourierman, CAST(ltpod.DateCreated AS DATE) AS DateCreated, CAST(MIN(ltpod.DateCreated) AS TIME) AS TimeCreated  
                        FROM LogTokenPOD ltpod WITH (NOLOCK)
                        GROUP BY ltpod.IdCourierman, CAST(ltpod.DateCreated AS DATE)
            ) AS ltp ON ltp.IdCourierman = sm.IdPuCourrier AND ltp.DateCreated = CAST(sp.StartDate AS DATE)
            LEFT JOIN (
                    SELECT dop.IdHeaderRecolection,   
                        SUM(ISNULL(dor.Pieces_Cold,0)) AS cold_count,
                        SUM(ISNULL(dor.Pieces_Dry,0)) AS dry_count,
                        MIN(dop.DateCreated) AS DateCreated 
                    FROM [dbo].[DeliveryOrderPaymentDetail] AS dop WITH(NOLOCK)
                    LEFT JOIN[DeliveryBackOffice].[dbo].[DeliveryOrder] AS dor WITH(NOLOCK) 
                        ON dor.Guide_Number = dop.GuideNumber AND dor.Guide_Serie = dop.GuideSerie
                    GROUP BY dop.IdHeaderRecolection
            )smt ON smt.IdHeaderRecolection = sp.SchedulePickupId
            LEFT JOIN (
                    SELECT tbhl.IdTownship,hl.HubName, cre.RegionName
                    FROM [DeliveryBackOffice].dbo.TownshipByHubLogistic  AS tbhl WITH(NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].HubLogistics AS hl WITH(NOLOCK) 
                        ON tbhl.IdHublogistic = hl.Idhublogistic
                    INNER JOIN [DeliveryBackOffice].dbo.[HubByRegion] hbr WITH (NOLOCK) 
                        ON hl.IdHubLogistic = hbr.HubLogisticId
                    INNER JOIN [DeliveryBackOffice].dbo.[CatRegion] cre WITH (NOLOCK) 
                        ON cre.IdCatRegion = hbr.RegionId
                    WHERE tbhl.StatusTownshipHub = 1
                        AND hl.HubStatus = 1
            ) AS hlbts ON hlbts.IdTownship = sp.TownshipId
            LEFT JOIN [DeliveryBackOffice].[dbo].[IncidenceServices] AS ins WITH(NOLOCK) 
                ON ins.ServiceManagementId = sm.IdServiceManagement
            LEFT JOIN [DeliveryBackOffice].[dbo].SettlementByPickup AS sbp WITH(NOLOCK) 
                ON sbp.RouteAssigmentId = sm.IdPuRouteAssigment
        WHERE sm.RowStatus = 1
            AND CAST(sp.StartDate AS DATE) >= @StartDate
            AND CAST(sp.EndDate AS DATE) <= @EndDate
    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END;
