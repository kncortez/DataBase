
CREATE PROCEDURE [dbo].[analisis_recolecciones2]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        SEM.IdServiceManagement,
        SCP.DateCreated AS RequestDate,
        SCP.StartDate,
        SCP.EndDate,
        ISNULL(CS.SysNameSystem, 'Hermes Web') AS NameSystem,
        CSS.IdServiceStatus,
        CSS.Name,
        SRE.First_Name + ' ' + SRE.Last_Name AS Courier,
        CTV.Name AS TypeVehicle,
        IIF(SCP.IsScheduled = 1, 'Programada', 'Demanda') AS PickupType,
        SCP.SenderId,
        SCP.SenderName,
        CTM.IdCustomer,
        CTM.Name AS CustomerName,
        INS.IdIncidence,
        INS.DescriptionIncidence,
        SCP.IdHubLogistics,
        ISNULL(conv.Hub, HBL.HubAbbreviation) AS HubAbbreviation,
        g.CountGuides,
        p.CountPieces,
        pu.PUSuccess,
        pu.RealPickupDate,
        VPC.Latitude,
        VPC.Longitude,
        IIF(ABS(VPC.Latitude) > 0, 1, 0) AS Georeference,
        DATEDIFF(HOUR, SCP.StartDate, pu.RealPickupDate) AS DifStartPickup,
        IIF(DATEDIFF(HOUR, SCP.StartDate, pu.RealPickupDate) <= 2, 1, 0) AS OnTime,
        IIF(DATEPART(HOUR, SCP.DateCreated) > 16, 1, 0) AS AfterHour,
        a.AssingDate,
        DATEDIFF(HOUR, SCP.DateCreated, a.AssingDate) AS DifRequestAssing,
        DATENAME(WEEKDAY, SCP.StartDate) AS StartDay,
        IIF(DATEDIFF(DAY, SCP.StartDate, pu.RealPickupDate) <= 1, 1, 0) AS OnTimeDate,
        conv.IdTownship AS IDtownsk
    FROM dbo.SchedulePickup SCP WITH (NOLOCK)
    INNER JOIN dbo.ServiceManagement SEM WITH (NOLOCK) 
        ON SEM.IdSchedulePickup = SCP.SchedulePickupId
    INNER JOIN dbo.CatServiceStatus CSS WITH (NOLOCK) 
        ON CSS.IdServiceStatus = SEM.ServiceStatusId
    INNER JOIN dbo.SenderReceiver SRE WITH (NOLOCK) 
        ON SRE.ID = SEM.IdPuCourrier
    LEFT JOIN dbo.CatTypeVehicle CTV WITH (NOLOCK) 
        ON SCP.TypeVehicleId = CTV.IdTypeVehicle
    LEFT JOIN dbo.VisitPointClient VPC WITH (NOLOCK) 
        ON VPC.CodeOfReference = SCP.SenderId
    LEFT JOIN dbo.Customer CTM WITH (NOLOCK) 
        ON CTM.IdCustomer = VPC.CustomerID
    LEFT JOIN dbo.IncidenceServices INS WITH (NOLOCK) 
        ON INS.ServiceManagementId = SEM.IdServiceManagement
    LEFT JOIN dbo.HubLogistics HBL WITH (NOLOCK) 
        ON HBL.IdHubLogistic = ISNULL(SCP.IdHubLogistics, SRE.HubLogisticId)
    LEFT JOIN dbo.CatSystem CS WITH (NOLOCK) 
        ON SCP.IdSourcePlataform = CS.SysIdSystem

    OUTER APPLY (
        SELECT COUNT(1) AS CountGuides
        FROM dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
        WHERE DOP.IdHeaderRecolection = SCP.SchedulePickupId
    ) g

    OUTER APPLY (
        SELECT COUNT(1) AS CountPieces
        FROM dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
        INNER JOIN dbo.DeliveryOrderPiece DPP WITH (NOLOCK)
            ON DPP.GuideSerie = DOP.GuideSerie 
           AND DPP.GuideNumber = DOP.GuideNumber
        WHERE DOP.IdHeaderRecolection = SCP.SchedulePickupId
    ) p

    OUTER APPLY (
        SELECT TOP 1 
            IIF(DOD.DateCreatedInSystem IS NULL, 0, 1) AS PUSuccess,
            DOD.DateCreatedInSystem AS RealPickupDate
        FROM dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
        INNER JOIN dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
            ON DOP.GuideSerie = DOD.Guide_Serie 
           AND DOP.GuideNumber = DOD.Guide_Number
        WHERE DOD.StatusOrderId IN (2,11,20)
          AND DOP.IdHeaderRecolection = SCP.SchedulePickupId
        ORDER BY DOD.StatusOrderId ASC
    ) pu

    OUTER APPLY (
        SELECT TOP 1 ev.DateCreated AS AssingDate
        FROM dbo.EventService ev WITH (NOLOCK)
        WHERE ev.ServiceStatusId = 2 
          AND ev.ServiceManagementId = SEM.IdServiceManagement
        ORDER BY ev.DateCreated DESC
    ) a

    OUTER APPLY (
        SELECT TOP 1 dpm.Hub, tn.IdTownship
        FROM dbo.DumpServiceCoverage dpm WITH (NOLOCK)
        INNER JOIN dbo.Township tn WITH (NOLOCK) 
            ON tn.HeaderCode = dpm.HeaderCode
        WHERE tn.IdTownship = COALESCE(SCP.TownshipId, VPC.IdTownship)
    ) conv

    WHERE SCP.DateCreated >= '2024-01-01';
END