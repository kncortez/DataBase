
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
CREATE PROCEDURE [dbo].[spg_get_RoutePreparationPickUp] @datePickUp AS DATE = ''
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
           shp.EndDate,
           CONVERT(VARCHAR(10), shp.StartDate, 105) AS datePickUp,
           CONVERT(VARCHAR(10), shp.StartDate, 108) AS hourPickUp,
           CONCAT(FORMAT(shp.StartDate, 'HH:mm'), ' - ', FORMAT(shp.EndDate, 'HH:mm')) AS rangeHour,
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
        LEFT JOIN dbo.ServiceManagement srv
            ON srv.IdSchedulePickup = shp.SchedulePickupId
        LEFT JOIN [DeliveryBackOffice].[dbo].[CatServiceStatus] AS css WITH (NOLOCK)
            ON css.IdServiceStatus = srv.ServiceStatusId
    WHERE
        --@datePickUp BETWEEN CONVERT(DATE, shp.StartDate) AND CONVERT( DATE, shp.EndDate)
        --AND shp.AssigmentStatus IS NULL
        (NOT (
                 NOT (
                         @datePickUp_Internal >= CONVERT(DATE, shp.StartDate)
                         AND CONVERT(DATE, shp.EndDate) >= @datePickUp_Internal
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
        AND (dro.Guide_Number IS NULL OR (dro.Guide_Number IS NOT NULL AND dro.StatusOrderId <> 7)); -- Si tiene guía y no está anulada

    --DECLARE @guides NVARCHAR(MAX) =
    --        (
    --            SELECT STUFF(
    --                   (
    --                      SELECT DISTINCT
    --                              ',' + CONCAT(GuideSerie, GuideNumber)
    --                       FROM @tbl
    --                       WHERE Amount = 0
    --                             AND Timeid < 3
    --                       GROUP BY GuideSerie,
    --                                GuideNumber
    --                       FOR XML PATH('')
    --                   ),
    --                   1,
    --                   1,
    --                   ''
    --                        )
    --        );

    --PRINT 'inicia brain';
    --PRINT CONVERT(VARCHAR, GETDATE(), 9);
    --INSERT INTO @TempPrice
    --(
    --    GuideSerie,
    --    GuideNumber,
    --    IsCollect,
    --    Price,
    --    COD,
    --    AmountPaid,
    --    CODPaid,
    --    CODIsPaid,
    --    PaymentTime,
    --    TimeSequence,
    --    FelNumber,
    --    IsPaid,
    --    IsCustomer,
    --    ConditionPayment,
    --    HaveCredit,
    --    CollectCOD,
    --    ReturnRate,
    --    AmountToPay,
    --    CODAmount,
    --    ReturnRates
    --)
    --EXEC [dbo].[spws_get_guide_pending_payment] @InGuides = @guides,
    --                                            @InTime = 2,
    --                                            @IsReturn = 'FALSE',
    --                                            @CodeApp = 'SIFDCECOM300720201459',
    --                                            @IdModule = 1,
    --                                            @Token = 'SYSTEM';



    PRINT 'termina brain';
    PRINT CONVERT(VARCHAR, GETDATE(), 9);
    SELECT tb.Periodicy,
           tb.idSchedulePickUp,
           tb.Name,
           tb.Address,
           tb.Zone,
           tb.Phone,
           tb.StartDate,
           tb.EndDate,
           tb.datePickUp,
           tb.hourPickUp,
           tb.rangeHour,
           SUM(tb.QuantityRegularPackages) QuantityRegularPackages,
           SUM(tb.QuantityOverDimensionedPackage) QuantityOverDimensionedPackage,
           CAST(ROUND(AVG(tb.EstimatedWeight), 2) AS NUMERIC(18, 2)) EstimatedWeight,
           tb.IdHubLogistics,
           tb.HubAbbreviation,
           tb.NameTownship,
           tb.NameProvince,
           tb.TypeService,
           tb.SchedulePickupStatus,
           --SUM(ISNULL(tp.AmountToPay,0)) Amount,
           tb.ServiceVehicle,
           --ISNULL(tb.StatusName,'') StatusName
           tb.IdServiceManagement
    FROM @tbl tb
        LEFT JOIN @TempPrice tp
            ON tp.GuideSerie = tb.GuideSerie
               AND tp.GuideNumber = tb.GuideNumber
    GROUP BY idSchedulePickUp,
             Name,
             NameProvince,
             NameTownship,
             Address,
             Zone,
             TypeService,
             SchedulePickupStatus,
             StartDate,
             Periodicy,
             Phone,
             StartDate,
             EndDate,
             datePickUp,
             hourPickUp,
             rangeHour,
             IdHubLogistics,
             HubAbbreviation,
             ServiceVehicle,
             --StatusName
             IdServiceManagement
    OPTION (OPTIMIZE FOR UNKNOWN);

END;