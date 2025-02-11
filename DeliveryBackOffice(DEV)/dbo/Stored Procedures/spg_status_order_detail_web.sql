
-- =============================================
-- Author:		<Carlos,Cano>
-- Create date: <13/06/2020>
-- Description:	<Detalle de rastreo en pagina web tracking para el cliente>
-- =============================================
-- Author:		<Jerson Ochoa>
-- Update date: <21-02-2023>
-- Description: <Management for checkpoint icons>
-- Update date: <28-03-2023>
-- Description: <Add Username and station for each registered checkpoint>
-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <24-07-2024>
-- Description: <Se agrega CommentOnIncident para devolver el comentario que el piloto ingreso al momento de crear la incidencia>
-- =============================================
CREATE PROCEDURE [dbo].[spg_status_order_detail_web]
    @Guide_Serie NVARCHAR(2),
    @Guide_Number BIGINT
AS
BEGIN

	DECLARE @StatusIncident INT;
	DECLARE @StatusIncidentValidated INT;
    DECLARE @GuideDeliveryLatitude NVARCHAR(20) = '';
	DECLARE @GuideDeliveryLongitude NVARCHAR(20) = '';

	SELECT
		TOP 1
			@GuideDeliveryLatitude = DA.Latitude,
			@GuideDeliveryLongitude = DA.Longitude
			
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
		DA.Date_Created DESC;

	SET @StatusIncident = (SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription =  'Incidencia en ruta')
	SET @StatusIncidentValidated = (SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription =  'Incidencia Validada')

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb.dbo.#OrdChkpnt', 'U') IS NOT NULL
        DROP TABLE #OrdChkpnt;

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
		   RES.[CommentOnIncident],
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
           RES.NextSteps,
		   RES.UserIncident,
           RES.ValidGeolocationEvidence,
           RES.ValidPhotographicEvidence
    INTO #OrdChkpnt
    FROM
    (
        SELECT 0 [EventID],
               do.Guide_Serie + CAST(do.Guide_Number AS NVARCHAR) AS [OrderId],
               ISNULL(do.Receiver_FirstName, '') + ' ' + ISNULL(do.Receiver_LastName, '') AS [CustomerFullname],
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
			   '' AS [CommentOnIncident],
               '' AS [StageDescription],
               '' AS [CheckpointIcon],
               '' AS [ImagePath],
               --(Select top 1 Path_Dry from DeliveryProof where Guide_Number = 247619 order by Date_Photo desc) AS Dry,
               --(Select top 1 Path_Cold from DeliveryProof where Guide_Number = 247619 order by Date_Photo desc) AS Cold,
               '' AS [Dry],
               '' AS [Cold],
               --ISNULL([Cold], '') AS Cold,
               ISNULL([NameOfReceiver], '') AS NameOfReceiver,
               ISNULL(Sender_FirstName, '') + ' ' + ISNULL(Sender_LastName, '') AS Place,
               do.Manifest_Serie + CAST(do.Manifest_Number AS VARCHAR) AS [ManifestNumber],
               ISNULL(da.Latitude, '') [Latitude],
               ISNULL(da.Longitude, '') [Longitude],
               '' [Token],
               '' NextSteps,
			   '' [UserIncident],
                 ''   AS 'ValidGeolocationEvidence',
				 '' AS 'ValidPhotographicEvidence'
        FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
                ON da.Guide_Serie = do.Guide_Serie
                   AND da.Guide_Number = do.Guide_Number
        WHERE do.Guide_Serie = @Guide_Serie
              AND do.Guide_Number = @Guide_Number
        UNION
        SELECT
            --ROW_NUMBER() OVER (ORDER BY  dod.StatusOrderId ASC)  AS EventID,
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
			 ( CASE
                    WHEN dod.StatusOrderId = @StatusIncident THEN
						ISNULL([COI].[CommentOnIncident], '')
					END
			   ) AS [CommentOnIncident],               
            (CASE
                 WHEN dod.StatusOrderId IN ( 6, 8,@StatusIncidentValidated ) THEN
                     ISNULL(dod.Observations, '')
                 WHEN dod.StatusOrderId IN ( 12/*, 45 */) THEN
                     ISNULL(
                     (
                         SELECT TOP 1
                                (
                                    SELECT '[ '
                                           + DeliveryBackOffice.dbo.[CapitalizeFirstLetter](LOWER(courier.First_Name)
                                                                                            + ' '
                                                                                            + LOWER(courier.Last_Name)
                                                                                           )
                                           + ' ]' + ' ' + CASE
                                                              WHEN [HL].[HubAbbreviation] IS NOT NULL THEN
                                        ('[ ' + [HL].[HubAbbreviation] + ' ]')
                                                              ELSE
                                                                  ''
                                                          END
                                    FROM dbo.SenderReceiver courier
                                        LEFT JOIN [dbo].[HubLogistics] HL
                                            ON [courier].[HubLogisticId] = [HL].[IdHubLogistic]
                                    WHERE courier.ID = da.ID_Courier
                                ) + ' ' +
                             --I.DescriptionIncidence  + ' ' + ISNULL(dod.Observations,'')
                             ISNULL(dod.Observations, '')
                         FROM DeliveryBackOffice.dbo.CatTypeIncidence I
                             INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da
                                 ON da.ID_Incident = I.IdIncidenceType
                         WHERE dod.Guide_Serie = da.Guide_Serie
                               AND dod.Guide_Number = da.Guide_Number
                         ORDER BY da.Date_Created DESC
                     ),
                     ''
                           )
				WHEN dod.StatusOrderId = @StatusIncident THEN
						(SELECT TOP 1 cti.NameIncidence FROM DeliveryAttempt dla  
						INNER JOIN CatTypeIncidence cti 
						ON dla.ID_Incident = cti.IdIncidenceType WHERE dod.Guide_Serie = @Guide_Serie AND dod.Guide_Number = @Guide_Number AND dod.DeliveryAttemptId = dla.ID)

                 WHEN dod.StatusOrderId IN ( 15 ) THEN
                     ''
                 ELSE
                     ISNULL(
                               dod.Observations,
                               ISNULL(
                               (
                                   SELECT TOP 1 '[ ' + [P].[PerFirstName] + ' ' + [P].[PerLastName] + ' ]' + ' ' + '[ '
                                          + [CS].[StationName] + ' ]'
                                   FROM [dbo].[TokenLog] TL
                                       INNER JOIN [RegisterUser] RU
                                           ON [TL].[TknIdUser] = [RU].[UsrIdUser]
                                       INNER JOIN [dbo].[Person] P
                                           ON [RU].[UsrIdPerson] = [PerIdPerson]
                                       INNER JOIN [dbo].[RolByUserBySystem] RUS
                                           ON [TL].[TknIdSystem] = [RUS].[RusIdSystem]
                                              AND [RU].[UsrIdUser] = [RUS].[RusIdUser]
                                       INNER JOIN [dbo].[CatStation] CS
                                           ON [RUS].[StationId] = [CS].[IdStation]
                                   WHERE [TL].[TknIdToken] = [dod].[UserCreated]
                               ),
                               ''
                                     )
                           )
             END
            ) AS [StageDescription],
            ISNULL([CCT].[CheckpointIcon], '') AS [CheckpointIcon],
            (CASE 
                 WHEN  dod.StatusOrderId = 5  THEN
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
                                       WHERE dp.Guide_Serie = @Guide_Serie 
                                             AND dp.Guide_Number = @Guide_Number
                                             AND
                                             (
                                                 dp.Proof_Incident != 0x
                                                 OR dp.Proof_Incident IS NULL
                                             )
                                            AND da.Verified = 1
                                            AND da.Accepted = 1
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
						(SELECT TOP 1
                            dlp.Path_Incident
							FROM dbo.DeliveryAttempt datt
                         INNER JOIN dbo.DeliveryProof dlp
                             ON datt.ID_Proof = dlp.ID
							WHERE dod.Guide_Serie = @Guide_Serie
                          AND dod.Guide_Number = @Guide_Number
                          AND dod.DeliveryAttemptId = datt.ID)
                 ELSE
                     ''
             END
            ) AS [ImagePath],
            CASE WHEN dod.StatusOrderId = 5 THEN 
			    ISNULL(
						(Cast(DeliveryBackOffice.dbo.fn_get_document_image_url(@Guide_Serie + CAST(@Guide_Number AS VARCHAR)) as VARCHAR(300))),
						--ISNULL('https://tracking.forzadelivery.com/DocImages/GT.DELIVERYZ12/Copia1/V291/17088433.jpg',
						(
							SELECT TOP 1
							IIF([dp].[Path_Dry] = '', dp.Path_Dry,ISNULL([Path_Dry], [Path_Dry]))
								FROM [DeliveryBackOffice].[dbo].[DeliveryProof] dp WITH (NOLOCK)
									INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
										ON da.Guide_Serie = dp.Guide_Serie
											AND da.Guide_Number = dp.Guide_Number
								WHERE da.Guide_Serie = @Guide_Serie 
										AND da.Guide_Number = @Guide_Number
										AND da.Delivered = 1 order By dp.Date_Photo desc)
						)
			ELSE '' 
			END AS [Dry],
            (
                SELECT TOP 1
                       IIF([dp].[Path_Cold] = '', dp.Path_Cold, ISNULL([Path_Cold], [Path_Cold]))
                FROM [DeliveryBackOffice].[dbo].[DeliveryProof] dp WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
                        ON da.Guide_Serie = dp.Guide_Serie
                           AND da.Guide_Number = dp.Guide_Number
                WHERE dp.Guide_Serie = @Guide_Serie 
                    AND dp.Guide_Number = @Guide_Number
                    AND da.Verified = 1
                    AND da.Accepted = 1
                ORDER BY dp.Date_Photo DESC
            ) AS [Cold],
            '' AS NameOfReceiver,
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
                        AND dt.Delivered = 0
						AND (cfo.IsDenied = 0 or cfo.IsDenied IS NULL ))

				ELSE '' END) AS Latitude,
               (CASE WHEN dod.StatusOrderId = 5 THEN @GuideDeliveryLongitude 
				  WHEN dod.StatusOrderId = @StatusIncidentValidated THEN 
				  --(SELECT TOP 1 Longitude FROM DeliveryAttempt WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number) 
						(SELECT TOP 1 Longitude FROM DeliveryAttempt dt WITH (NOLOCK)
						INNER JOIN ConfirmationOfIncidence cfo WITH (NOLOCK)
							ON dt.ConfirmationOfIncidenceId = cfo.IdConfirmationOfIncidence
						WHERE  dod.Guide_Serie = @Guide_Serie 
						AND dod.Guide_Number = @Guide_Number
                        AND dt.Delivered = 0
                        AND dod.DeliveryAttemptId = dt.ID
						AND ISNULL(cfo.IsDenied,0) = 0)
			
				ELSE '' END) AS Longitude,
            --'' AS Latitude,
            --'' AS Longitude,
            dod.UserCreated Token,
            '' AS NextSteps,
			(CASE
                    WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
							(  SELECT TOP 1
								(prs.PerFirstName+' '+prs.PerLastName) FROM Person prs
									INNER JOIN RegisterUser usr
										ON prs.PerIdPerson = usr.UsrIdPerson
									INNER JOIN TokenLog tkl
										ON usr.UsrIdUser = tkl.TknIdUser
									WHERE dod.Guide_Serie = @Guide_Serie
										  AND dod.Guide_Number = @Guide_Number
										  AND dod.UserCreated = CONVERT(VARCHAR(50), tkl.TknIdToken))

					WHEN dod.StatusOrderId = @StatusIncident  THEN
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
            INNER JOIN [dbo].[CatCheckpointType] CCT
                ON [so].[CatCheckpointTypeId] = [CCT].[IdCatCheckpointType]
            LEFT  JOIN [dbo].[DeliveryAttempt] da WITH(NOLOCK)
			    ON   da.ID=dod.DeliveryAttemptId
			LEFT JOIN [dbo].[ConfirmationOfIncidence] COI WITH(NOLOCK) 
			    ON da.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
        WHERE dod.Guide_Serie = @Guide_Serie
              AND dod.Guide_Number = @Guide_Number
        --ORDER BY DateCreated
        GROUP BY CONVERT(DATE, dod.DateCreated),
                 dod.Guide_Serie,
                 dod.Guide_Number,
                 dod.StatusOrderId,
                 dod.UserCreated,
                 dod.Observations,
                 so.OrderDescription,
                 [CCT].[CheckpointIcon],
				 dod.DeliveryAttemptId,
                 COI.ValidGeolocationEvidence,
				 COI.IsConfirmed,
				 COI.IsDenied,
				 COI.ValidPhotographicEvidence,
				 COI.CommentOnIncident
    ) RES
    ORDER BY RES.[StageDate] DESC,
             RES.[EventID];


    SELECT DISTINCT
           OrdChkPnt.[EventID],
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
		   OrdChkPnt.ClasificationIncident,
		   OrdChkPnt.[CommentOnIncident],
           ISNULL(
                     '[ '
                     + DeliveryBackOffice.dbo.[CapitalizeFirstLetter](ISNULL(epl.FirstName, '') + ' '
                                                                      + ISNULL(epl.LastName1, '')
                                                                     ) + ' ]' + --[who],
                     ' ' + '[ ' +
                     (
                         SELECT TOP (1)
                                CS.StationName
                         FROM DeliveryBackOffice.dbo.CatStation CS WITH (NOLOCK)
                             INNER JOIN DeliveryBackOffice.dbo.RolByUserBySystem RBUBS WITH (NOLOCK)
                                 ON CS.IdStation = RBUBS.StationId
                                    AND CS.RowStatus = 1
                         WHERE IU.RegisterUserID = RBUBS.RusIdUser
                         ORDER BY CS.IdStation DESC
                     ) + ' ]' + --[Where]
                     '', --[Complement] 
                     ''
                 ) + '' + ISNULL(OrdChkPnt.StageDescription, '') AS [StageDescription],
           OrdChkPnt.[CheckpointIcon],
           OrdChkPnt.[ImagePath],
           OrdChkPnt.[Dry],
           OrdChkPnt.[Cold],
           OrdChkPnt.[NameOfReceiver],
           OrdChkPnt.[Place],
           OrdChkPnt.[ManifestNumber],
           OrdChkPnt.[Latitude],
           OrdChkPnt.[Longitude], --,
           OrdChkPnt.NextSteps,
		   OrdChkPnt.UserIncident
           ,OrdChkPnt.ValidGeolocationEvidence
		   ,OrdChkPnt.ValidPhotographicEvidence
    FROM #OrdChkpnt OrdChkPnt
        LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken token WITH (NOLOCK)
            ON OrdChkPnt.Token = token.SSN_IdToken
        LEFT JOIN DenariusUser_Dev.dbo.LGN_User duser WITH (NOLOCK)
            ON duser.USR_IdUser = token.SSN_IdUser
               AND duser.USR_Username = token.SSN_Username
        LEFT JOIN DenariusDesktop_Dev.dbo.LGT_INF_Employee epl WITH (NOLOCK)
            ON epl.IdEmployee = duser.USR_IdEmployee
        LEFT JOIN DeliveryBackOffice.dbo.InternalUser IU WITH (NOLOCK)
            ON epl.CodeEmployee = IU.IdUser
    ORDER BY OrdChkPnt.[StageDate] DESC,
             OrdChkPnt.[EventID];

END;



