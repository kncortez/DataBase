
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <05-09-2022>
-- Description:	< Detalle de rastreo interno para nuevo portal web >
-- =============================================
-- Author:		<Jerson Ochoa>
-- Update date: <21-02-2023>
-- Description: <Management for checkpoint icons>
-- =============================================
CREATE PROCEDURE [dbo].[GetDetailedTrackingDataOfGuide]
    @Guide_Serie NVARCHAR(2),
    @Guide_Number BIGINT,
	@Receiver_Phone NVARCHAR(100) = NULL
AS
BEGIN
   
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
		Delivery_Max_Date DATETIME,
		Receiver_Phone NVARCHAR(100)
	);

	-- Variables de datos de entrega
	DECLARE @GuideDeliveryLatitude NVARCHAR(20) = '';
	DECLARE @GuideDeliveryLongitude NVARCHAR(20) = '';
	DECLARE @GuideDeliveryCourierAttempt NVARCHAR(200) = '';
	DECLARE @StatusIncident INT;
	DECLARE @StatusIncidentValidated INT;

	SET @StatusIncident = (SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription =  'Incidencia en ruta')
	SET @StatusIncidentValidated = (SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription =  'Incidencia Validada')


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
		(Guide_Serie, Guide_Number, SenderName, Sender_Address, ReceiverName, Receiver_Address, Manifest_Serie, Manifest_Number, NameOfReceiver, Delivery_Max_Date, Receiver_Phone)
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
			, LTRIM(RTRIM(DO.Receiver_Phone))
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
	WHERE
		DO.Guide_Serie = @Guide_Serie
		AND
		DO.Guide_Number = @Guide_Number;

	--Control para mostrar imagenes
	DECLARE @IsPhoneValid BIT = CASE WHEN @Receiver_Phone IS NOT NULL AND LTRIM(RTRIM(@Receiver_Phone)) = ( SELECT
			Receiver_Phone
		FROM @GuideOrderTemp) THEN 1
		ELSE 0
	END

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
		   RES.[ClasificationIncident],
           RES.[StageDescription],
		   RES.[CheckpointIcon],
           RES.[ImagePath],
		   RES.[Dry],
		   RES.[Cold],
           RES.[NameOfReceiver],
           RES.[Place],
           RES.[ManifestNumber],
           RES.[Latitude],
           RES.[Longitude],
		   RES.Token,
		   RES.Price,
		   RES.COD,		   
		   RES.NextSteps,
		   RES.UserIncident,
		   RES.Receiver_Phone,
		   RES.ValidGeolocationEvidence,
	 	   RES.ValidPhotographicEvidence
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
			'' AS [ClasificationIncident],
			'' AS [StageDescription], 
			'' AS [CheckpointIcon],
			'' AS [ImagePath],
			 '' AS [Dry],
			 '' AS [Cold],
			ISNULL(do.[NameOfReceiver], '') AS NameOfReceiver,
			do.SenderName AS Place,
			do.Manifest_Serie + CAST(do.Manifest_Number AS VARCHAR) AS [ManifestNumber],
			''  [Latitude],
			'' [Longitude],
			'' [Token],
			dor.PriceShippment [Price],
			dor.Collect_OnDelivery [COD],
			NULL [NextSteps],
			'' [UserIncident],
			do.Receiver_Phone,
			'0'AS ValidGeolocationEvidence,
			'0' AS ValidPhotographicEvidence
	FROM @GuideOrderTemp do
	    INNER JOIN dbo.DeliveryOrder dor WITH(NOLOCK) 
		    ON do.Guide_Serie = dor.Guide_Serie And 
			   do.Guide_Number = dor.Guide_Number
		INNER JOIN dbo.DeliveryOrderDetail  dod WITH(NOLOCK)
		    ON  dor.Guide_Serie = dod.Guide_Serie And 
			    dor.Guide_Number = dod.Guide_Number 
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
			ON  dod.DeliveryAttemptId = da.ID
		LEFT JOIN [dbo].[ConfirmationOfIncidence] COI WITH(NOLOCK)
		    ON  da.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence 
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
			 ( CASE
                    WHEN dod.StatusOrderId = @StatusIncident THEN
						
						(SELECT TOP 1 cic.IncidenceTypeName FROM DeliveryAttempt dla WITH (NOLOCK)
						INNER JOIN CatTypeIncidence cti WITH (NOLOCK)
						ON dla.ID_Incident = cti.IdIncidenceType 
						INNER JOIN CatIncidenceClasification cic WITH (NOLOCK)
						ON cti.IncidenceClasificationId = cic.IdCatIncidenceClasification
						WHERE dod.Guide_Serie = @Guide_Serie AND dod.Guide_Number = @Guide_Number AND dod.DeliveryAttemptId = dla.ID)
				ELSE
                       ''
                END

			   ) AS [ClasificationIncident],
            (CASE
                 WHEN dod.StatusOrderId IN ( 6, 8, @StatusIncidentValidated ) THEN
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
							FROM DeliveryBackOffice.dbo.CatTypeIncidence I WITH(NOLOCK)
								INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da  WITH(NOLOCK)
									ON da.ID_Incident = I.IdIncidenceType
                         WHERE dod.Guide_Serie = da.Guide_Serie
                               AND dod.Guide_Number = da.Guide_Number
                         ORDER BY da.Date_Created DESC
                     ),
                     ''
                           )
				 WHEN dod.StatusOrderId = @StatusIncident THEN
						   (CASE
								WHEN (SELECT TOP 1 cic.IncidenceTypeName FROM DeliveryAttempt dla WITH (NOLOCK)  
									INNER JOIN CatTypeIncidence cti WITH (NOLOCK)
									ON dla.ID_Incident = cti.IdIncidenceType 
									INNER JOIN CatIncidenceClasification cic WITH (NOLOCK)
									ON cti.IncidenceClasificationId = cic.IdCatIncidenceClasification
									WHERE dod.Guide_Serie = @Guide_Serie AND dod.Guide_Number = @Guide_Number AND dod.DeliveryAttemptId = dla.ID) = 'Incidencias operativas' THEN

								--(SELECT TOP 1 cti.NameIncidencePublic FROM DeliveryAttempt dla WITH (NOLOCK) 
								--INNER JOIN CatTypeIncidence cti WITH (NOLOCK)
								--ON dla.ID_Incident = cti.IdIncidenceType WHERE dla.Guide_Serie = @Guide_Serie AND dla.Guide_Number = @Guide_Number)
										(SELECT TOP 1 cti.NameIncidencePublic FROM DeliveryAttempt dla WITH (NOLOCK) 
											INNER JOIN CatTypeIncidence cti WITH (NOLOCK)
											ON dla.ID_Incident = cti.IdIncidenceType WHERE dod.Guide_Serie = @Guide_Serie AND dod.Guide_Number = @Guide_Number AND dod.DeliveryAttemptId = dla.ID)
								ELSE
									(SELECT TOP 1 cti.NameIncidence FROM DeliveryAttempt dla WITH (NOLOCK) 
											INNER JOIN CatTypeIncidence cti WITH (NOLOCK)
											ON dla.ID_Incident = cti.IdIncidenceType WHERE dod.Guide_Serie = @Guide_Serie AND dod.Guide_Number = @Guide_Number AND dod.DeliveryAttemptId = dla.ID)
								
							END
							)
					
				ELSE
					ISNULL(so.StatusOrderTrackingDescription, '')
             END
            ) AS [StageDescription],
			ISNULL([CCT].[CheckpointIcon], '') AS [CheckpointIcon],
            (CASE WHEN dod.StatusOrderId = 5 THEN
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
						WHEN dod.StatusOrderId =@StatusIncidentValidated THEN 
						--(SELECT TOP 1 Path_Incident FROM DeliveryProof WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number)
								 (SELECT TOP 1
                            dlp.Path_Incident
							FROM dbo.DeliveryAttempt datt WITH (NOLOCK)
						 INNER JOIN ConfirmationOfIncidence cfo WITH (NOLOCK)
							ON datt.ConfirmationOfIncidenceId = cfo.IdConfirmationOfIncidence
                         INNER JOIN dbo.DeliveryProof dlp WITH (NOLOCK)
                             ON datt.ID_Proof = dlp.ID
							WHERE dod.Guide_Serie = @Guide_Serie
                          AND dod.Guide_Number = @Guide_Number
                          AND dod.DeliveryAttemptId = datt.ID
						  AND ISNULL(cfo.IsDenied,0) = 0 )
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
            (CASE WHEN dod.StatusOrderId = 5 THEN @GuideDeliveryLatitude 
				  WHEN dod.StatusOrderId = @StatusIncidentValidated THEN 
				  --(SELECT TOP 1 Latitude FROM DeliveryAttempt WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number) 
						 (SELECT TOP 1 Latitude FROM DeliveryAttempt dt WITH (NOLOCK) 
					 INNER JOIN ConfirmationOfIncidence cfo WITH (NOLOCK) 
							ON dt.ConfirmationOfIncidenceId = cfo.IdConfirmationOfIncidence
						WHERE dod.Guide_Serie = @Guide_Serie 
						AND dod.Guide_Number = @Guide_Number
                        AND dod.DeliveryAttemptId = dt.ID
						AND ISNULL(cfo.IsDenied,0) = 0 )

				ELSE '' END) AS Latitude,
            (CASE WHEN dod.StatusOrderId = 5 THEN @GuideDeliveryLongitude 
				  WHEN dod.StatusOrderId = @StatusIncidentValidated THEN 
				  --(SELECT TOP 1 Longitude FROM DeliveryAttempt WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number) 
						(SELECT TOP 1 Longitude FROM DeliveryAttempt dt WITH (NOLOCK)
						INNER JOIN ConfirmationOfIncidence cfo WITH (NOLOCK)
							ON dt.ConfirmationOfIncidenceId = cfo.IdConfirmationOfIncidence
						WHERE  dod.Guide_Serie = @Guide_Serie 
						AND dod.Guide_Number = @Guide_Number
                        AND dod.DeliveryAttemptId = dt.ID
						AND ISNULL(cfo.IsDenied,0) = 0 )
			
				ELSE '' END) AS Longitude,
			dod.UserCreated Token,
			0 [Price],
			0 [COD],
			so.NextSteps NextSteps,
			(CASE
                    WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
								(  SELECT TOP 1
								(prs.PerFirstName+' '+prs.PerLastName) FROM Person prs WITH (NOLOCK)
									INNER JOIN RegisterUser usr WITH (NOLOCK)
										ON prs.PerIdPerson = usr.UsrIdPerson
									INNER JOIN TokenLog tkl WITH (NOLOCK)
										ON usr.UsrIdUser = tkl.TknIdUser
									WHERE dod.Guide_Serie = @Guide_Serie
										  AND dod.Guide_Number = @Guide_Number
										  AND dod.UserCreated = CONVERT(VARCHAR(50), tkl.TknIdToken))
					WHEN dod.StatusOrderId = @StatusIncident THEN
								(CASE 
									WHEN (SELECT TOP 1 dttt.ID_Courier FROM DeliveryAttempt dttt WITH (NOLOCK) WHERE dttt.ID = dod.DeliveryAttemptId) IS NOT NULL THEN
									(SELECT TOP 1 (srv.First_Name +' '+srv.Last_Name) FROM SenderReceiver srv WITH (NOLOCK)
											INNER JOIN DeliveryAttempt dat WITH (NOLOCK)
											ON srv.ID = dat.ID_Courier
											WHERE dod.Guide_Number = @Guide_Number AND dat.ID = dod.DeliveryAttemptId)
									
									ELSE

									(SELECT TOP 1
									tk.SSN_Username
									FROM dbo.DeliveryAttempt dat WITH (NOLOCK)
									LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
										 ON tk.SSN_IdToken = CONVERT(VARCHAR(50), dat.User_Created)
								   WHERE dod.Guide_Serie = @Guide_Serie
										AND dod.Guide_Number = @Guide_Number
										AND dod.DeliveryAttemptId = dat.ID)
							 END
							)
                    ELSE
                        ''
                END
               ) AS UserIncident,
			   GOT.Receiver_Phone,
			      IIF(COI.ValidGeolocationEvidence IS NULL AND dod.StatusOrderId=50,
                      IIF(IsConfirmed = 1 AND IsDenied = 0 AND dod.StatusOrderId=50, 1, 0),
                                IIF(COI.ValidGeolocationEvidence = 1 AND dod.StatusOrderId=50, 1, 0))
			                             AS 'ValidGeolocationEvidence',
			   IIF(COI.ValidPhotographicEvidence IS NULL AND dod.StatusOrderId=50,
				       IIF(IsConfirmed = 1 AND IsDenied = 0 AND dod.StatusOrderId=50, 1, 0), 
				                   IIF(COI.ValidPhotographicEvidence = 1 AND dod.StatusOrderId=50, 1, 0)) AS 'ValidPhotographicEvidence'
            FROM dbo.DeliveryOrderDetail dod WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
                ON so.StatusOrderId = dod.StatusOrderId
				AND so.CatStatusTypeId = 2
			INNER JOIN	[dbo].[CatCheckpointType] CCT
				ON [so].[CatCheckpointTypeId] = [CCT].[IdCatCheckpointType]
			INNER JOIN @GuideOrderTemp GOT
			    ON  GOT.Guide_Serie =  dod.Guide_Serie  AND  GOT.Guide_Number = dod.Guide_Number
			LEFT  JOIN [dbo].[DeliveryAttempt] da WITH(NOLOCK)
			    ON  dod.DeliveryAttemptId = da.ID 
			LEFT JOIN [dbo].[ConfirmationOfIncidence] COI WITH(NOLOCK) 
			    ON da.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
        WHERE dod.Guide_Serie = @Guide_Serie
              AND dod.Guide_Number = @Guide_Number
        GROUP BY CONVERT(DATE, dod.DateCreated),
                 dod.Guide_Serie,
                 dod.Guide_Number,
                 dod.StatusOrderId,
                 dod.UserCreated,
                 dod.Observations,
                 so.OrderDescription,
				 so.StatusOrderTrackingDescription,
				 so.NextSteps,
				 [CCT].[CheckpointIcon],
				 dod.DeliveryAttemptId,
				 GOT.Receiver_Phone,
				 COI.ValidGeolocationEvidence,
			     COI.ValidPhotographicEvidence,
				 COI.IsConfirmed ,
				 COI.IsDenied
    ) RES
    ORDER BY RES.[StageDate] DESC,
             RES.[EventID];

	CREATE NONCLUSTERED INDEX ix_OrdChkpnt_Token_StageDate_EventID ON #OrdChkpnt ([Token],[StageDate],[EventID]);
			 
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
			   OrdChkPnt.[ClasificationIncident],
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
			   OrdChkPnt.[CheckpointIcon],
			   OrdChkPnt.[ImagePath],
			   OrdChkPnt.[Dry],
			   OrdChkPnt.[Cold],
			   OrdChkPnt.[NameOfReceiver],
			   OrdChkPnt.[Place],
			   OrdChkPnt.[ManifestNumber],
			   OrdChkPnt.[Latitude],
			   OrdChkPnt.[Longitude]
			   ,ISNULL(OrdChkPnt.Price,0) Price
			   ,ISNULL(OrdChkPnt.COD,0) COD
			   ,OrdChkPnt.[NextSteps]
			   ,OrdChkPnt.[UserIncident]
			   ,OrdChkPnt.[Receiver_Phone]
			   ,OrdChkPnt.ValidGeolocationEvidence
			   ,OrdChkPnt.ValidPhotographicEvidence
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
	ORDER BY OrdChkPnt.[StageDate] DESC,
			 OrdChkPnt.[EventID];

	IF OBJECT_ID('tempdb.dbo.#OrdChkpnt', 'U') IS NOT NULL DROP TABLE #OrdChkpnt;

END;