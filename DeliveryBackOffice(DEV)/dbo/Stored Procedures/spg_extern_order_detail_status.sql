

-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <13/06/2020>
-- Description:	<Detalle de rastreo en pagina web tracking externa para el cliente, sin datos sensibles>
-- =============================================
-- Author:		<Jerson Ochoa>
-- Update date: <21-02-2023>
-- Description: <Management for checkpoint icons>
-- =============================================
CREATE PROCEDURE [dbo].[spg_extern_order_detail_status]
    @Guide_Serie NVARCHAR(2)
  , @Guide_Number BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExternalTypeId INT =
            (
                SELECT TOP 1
                       CST.IdCatStatusType
                FROM [DeliveryBackOffice].[dbo].[CatStatusType] CST WITH (NOLOCK)
                WHERE CST.StatusType = 'Externo' COLLATE Latin1_General_CI_AI
            );

    DECLARE @GuideOrderTemp AS TABLE
    (
        Guide_Serie NVARCHAR(2)
      , Guide_Number INT
      , SenderName NVARCHAR(200)
      , Sender_Address NVARCHAR(600)
      , ReceiverName NVARCHAR(200)
      , Receiver_Address NVARCHAR(600)
      , Manifest_Serie NVARCHAR(2)
      , Manifest_Number INT
      , NameOfReceiver NVARCHAR(200)
      , Delivery_Max_Date DATETIME
      , Receiver_Phone NVARCHAR(100)
      , Price_Guide DECIMAL(14, 2)
      , Price_COD DECIMAL(14, 2)
    );

    -- Variables de datos de entrega
    DECLARE @GuideDeliveryLatitude NVARCHAR(20) = N'';
    DECLARE @GuideDeliveryLongitude NVARCHAR(20) = N'';
    DECLARE @GuideDeliveryCourierAttempt NVARCHAR(200) = N'';
    DECLARE @StatusIncident INT;
    DECLARE @StatusIncidentValidated INT;

    SET @StatusIncident =
    (
        SELECT StatusOrderId
        FROM StatusOrder WITH (NOLOCK)
        WHERE OrderDescription = 'Incidencia en ruta'
    );
    SET @StatusIncidentValidated =
    (
        SELECT StatusOrderId
        FROM StatusOrder WITH (NOLOCK)
        WHERE OrderDescription = 'Incidencia Validada'
    );

    SELECT TOP 1
           @GuideDeliveryLatitude  = DA.Latitude
         , @GuideDeliveryLongitude = DA.Longitude
         , @GuideDeliveryCourierAttempt
                                   = LTRIM(RTRIM(CONCAT(LTRIM(RTRIM(SR.First_Name)), ' ', LTRIM(RTRIM(SR.Last_Name)))))
    FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt]          DA WITH (NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryProof]  DP WITH (NOLOCK)
            ON DA.Guide_Number = DP.Guide_Number
               AND DA.Guide_Serie = DP.Guide_Serie
        INNER JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH (NOLOCK)
            ON DA.ID_Courier = SR.ID
    WHERE DA.Guide_Serie = @Guide_Serie
          AND DA.Guide_Number = @Guide_Number
          AND DA.Delivered = 1
    ORDER BY DA.Date_Created DESC;

    -- Datos de guía
    INSERT INTO @GuideOrderTemp
    (
        Guide_Serie
      , Guide_Number
      , SenderName
      , Sender_Address
      , ReceiverName
      , Receiver_Address
      , Manifest_Serie
      , Manifest_Number
      , NameOfReceiver
      , Delivery_Max_Date
      , Receiver_Phone
      , Price_Guide
      , Price_COD
    )
    SELECT TOP 1
           DO.Guide_Serie
         , DO.Guide_Number
         , LTRIM(RTRIM(ISNULL(DO.Sender_FirstName, '') + ' ' + ISNULL(DO.Sender_LastName, '')))
         , Sender_Address
         , LTRIM(RTRIM(ISNULL(DO.Receiver_FirstName, '') + ' ' + ISNULL(DO.Receiver_LastName, '')))
         , DO.Receiver_Address
         , DO.Manifest_Serie
         , DO.Manifest_Number
         , DO.NameOfReceiver
         , DO.Delivery_Max_Date
         , LTRIM(RTRIM(DO.Receiver_Phone))
         , DO.PriceShippment
         , DO.Collect_OnDelivery
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
    WHERE DO.Guide_Serie = @Guide_Serie
          AND DO.Guide_Number = @Guide_Number;

    SELECT RES.[EventID]
         , RES.[OrderId]
         , RES.[CustomerFullname]
         , RES.[EstimatedDeliveryDate]
         , RES.[CourierName]
         , RES.[StageId]
         , RES.[StageDate]
         , RES.[StageTitle]
         , RES.[StageSource]
         , RES.[ClasificationIncident]
         , RES.[StageDescription]
         , RES.[CheckpointIcon]
         , RES.[NameOfReceiver]
         , RES.[Place]
         , RES.[NextSteps]
         , RES.[ImagePath]
         , RES.[Dry]
         , RES.[Cold]
         , RES.[Latitude]
         , RES.[Longitude]
         , RES.Receiver_Phone
         , RES.Price_Guide
         , RES.Price_COD
         , RES.UserIncident
         , RES.StatusValidated
         , RES.ValidGeolocationEvidence
         , RES.ValidPhotographicEvidence
    FROM
    (
        SELECT 0                                                 [EventID]
             , do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR) AS [OrderId]               -- guide [Field3]
             , do.ReceiverName                                   AS [CustomerFullname]      -- receiver fullname  [Field2]
             , CONVERT(VARCHAR, do.Delivery_Max_Date, 120)       AS [EstimatedDeliveryDate] --[Field5],
             , ''                                                [CourierName]              --[Field9]
             , ''                                                [StageId]                  -- status order id
             , ''                                                [StageDate]                -- date of status id
             , ''                                                [StageTitle]               -- status order name
             , 'web'                                             [StageSource]
             , ''                                                AS [ClasificationIncident]
             , ''                                                AS [StageDescription]      --detail description or observations in events
             , ''                                                AS [CheckpointIcon]
             , ISNULL([NameOfReceiver], '')                      AS NameOfReceiver
             , ISNULL(do.SenderName, '')                         AS Place
             , ''                                                NextSteps
             , ''                                                ImagePath
             , ''                                                Dry
             , ''                                                Cold
             , ''                                                Latitude
             , ''                                                Longitude
             , do.Receiver_Phone
             , ISNULL(do.Price_Guide, 0)                         'Price_Guide'
             , ISNULL(do.Price_COD, 0)                           'Price_COD'
             , ''                                                UserIncident
             , 0                                                 StatusValidated
             , 0                                                 ValidGeolocationEvidence
             , 0                                                 ValidPhotographicEvidence
        FROM @GuideOrderTemp do
        UNION
        SELECT DISTINCT
               RANK() OVER (PARTITION BY dod.Guide_Number ORDER BY dod.DateCreated ASC)     AS EventID
             , dod.Guide_Serie + CAST(dod.Guide_Number AS VARCHAR)                          AS [OrderId]            -- guide [Field3]
             , ''                                                                           [CustomerFullname]      -- receiver fullname  [Field2]
             , ''                                                                           [EstimatedDeliveryDate] --[Field5],
             , ''                                                                           [CourierName]           --[Field9]
             , CAST(dod.StatusOrderId AS NVARCHAR)                                          AS [StageId]            -- status order id
             , dod.DateCreated                                                              AS [StageDate]
             , (CASE
                    WHEN dod.StatusOrderId = @StatusIncident THEN
                        so.OrderDescription
                    WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
                        so.OrderDescription
                    ELSE
                        so.OrderDescription + ', ' + CAST(ISNULL(dod.Observations, '') AS NVARCHAR(50)) -- status order name
                END
               )                                                                            AS [StageTitle]         -- status order name
             , 'web'                                                                        AS [StageSource]
             , (CASE
                    WHEN dod.StatusOrderId = @StatusIncident THEN
                    (
                        SELECT TOP 1
                               cic.IncidenceTypeName
                        FROM DeliveryAttempt                     dla WITH (NOLOCK)
                            INNER JOIN CatTypeIncidence          cti WITH (NOLOCK)
                                ON dla.ID_Incident = cti.IdIncidenceType
                            INNER JOIN CatIncidenceClasification cic WITH (NOLOCK)
                                ON cti.IncidenceClasificationId = cic.IdCatIncidenceClasification
                        WHERE dod.Guide_Serie = @Guide_Serie
                              AND dod.Guide_Number = @Guide_Number
                              AND dod.DeliveryAttemptId = dla.ID
                    )
                    ELSE
                        ''
                END
               )                                                                            AS [ClasificationIncident]
             , (CASE
                    WHEN dod.StatusOrderId = @StatusIncident THEN
             (CASE
                  WHEN
                  (
                      SELECT TOP 1
                             cic.IncidenceTypeName
                      FROM DeliveryAttempt                     dla WITH (NOLOCK)
                          INNER JOIN CatTypeIncidence          cti WITH (NOLOCK)
                              ON dla.ID_Incident = cti.IdIncidenceType
                          INNER JOIN CatIncidenceClasification cic WITH (NOLOCK)
                              ON cti.IncidenceClasificationId = cic.IdCatIncidenceClasification
                      WHERE dod.Guide_Serie = @Guide_Serie
                            AND dod.Guide_Number = @Guide_Number
                            AND dod.DeliveryAttemptId = dla.ID
                  ) = 'Incidencias operativas' THEN
                  (
                      SELECT TOP 1
                             cti.NameIncidencePublic
                      FROM DeliveryAttempt            dla WITH (NOLOCK)
                          INNER JOIN CatTypeIncidence cti WITH (NOLOCK)
                              ON dla.ID_Incident = cti.IdIncidenceType
                      WHERE dod.Guide_Serie = @Guide_Serie
                            AND dod.Guide_Number = @Guide_Number
                            AND dod.DeliveryAttemptId = dla.ID
                  )
                  ELSE
              (
                  SELECT TOP 1
                         cti.NameIncidence
                  FROM DeliveryAttempt            dla WITH (NOLOCK)
                      INNER JOIN CatTypeIncidence cti WITH (NOLOCK)
                          ON dla.ID_Incident = cti.IdIncidenceType
                  WHERE dod.Guide_Serie = @Guide_Serie
                        AND dod.Guide_Number = @Guide_Number
                        AND dod.DeliveryAttemptId = dla.ID
              )
              END
             )
                    WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
                        dod.Observations
                    ELSE
                        so.OrderDescription + ', ' + CAST(ISNULL(dod.Observations, '') AS NVARCHAR(50)) -- status order name
                END
               )                                                                            AS [StageTitle]         -- status order nameAS [StageDescription],
             , ISNULL([CCT].[CheckpointIcon], '')                                           [CheckpointIcon]
             , (CASE
                    WHEN dod.StatusOrderId = 5 THEN
                    (
                        SELECT TOP 1 NameOfReceiver FROM @GuideOrderTemp
                    )
                    ELSE
                        ''
                END
               )                                                                            AS NameOfReceiver
             , ''                                                                           AS Place
             , so.NextSteps                                                                 NextSteps
             , (CASE
                    WHEN dod.StatusOrderId = 5 THEN
                        IIF((
                                SELECT TOP 1
                                       Path_Dry
                                FROM DeliveryProof WITH (NOLOCK)
                                WHERE Guide_Serie = @Guide_Serie
                                      AND Guide_Number = @Guide_Number
                            ) IS NOT NULL
                          , (
                                SELECT TOP 1
                                       Path_Dry
                                FROM DeliveryProof WITH (NOLOCK)
                                WHERE Guide_Serie = @Guide_Serie
                                      AND Guide_Number = @Guide_Number
                            )
                          , (
                                SELECT TOP 1
                                       Path_Cold
                                FROM DeliveryProof WITH (NOLOCK)
                                WHERE Guide_Serie = @Guide_Serie
                                      AND Guide_Number = @Guide_Number
                            ))
                    WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
                    (
                        SELECT TOP 1
                               dlp.Path_Incident
                        FROM dbo.DeliveryAttempt               datt WITH (NOLOCK)
                            INNER JOIN ConfirmationOfIncidence cfo WITH (NOLOCK)
                                ON datt.ConfirmationOfIncidenceId = cfo.IdConfirmationOfIncidence
                            INNER JOIN dbo.DeliveryProof       dlp WITH (NOLOCK)
                                ON datt.ID_Proof = dlp.ID
                        WHERE dod.Guide_Serie = @Guide_Serie
                              AND dod.Guide_Number = @Guide_Number
                              AND dod.DeliveryAttemptId = datt.ID
                              AND
                              (
                                  cfo.IsDenied = 0
                                  OR cfo.IsDenied IS NULL
                              )
                    )
                    ELSE
                        ''
                END
               )                                                                            AS [ImagePath]
             , (CASE
                    WHEN dod.StatusOrderId = 5 THEN
                    (
                        SELECT TOP 1
                               IIF([dp].[Path_Dry] = '', dp.Path_Dry, ISNULL([Path_Dry], [Path_Dry]))
                        FROM [DeliveryBackOffice].[dbo].[DeliveryProof]       dp WITH (NOLOCK)
                            INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
                                ON da.Guide_Serie = dp.Guide_Serie
                                   AND da.Guide_Number = dp.Guide_Number
                                   AND da.Delivered = 1
                        WHERE dp.Guide_Serie = @Guide_Serie
                              AND dp.Guide_Number = @Guide_Number
                        ORDER BY dp.Date_Photo DESC
                    )
                    ELSE
                        ''
                END
               )                                                                            AS [Dry]
             , (CASE
                    WHEN dod.StatusOrderId = 5 THEN
                    (
                        SELECT TOP 1
                               IIF([dp].[Path_Cold] = '', dp.Path_Cold, ISNULL([Path_Cold], [Path_Cold]))
                        FROM [DeliveryBackOffice].[dbo].[DeliveryProof]       dp WITH (NOLOCK)
                            INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
                                ON da.Guide_Serie = dp.Guide_Serie
                                   AND da.Guide_Number = dp.Guide_Number
                                   AND da.Delivered = 1
                        WHERE dp.Guide_Serie = @Guide_Serie
                              AND dp.Guide_Number = @Guide_Number
                        ORDER BY dp.Date_Photo DESC
                    )
                    ELSE
                        ''
                END
               )                                                                            AS [Cold]
             , (CASE
                    WHEN dod.StatusOrderId = 5 THEN
                        @GuideDeliveryLatitude
                    WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
                    (
                        SELECT TOP 1
                               Latitude
                        FROM DeliveryAttempt                   dt WITH (NOLOCK)
                            INNER JOIN ConfirmationOfIncidence cfo WITH (NOLOCK)
                                ON dt.ConfirmationOfIncidenceId = cfo.IdConfirmationOfIncidence
                        WHERE dod.Guide_Serie = @Guide_Serie
                              AND dod.Guide_Number = @Guide_Number
                              AND dod.DeliveryAttemptId = dt.ID
                              AND dt.Delivered = 0
                              AND
                              (
                                  cfo.IsDenied = 0
                                  OR cfo.IsDenied IS NULL
                              )
                    )
                    ELSE
                        ''
                END
               )                                                                            AS Latitude
             , (CASE
                    WHEN dod.StatusOrderId = 5 THEN
                        @GuideDeliveryLongitude
                    WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
                    (
                        SELECT TOP 1
                               Longitude
                        FROM DeliveryAttempt                   dt WITH (NOLOCK)
                            INNER JOIN ConfirmationOfIncidence cfo WITH (NOLOCK)
                                ON dt.ConfirmationOfIncidenceId = cfo.IdConfirmationOfIncidence
                        WHERE dod.Guide_Serie = @Guide_Serie
                              AND dod.Guide_Number = @Guide_Number
                              AND dt.Delivered = 0
                              AND dod.DeliveryAttemptId = dt.ID
                              AND
                              (
                                  cfo.IsDenied = 0
                                  OR cfo.IsDenied IS NULL
                              )
                    )
                    ELSE
                        ''
                END
               )                                                                            AS Longitude
             , ''                                                                           [ReceiverPhone]
             , 0                                                                            [PriceGuide]
             , 0                                                                            [PriceCOD]
             , ''                                                                           AS UserIncident
             , (CASE
                    WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
             (@StatusIncidentValidated)
                    ELSE
                        0
                END
               )                                                                            AS StatusValidated
             , IIF(
                   COI.ValidGeolocationEvidence IS NULL
                   AND dod.StatusOrderId = 50
                 , IIF(IsConfirmed = 1 AND IsDenied = 0 AND dod.StatusOrderId = 50, 1, 0)
                 , IIF(COI.ValidGeolocationEvidence = 1 AND dod.StatusOrderId = 50, 1, 0))  AS 'ValidGeolocationEvidence'
             , IIF(
                   COI.ValidPhotographicEvidence IS NULL
                   AND dod.StatusOrderId = 50
                 , IIF(IsConfirmed = 1 AND IsDenied = 0 AND dod.StatusOrderId = 50, 1, 0)
                 , IIF(COI.ValidPhotographicEvidence = 1 AND dod.StatusOrderId = 50, 1, 0)) AS 'ValidPhotographicEvidence'
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail   dod WITH (NOLOCK) --on do.[Guide_Serie] =  dod.Guide_Serie and do.[Guide_Number] = dod.Guide_Number
            INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
                ON so.StatusOrderId = dod.StatusOrderId
                   AND so.CatStatusTypeId = @ExternalTypeId
            INNER JOIN [dbo].[CatCheckpointType]          CCT WITH (NOLOCK)
                ON [so].[CatCheckpointTypeId] = [CCT].[IdCatCheckpointType]
            LEFT JOIN [dbo].[DeliveryAttempt]             da WITH (NOLOCK)
                ON dod.DeliveryAttemptId = da.ID
            LEFT JOIN [dbo].[ConfirmationOfIncidence]     COI WITH (NOLOCK)
                ON da.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
        WHERE dod.Guide_Serie = @Guide_Serie
              AND dod.Guide_Number = @Guide_Number
    ) RES
    ORDER BY RES.[StageDate] DESC
           , RES.[EventID];

END;
