
CREATE PROCEDURE [dbo].[spg_deliveryorder_settlement_guides_returns] @IdManifest INT
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
        Receiver_Zone NVARCHAR(100),
        Receiver_Town NVARCHAR(100),
        Receiver_Departament NVARCHAR(100),
        Preparation_Date NVARCHAR(50),
        Shipping_Date NVARCHAR(50),
        Max_Date NVARCHAR(50),
        Receiver_Phone NVARCHAR(100),
        Price DECIMAL(16, 2)
    );


    -- tablix content
    INSERT INTO @temp
    SELECT DISTINCT
           do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR(50)) AS Guide_Code,
           (
               SELECT COUNT(*)
               FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop
                   JOIN DeliveryBackOffice.dbo.PieceByService pbs
                       ON pbs.GuidePieceId = dop.GuidePiece
               WHERE dop.GuideNumber = do.Guide_Number
                     AND dop.GuideSerie = do.Guide_Serie
                     AND dop.IsDry = 0
           ) AS Pieces_Cold,
           (
               SELECT COUNT(*)
               FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop
                   JOIN DeliveryBackOffice.dbo.PieceByService pbs
                       ON pbs.GuidePieceId = dop.GuidePiece
               WHERE dop.GuideNumber = do.Guide_Number
                     AND dop.GuideSerie = do.Guide_Serie
                     AND dop.IsDry = 1
           ) AS Pieces_Dry,
           ISNULL(do.Sender_FirstName, '') + ' ' + ISNULL(do.Sender_LastName, '') AS Receiver_Fullname,
           do.Sender_Address AS Receiver_Address,
           CONVERT(NVARCHAR, ISNULL(do.Sender_Zone, 0)) AS Receiver_Zone,
           do.Sender_Town AS Receiver_Town,
           do.Sender_Department AS Receiver_Departament,
           CONVERT(VARCHAR, do.Preparation_Date, 103) + ' ' + CONVERT(VARCHAR(5), do.Preparation_Date, 108) AS Preparation_Date,
           CONVERT(VARCHAR, do.Shipping_Date, 103) AS Shipping_Date,
           ISNULL(CONVERT(VARCHAR, do.Delivery_Max_Date, 103), '') AS Max_Date,
           do.Sender_Phone AS Receiver_Phone,
           sbpd.Price Price
    FROM DeliveryOrder do
        INNER JOIN DeliveryOrderPiece pc
            ON pc.GuideSerie = do.Guide_Serie
               AND pc.GuideNumber = do.Guide_Number
        JOIN dbo.PieceByService pbs
            ON pc.GuidePiece = pbs.GuidePieceId
        JOIN SettlementByPickupDetail sbpd
            ON do.Guide_Number = sbpd.GuideNumber
               AND sbpd.IsDispatched = 1
        JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail dop
            ON dop.GuideNumber = do.Guide_Number
               AND dop.GuideSerie = do.Guide_Serie
        JOIN SettlementByPickup sbp
            ON sbpd.SettlementByPickupId = sbp.Id
               AND sbp.SequenceCode = @IdManifest
               AND sbp.SubTypeServiceManagmentId = 3
               AND sbpd.RowStatus = 1;

    SELECT *
    FROM @temp
    ORDER BY Receiver_Departament ASC,
             Receiver_Town ASC,
             Receiver_Zone ASC,
             Receiver_Address ASC;

END;
