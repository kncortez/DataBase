/* =================================================
   SP:        [dbo].[spg_status_order_detail_wbs_custom]
   Propósito: <se agregan dos nuevos campos a la versión original spg_status_order_detail_wbs>
   Autor:     <Tito García>
   Historia:  <FDAPI-5729>
   Fecha:     2026-03-04
=== CHANGELOG ================================
2026-03-18 | Historia/épica: FDAPI-5953 | Autor: Mario Herrarte |
=========================================== */
ALTER PROCEDURE [dbo].[spg_status_order_detail_wbs_custom]
    @Guide_Serie NVARCHAR(2),
    @Guide_Number INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DeliveryOrder TABLE
    (
        Guide_Serie NVARCHAR(100),
        Guide_Number INT,
        Sender_FirstName NVARCHAR(100),
        Sender_LastName NVARCHAR(100),
        Receiver_FirstName NVARCHAR(100),
        Receiver_LastName NVARCHAR(100),
        OriginAdress NVARCHAR(255),
        DestinyAddress NVARCHAR(255),
        Delivery_Max_Date DATETIME,
        NameOfReceiver NVARCHAR(400),
        Manifest_Serie NVARCHAR(50),
        Manifest_Number INT
    );

    DECLARE @DeliveryOrderDetail TABLE
    (
        DateCreated DATETIME,
        Guide_Serie NVARCHAR(100),
        Guide_Number INT,
        StatusOrderId TINYINT,
        StageDate DATETIME,
        Observations NVARCHAR(500),
        OrderDescription NVARCHAR(500),
        TownshipName NVARCHAR(50),
        HeaderCode VARCHAR(10)
    );

    DECLARE @DeliveryAttempt TABLE
    (
        Guide_Serie NVARCHAR(100),
        Guide_Number INT,
        First_Name NVARCHAR(100),
        Last_Name NVARCHAR(100),
        DescriptionIncidence NVARCHAR(255),
        Latitude VARCHAR(50),
        Longitude VARCHAR(50),
        Observations NVARCHAR(500),
        CommentOnIncident NVARCHAR(500)
    );

    DECLARE @DelayTracking INT = (
	    SELECT Value FROM ConfigParams WHERE Name = 'DelayTracking'
    );

    INSERT INTO @DeliveryOrder
    SELECT do.Guide_Serie,
           do.Guide_Number,
           do.Sender_FirstName,
           do.Sender_LastName,
           do.Receiver_FirstName,
           do.Receiver_LastName,
           do.Sender_Address AS OriginAdress,
           do.Receiver_Address AS DestinyAddress,
           do.Delivery_Max_Date,
           do.NameOfReceiver,
           do.Manifest_Serie,
           do.Manifest_Number
    FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
    WHERE do.Guide_Serie = @Guide_Serie
          AND do.Guide_Number = @Guide_Number;

    INSERT INTO @DeliveryOrderDetail
    SELECT dod.DateCreated,
           dod.Guide_Serie,
           dod.Guide_Number,
           dod.StatusOrderId,
           dod.DateCreated AS StageDate,
           dod.Observations,
           so.OrderDescription,
           ISNULL(t.TownshipName,''),
           ISNULL(t.HeaderCode,'')
    FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
            ON so.StatusOrderId = dod.StatusOrderId
        LEFT JOIN DeliveryBackOffice.dbo.CatStation cat WITH (NOLOCK)
            ON dod.StationId = cat.IdStation
        LEFT JOIN DeliveryBackOffice.dbo.Township t WITH (NOLOCK)
            ON cat.TownshipId = t.IdTownship
    WHERE dod.Guide_Serie = @Guide_Serie
          AND dod.Guide_Number = @Guide_Number
          AND dod.DateCreated < DATEADD(MINUTE, -@DelayTracking, GETDATE());

    INSERT INTO @DeliveryAttempt
    SELECT TOP 1
           DA.Guide_Serie,
           DA.Guide_Number,
           CUR.First_Name,
           CUR.Last_Name,
           INC.DescriptionIncidence,
           DA.Latitude,
           DA.Longitude,
           Observations,
           CommentOnIncident
    FROM @DeliveryOrderDetail DET
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryAttempt DA WITH (NOLOCK)
            ON DA.Guide_Serie = DET.Guide_Serie
               AND DA.Guide_Number = DET.Guide_Number
        LEFT JOIN DeliveryBackOffice.dbo.CatTypeIncidence INC WITH (NOLOCK)
            ON DA.ID_Incident = INC.IdIncidenceType
        LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver CUR WITH (NOLOCK)
            ON CUR.ID = DA.ID_Courier
        LEFT JOIN DeliveryBackOffice.dbo.ConfirmationOfIncidence COI WITH (NOLOCK)
            ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
    WHERE DA.Guide_Serie = @Guide_Serie
          AND DA.Guide_Number = @Guide_Number;

    SELECT RES.[EventID],
           RES.[OrderId],
           RES.[CustomerFullname],
           RES.[OriginAdress],
           RES.[OriginLatitude],
           RES.[OriginLongitude],
           RES.[DestinyAddress],
           RES.[DestintyLatitude],
           RES.[DestinyLongitude],
           RES.[EstimatedDeliveryDate],
           RES.[CourierName],
           RES.[StageId],
           RES.[StageDate],
           RES.[StageTitle],
           RES.[StageSource],
           RES.[StageDescription],
           RES.[ImagePath],
           RES.[NameOfReceiver],
           RES.[Place],
           RES.[ManifestNumber],
           RES.[Latitude],
           RES.[Longitude],
           RES.[CommentOnIncident],
           RES.[Timezone],
           RES.[TownshipName],
           RES.[TownshipHeaderCode]
    FROM
    (
        SELECT 0 [EventID],
               do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR) AS [OrderId],
               ISNULL(do.Receiver_FirstName, '') + ' ' + ISNULL(do.Receiver_LastName, '') AS [CustomerFullname],
               OriginAdress,
               '' AS [OriginLatitude],
               '' AS [OriginLongitude],
               DestinyAddress,
               '' AS [DestintyLatitude],
               '' AS [DestinyLongitude],
               CONVERT(VARCHAR, do.Delivery_Max_Date, 120) AS [EstimatedDeliveryDate],
               '' [CourierName],
               '' [StageId],
               '' [StageDate],
               '' [StageTitle],
               'web' [StageSource],
               '' AS [StageDescription],
               '' AS [ImagePath],
               ISNULL([NameOfReceiver], do.Receiver_FirstName) AS NameOfReceiver,
               ISNULL(Sender_FirstName, '') + ' ' + ISNULL(Sender_LastName, '') AS Place,
               do.Manifest_Serie + CAST(do.Manifest_Number AS VARCHAR) AS [ManifestNumber],
               da.Latitude,
               da.Longitude,
               '' AS [CommentOnIncident],
               '' AS [Timezone],
               '' AS [TownshipName],
               '' AS [TownshipHeaderCode]
        FROM @DeliveryOrder do
            LEFT JOIN @DeliveryAttempt da
                ON da.Guide_Serie = do.Guide_Serie
                   AND da.Guide_Number = do.Guide_Number
        UNION
        SELECT ROW_NUMBER() OVER (ORDER BY DOD.DateCreated ASC) AS EventID,
               DOD.Guide_Serie + CAST(DOD.Guide_Number AS VARCHAR) AS [OrderId],
               '' [CustomerFullname],
               '' [OriginAdress],
               '' [OriginLatitude],
               '' [OriginLongitude],
               '' [DestinyAddress],
               '' [DestintyLatitude],
               '' [DestinyLongitude],
               '' [EstimatedDeliveryDate],
               '' [CourierName],
               CAST(DOD.StatusOrderId AS NVARCHAR) AS [StageId],
               DOD.DateCreated AS [StageDate],
               OrderDescription AS [StageTitle],
               'web' AS [StageSource],
               (CASE
                    WHEN DOD.StatusOrderId IN ( 6, 8 ) THEN
                        ISNULL(DOD.Observations, '')
                    WHEN DOD.StatusOrderId IN ( 12 ) THEN
                        ISNULL(
                        (
                            SELECT '[ '
                                   + DeliveryBackOffice.dbo.[CapitalizeFirstLetter](LOWER(First_Name) + ' '
                                                                                    + LOWER(Last_Name)
                                                                                   ) + ' ] '
                                   + DescriptionIncidence + ' ' + ISNULL(Observations, '')
                            FROM @DeliveryAttempt
                        ),
                        ''
                              )
                    WHEN DOD.StatusOrderId IN ( 15 ) THEN
                        ''
                    ELSE
                        ISNULL(DOD.Observations, '')
                END
               ) AS [StageDescription],
               '' AS [ImagePath],
               '' AS NameOfReceiver,
               '' AS Place,
               '' AS [ManifestNumber],
               '' AS Latitude,
               '' AS Longitude,
               CommentOnIncident,
               'GTM-6' AS [Timezone],
               DOD.TownshipName AS [TownshipName],
               DOD.HeaderCode AS [TownshipHeaderCode]
        FROM @DeliveryOrderDetail DOD
            LEFT JOIN @DeliveryAttempt DA
                ON DOD.Guide_Serie = DA.Guide_Serie
                   AND DOD.Guide_Number = DA.Guide_Number
    ) RES
    ORDER BY RES.[EventID],
             RES.[StageDate] ASC;
END;
