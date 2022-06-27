
--drop procedure  [dbo].[spg_settlement_returned_guides_PickUp]
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-03-11>
-- Description:	<Recupera detalle para generar manifiesto de liquidación (PickUp)>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_arrived_guides_PickUp] @IdManifest INT
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
    SELECT CONCAT(do.Guide_Serie, do.Guide_Number) Guide_Code,
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
                     AND sbpd.IsPieceLiquidaded = 1
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
                   INNER JOIN SettlementByPickupDetail sbpd WITH(NOLOCK)
                       ON (sbp.Id = sbpd.SettlementByPickupId)
                   INNER JOIN DeliveryOrderPiece dop WITH(NOLOCK)
                       ON dop.GuideSerie = sbpd.GuideSerie
                          AND dop.GuideNumber = sbpd.GuideNumber
                          AND dop.NoPiece = sbpd.NoPiece
               WHERE Id = @IdManifest
                     AND sbpd.GuideSerie = do.Guide_Serie
                     AND sbpd.GuideNumber = do.Guide_Number
                     AND sbpd.IsPieceLiquidaded = 1
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
           ISNULL(do.Receiver_FirstName, '') + ' ' + ISNULL(do.Receiver_LastName, '') Receiver_Fullname,
           do.Receiver_Address Receiver_Address,
           CONVERT(NVARCHAR, ISNULL(do.Receiver_Zone, 0)) Receiver_Zone,
           do.Receiver_Town Receiver_Town,
           do.Receiver_Department Receiver_Departament,
           CONVERT(VARCHAR, do.Preparation_Date, 103) + ' ' + CONVERT(VARCHAR(5), do.Preparation_Date, 108) Preparation_Date,
           CONVERT(VARCHAR, do.Shipping_Date, 103) Shipping_Date,
           ISNULL(CONVERT(VARCHAR, do.Delivery_Max_Date, 103), '') Max_Date,
           do.Receiver_Phone Receiver_Phone,
           (
               SELECT DeliveryBackOffice.dbo.fn_get_rackposition(do.Guide_Serie, do.Guide_Number)
           ) Rack_Position,
           Collect_OnDelivery
    FROM
    (
        SELECT spd.GuideSerie,
               spd.GuideNumber,
               COUNT(1) Pieces,
               (ISNULL(do.Pieces_Dry, 0) + ISNULL(do.Pieces_Cold, 0)) Total
        FROM SettlementByPickup sp WITH(NOLOCK)
            INNER JOIN SettlementByPickupDetail spd WITH(NOLOCK)
                ON spd.SettlementByPickupId = sp.Id
            INNER JOIN DeliveryOrder do WITH (NOLOCK)
                ON do.Guide_Serie = spd.GuideSerie
                   AND do.Guide_Number = spd.GuideNumber
        WHERE sp.Id = @IdManifest
              AND spd.IsPieceLiquidaded = 1 -- Pieza de la guia liquidada
        GROUP BY spd.GuideSerie,
                 spd.GuideNumber,
                 do.Pieces_Dry,
                 do.Pieces_Cold
    ) X
        INNER JOIN DeliveryOrder do WITH (NOLOCK)
            ON do.Guide_Serie = X.GuideSerie
               AND do.Guide_Number = X.GuideNumber
    WHERE X.Pieces = X.Total; --Piezas completas

    SELECT *
    FROM @temp
    ORDER BY Receiver_Departament ASC,
             Receiver_Town ASC,
             Receiver_Zone ASC,
             Receiver_Address ASC;

END;
