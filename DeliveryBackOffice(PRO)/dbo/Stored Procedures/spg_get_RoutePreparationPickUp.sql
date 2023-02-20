
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-10>
-- Description:	<Devuelve información para preparación de ruta>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <2020-03-21>
-- Description:	< Adición de WITH(NOLOCK) para evitar bloqueos >
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <2022-07-20>
-- Description:	< Cambio de agrupaciones para evitar duplicados (Falsos positivos) >
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_RoutePreparationPickUp]
    @datePickUp AS DATE = '',
    @hubId INT = -1
AS
BEGIN
    SET ARITHABORT ON;

    PRINT 'INICIO';
    PRINT CONVERT(VARCHAR, GETDATE(), 9);

    DECLARE @datePickUp_Internal DATE = @datePickUp;
    DECLARE @TempPrice TABLE
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
        --AmountToPay DECIMAL(14, 2) NULL,
        CODAmount DECIMAL(14, 2) NULL,
        ReturnRates DECIMAL(14, 2) NULL
    );


    DECLARE @tbl TABLE
    (
        Periodicy NVARCHAR(50) NULL,
        idSchedulePickUp INT NULL,
        Name VARCHAR(200) NULL,
        Address VARCHAR(500) NULL,
        Zone NVARCHAR(100) NULL,
        Phone VARCHAR(50) NULL,
        StartDate DATETIME NULL,
        EndDate DATETIME NULL,
        datePickUp VARCHAR(10) NULL,
        hourPickUp VARCHAR(10) NULL,
        rangeHour VARCHAR(23) NULL,
        QuantityRegularPackages INT NULL,
        QuantityOverDimensionedPackage INT NULL,
        EstimatedWeight DECIMAL NULL,
        IdHubLogistics INT NULL,
        HubAbbreviation VARCHAR(5) NULL,
        NameTownship NVARCHAR(100) NULL,
        NameProvince NVARCHAR(100) NULL,
        TypeService VARCHAR(3) NULL,
        SchedulePickupStatus BIT NULL,
        GuideSerie NVARCHAR(2) NULL,
        GuideNumber INT NULL,
        ServiceVehicle NVARCHAR(100) NULL,
        --Amount DECIMAL(12, 2) NULL,
        Timeid INT NULL,
        --StatusName NVARCHAR(100)
        IdServiceManagement INT NULL
    );

    PRINT 'Insert tabla temp';
    PRINT GETDATE();

    INSERT INTO @tbl
    SELECT 'Demanda' Periodicy,
           SchedulePickupId 'idSchedulePickUp',
           SenderName 'Name',
           AddressPickup 'Address',
           ISNULL(dro.Sender_Zone, '0') Zone,
           SenderPhone 'Phone',
           shp.StartDate,
           ISNULL(shp.EndDate, DATEADD(HOUR, 19, CAST(CAST(shp.StartDate AS DATE) AS DATETIME))),
           CONVERT(VARCHAR(10), shp.StartDate, 105) AS datePickUp,
           CONVERT(VARCHAR(10), shp.StartDate, 108) AS hourPickUp,
           CONCAT(CONVERT(VARCHAR(10), shp.StartDate, 108), '   ', CONVERT(VARCHAR(10), ISNULL(shp.EndDate, DATEADD(HOUR, 19, CAST(CAST(shp.StartDate AS DATE) AS DATETIME))), 108)) AS rangeHour,
           QuantityRegularPackages,
           QuantityOverDimensionedPackage,
           EstimatedWeight,
           IdHubLogistics,
           hub.HubAbbreviation,
           (CASE
                WHEN dro.Sender_Town IS NOT NULL THEN
                    dro.Sender_Town
                WHEN shp.TownshipId IS NOT NULL THEN
                    twnT.TownshipName
                ELSE
                    ''
            END
           ) AS NameTownship,
           (CASE
                WHEN dro.Sender_Department IS NOT NULL THEN
                    dro.Sender_Department
                WHEN shp.TownshipId IS NOT NULL THEN
                    prv.ProvinceName
                ELSE
                    ''
            END
           ) AS NameProvince,
           (CASE
                WHEN dro.TypeService IS NOT NULL THEN
                    dro.TypeService
                ELSE
                    ''
            END
           ) AS TypeService,
           ISNULL(SchedulePickupStatus, 'True') SchedulePickupStatus,
           dop.GuideSerie,
           dop.GuideNumber,
           ISNULL(ctv.Name, '') ServiceVehicle,
           --ISNULL(srv.Amount, 0),
           dop.TimePlaId,
           --,css.[Name] StatusName
           srv.IdServiceManagement
    FROM DeliveryBackOffice.dbo.SchedulePickup AS shp WITH (NOLOCK)
        --LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics] AS hub WITH (NOLOCK)
        --    ON shp.IdHubLogistics = hub.IdHubLogistic
        LEFT JOIN [DeliveryBackOffice].[dbo].[Township] twnT WITH (NOLOCK)
            ON shp.TownshipId = twnT.IdTownship
        LEFT JOIN [DeliveryBackOffice].[dbo].[Province] prv WITH (NOLOCK)
            ON prv.IdProvince = twnT.IdProvince
        LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] dop WITH (NOLOCK)
            ON dop.IdHeaderRecolection = shp.SchedulePickupId
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder AS dro WITH (NOLOCK)
            ON dro.Guide_Number = dop.GuideNumber
               AND dro.Guide_Serie = dop.GuideSerie
               AND dro.SalePipeLineId != 7
        LEFT JOIN [DeliveryBackOffice].[dbo].[Township] twnTdro WITH (NOLOCK)
            ON dro.SenderIdTownship = twnTdro.IdTownship
        LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
            ON shp.SenderId = vpc.CodeOfReference
        LEFT JOIN [DeliveryBackOffice].[dbo].[Township] TwnTvpc WITH (NOLOCK)
            ON vpc.IdTownship = TwnTvpc.IdTownship
        LEFT JOIN
        (
            SELECT DSCAux.HeaderCode,
                   MAX(DSCAux.Hub) 'HubAbbreviation'
            FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSCAux WITH (NOLOCK)
            GROUP BY DSCAux.HeaderCode
        ) hub
            ON ISNULL(ISNULL(twnT.HeaderCode, twnTdro.HeaderCode), TwnTvpc.HeaderCode) = hub.HeaderCode
        LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeVehicle] ctv WITH (NOLOCK)
            ON shp.TypeVehicleId = ctv.IdTypeVehicle
        LEFT JOIN dbo.ServiceManagement srv WITH (NOLOCK)
            ON srv.IdSchedulePickup = shp.SchedulePickupId
        LEFT JOIN [DeliveryBackOffice].[dbo].[CatServiceStatus] AS css WITH (NOLOCK)
            ON css.IdServiceStatus = srv.ServiceStatusId
    WHERE
        --@datePickUp BETWEEN CONVERT(DATE, shp.StartDate) AND CONVERT( DATE, shp.EndDate)
        --AND shp.AssigmentStatus IS NULL
        (NOT (
                 NOT (
                         @datePickUp_Internal >= CONVERT(DATE, shp.StartDate)
                         AND CONVERT(DATE, ISNULL(shp.EndDate, DATEADD(HOUR, 19, CAST(CAST(shp.StartDate AS DATE) AS DATETIME)))) >= @datePickUp_Internal
                     )
                 AND NOT (@datePickUp_Internal = '')
             )
        )
        AND (NOT (
                     NOT (AssigmentStatus = 0)
                     AND NOT (AssigmentStatus IS NULL)
                 )
            )
        AND shp.RowStatus = 1
        AND
        (
            @hubId = -1
            OR shp.IdHubLogistics = @hubId
        );
   
    PRINT 'termina brain';
    PRINT CONVERT(VARCHAR, GETDATE(), 9);
    SELECT MAX(tb.Periodicy) 'Periodicy',
           tb.idSchedulePickUp,
           MAX(tb.Name) 'Name',
           tb.Address,
           MAX(tb.Zone) 'Zone',
           MAX(tb.Phone) 'Phone',
           MAX(tb.StartDate) 'StartDate',
           MAX(tb.EndDate) 'EndDate',
           MAX(tb.datePickUp) 'datePickUp',
           MAX(tb.hourPickUp) 'hourPickUp',
           MAX(tb.rangeHour) 'rangeHour',
           SUM(tb.QuantityRegularPackages) QuantityRegularPackages,
           SUM(tb.QuantityOverDimensionedPackage) QuantityOverDimensionedPackage,
           CAST(ROUND(AVG(tb.EstimatedWeight), 2) AS NUMERIC(18, 2)) EstimatedWeight,
           MAX(tb.IdHubLogistics) 'IdHubLogistics',
           MAX(tb.HubAbbreviation) 'HubAbbreviation',
           MAX(tb.NameTownship) 'NameTownship',
           MAX(tb.NameProvince) 'NameProvince',
           MIN(tb.TypeService) 'TypeService',
           tb.SchedulePickupStatus 'SchedulePickupStatus',
           --SUM(ISNULL(tp.AmountToPay,0)) Amount,
           MIN(tb.ServiceVehicle) 'ServiceVehicle',
           --ISNULL(tb.StatusName,'') StatusName
           tb.IdServiceManagement
    FROM @tbl tb
        LEFT JOIN @TempPrice tp
            ON tp.GuideSerie = tb.GuideSerie
               AND tp.GuideNumber = tb.GuideNumber
    GROUP BY idSchedulePickUp,
             IdServiceManagement,
             Address,
            
             SchedulePickupStatus
  OPTION (OPTIMIZE FOR UNKNOWN);

END;