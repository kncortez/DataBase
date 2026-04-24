/* =================================================
   SP:        [dbo].[spg_Settlement_PickUp]
   Propósito: <Devuelve todas las Pickups asociadas a una ruta.>
   Autor:     Hugo Gómez
   Historia:  <FDAPI-????>
   Fecha:     <2020-02-15>
   === CHANGELOG ============================
2026-04-24 | Historia/épica: <FDAPI-6122> | Autor: Caleb Loarca | Se modifica la tabla 2 de respuesta para devolver Guías recolectadas en Sitio y poder liquidarlas.
2024-06-11 | Historia/épica: <FDAPI-????> | Autor: Daniel Ramirez | Se agrega filtro de pais, por defecto GT.
=========================================== */

CREATE PROCEDURE [dbo].[spg_Settlement_PickUp] 
@Route     VARCHAR(100) = 'GUA001',
@IdCountry VARCHAR(2) = 'GT'
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    DECLARE @tiempo DATE = CAST(GETDATE() AS DATE);
    DECLARE @CountryFilter VARCHAR(2) = ISNULL(@IdCountry, 'GT');

    CREATE TABLE #Guides
    (
        Guide_Serie NVARCHAR(2),
        Guide_Number INT,
        Serie_Manifest NVARCHAR(2),
        Numero_Manifest INT,
        Sender_FirstName NVARCHAR(100),
        Sender_LastName NVARCHAR(100),
        piece INT,
        IdRoute INT,
        ID INT,
        PRIMARY KEY (Guide_Number, Guide_Serie)
    );

    INSERT INTO #Guides
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
    FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH(NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece ordp WITH(NOLOCK)
            ON ord.Guide_Serie = ordp.GuideSerie
               AND ord.Guide_Number = ordp.GuideNumber
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail dop WITH(NOLOCK)
            ON dop.GuideSerie = ord.Guide_Serie
               AND dop.GuideNumber = ord.Guide_Number
        LEFT JOIN DeliveryBackOffice.dbo.SchedulePickup sp WITH(NOLOCK)
            ON sp.SchedulePickupId = dop.IdHeaderRecolection
        LEFT JOIN DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
            ON sm.IdSchedulePickup = sp.SchedulePickupId
        INNER JOIN DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK)
            ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
        INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK)
            ON cr.IdRoute = ra.IdRoute
        INNER JOIN DeliveryBackOffice.dbo.Township tw WITH(NOLOCK)
            ON cr.IdTownship = tw.IdTownship
        INNER JOIN DeliveryBackOffice.dbo.Province pr WITH(NOLOCK)
            ON pr.IdProvince = tw.IdProvince
        INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr WITH(NOLOCK)
            ON sr.ID = ra.IdCurrierMan
    WHERE cr.CodeRoute = @Route
          AND
          (
              ordp.StatusOrderId NOT IN ( 7, 5 ) --(11, 10, 7, 5)
              OR ordp.StatusOrderId IS NULL
          )
          AND CAST(sp.StartDate AS DATE) = @tiempo
          AND ISNULL(pr.IdCountry, @CountryFilter) = @CountryFilter
    GROUP BY ord.Guide_Serie,
             ord.Guide_Number,
             ord.Manifest_Serie,
             ord.Manifest_Number,
             ord.Sender_FirstName,
             ord.Sender_LastName,
             ra.IdRouteAssigment,
             sr.ID;

    /* CTE para información de ruta centralizada */
    WITH RouteInfo AS
    (
        SELECT cr.IdRoute, cr.CodeRoute, cr.rowstatus
        FROM DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.Township tw WITH(NOLOCK)
                ON cr.IdTownship = tw.IdTownship
            INNER JOIN DeliveryBackOffice.dbo.Province pr WITH(NOLOCK)
                ON pr.IdProvince = tw.IdProvince
        WHERE cr.CodeRoute = @Route 
              AND ISNULL(pr.IdCountry, @CountryFilter) = @CountryFilter
    )
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
    FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH(NOLOCK)
        --left join DeliveryOrderDetail ordd on (ord.Guide_Number = ordd.Guide_Number and ord.Guide_Serie = ordd.Guide_Serie)
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece ordp WITH(NOLOCK)
            ON ord.Guide_Serie = ordp.GuideSerie
               AND ord.Guide_Number = ordp.GuideNumber
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail dop WITH(NOLOCK)
            ON dop.GuideSerie = ord.Guide_Serie
               AND dop.GuideNumber = ord.Guide_Number
        LEFT JOIN DeliveryBackOffice.dbo.SchedulePickup sp WITH(NOLOCK)
            ON sp.SchedulePickupId = dop.IdHeaderRecolection
        LEFT JOIN DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
            ON sm.IdSchedulePickup = sp.SchedulePickupId
        INNER JOIN DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK)
            ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
        INNER JOIN RouteInfo ri ON ra.IdRoute = ri.IdRoute
        INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr WITH(NOLOCK)
            ON sr.ID = ra.IdCurrierMan
    WHERE ri.CodeRoute = @Route
          AND (ordp.StatusOrderId NOT IN (11, 10, 7, 5) OR ordp.StatusOrderId IS NULL)
          AND CAST(sp.StartDate AS DATE) = @tiempo;

    /* TABLE 1 */
    SELECT COUNT(DISTINCT guides.NUMEROGUIA) NUMEROGUIA
    FROM
    (
        SELECT Guide_Number NUMEROGUIA
        FROM #Guides
        UNION
        SELECT DISTINCT tbb.GuideNumber
        FROM DeliveryBackOffice.dbo.TransactionalBackbone tbb WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK)
                ON cr.IdRoute = tbb.RouteId
            INNER JOIN DeliveryBackOffice.dbo.Township tw WITH(NOLOCK)
                ON cr.IdTownship = tw.IdTownship
            INNER JOIN DeliveryBackOffice.dbo.Province pr WITH(NOLOCK)
                ON pr.IdProvince = tw.IdProvince
        WHERE cr.CodeRoute = @Route
              AND CAST(tbb.DateCreated AS DATE) = @tiempo
              AND tbb.RowStatus = 1
              AND ISNULL(pr.IdCountry, @CountryFilter) = @CountryFilter
    ) guides;

    /* TABLE 2 */
    SELECT CASE WHEN do.Manifest_Serie IS NOT NULL AND do.Manifest_Number IS NOT NULL 
                THEN CONCAT(do.Manifest_Serie, '-', do.Manifest_Number)
                ELSE ''
           END MANIFIESTO,
           ISNULL(ISNULL(sp.SenderName, CONCAT(do.Sender_FirstName,' ',do.Sender_LastName)), 'RECOLECCION EN SITIO') REMITENTE,
           ISNULL(do.Pieces_Dry, 0) + ISNULL(do.Pieces_Cold, 0) PIECE
    FROM DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
            ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
        INNER JOIN DeliveryBackOffice.dbo.SchedulePickup sp WITH(NOLOCK)
            ON sp.SchedulePickupId = sm.IdSchedulePickup
        INNER JOIN DeliveryBackOffice.dbo.FinishPickUpDetail dop WITH(NOLOCK)
            ON dop.SchedulePickupId = sp.SchedulePickupId
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
            ON do.Guide_Serie = dop.GuideSerie
               AND do.Guide_Number = dop.GuideNumber
        INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK)
            ON cr.IdRoute = ra.IdRoute
        INNER JOIN DeliveryBackOffice.dbo.Township tw WITH(NOLOCK)
            ON cr.IdTownship = tw.IdTownship
        INNER JOIN DeliveryBackOffice.dbo.Province pr WITH(NOLOCK)
            ON pr.IdProvince = tw.IdProvince
    WHERE cr.CodeRoute = @Route
          AND ra.DateOfRoute = @tiempo
          AND ISNULL(pr.IdCountry, @CountryFilter) = @CountryFilter;



    /* TABLE 3 */
    SELECT DISTINCT rta.IdRouteAssigment AS IdRoute
    FROM DeliveryBackOffice.dbo.RouteAssigment rta WITH(NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.CatRoute ctr WITH(NOLOCK)
            ON ctr.IdRoute = rta.IdRoute
        INNER JOIN DeliveryBackOffice.dbo.Township tw WITH(NOLOCK)
            ON ctr.IdTownship = tw.IdTownship
        INNER JOIN DeliveryBackOffice.dbo.Province pr WITH(NOLOCK)
            ON pr.IdProvince = tw.IdProvince
    WHERE ctr.CodeRoute = @Route
          AND CAST(rta.DateOfRoute AS DATE) = @tiempo
          AND ISNULL(pr.IdCountry, @CountryFilter) = @CountryFilter;


    /* TABLE 4 */
    SELECT DISTINCT sr.ID,
           CONCAT(sr.First_Name, ' ', sr.Last_Name) NAMECOURIER,
           CAST(rta.DateOfRoute AS DATE) AS DATERECOLECT
    FROM DeliveryBackOffice.dbo.RouteAssigment rta WITH(NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.CatRoute ctr WITH(NOLOCK)
            ON ctr.IdRoute = rta.IdRoute
        INNER JOIN DeliveryBackOffice.dbo.Township tw WITH(NOLOCK)
            ON ctr.IdTownship = tw.IdTownship
        INNER JOIN DeliveryBackOffice.dbo.Province pr WITH(NOLOCK)
            ON pr.IdProvince = tw.IdProvince
        INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr WITH(NOLOCK)
            ON sr.ID = rta.IdCurrierMan
    WHERE ctr.CodeRoute = @Route
         AND CAST(rta.DateOfRoute AS DATE) = @tiempo
         AND ISNULL(pr.IdCountry, @CountryFilter) = @CountryFilter;

    /* TABLE 5 - Guías liquidadas de una ruta en la fecha actual */
    SELECT tbb.GuideSerie,
           tbb.GuideNumber,
           tbb.GuidePiece,
           ISNULL(dop.IsDry, 1) IsDry,
           ISNULL(do.Pieces_Dry, 0) + ISNULL(do.Pieces_Cold, 0) Pieces
    FROM DeliveryBackOffice.dbo.TransactionalBackbone tbb WITH(NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
            ON dop.GuideSerie = tbb.GuideSerie
               AND dop.GuideNumber = tbb.GuideNumber
               AND dop.NoPiece = tbb.GuidePiece
        INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK)
            ON cr.IdRoute = tbb.RouteId
        INNER JOIN DeliveryBackOffice.dbo.Township tw WITH(NOLOCK)
            ON cr.IdTownship = tw.IdTownship
        INNER JOIN DeliveryBackOffice.dbo.Province pr WITH(NOLOCK)
            ON pr.IdProvince = tw.IdProvince
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
            ON do.Guide_Serie = dop.GuideSerie
               AND do.Guide_Number = dop.GuideNumber
    WHERE cr.CodeRoute = @Route
          AND CAST(tbb.DateCreated AS DATE) = @tiempo
          AND tbb.RowStatus = 1
          AND ISNULL(pr.IdCountry, @CountryFilter) = @CountryFilter
    ORDER BY tbb.DateCreated DESC;

    /* TABLE 6 - Último manifiesto liquidado */
    SELECT TOP 1 sbp.Id IdManifest
    FROM DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK)
            ON cr.IdRoute = ra.IdRoute
        INNER JOIN DeliveryBackOffice.dbo.Township tw WITH(NOLOCK)
            ON cr.IdTownship = tw.IdTownship
        INNER JOIN DeliveryBackOffice.dbo.Province pr WITH(NOLOCK)
            ON pr.IdProvince = tw.IdProvince
        INNER JOIN DeliveryBackOffice.dbo.SettlementByPickup sbp WITH(NOLOCK)
            ON sbp.RouteAssigmentId = ra.IdRouteAssigment
               AND sbp.IdCourier = ra.IdCurrierMan
               AND CAST(sbp.DatePrinted AS DATE) = @tiempo
    WHERE cr.CodeRoute = @Route
          AND CAST(ra.DateCreated AS DATE) = @tiempo
          AND ISNULL(pr.IdCountry, @CountryFilter) = @CountryFilter
    ORDER BY sbp.Id DESC;


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
            INNER JOIN DeliveryBackOffice.dbo.Township tw WITH(NOLOCK)
                ON (cr.IdTownship = tw.IdTownship)
            INNER JOIN DeliveryBackOffice.dbo.Province pr WITH(NOLOCK)
                ON (pr.IdProvince = tw.IdProvince)
            INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
                ON do.Guide_Serie = tbb.GuideSerie
                   AND do.Guide_Number = tbb.GuideNumber
        WHERE cr.CodeRoute = @Route
              AND IIF(pr.IdCountry IS NULL,'GT',pr.IdCountry) = @IdCountry
              AND CAST(tbb.DateCreated AS DATE) = @tiempo
              AND tbb.RowStatus = 1
        GROUP BY tbb.GuideNumber,
                 do.Pieces_Dry,
                 do.Pieces_Cold
    ) cn
    WHERE cn.Pieces = cn.Total;

    SELECT cr.IdRoute AS RouteExists
      FROM DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK) 
           INNER JOIN DeliveryBackOffice.dbo.Township tw WITH(NOLOCK)
               ON (cr.IdTownship = tw.IdTownship)
           INNER JOIN DeliveryBackOffice.dbo.Province pr WITH(NOLOCK)
               ON (pr.IdProvince = tw.IdProvince)
     WHERE cr.CodeRoute = @Route AND cr.rowstatus = 1
       AND IIF(pr.IdCountry IS NULL,'GT',pr.IdCountry) = @IdCountry
END;