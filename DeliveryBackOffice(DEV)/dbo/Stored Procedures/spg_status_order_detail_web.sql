
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
CREATE PROCEDURE [dbo].[spg_status_order_detail_web]
    @Guide_Serie NVARCHAR(2),
    @Guide_Number BIGINT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

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
		   RES.[CheckpointIcon],
           RES.[ImagePath],
		   RES.[Dry],
		   RES.[Cold],
           RES.[NameOfReceiver],
           RES.[Place],
           RES.[ManifestNumber],
           RES.[Latitude],
           RES.[Longitude],
		   RES.Token
		    ,RES.NextSteps
	INTO #OrdChkpnt
    FROM
    (
		SELECT 0 [EventID],
			do.Guide_Serie  + CAST(do.Guide_Number AS NVARCHAR) AS [OrderId],
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
			ISNULL(da.Latitude,'')  [Latitude],
			ISNULL(da.Longitude,'') [Longitude],
			'' [Token]
			,'' NextSteps
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
            (CASE
                 WHEN dod.StatusOrderId IN ( 6, 8 ) THEN
                     ISNULL(dod.Observations, '')
                 WHEN dod.StatusOrderId IN ( 12, 45 ) THEN
                     ISNULL(
                     (
                         SELECT TOP 1
								   (SELECT '[ ' + 
											DeliveryBackOffice.dbo.[CapitalizeFirstLetter](LOWER(courier.First_Name) + ' '+LOWER(courier.Last_Name)) +
											' ]'
											+ ' ' +
											'[ ' + [HL].[HubAbbreviation] + ' ]'
								   FROM dbo.SenderReceiver courier 
								   INNER JOIN [dbo].[HubLogistics] HL
									ON [courier].[HubLogisticId] = [HL].[IdHubLogistic]
								   WHERE courier.ID = da.ID_Courier) + ' ' + 
								   --I.DescriptionIncidence  + ' ' + ISNULL(dod.Observations,'')
								   ISNULL(dod.Observations,'')
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
					ISNULL(dod.Observations, 
						ISNULL((SELECT  '[ ' + [P].[PerFirstName] + ' ' + [P].[PerLastName] +' ]' + ' ' +
									'[ ' + [CS].[StationName] +' ]' 
							FROM	[dbo].[TokenLog] TL
							INNER JOIN [RegisterUser] RU
								ON [TL].[TknIdUser] = [RU].[UsrIdUser]
							INNER JOIN [dbo].[Person] P
								ON [RU].[UsrIdPerson] = [PerIdPerson]
							INNER JOIN [dbo].[RolByUserBySystem] RUS
								ON [TL].[TknIdSystem] = [RUS].[RusIdSystem]
								AND [RU].[UsrIdUser] = [RUS].[RusIdUser]
							INNER JOIN [dbo].[CatStation] CS
								ON	[RUS].[StationId] = [CS].[IdStation]
							WHERE	[TL].[TknIdToken] = [DOD].[UserCreated]
						), '')
					)
             END
            ) AS [StageDescription],
			ISNULL([CCT].[CheckpointIcon], '') AS [CheckpointIcon],
            (CASE ROW_NUMBER() OVER (ORDER BY CONVERT(DATE, dod.DateCreated) ASC)
                 WHEN 1 THEN
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

			(SELECT TOP 1
			IIF([dp].[Path_Dry] = '', dp.Path_Dry,ISNULL([Path_Dry], [Path_Dry]))
                                       FROM [DeliveryBackOffice].[dbo].[DeliveryProof] dp WITH (NOLOCK)
                                         INNER  JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
                                               ON da.Guide_Serie = dp.Guide_Serie
                                                  AND da.Guide_Number = dp.Guide_Number
                                                  AND da.Verified = 1
                                                  AND da.Accepted = 1
                                       WHERE dp.Guide_Serie = 'FD'
                                             AND dp.Guide_Number = @Guide_Number order By dp.Date_Photo desc) AS [Dry],

			(SELECT TOP 1
			IIF([dp].[Path_Cold] = '', dp.Path_Cold,ISNULL([Path_Cold], [Path_Cold]))
                                       FROM [DeliveryBackOffice].[dbo].[DeliveryProof] dp WITH (NOLOCK)
                                          INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
                                               ON da.Guide_Serie = dp.Guide_Serie
                                                  AND da.Guide_Number = dp.Guide_Number
                                                  AND da.Verified = 1
                                                  AND da.Accepted = 1
                                       WHERE dp.Guide_Serie = 'FD'
                                             AND dp.Guide_Number = @Guide_Number order By dp.Date_Photo desc) AS [Cold],

            '' AS NameOfReceiver,
            '' AS Place,
            '' AS [ManifestNumber],
            '' AS Latitude,
            '' AS Longitude,
			dod.UserCreated Token
			,'' AS NextSteps
        FROM dbo.DeliveryOrderDetail dod WITH (NOLOCK)
           INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
                ON so.StatusOrderId = dod.StatusOrderId
			INNER JOIN [dbo].[CatCheckpointType] CCT
				ON [so].[CatCheckpointTypeId] = [CCT].[IdCatCheckpointType]
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
				 [CCT].[CheckpointIcon]
    ) RES
    ORDER BY RES.[StageDate] DESC,
             RES.[EventID];


	SELECT DISTINCT OrdChkPnt.[EventID],
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
			   ISNULL(
		   			'[ ' + DeliveryBackOffice.dbo.[CapitalizeFirstLetter](ISNULL(epl.FirstName,'') + ' ' + ISNULL(epl.LastName1,'')) + ' ]' + --[who],
					' ' +
					'[ ' + (SELECT TOP (1) CS.StationName
							FROM DeliveryBackOffice.dbo.CatStation CS WITH (NOLOCK)
								INNER JOIN DeliveryBackOffice.dbo.RolByUserBySystem RBUBS WITH(NOLOCK)
								ON
									CS.IdStation = RBUBS.StationId AND CS.RowStatus = 1
							WHERE IU.RegisterUserID = RBUBS.RusIdUser
							ORDER BY CS.IdStation DESC 
							) + ' ]' +--[Where]
					 '' --[Complement] 
					,'') 
			   + '' + ISNULL(OrdChkPnt.StageDescription,'') 
			   AS [StageDescription] ,
			   OrdChkPnt.[CheckpointIcon],
			   OrdChkPnt.[ImagePath],
			   OrdChkPnt.[Dry],
			   OrdChkPnt.[Cold],
			   OrdChkPnt.[NameOfReceiver],
			   OrdChkPnt.[Place],
			   OrdChkPnt.[ManifestNumber],
			   OrdChkPnt.[Latitude],
			   OrdChkPnt.[Longitude]--,
			   ,OrdChkPnt.NextSteps
			   --OrdChkPnt.Token
	FROM #OrdChkpnt OrdChkPnt
		LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken token  WITH (NOLOCK) ON OrdChkPnt.Token = token.SSN_IdToken
		LEFT JOIN DenariusUser_Dev.dbo.LGN_User duser  WITH (NOLOCK) ON duser.USR_IdUser = token.SSN_IdUser AND duser.USR_Username = token.SSN_Username
		LEFT JOIN DenariusDesktop_Dev.dbo.LGT_INF_Employee epl  WITH (NOLOCK) ON epl.IdEmployee = duser.USR_IdEmployee 
		LEFT JOIN DeliveryBackOffice.dbo.InternalUser IU WITH(NOLOCK) ON epl.CodeEmployee = IU.IdUser
	ORDER BY OrdChkPnt.[StageDate] DESC,
			 OrdChkPnt.[EventID];

END;



