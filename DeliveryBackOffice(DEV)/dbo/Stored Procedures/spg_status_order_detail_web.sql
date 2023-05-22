
-- =============================================
-- Author:		<Carlos,Cano>
-- Create date: <13/06/2020>
-- Description:	<Detalle de rastreo en pagina web tracking para el cliente>
-- =============================================
-- Updates
-- Author:		<Jerson Ochoa>
-- Date:		<21-02-2023>
-- Description: <Management for checkpoint icons>
-- Date:		<28-03-2023>
-- Description: <Add Username and station for each registered checkpoint>
-- Date:		<24-04-2023>
-- Description: <Show coordinates, pictures and incidence description>
-- Date:		<09-05-2023>
-- Description: <Show coordinates, pictures and incidence description by DeliveryAttemptId>
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
		   RES.[Token],
		   RES.[NextSteps], 
		   RES.[IncidenceDescription]
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
			'' [Token],
			'' NextSteps,
			'' IncidenceDescription
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
                 WHEN dod.StatusOrderId IN ( 6, 8 ) THEN -- 6 Retornado al origen | 8 Paquete Retornado para Reproceso
                     ISNULL(dod.Observations, '')
                 WHEN dod.StatusOrderId IN ( 12, 45 ) THEN -- 12 Intento de entrega fallida | 45 Incidencia en ruta
                     ISNULL(
						 (
							(
								CASE
									WHEN [SR].[ID] IS NOT NULL THEN '[ ' + 
									DeliveryBackOffice.dbo.[CapitalizeFirstLetter](LOWER([SR].First_Name) + ' '+LOWER([SR].Last_Name)) +
									' ]'
									ELSE ''
								END
							)
									+ ' ' +
									(
										CASE 
											WHEN [HL].[HubAbbreviation] IS NOT NULL THEN ( '[ ' + [HL].[HubAbbreviation] + ' ]' )
											ELSE ''
										END
									)
							+ ' ' + 
							ISNULL(dod.Observations,'')
                     ),
                     ''
                )
                 WHEN dod.StatusOrderId IN ( 15 ) THEN -- 15 Generado
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
            (
                ISNULL(	
					ISNULL(
							
											
											
									ISNULL
									(
										[DP].[Path_Dry]
										,[DP].[Path_Incident]
									)
									,
									(CAST(DeliveryBackOffice.dbo.fn_get_document_image_url(dod.Guide_Serie + CAST(dod.Guide_Number AS VARCHAR) ) AS VARCHAR(300))
											)
							), 
					''
				)
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
                                             AND dp.Guide_Number = @Guide_Number ORDER BY dp.Date_Photo DESC) AS [Dry],

			(SELECT TOP 1
			IIF([dp].[Path_Cold] = '', dp.Path_Cold,ISNULL([Path_Cold], [Path_Cold]))
                                       FROM [DeliveryBackOffice].[dbo].[DeliveryProof] dp WITH (NOLOCK)
                                          INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
                                               ON da.Guide_Serie = dp.Guide_Serie
                                                  AND da.Guide_Number = dp.Guide_Number
                                                  AND da.Verified = 1
                                                  AND da.Accepted = 1
                                       WHERE dp.Guide_Serie = 'FD'
                                             AND dp.Guide_Number = @Guide_Number ORDER BY dp.Date_Photo DESC) AS [Cold],

            '' AS NameOfReceiver,
            '' AS Place,
            '' AS [ManifestNumber],
            [DA].[Latitude] AS Latitude,
            [DA].[Longitude] AS Longitude,
			dod.UserCreated Token,
			'' AS NextSteps,
			ISNULL([CTI].[NameIncidence], '') AS [IncidenceDescription]
        FROM dbo.DeliveryOrderDetail dod WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
			ON so.StatusOrderId = dod.StatusOrderId
		INNER JOIN [dbo].[CatCheckpointType] CCT  WITH(NOLOCK)	
			ON [so].[CatCheckpointTypeId] = [CCT].[IdCatCheckpointType]
		LEFT JOIN [dbo].[DeliveryAttempt] DA  WITH(NOLOCK) 
			ON [DOD].[DeliveryAttemptId] = [DA].[ID]
		LEFT JOIN [dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) 
			ON [DA].[ID_Incident] = [CTI].[IdIncidenceType]
		LEFT JOIN [dbo].[DeliveryProof] DP  WITH(NOLOCK) 
			ON [DP].[ID] = [DA].[ID_Proof]
		LEFT JOIN [dbo].[SenderReceiver] SR  WITH(NOLOCK) 
			ON [DA].[ID_Courier] = [SR].[ID]
		LEFT JOIN [dbo].[HubLogistics] HL
			ON [SR].[HubLogisticId] = [HL].[IdHubLogistic]
        WHERE dod.Guide_Serie = @Guide_Serie
            AND dod.Guide_Number = @Guide_Number
        GROUP BY CONVERT(DATE, dod.DateCreated),
                 dod.Guide_Serie,
                 dod.Guide_Number,
                 dod.StatusOrderId,
                 dod.UserCreated,
                 dod.Observations,
				 dod.DateCreated,
				 [DA].[Latitude],
				 [DA].[Longitude],
                 so.OrderDescription,
				 [CCT].[CheckpointIcon],
				 [DOD].[DeliveryAttemptId],
				 [CTI].[NameIncidence],
				 [DP].[Path_Dry],
				 [DP].[Path_Cold],
				 [DP].[Path_Incident],
				 [SR].[ID],
				 [SR].First_Name,
				 [SR].[Last_Name],
				 [HL].[HubAbbreviation]
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
			   OrdChkPnt.[Longitude],
			   OrdChkPnt.NextSteps,
			   OrdChkPnt.IncidenceDescription
			   --OrdChkPnt.Token
	FROM #OrdChkpnt OrdChkPnt
		LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken token  WITH (NOLOCK) ON OrdChkPnt.Token = token.SSN_IdToken
		LEFT JOIN DenariusUser_Dev.dbo.LGN_User duser  WITH (NOLOCK) ON duser.USR_IdUser = token.SSN_IdUser AND duser.USR_Username = token.SSN_Username
		LEFT JOIN DenariusDesktop_Dev.dbo.LGT_INF_Employee epl  WITH (NOLOCK) ON epl.IdEmployee = duser.USR_IdEmployee 
		LEFT JOIN DeliveryBackOffice.dbo.InternalUser IU WITH(NOLOCK) ON epl.CodeEmployee = IU.IdUser
	ORDER BY OrdChkPnt.[StageDate] DESC,
			 OrdChkPnt.[EventID];

END;



