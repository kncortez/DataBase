
--drop procedure  [dbo].[spg_settlement_returned_guides_PickUp]
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-03-11>
-- Description:	<Recupera detalle para generar manifiesto de liquidación (PickUp)>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_not_arrived_guides_PickUp] @IdManifest INT
AS
BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @temp TABLE
    (
        Guide_Code NVARCHAR(MAX),
        Pieces_Cold INT,
        Pieces_Dry INT,
        Receiver_Fullname NVARCHAR(201),
        Receiver_Address NVARCHAR(600),
        Receiver_Zone NVARCHAR(50),
        Receiver_Town NVARCHAR(100),
        Receiver_Departament NVARCHAR(100),
        Preparation_Date NVARCHAR(50),
        Shipping_Date NVARCHAR(50),
        Max_Date NVARCHAR(50),
        Receiver_Phone NVARCHAR(100),
        Rack_Position NVARCHAR(MAX),
        Collect_on_Delivery DECIMAL(16, 2)
    );

    -- tablix content
    INSERT INTO @temp
    SELECT do.Guide_Serie + ISNULL(CONVERT(NVARCHAR, do.Guide_Number), '') AS Guide_Code,
           ISNULL(
           (
               SELECT COUNT(1)
               FROM SettlementByPickup sbp WITH(NOLOCK)
                   INNER JOIN SettlementByPickupDetail sbpd WITH(NOLOCK)
                       ON (sbp.Id = sbpd.SettlementByPickupId)
                   INNER JOIN DeliveryOrderPiece dop WITH(NOLOCK)
                       ON dop.GuideSerie = sbpd.GuideSerie
                          AND dop.GuideNumber = sbpd.GuideNumber
                          AND dop.NoPiece = sbpd.NoPiece
               WHERE Id = @IdManifest
                     AND sbpd.GuideSerie = do.Guide_Serie
                     AND sbpd.GuideNumber = do.Guide_Number
                     AND sbpd.IsPieceLiquidaded = 0
                     AND (dop.IsDry = 0)
               GROUP BY sbpd.GuideSerie,
                        sbpd.GuideNumber
           ),
           0
                 ) Pieces_Cold,
           ISNULL(
           (
               SELECT COUNT(1)
               FROM SettlementByPickup sbp WITH(NOLOCK)
                   INNER JOIN SettlementByPickupDetail sbpd
                       ON (sbp.Id = sbpd.SettlementByPickupId)
                   INNER JOIN DeliveryOrderPiece dop WITH(NOLOCK)
                       ON dop.GuideSerie = sbpd.GuideSerie
                          AND dop.GuideNumber = sbpd.GuideNumber
                          AND dop.NoPiece = sbpd.NoPiece
               WHERE Id = @IdManifest
                     AND sbpd.GuideSerie = do.Guide_Serie
                     AND sbpd.GuideNumber = do.Guide_Number
                     AND sbpd.IsPieceLiquidaded = 0
                     AND
                     (
                         dop.IsDry IS NULL
                         OR dop.IsDry = 1
                     )
               GROUP BY sbpd.GuideSerie,
                        sbpd.GuideNumber
           ),
           0
                 ) Pieces_Dry,
           ISNULL(do.Receiver_FirstName, '') + ' ' + ISNULL(do.Receiver_LastName, '') AS Receiver_Fullname,
           do.Receiver_Address AS Receiver_Address,
           CONVERT(NVARCHAR, ISNULL(do.Receiver_Zone, 0)) AS Receiver_Zone,
           do.Receiver_Town AS Receiver_Town,
           do.Receiver_Department AS Receiver_Departament,
           CONVERT(VARCHAR, do.Preparation_Date, 103) + ' ' + CONVERT(VARCHAR(5), do.Preparation_Date, 108) AS Preparation_Date,
           CONVERT(VARCHAR, do.Shipping_Date, 103) AS Shipping_Date,
           ISNULL(CONVERT(VARCHAR, do.Delivery_Max_Date, 103), '') AS Max_Date,
           do.Receiver_Phone AS Receiver_Phone,
           (
               SELECT DeliveryBackOffice.dbo.fn_get_rackposition(do.Guide_Serie, do.Guide_Number)
           ) AS Rack_Position,
           Collect_OnDelivery
    FROM [DeliveryBackOffice].[dbo].DeliveryOrder do WITH(NOLOCK)
        INNER JOIN
        (
            SELECT GuideSerie,
                   GuideNumber
            FROM [DeliveryBackOffice].[dbo].SettlementByPickupDetail WITH(NOLOCK)
            WHERE SettlementByPickupId = @IdManifest
                  AND IsPieceLiquidaded = 0 -- Pieza de la guia no liquidada
            GROUP BY GuideSerie,
                     GuideNumber
        ) dsd
            ON do.Guide_Serie = dsd.GuideSerie
               AND do.Guide_Number = dsd.GuideNumber
    ORDER BY Receiver_Departament ASC,
             Receiver_Town ASC,
             Receiver_Zone ASC,
             Receiver_Address ASC;

    INSERT INTO @temp
    SELECT '' Guide_Code,
           '' Pieces_Cold,
           '' Pieces_Dry,
           ISNULL(sp.SenderName, vpc.DescriptionOfClient) Receiver_Fullname,
           ISNULL(ISNULL(REPLACE(sp.AddressPickup, '"', ''), REPLACE(vpc.Address, '"', '')), 'N/A') Receiver_Address,
           CONVERT(NVARCHAR, ISNULL(vpc.Zone, 0)) Receiver_Zone,
           vpc.Town Receiver_Town,
           vpc.Department Receiver_Departament,
           '' Preparation_Date,
           '' Shipping_Date,
           '' Max_Date,
           vpc.Phone Receiver_Phone,
           '' Rack_Position,
           0 Collect_OnDelivery
    FROM SettlementByPickup sbp WITH(NOLOCK)
        INNER JOIN RouteAssigment ra WITH(NOLOCK)
            ON ra.IdRouteAssigment = sbp.RouteAssigmentId
        INNER JOIN ServiceManagement sm WITH(NOLOCK)
            ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
        INNER JOIN SchedulePickup sp WITH(NOLOCK)
            ON sp.SchedulePickupId = sm.IdSchedulePickup
        INNER JOIN VisitPointClient vpc WITH(NOLOCK)
            ON vpc.CodeOfReference = sp.SenderId
        LEFT JOIN DeliveryOrderPaymentDetail dopd
            ON dopd.IdHeaderRecolection = sp.SchedulePickupId
        LEFT JOIN DeliveryOrder do
            ON do.Guide_Serie = dopd.GuideSerie
               AND do.Guide_Number = dopd.GuideNumber
    WHERE sbp.Id = @IdManifest
          AND sm.ServiceStatusId <> 3;




    SELECT *
    FROM @temp;
--order by Receiver_Departament asc, Receiver_Town asc, Receiver_Zone asc, Receiver_Address asc

END;