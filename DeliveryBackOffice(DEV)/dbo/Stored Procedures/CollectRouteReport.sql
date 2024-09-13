-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-08-26>
-- Description: <Se agrega SP para reporte de monitoreo de servicios de recolecci�n>
-- =============================================
ALTER PROCEDURE [dbo].[CollectRouteReport]
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            -- Fecha despacho (Primer inicio de sesi�n del d�a, sin hora)
            COALESCE(ltp.DateCreated, '') AS DateOfRoute,
            --Pa�s Origen (relacionado con el servicio) Si sale antes de multipa�s se deja quemado GT luego considerarlo para multipa�s
            'GT' AS Country,
            --N�mero de servicio (ID del servicio) Formato de ODR, similar al formato definido en reporte de Dispatch Track PREGUNTAR A LA OPERACI�N SI ESTE FORMATO ES V�LIDO Y NO SOLO SE VA TENER PARA REPORTER�A 
            IIF(sp.IsScheduled = 0, CONCAT('RDG', sm.IdServiceManagement), CONCAT('RPG', sm.IdServiceManagement)) AS ServiceManagementNumber,
            --Nombre del cliente
            sp.SenderName AS ClientName,
            --Punto de visita
            vpc.DescriptionOfClient AS VisitPoint,
            --Hub (de la direcci�n del servicio), Tomar en cuenta servicios por garant�a que deber�a guardar al hacer el servicio por garant�a en punto de recolecci�n que corresponde
            ISNULL(IIF(hl.HubAbbreviation IS NOT NULL, hl.HubAbbreviation, hlbts.HubName), BHC.HubAbbreviation) AS HubName, -- si el servicio no tiene hub poner el hub del pilot CRAS
            --Regi�n
            IIF(cre.RegionName IS NOT NULL, cre.RegionName, hlbts.RegionName) AS RegionName,
            --DPI Courier
            sr.CUI AS CourierDPI,
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
            --Hora del despacho (Primer inicio de sesi�n del d�a)
            ltp.TimeCreated AS DispatchTime,
            --Hora de liquidaci�n
            CAST(sbp.DateCreated AS TIME(0)) AS SettlementTime,
            --Tipo de servicio (A demanda/Programado)
            IIF(sp.IsScheduled = 0, 'A demanda', 'Programado') AS ServiceType,
            --Estado del servicio
            css.Name AS ServicesStatus,
            --Servicio se ejecut� en tiempo (validar ventana horaria, que pasa si se ejecuta antes? si se pone en tiempo)
            smt.DateCreated,
            sp.StartDate,
            sp.EndDate,
            IIF(smt.DateCreated IS NOT NULL,
                IIF(
                    CAST(smt.DateCreated AS TIME) <= IIF(sp.EndDate IS NOT NULL,
                                                         CAST(sp.EndDate AS TIME),
                                                         '19:00:00.0000000'),
                    'Si',
                    'No'),
                '') AS ServiceOntime,
            --Hora inicio (que corresponde al servicio)
            CAST(sp.StartDate AS TIME(0)) AS StartTime,
            --Hora fin (que corresponde al servicio)
            IIF(sp.EndDate IS NOT NULL, CAST(sp.EndDate AS TIME(0)), '19:00:00') AS EndTime,
            --Piezas recolectadas (recolectan en POD, lo que liquidaron en recos, en la liquidaci�n no asocia los servicios, tomarlo en cuenta y validarlo con C. Valdes si fuera necesario)
            smt.cold_count AS ColdNumberOfItems,
            smt.dry_count AS DryNumberOfItems,
            ISNULL(smt.dry_count, 0) + ISNULL(smt.cold_count, 0) AS TotalNumberOfItems,
            --Nombre de incidencia (Que incidencia report�)	
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
            LEFT JOIN [DeliveryBackOffice].dbo.RouteAssigment ra WITH (NOLOCK)
                ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
			 LEFT JOIN [DeliveryBackOffice].dbo.[SenderReceiver] sr WITH (NOLOCK)
 				 --ON sr.ID = sm.IdPuCourrier
				ON ra.IdCurrierMan = sr.ID
			 LEFT JOIN dbo.HubLogistics BHC WITH (NOLOCK)
                ON BHC.IdHubLogistic = sr.HubLogisticId
            LEFT JOIN [DeliveryBackOffice].dbo.CatTypeSenderReceiver ctsr WITH (NOLOCK)
                ON sr.CatTypeSenderReceiverId = ctsr.IdCatTypeSenderReceiver
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
            ) AS smt
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
        ) AS hlbts
            OUTER APPLY
        (
            SELECT TOP 1
                   A1.ServiceManagementId,
                   A1.DescriptionIncidence
            FROM [DeliveryBackOffice].[dbo].[IncidenceServices] A1 WITH (NOLOCK)
            WHERE A1.ServiceManagementId = sm.IdServiceManagement
        ) AS ins
            OUTER APPLY
        (
            SELECT TOP 1 sbp.DateCreated
            FROM [DeliveryBackOffice].[dbo].SettlementByPickup AS sbp WITH (NOLOCK)
            WHERE sbp.RouteAssigmentId = sm.IdPuRouteAssigment
        ) AS sbp
        WHERE sm.RowStatus = 1
              AND CAST(sp.StartDate AS DATE) >= @StartDate
              AND CAST(ISNULL(sp.EndDate, @EndDate) AS DATE) <= @EndDate;
    END TRY
    BEGIN CATCH

        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description';

    END CATCH;
END;
