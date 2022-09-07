
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <05-09-2022>
-- Description:	< Detalle de rastreo interno para nuevo portal web >
-- =============================================
CREATE PROCEDURE [dbo].[GetDetailedTrackingDataOfGuide]
    @Guide_Serie NVARCHAR(2),
    @Guide_Number BIGINT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	
	DECLARE @GuideOrderTemp AS TABLE(
		Guide_Serie NVARCHAR(2),
		Guide_Number INT,
		SenderName NVARCHAR(200),
		Sender_Address NVARCHAR(600),
		ReceiverName NVARCHAR(200),
		Receiver_Address NVARCHAR(600),
		Manifest_Serie NVARCHAR(2),
		Manifest_Number INT,
		NameOfReceiver NVARCHAR(200),
		Delivery_Max_Date DATETIME
	);

	-- Variables de datos de entrega
	DECLARE @GuideDeliveryLatitude NVARCHAR(20) = '';
	DECLARE @GuideDeliveryLongitude NVARCHAR(20) = '';
	DECLARE @GuideDeliveryCourierAttempt NVARCHAR(200) = '';

	SELECT
		TOP 1
			@GuideDeliveryLatitude = DA.Latitude,
			@GuideDeliveryLongitude = DA.Longitude,
			@GuideDeliveryCourierAttempt = LTRIM(RTRIM(CONCAT(LTRIM(RTRIM(SR.First_Name)), ' ', LTRIM(RTRIM(SR.Last_Name)))))
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH(NOLOCK)
		INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryProof] DP WITH(NOLOCK)
			ON
				DA.Guide_Number = DP.Guide_Number
				AND
				DA.Guide_Serie = DP.Guide_Serie
		INNER JOIN
			[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH(NOLOCK)
			ON
				DA.ID_Courier = SR.ID
	WHERE
		DA.Guide_Serie = @Guide_Serie
		AND
		DA.Guide_Number = @Guide_Number
		AND
		DA.Delivered = 1
	ORDER BY
		DA.Date_Created DESC

	-- Datos de guía
	INSERT INTO
		@GuideOrderTemp
		(Guide_Serie, Guide_Number, SenderName, Sender_Address, ReceiverName, Receiver_Address, Manifest_Serie, Manifest_Number, NameOfReceiver, Delivery_Max_Date)
	SELECT
		TOP 1
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
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
	WHERE
		DO.Guide_Serie = @Guide_Serie
		AND
		DO.Guide_Number = @Guide_Number;

	IF OBJECT_ID('tempdb.dbo.#OrdChkpnt', 'U') IS NOT NULL DROP TABLE #OrdChkpnt;

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
		   RES.[Dry],
		   RES.[Cold],
           RES.[NameOfReceiver],
           RES.[Place],
           RES.[ManifestNumber],
           RES.[Latitude],
           RES.[Longitude],
		   RES.Token
	INTO #OrdChkpnt
    FROM
    (
		SELECT 0 [EventID],
			do.Guide_Serie  + CAST(do.Guide_Number AS NVARCHAR) AS [OrderId],
			do.ReceiverName AS [CustomerFullname], 
			do.Sender_Address AS [OriginAdress],
			'' AS [OriginLatitude],
			'' AS [OriginLongitude],
			do.Receiver_Address AS [DestinyAddress],
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
			 '' AS [Dry],
			 '' AS [Cold],
			ISNULL(do.[NameOfReceiver], '') AS NameOfReceiver,
			do.SenderName AS Place,
			do.Manifest_Serie + CAST(do.Manifest_Number AS VARCHAR) AS [ManifestNumber],
			''  [Latitude],
			'' [Longitude],
			'' [Token]
	FROM @GuideOrderTemp do
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
			ON da.Guide_Serie = do.Guide_Serie
				AND da.Guide_Number = do.Guide_Number
	WHERE do.Guide_Serie = @Guide_Serie
			AND do.Guide_Number = @Guide_Number
		UNION
        SELECT
            RANK() OVER (PARTITION BY dod.Guide_Number
                         ORDER BY CONVERT(DATE, dod.DateCreated),
                                  dod.StatusOrderId ASC
                        ) AS EventID,
            dod.Guide_Serie + CAST(dod.Guide_Number AS VARCHAR) AS [OrderId], 
            '' [CustomerFullname],                            
            '' [OriginAdress],                                
            '' [OriginLatitude],
            '' [OriginLongitude],
            '' [DestinyAddress],                              
            '' [DestintyLatitude],
            '' [DestinyLongitude],
            '' [EstimatedDeliveryDate],                       
            '' [CourierName],                                 
            CAST(dod.StatusOrderId AS NVARCHAR) AS [StageId], 
            (MAX(dod.DateCreated)) AS [StageDate],            
            so.OrderDescription AS [StageTitle],              
            'web' AS [StageSource],
            (CASE
                 WHEN dod.StatusOrderId IN ( 6, 8 ) THEN
                     ISNULL(dod.Observations, '')
                 WHEN dod.StatusOrderId IN ( 12 ) THEN
                     ISNULL(
                     (
                         SELECT TOP 1
								   (SELECT '[ ' + 
											DeliveryBackOffice.dbo.[CapitalizeFirstLetter](LOWER(courier.First_Name) + ' '+LOWER(courier.Last_Name)) +
											' ]'
								   FROM dbo.SenderReceiver courier WHERE courier.ID = da.ID_Courier ) + ' ' + 
								   I.DescriptionIncidence  + ' ' + ISNULL(dod.Observations,'')
							FROM DeliveryBackOffice.dbo.CatTypeIncidence I 
								INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da 
									ON da.ID_Incident = I.IdIncidenceType
                         WHERE dod.Guide_Serie = da.Guide_Serie
                               AND dod.Guide_Number = da.Guide_Number
                         ORDER BY da.Date_Created DESC
                     ),
                     ''
                           )
                 WHEN dod.StatusOrderId IN ( 15 ) THEN
                     ''
				ELSE
					ISNULL(dod.Observations, ISNULL(so.StatusOrderTrackingDescription , ''))
             END
            ) AS [StageDescription]
            ,(CASE dod.StatusOrderId
                 WHEN 5 THEN
                     ISNULL(
                               ISNULL(
                               (
                                   SELECT TOP 1
                                          'data:image/jpeg;base64,'
                                          +
                                          (
                                              SELECT CAST('' AS XML).value(
                                                                              'xs:base64Binary(sql:column("PICTURE"))',
                                                                              'varchar(max)'
                                                                          )
                                          )
                                   FROM
                                   (
                                       SELECT IIF([dp].[Proof_Dry] = 0x,
                                                  dp.Proof_Cold,
                                                  ISNULL([Proof_Dry], [Proof_Incident])) AS PICTURE,
                                              Date_Photo
                                       FROM [DeliveryBackOffice].[dbo].[DeliveryProof] dp WITH (NOLOCK)
                                           INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
                                               ON da.Guide_Serie = dp.Guide_Serie
                                                  AND da.Guide_Number = dp.Guide_Number
												  AND da.Delivered = 1
                                       WHERE dp.Guide_Serie = 'FD'
                                             AND dp.Guide_Number = @Guide_Number
                                             AND
                                             (
                                                 dp.Proof_Incident != 0x
                                                 OR dp.Proof_Incident IS NULL
                                             )
                                   ) L1
                                   ORDER BY L1.Date_Photo DESC
                               ),
                               (CAST(DeliveryBackOffice.dbo.fn_get_document_image_url(dod.Guide_Serie
                                                                                      + CAST(dod.Guide_Number AS VARCHAR)
                                                                                     ) AS VARCHAR(300))
                               )
                                     ),
                               ''
                           )
                 ELSE
                     ''
             END
            ) AS [ImagePath],

			(CASE WHEN dod.StatusOrderId = 5 THEN 
				(SELECT TOP 1
					IIF([dp].[Path_Dry] = '', dp.Path_Dry,ISNULL([Path_Dry], [Path_Dry]))
						FROM [DeliveryBackOffice].[dbo].[DeliveryProof] dp WITH (NOLOCK)
							INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
								ON da.Guide_Serie = dp.Guide_Serie
									AND da.Guide_Number = dp.Guide_Number
									AND da.Delivered = 1
						WHERE dp.Guide_Serie = 'FD'
								AND dp.Guide_Number = @Guide_Number order By dp.Date_Photo desc)
			ELSE '' END) AS [Dry],

			(CASE WHEN dod.StatusOrderId = 5 THEN 
				(SELECT TOP 1
					IIF([dp].[Path_Cold] = '', dp.Path_Cold,ISNULL([Path_Cold], [Path_Cold]))
                        FROM [DeliveryBackOffice].[dbo].[DeliveryProof] dp WITH (NOLOCK)
                            INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
                                ON da.Guide_Serie = dp.Guide_Serie
                                    AND da.Guide_Number = dp.Guide_Number
									AND da.Delivered = 1
                        WHERE dp.Guide_Serie = 'FD'
                                AND dp.Guide_Number = @Guide_Number order By dp.Date_Photo desc)
			ELSE '' END) AS [Cold],

            (CASE WHEN dod.StatusOrderId = 5 THEN (SELECT TOP 1 NameOfReceiver FROM @GuideOrderTemp) ELSE '' END) AS NameOfReceiver,
            '' AS Place,
            '' AS [ManifestNumber],
            (CASE WHEN dod.StatusOrderId = 5 THEN @GuideDeliveryLatitude ELSE '' END) AS Latitude,
            (CASE WHEN dod.StatusOrderId = 5 THEN @GuideDeliveryLongitude ELSE '' END) AS Longitude,
			dod.UserCreated Token
        FROM dbo.DeliveryOrderDetail dod WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
                ON so.StatusOrderId = dod.StatusOrderId
				AND so.CatStatusTypeId = 2
        WHERE dod.Guide_Serie = @Guide_Serie
              AND dod.Guide_Number = @Guide_Number
        GROUP BY CONVERT(DATE, dod.DateCreated),
                 dod.Guide_Serie,
                 dod.Guide_Number,
                 dod.StatusOrderId,
                 dod.UserCreated,
                 dod.Observations,
                 so.OrderDescription,
				 so.StatusOrderTrackingDescription
    ) RES
    ORDER BY RES.[StageDate] ASC,
             RES.[EventID];


	SELECT     OrdChkPnt.[EventID],
			   OrdChkPnt.[OrderId],
			   OrdChkPnt.[CustomerFullname],
			   OrdChkPnt.[OriginAdress],
			   OrdChkPnt.[OriginLatitude],
			   OrdChkPnt.[OriginLongitude],
			   OrdChkPnt.[DestinyAddress],
			   OrdChkPnt.[DestintyLatitude],
			   OrdChkPnt.[DestinyLongitude],
			   OrdChkPnt.[EstimatedDeliveryDate],
			   OrdChkPnt.[CourierName],
			   OrdChkPnt.[StageId],
			   OrdChkPnt.[StageDate],
			   OrdChkPnt.[StageTitle],
			   OrdChkPnt.[StageSource],
			   LTRIM(RTRIM(ISNULL(
					'[ ' + ISNULL(vpc.DescriptionOfClient, (SELECT TOP (1) hub.HubAbbreviation 
							FROM DeliveryBackOffice.dbo.HubLogistics hub  WITH (NOLOCK)
							WHERE hub.IdStation = epl.IdStation AND hub.HubStatus ='TRUE'
							ORDER BY hub.IdStation 
							)) + ' ]' +--[Where]
					 '' --[Complement] 
					,'') 
			   + ' ' + ISNULL(OrdChkPnt.StageDescription,'')))
			   AS [StageDescription] ,
			   OrdChkPnt.[ImagePath],
			   OrdChkPnt.[Dry],
			   OrdChkPnt.[Cold],
			   OrdChkPnt.[NameOfReceiver],
			   OrdChkPnt.[Place],
			   OrdChkPnt.[ManifestNumber],
			   OrdChkPnt.[Latitude],
			   OrdChkPnt.[Longitude]
	FROM #OrdChkpnt OrdChkPnt
	-- Obtener datos desde usuario Desktop
	LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken token  WITH (NOLOCK) ON OrdChkPnt.Token = token.SSN_IdToken
	LEFT JOIN DenariusUser_Dev.dbo.LGN_User duser  WITH (NOLOCK) ON duser.USR_IdUser = token.SSN_IdUser AND duser.USR_Username = token.SSN_Username
	LEFT JOIN DenariusDesktop_Dev.dbo.LGT_INF_Employee epl  WITH (NOLOCK) ON epl.IdEmployee = duser.USR_IdEmployee 
	-- Obtener datos desde usuario portal
	LEFT JOIN DeliveryBackOffice.dbo.TokenLog tl WITH(NOLOCK) ON OrdChkPnt.Token = tl.TknIdToken
	LEFT JOIN DeliveryBackOffice.dbo.RegisterUser ru WITH(NOLOCK) ON tl.TknIdUser = ru.UsrIdUser
	LEFT JOIN DeliveryBackOffice.dbo.VisitPointByUser vpbu WITH(NOLOCK) ON ru.UsrIdUser = vpbu.RegisterUserID
	LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK) ON vpbu.IdVisitPointClient = vpc.IdVisitPointClient and vpc.IdKindOfVPClient = 1 and vpc.DescriptionOfClient LIKE 'FD%EXC%'
	ORDER BY OrdChkPnt.[StageDate] ASC,
			 OrdChkPnt.[EventID];

	IF OBJECT_ID('tempdb.dbo.#OrdChkpnt', 'U') IS NOT NULL DROP TABLE #OrdChkpnt;

END;