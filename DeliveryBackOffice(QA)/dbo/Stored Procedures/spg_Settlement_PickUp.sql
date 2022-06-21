
-- =============================================
-- Author:		<Hugo, Gómez>
-- Create date: <2020-02-15>
-- Description:	<Devuelve todas las Pickups asociadas a una ruta >
-- =============================================
CREATE PROCEDURE [dbo].[spg_Settlement_PickUp] @Route VARCHAR(100) = 'GUA001'
AS
BEGIN

    DECLARE @tiempo DATE =
            (
                SELECT CAST(GETDATE() AS DATE)
            );

    DECLARE @Guides TABLE
    (
        Guide_Serie NVARCHAR(2),
        Guide_Number INT,
        Serie_Manifest NVARCHAR(2),
        Numero_Manifest INT,
        Sender_FirstName NVARCHAR(100),
        Sender_LastName NVARCHAR(100),
        piece INT,
        IdRoute INT,
        ID INT
    );

    INSERT INTO @Guides
    SELECT DISTINCT
           ord.Guide_Serie,
           ord.Guide_Number,
           ord.Manifest_Serie,
           ord.Manifest_Number,
           ord.Sender_FirstName,
           ord.Sender_LastName,
           COUNT(ordp.NoPiece) piece,
           ra.IdRouteAssigment,
           sr.ID
    FROM DeliveryOrder ord WITH(NOLOCK)
        --left join DeliveryOrderDetail ordd on (ord.Guide_Number = ordd.Guide_Number and ord.Guide_Serie = ordd.Guide_Serie)
        LEFT JOIN DeliveryOrderPiece ordp WITH(NOLOCK)
            ON (
                   ord.Guide_Number = ordp.GuideNumber
                   AND ord.Guide_Serie = ordp.GuideSerie
               )
        LEFT JOIN DeliveryOrderPaymentDetail dop WITH(NOLOCK)
            ON (
                   dop.GuideNumber = ord.Guide_Number
                   AND dop.GuideSerie = ord.Guide_Serie
               )
        LEFT JOIN SchedulePickup sp WITH(NOLOCK)
            ON (sp.SchedulePickupId = dop.IdHeaderRecolection)
        LEFT JOIN ServiceManagement sm WITH(NOLOCK)
            ON (sm.IdSchedulePickup = sp.SchedulePickupId)
        INNER JOIN RouteAssigment ra WITH(NOLOCK)
            ON (ra.IdRouteAssigment = sm.IdPuRouteAssigment)
        INNER JOIN CatRoute cr WITH(NOLOCK)
            ON (cr.IdRoute = ra.IdRoute)
        INNER JOIN SenderReceiver sr WITH(NOLOCK)
            ON (sr.ID = ra.IdCurrierMan)
    WHERE cr.CodeRoute = @Route
          AND
          (
              ordp.StatusOrderId NOT IN ( 7, 5 ) --(11, 10, 7, 5)
              OR ordp.StatusOrderId IS NULL
          )
          AND CAST(sm.DateCreated AS DATE) = @tiempo
    --where cr.CodeRoute = @Route and (ordp.StatusOrderId not in (11,10,7,5)or ordp.StatusOrderId is null)  and ord.StatusOrderId not in (11,10,7,5) and ordp.IsPickup = 1  and cast(sm.DateCreated as date) = @tiempo
    GROUP BY ord.Guide_Serie,
             ord.Guide_Number,
             ord.Manifest_Serie,
             ord.Manifest_Number,
             ord.Sender_FirstName,
             ord.Sender_LastName,
             ra.IdRouteAssigment,
             sr.ID;
    --and es.ServiceStatusId = 3


    /* TABLE 0 */
    SELECT ordp.NoPiece PIECE,
           CONCAT(ord.Guide_Serie, ord.Guide_Number, '-', NoPiece) GUIA,
           sp.SchedulePickupId PickUp,
           sp.DateCreated DATERECOLECT,
           CONCAT(ord.Sender_FirstName, ord.Sender_LastName) REMITENTE,
           CONCAT(ord.Manifest_Serie, '-', ord.Manifest_Number) MANIFIESTO,
           CONCAT(sr.First_Name, ' ', sr.Last_Name) NAMECOURIER,
           sm.IdServiceManagement,
           sm.ServiceStatusId
    FROM DeliveryOrder ord WITH(NOLOCK)
        --left join DeliveryOrderDetail ordd on (ord.Guide_Number = ordd.Guide_Number and ord.Guide_Serie = ordd.Guide_Serie)
        LEFT JOIN DeliveryOrderPiece ordp WITH(NOLOCK)
            ON (
                   ord.Guide_Number = ordp.GuideNumber
                   AND ord.Guide_Serie = ordp.GuideSerie
               )
        LEFT JOIN DeliveryOrderPaymentDetail dop WITH(NOLOCK)
            ON (
                   dop.GuideNumber = ord.Guide_Number
                   AND dop.GuideSerie = ord.Guide_Serie
               )
        LEFT JOIN SchedulePickup sp WITH(NOLOCK)
            ON (sp.SchedulePickupId = dop.IdHeaderRecolection)
        LEFT JOIN ServiceManagement sm WITH(NOLOCK)
            ON (sm.IdSchedulePickup = sp.SchedulePickupId)
        INNER JOIN RouteAssigment ra WITH(NOLOCK)
            ON (ra.IdRouteAssigment = sm.IdPuRouteAssigment)
        INNER JOIN CatRoute cr WITH(NOLOCK)
            ON (cr.IdRoute = ra.IdRoute)
        INNER JOIN SenderReceiver sr WITH(NOLOCK)
            ON (sr.ID = ra.IdCurrierMan)
    --inner join  EventService es on (es.ServiceManagementId = sm.IdServiceManagement )
    WHERE cr.CodeRoute = @Route
          AND
          (
              ordp.StatusOrderId NOT IN ( 11, 10, 7, 5 )
              OR ordp.StatusOrderId IS NULL
          )
          AND CAST(sm.DateCreated AS DATE) = @tiempo; ---and es.ServiceStatusId = 3 and ord.StatusOrderId not in (11,10,7,5)  --
    --where cr.CodeRoute = @Route and (ordp.StatusOrderId not in (11,10,7,5)or ordp.StatusOrderId is null) and cast(sm.DateCreated as date) = @tiempo and ordp.IsPickup = 1 ---and es.ServiceStatusId = 3 and ord.StatusOrderId not in (11,10,7,5)  --

    /* TABLE 1 */
    SELECT COUNT(guides.NUMEROGUIA) NUMEROGUIA
    FROM
    (
        SELECT Guide_Number NUMEROGUIA
        FROM @Guides
        UNION
        SELECT DISTINCT
               tbb.GuideNumber NUMEROGUIA
        FROM DeliveryBackOffice.dbo.TransactionalBackbone tbb WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK)
                ON (cr.IdRoute = tbb.RouteId)
        WHERE cr.CodeRoute = @Route
              AND CAST(tbb.DateCreated AS DATE) = @tiempo
              AND tbb.RowStatus = 1
    ) guides;

    /* TABLE 2 */
    SELECT (CASE
                WHEN do.Manifest_Serie IS NOT NULL
                     AND do.Manifest_Number IS NOT NULL THEN
                    CONCAT(do.Manifest_Serie, '-', do.Manifest_Number)
                ELSE
                    ''
            END
           ) MANIFIESTO,
           ISNULL(sp.SenderName, vpc.DescriptionOfClient) REMITENTE,
           ISNULL(do.Pieces_Dry, 0) + ISNULL(do.Pieces_Cold, 0) PIECE
    --,vpc.CodeOfReference CodeOfReference
    FROM RouteAssigment ra WITH(NOLOCK)
        INNER JOIN ServiceManagement sm WITH(NOLOCK)
            ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
        INNER JOIN SchedulePickup sp WITH(NOLOCK)
            ON sp.SchedulePickupId = sm.IdSchedulePickup
        INNER JOIN VisitPointClient vpc WITH(NOLOCK)
            ON vpc.CodeOfReference = sp.SenderId
        LEFT JOIN DeliveryOrderPaymentDetail dopd WITH(NOLOCK)
            ON dopd.IdHeaderRecolection = sp.SchedulePickupId
        LEFT JOIN DeliveryOrder do WITH(NOLOCK)
            ON do.Guide_Serie = dopd.GuideSerie
               AND do.Guide_Number = dopd.GuideNumber
    WHERE ra.IdRoute =
    (
        SELECT cr.IdRoute FROM CatRoute cr WITH(NOLOCK) WHERE cr.CodeRoute = @Route
    )
          AND ra.DateOfRoute = @tiempo
          AND sp.AssigmentStatus = 1;



    /* TABLE 3 */
    SELECT rta.IdRouteAssigment AS IdRoute
    FROM DeliveryBackOffice.dbo.RouteAssigment rta WITH(NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.CatRoute ctr WITH(NOLOCK)
            ON ctr.IdRoute = rta.IdRoute
        LEFT JOIN SenderReceiver sr WITH(NOLOCK)
            ON sr.ID = rta.IdCurrierMan
    WHERE ctr.CodeRoute = @Route
          AND CAST(rta.DateOfRoute AS DATE) = @tiempo;


    /* TABLE 4 */
    SELECT sr.ID,
           CONCAT(sr.First_Name, ' ', sr.Last_Name) NAMECOURIER,
           CAST(rta.DateOfRoute AS DATE) AS DATERECOLECT
    FROM DeliveryBackOffice.dbo.RouteAssigment rta WITH(NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.CatRoute ctr WITH(NOLOCK)
            ON ctr.IdRoute = rta.IdRoute
        LEFT JOIN SenderReceiver sr WITH(NOLOCK)
            ON sr.ID = rta.IdCurrierMan
    WHERE ctr.CodeRoute = @Route
          AND CAST(rta.DateOfRoute AS DATE) = @tiempo;

    /*	TABLE 5 
		Selecciona todas las guías liquidadas de una ruta en la fecha actual.
	*/
    SELECT tbb.GuideSerie GuideSerie,
           tbb.GuideNumber GuideNumber,
           tbb.GuidePiece GuidePiece,
           ISNULL(dop.IsDry, 1) IsDry,
           COALESCE(do.Pieces_Dry, 0) + COALESCE(do.Pieces_Cold, 0) Pieces
    FROM DeliveryBackOffice.dbo.TransactionalBackbone tbb WITH(NOLOCK)
        INNER JOIN DeliveryOrderPiece dop WITH(NOLOCK)
            ON dop.GuideSerie = tbb.GuideSerie
               AND dop.GuideNumber = tbb.GuideNumber
               AND dop.NoPiece = tbb.GuidePiece
        INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK)
            ON (cr.IdRoute = tbb.RouteId)
        INNER JOIN DeliveryOrder do WITH (NOLOCK)
            ON do.Guide_Serie = dop.GuideSerie
               AND do.Guide_Number = dop.GuideNumber
    WHERE cr.CodeRoute = @Route
          AND CAST(tbb.DateCreated AS DATE) = @tiempo
          AND tbb.RowStatus = 1
    ORDER BY tbb.DateCreated DESC;

    /* TABLE 6 */
    SELECT TOP 1
           sbp.Id IdManifest
    FROM RouteAssigment ra WITH(NOLOCK)
        INNER JOIN CatRoute cr
            ON (cr.IdRoute = ra.IdRoute)
        INNER JOIN SettlementByPickup sbp WITH(NOLOCK)
            ON (
                   sbp.RouteAssigmentId = ra.IdRouteAssigment
                   AND sbp.IdCourier = ra.IdCurrierMan
                   AND CAST(sbp.DatePrinted AS DATE) = @tiempo
               )
    --inner join  EventService es on (es.ServiceManagementId = sm.IdServiceManagement )
    WHERE cr.CodeRoute = @Route
          AND CAST(ra.DateCreated AS DATE) = @tiempo ---and es.ServiceStatusId = 3 and ord.StatusOrderId not in (11,10,7,5)  --
    --where cr.CodeRoute = @Route and (ordp.StatusOrderId  in (11,2,16)or ordp.StatusOrderId is null) and cast(sm.DateCreated as date) = @tiempo and ordp.IsPickup = 1
    ORDER BY 1 DESC;


    /*	TABLE 7 
		Cuenta las guías escaneadas
	*/
    SELECT COUNT(1) COMPLETE
    FROM
    (
        SELECT tbb.GuideNumber,
               COUNT(1) Pieces,
               (ISNULL(do.Pieces_Dry, 0) + ISNULL(do.Pieces_Cold, 0)) Total
        FROM DeliveryBackOffice.dbo.TransactionalBackbone tbb WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK)
                ON (cr.IdRoute = tbb.RouteId)
            INNER JOIN DeliveryOrder do WITH(NOLOCK)
                ON do.Guide_Serie = tbb.GuideSerie
                   AND do.Guide_Number = tbb.GuideNumber
        WHERE cr.CodeRoute = @Route
              AND CAST(tbb.DateCreated AS DATE) = @tiempo
              AND tbb.RowStatus = 1
        GROUP BY tbb.GuideNumber,
                 do.Pieces_Dry,
                 do.Pieces_Cold
    ) cn
    WHERE cn.Pieces = cn.Total;

END;