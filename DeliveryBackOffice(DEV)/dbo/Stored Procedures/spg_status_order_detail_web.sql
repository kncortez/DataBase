
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
                                    FROM dbo.SenderReceiver courier WITH(NOLOCK)
                                        LEFT JOIN [dbo].[HubLogistics] HL WITH(NOLOCK)
                                            ON [courier].[HubLogisticId] = [HL].[IdHubLogistic]
                                    WHERE courier.ID = da.ID_Courier
                                ) + ' ' +
                             --I.DescriptionIncidence  + ' ' + ISNULL(dod.Observations,'')
                             ISNULL(dod.Observations, '')
                         FROM DeliveryBackOffice.dbo.CatTypeIncidence I WITH(NOLOCK)
                             INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH(NOLOCK)
                                 ON da.ID_Incident = I.IdIncidenceType
                         WHERE dod.Guide_Serie = da.Guide_Serie
                               AND dod.Guide_Number = da.Guide_Number
                         ORDER BY da.Date_Created DESC
                     ),
                     ''
                           )
				WHEN dod.StatusOrderId = @StatusIncident THEN
						(SELECT TOP 1 cti.NameIncidence FROM DeliveryAttempt dla   WITH(NOLOCK)
						INNER JOIN CatTypeIncidence cti WITH(NOLOCK)
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
                                   FROM [dbo].[TokenLog] TL WITH(NOLOCK)
                                       INNER JOIN [RegisterUser] RU WITH(NOLOCK)
                                           ON [TL].[TknIdUser] = [RU].[UsrIdUser]
                                       INNER JOIN [dbo].[Person] P WITH(NOLOCK)
                                           ON [RU].[UsrIdPerson] = [PerIdPerson]
                                       INNER JOIN [dbo].[RolByUserBySystem] RUS WITH(NOLOCK)
                                           ON [TL].[TknIdSystem] = [RUS].[RusIdSystem]
                                              AND [RU].[UsrIdUser] = [RUS].[RusIdUser]
                                       INNER JOIN [dbo].[CatStation] CS WITH(NOLOCK)
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
                                                  AND da.Verified = 1
                                                  AND da.Accepted = 1
                                       WHERE dp.Guide_Serie = @Guide_Serie 
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
						(SELECT TOP 1
                            dlp.Path_Incident
							FROM dbo.DeliveryAttempt datt WITH(NOLOCK)
                         INNER JOIN dbo.DeliveryProof dlp WITH(NOLOCK)
                             ON datt.ID_Proof = dlp.ID
							WHERE dod.Guide_Serie = @Guide_Serie
                          AND dod.Guide_Number = @Guide_Number
                          AND dod.DeliveryAttemptId = datt.ID)
                 ELSE
                     ''
             END
            ) AS [ImagePath],
            CASE WHEN dod.StatusOrderId = 5 THEN 
                --'http://develop.apicore.forzadelivery.io/Comprobantes/Comprobante_FD9561473.jpg',
                ''
            ELSE NULL
            END AS [digitalProofDelivery],
             (CASE WHEN dod.StatusOrderId = 5 THEN 
				(SELECT TOP 1
					IIF([dp].[Path_Dry] = '', dp.Path_Dry,ISNULL([Path_Dry], [Path_Dry]))
						FROM [DeliveryBackOffice].[dbo].[DeliveryProof] dp WITH (NOLOCK)
							INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
								ON da.Guide_Serie = dp.Guide_Serie
									AND da.Guide_Number = dp.Guide_Number
						WHERE da.Guide_Serie = @Guide_Serie 
								AND da.Guide_Number = @Guide_Number
                                AND da.Delivered = 1 order By dp.Date_Photo desc)
			ELSE '' END) AS [Dry],
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
								(prs.PerFirstName+' '+prs.PerLastName) FROM Person prs WITH(NOLOCK)
									INNER JOIN RegisterUser usr WITH(NOLOCK)
										ON prs.PerIdPerson = usr.UsrIdPerson
									INNER JOIN TokenLog tkl WITH(NOLOCK)
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
											WHERE  dod.Guide_Number = @Guide_Number  AND dod.Guide_Serie = @Guide_Serie  AND dat.ID = dod.DeliveryAttemptId)
									
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
            INNER JOIN [dbo].[CatCheckpointType] CCT WITH(NOLOCK)
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
                                   
                         WHERE IU.RegisterUserID = RBUBS.RusIdUser  AND CS.RowStatus = 1
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