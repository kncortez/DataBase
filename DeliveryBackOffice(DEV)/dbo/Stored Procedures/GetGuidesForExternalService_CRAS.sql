-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-12-27>
-- Description:	< Recupera datos de guías para ingresar a una plataforma externa, las cuales no han sido procesadas para ingreso a Simpliroute de forma automatizada. Adicional intenta tomar guías indiscriminadamente y revisar la información de las mismas, corrigiendo: Hubs. >
-- =============================================
CREATE PROCEDURE [dbo].[GetGuidesForExternalService_CRAS]
	@Date DATETIME = NULL,
	@Hub NVARCHAR(5) = 'GUA',
	@Municipalidad NVARCHAR(50) = 'Guatemala',
	@Departamento NVARCHAR(50) = 'Guatemala',
	@Status INT = 11
AS
BEGIN

	IF (@Date IS NULL)
	BEGIN
		SET @Date = DATEADD( MINUTE, -31, GETDATE() )
	END
	ELSE
	BEGIN
		SET @Date = DATEADD( MINUTE, -31, @Date)
	END

	DECLARE @ReviewGuideDate DATETIME = DATEADD(MINUTE, -61, GETDATE())

	DECLARE @jsonResult NVARCHAR(MAX)

	-- Limpieza de servicios que estan siendo procesados
	DECLARE @AcceptedGuides TblGuides;

	-- Manejo de transaccion
	DECLARE @CanComplete BIT = 0;

	BEGIN TRANSACTION
	BEGIN TRY
		
		--PRINT '@CanComplete INICIA'

		-- Liberar intentos viejos de traslado de guías
		UPDATE EPSL
		SET RowStatus = 0,
			TokenUpdated = 'SYS-HERMESROUTES',
			DateUpdated = GETDATE()
		FROM [DeliveryBackOffice].[dbo].[ExternalPlatformServiceLog] EPSL
		WHERE EPSL.DateCreated <= @Date
		AND EPSL.RowStatus = 1
		AND CAST(EPSL.DateCreated AS DATE) = CAST(@Date AS DATE);
		
		--PRINT '@CanComplete PRIMER UPDATE'

		-- Bloquear guías para manejo de concurrencia
		INSERT INTO [DeliveryBackOffice].[dbo].[ExternalPlatformServiceLog]
			(ExternalPlatformId, GuideSerie, GuideNumber, RowStatus, TokenCreated, DateCreated)
		OUTPUT inserted.GuideSerie, inserted.GuideNumber INTO @AcceptedGuides(Guide_Serie, Guide_Number)
		SELECT DISTINCT
			2, DOR.Guide_Serie, DOR.Guide_Number, 1, 'SYS-HERMESROUTES', GETDATE()
		FROM
			DeliveryBackOffice.dbo.DeliveryOrder DOR WITH(NOLOCK)
			JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH(NOLOCK)
				ON DOR.Guide_Serie = DOD.Guide_Serie
				AND DOR.Guide_Number = DOD.Guide_Number
				AND DOD.StatusOrderId = @Status
				AND DOD.DateCreatedInSystem >= @Date
			LEFT JOIN [DeliveryBackOffice].[dbo].[ExternalPlatformServiceLog] EPSL
				ON 
				DOR.Guide_Serie = EPSL.GuideSerie
				AND
				DOR.Guide_Number = EPSL.GuideNumber
				AND 
				EPSL.RowStatus = 1
				AND
				CAST(EPSL.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
			WHERE
				DOR.Receiver_Department = @Departamento
				AND
				DOR.StatusOrderId = @Status
				AND
				DOR.Guide_Number NOT IN ( 
						SELECT
							EXPSRG.GuideNumber
						FROM 
							DeliveryBackOffice.dbo.ExtPlatServiceRelationshipWithGuide EXPSRG
						JOIN
							DeliveryBackOffice.dbo.ExtPlatformService EPS ON EXPSRG.ExtPlatServiceId = EPS.IdExtPlatformService
						WHERE
							EPS.IsDelivery = 1
							AND
							CAST(EPS.DateCreated AS DATE) = CAST(@Date AS DATE)
					)
				AND
				EPSL.IdExternalPlatformServiceLog IS NULL

		CREATE TABLE #ReviewDeliveryOrderData (
			GuideSerie NVARCHAR(2),
			GuideNumber INT,
			GuideReviewedHubOrigin INT,
			GuideReviewedSenderAddress NVARCHAR(300),
			GuideReviewedHubDestiny INT,
			GuideReviewedReceiverAddress NVARCHAR(300)
		)

		--PRINT '@CanComplete PRIMER INSERT'

		create nonclustered index tempreview on #ReviewDeliveryOrderData (GuideSerie, GuideNumber)

		--PRINT '@CanComplete create nonclustered'

		

		INSERT INTO #ReviewDeliveryOrderData
		SELECT
			DO.Guide_Serie
			,DO.Guide_Number
			,(SELECT TOP 1 HL.IdHubLogistic FROM DeliveryBackOffice.dbo.HubLogistics HL WHERE HL.HubAbbreviation = dbo.FnReviewServiceTargetHub(DO.Guide_Serie, DO.Guide_Number, 2)) -- Origen
			,CONVERT(NVARCHAR(200),dbo.FnFixAddressExternalPlatformService(DO.Sender_Address,DO.Sender_Department,DO.Sender_Town))
			,(SELECT TOP 1 HL.IdHubLogistic FROM DeliveryBackOffice.dbo.HubLogistics HL WHERE HL.HubAbbreviation = dbo.FnReviewServiceTargetHub(DO.Guide_Serie, DO.Guide_Number, 1)) -- Destino
			,CONVERT(NVARCHAR(200),dbo.FnFixAddressExternalPlatformService(DO.Receiver_Address,DO.Receiver_Department, DO.Receiver_Town))
		FROM
			DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
			WHERE
				DO.DateCreated >= @ReviewGuideDate
		UNION
		SELECT
			DO.Guide_Serie
			,DO.Guide_Number
			,(SELECT TOP 1 HL.IdHubLogistic FROM DeliveryBackOffice.dbo.HubLogistics HL WHERE HL.HubAbbreviation = dbo.FnReviewServiceTargetHub(DO.Guide_Serie, DO.Guide_Number, 2)) -- Origen
			,CONVERT(NVARCHAR(200),dbo.FnFixAddressExternalPlatformService(DO.Sender_Address,DO.Sender_Department,DO.Sender_Town))
			,(SELECT TOP 1 HL.IdHubLogistic FROM DeliveryBackOffice.dbo.HubLogistics HL WHERE HL.HubAbbreviation = dbo.FnReviewServiceTargetHub(DO.Guide_Serie, DO.Guide_Number, 1)) -- Destino
			,CONVERT(NVARCHAR(200),dbo.FnFixAddressExternalPlatformService(DO.Receiver_Address,DO.Receiver_Department, DO.Receiver_Town))
		FROM
			DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
			JOIN
				@AcceptedGuides AG
				ON 
				DO.Guide_Serie = AG.Guide_Serie
				AND
				DO.Guide_Number = AG.Guide_Number

		PRINT '@CanComplete Inserta temporal #ReviewDeliveryOrderData'

		UPDATE DO
		SET
			DO.HubOriginId = CDOD.GuideReviewedHubOrigin
			,DO.Sender_Address = CDOD.GuideReviewedSenderAddress
			,DO.HubDestinationId = CDOD.GuideReviewedHubDestiny
			,DO.Receiver_Address = CDOD.GuideReviewedReceiverAddress
		FROM
			DeliveryBackOffice.dbo.DeliveryOrder DO
			JOIN
			#ReviewDeliveryOrderData CDOD
			ON 
				DO.Guide_Serie = CDOD.GuideSerie
				AND
				DO.Guide_Number = CDOD.GuideNumber

		PRINT '@CanComplete Actualiza HUBS Y DIRECCIONES'

		IF OBJECT_ID('tempdb.dbo.#ReviewDeliveryOrderData', 'U') IS NOT NULL DROP TABLE #ReviewDeliveryOrderData;
		PRINT 'construyend json'
		set @jsonResult = (SELECT STUFF(( 
							SELECT DISTINCT REPLACE(
								',{' +
								+ '"title"' + ':' + '"' + CAST(CONCAT (DOR.Guide_Serie, DOR.Guide_Number,' ', LTRIM(RTRIM(CONCAT( DOR.Receiver_FirstName , ' ', ISNULL(DOR.Receiver_LastName,'')))) ) AS NVARCHAR) + '"' + ','
								+ '"address"' + ':' + '"' + REPLACE(REPLACE(dbo.fn_ReplaceSpecialCharsForJSON(DOR.Receiver_Address),CHAR(13),''),CHAR(10),'') + '"' + ','
								+ '"planned_date"' + ':' + '"' + CONVERT(VARCHAR, GETDATE(), 23) + '"' + ','
								+ (
									CASE 
										WHEN ISNULL(LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(SSHL.Latitude))),'') <> '' AND ISNULL(LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(SSHL.Longitude))),'') <> ''  THEN
											'"latitude"' + ':' + LTRIM(RTRIM(SSHL.Latitude))+ ',' +
											+ '"longitude"' + ':' + LTRIM(RTRIM(SSHL.Longitude))  + ',' 
										WHEN ISNULL(LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(EXC.Latitude))),'') <> '' AND ISNULL(LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(EXC.Longitude))),'') <> '' THEN
											'"latitude"' + ':' + LTRIM(RTRIM(EXC.Latitude)) + ',' +
											+ '"longitude"' + ':' + LTRIM(RTRIM(EXC.Longitude)) + ',' 
										/*WHEN ISNULL(LTRIM(RTRIM(VPC.Latitude)),'') <> '' AND ISNULL(LTRIM(RTRIM(VPC.Longitude)),'') <> '' THEN
											'"latitude"' + ':' + CAST(CAST(LTRIM(RTRIM(VPC.Latitude)) AS DECIMAL(9,6)) AS NVARCHAR) + ',' +
											+ '"longitude"' + ':' + CAST(CAST(LTRIM(RTRIM(VPC.Longitude)) AS DECIMAL(9,6)) AS NVARCHAR) + ',' */
										WHEN ISNULL(SDFG.Latitude, 0) <> 0 AND ISNULL(SDFG.Longitude, 0) <> 0 THEN
											'"latitude"' + ':' + CAST(SDFG.Latitude AS NVARCHAR) + ',' +
											+ '"longitude"' + ':' + CAST(SDFG.Longitude AS NVARCHAR) + ',' 
										ELSE
											''
									END
								  ) + 
								+ '"contact_name"' + ':' + '"' + LTRIM(RTRIM(CONCAT( DOR.Receiver_FirstName , ' ', ISNULL(DOR.Receiver_LastName,'')))) + '"' + ','
								+ '"skills_required"' + ':' + '[' + '"' + MAX(HL.HubAbbreviation) + '"' + ']' + ','
								+ '"skills_optional"' + ':' + '[' + IIF(DOR.Package_Type = 2, '"Sobre"','' ) + ']' + ','
								+ '"load"' + ':' + CAST( IIF(DOR.Package_Type = 2, 0, ( SUM( ISNULL(DOP.PieceHeight,30) * ISNULL(DOP.PieceLength,10) * ISNULL(DOP.PieceWidth,20) ) / 1000000 ) ) AS NVARCHAR) + ','
								+ IIF(DOR.Package_Type = 2, CONCAT('"load_2":', DOR.Pieces_Dry, ','), '')
								+ ( -- 1 = Domingo | 7 = Sabado 
									CASE
										WHEN DATEPART( DW, GETDATE() ) = 7 THEN (
																					CASE 
																						WHEN SDFG.StartTime IS NOT NULL THEN
																							+ '"window_start"' + ':' + '"' + CONVERT(NVARCHAR, SDFG.StartTime, 108) + '"' + ','
																							+ '"window_end"' + ':' + '"' + CONVERT(NVARCHAR, SDFG.EndTime, 108) + '"' +  ','
																						WHEN DOR.TypeService = 'SDD' THEN 
																							+ '"window_start"' + ':' + '"08:00"' + ','
																							+ '"window_end"' + ':' + '"21:00"' + ','
																						WHEN ISNULL(DOR.IdDeliveryOption,0)=3 THEN 
																							+ '"window_start"' + ':' + '"08:00"' + ','
																							+ '"window_end"' + ':' + '"13:00"' + ','
																						ELSE
																							+ '"window_start"' + ':' + '"08:00"' + ','
																							+ '"window_end"' + ':' + '"18:00"' + ','
																					END
																				)
										ELSE (
												CASE 
													WHEN SDFG.StartTime IS NOT NULL THEN
														+ '"window_start"' + ':' + '"' + CONVERT(NVARCHAR, SDFG.StartTime, 108) + '"' + ','
														+ '"window_end"' + ':' + '"' + CONVERT(NVARCHAR, SDFG.EndTime, 108) + '"' +  ','
													WHEN DOR.TypeService = 'SDD' THEN 
														+ '"window_start"' + ':' + '"08:00"' + ','
														+ '"window_end"' + ':' + '"21:00"' + ','
													WHEN ISNULL(DOR.IdDeliveryOption,0) = 3 THEN 
														+ '"window_start"' + ':' + '"08:00"' + ','
														+ '"window_end"' + ':' + '"17:00"' + ','
													ELSE
														+ '"window_start"' + ':' + '"08:00"' + ','
														+ '"window_end"' + ':' + '"18:00"' + ','
												END
											)
									END
								) +
								+ IIF(SDFG.StartTime2 IS NOT NULL, '"window_start_2"' + ':' + '"' + CONVERT(NVARCHAR, SDFG.StartTime2, 108) + '"' + ','
														+ '"window_end_2"' + ':' + '"' + CONVERT(NVARCHAR, SDFG.EndTime2, 108) + '"' +  ',', '') +
								+ (
									CASE
										WHEN DOR.TypeService = 'SDD' THEN -- SDD
											+ '"priority_level"' + ':' + '3' + ','
										WHEN DOR.TypeService = 'TDA' THEN -- TDA
											+ '"priority_level"' + ':' + '5' + ','
										ELSE
											+ '"priority_level"' + ':' + '4' + ','
									END
								) 
								+ '"duration"' + ':' + '"00:10:00"' + ','
								+ '"reference"' + ':' + '"' + CONCAT (DOR.Guide_Serie, DOR.Guide_Number) + '"' + ','
								+ '"notes"' + ':' + '"' + 'Dirección: ' + REPLACE(REPLACE(dbo.fn_ReplaceSpecialCharsForJSON(DOR.Receiver_Address),CHAR(13),''),CHAR(10),'') + CHAR(13) + CHAR(10) +
								+ IIF(ISNULL(DOR.IndicationsToSendDestination,'') <> '', 'Instrucciones adicionales: ' + LTRIM(RTRIM(dbo.fn_ReplaceSpecialCharsForJSON(ISNULL(DOR.IndicationsToSendDestination,'')))), '') + '"' + ','
								+ (
									CASE
										WHEN DOR.Sender_ID IN (SELECT CodeOfReference FROM DeliveryBackOffice.dbo.VisitPointClient WHERE CustomerID = 1) THEN
											'"extra_field_values"' + ':' + '{' +
												+ '"AlternantName"' + ':' + '"' + LTRIM(RTRIM(ISNULL(DOR.Receiver_Alternant_FullName,''))) + '"' + ','
												+ '"TotalDryPieces"' + ':' + CAST(DOR.Pieces_Dry AS NVARCHAR) + ','
												+ '"TotalColdPieces"'  + ':' + CAST(DOR.Pieces_Cold AS NVARCHAR)
											+ '}' + ',' +
											'"visit_type"' + ':' + '"IGSS"' -- Por cambiar si es necesario trasladar esta data a BD | Se reemplaza durante el proceso
										WHEN ISNULL(DOR.IdDeliveryOption,0) = 3 THEN
											'"extra_field_values"' + ':' + '{' +
												+ '"AlternantName"' + ':' + '"' + LTRIM(RTRIM(ISNULL(DOR.Receiver_Alternant_FullName,''))) + '"' + ','
												+ '"TotalDryPieces"' + ':' + CAST(DOR.Pieces_Dry AS NVARCHAR) + ','
												+ '"TotalColdPieces"'  + ':' + CAST(DOR.Pieces_Cold AS NVARCHAR)
											+ '}' + ',' +
											'"visit_type"' + ':' + '"ExpressCenter"' -- Por cambiar si es necesario trasladar esta data a BD | Se reemplaza durante el proceso
										WHEN ISNULL(DOR.IsCollect,0) = 1 THEN
											'"extra_field_values"' + ':' + '{' +
												+ '"AlternantName"' + ':' + '"' + LTRIM(RTRIM(ISNULL(DOR.Receiver_Alternant_FullName,''))) + '"' + ','
												+ '"TotalDryPieces"' + ':' + CAST(DOR.Pieces_Dry AS NVARCHAR) + ','
												+ '"TotalColdPieces"'  + ':' + CAST(DOR.Pieces_Cold AS NVARCHAR) + ','
												+ '"TaxPlayerNumber"' + ':' + '"CF"' + ','
												+ '"TaxPlayerName"' + ':' + '"CONSUMIDOR FINAL"' + ','
												+ '"TaxPlayerAddress"' + ':' + '"' + REPLACE(REPLACE(dbo.fn_ReplaceSpecialCharsForJSON(DOR.Receiver_Address),CHAR(13),''),CHAR(10),'') + '"' + ','
												+ '"TaxPlayerMail"' + ':' + '"' + LTRIM(RTRIM(ISNULL(DOR.Receiver_Email,''))) + '"' + ','
												+ '"TotalCharge"' + ':' + CAST((IIF(ISNULL(DOR.IsCollect,0) = 1,ISNULL(DOR.PriceShippment,0),0) + ISNULL(DOR.Collect_OnDelivery,0)) AS NVARCHAR) + ','
												+ '"ServiceCharge"' + ':' + CAST(IIF(ISNULL(DOR.IsCollect,0) = 1,ISNULL(DOR.PriceShippment,0),0) AS NVARCHAR) + ','
												+ '"CoDCharge"' + ':' + CAST(ISNULL(DOR.Collect_OnDelivery,0) AS NVARCHAR) + ','
												+ '"CollectCoD"' + ':' + (CASE WHEN ISNULL(DOR.Collect_OnDelivery,0) > 0 THEN 'true' ELSE 'false' END)
											+ '}' + ',' +
											'"visit_type"' + ':' + '"ConFacturación"' -- Por cambiar si es necesario trasladar esta data a BD | Se reemplaza durante el proceso
										ELSE
											'"extra_field_values"' + ':' + '{' +
												+ '"AlternantName"' + ':' + '"' + LTRIM(RTRIM(ISNULL(DOR.Receiver_Alternant_FullName,''))) + '"' + ','
												+ '"TotalDryPieces"' + ':' + CAST(DOR.Pieces_Dry AS NVARCHAR) + ','
												+ '"TotalColdPieces"'  + ':' + CAST(DOR.Pieces_Cold AS NVARCHAR) + ','
												+ '"TotalCharge"' + ':' + CAST((IIF(ISNULL(DOR.IsCollect,0) = 1,ISNULL(DOR.PriceShippment,0),0) + ISNULL(DOR.Collect_OnDelivery,0)) AS NVARCHAR) + ','
												+ '"ServiceCharge"' + ':' + CAST(IIF(ISNULL(DOR.IsCollect,0) = 1,ISNULL(DOR.PriceShippment,0),0) AS NVARCHAR) + ','
												+ '"CoDCharge"' + ':' + CAST(ISNULL(DOR.Collect_OnDelivery,0) AS NVARCHAR) + ','
												+ '"CollectCoD"' + ':' + (CASE WHEN ISNULL(DOR.Collect_OnDelivery,0) > 0 THEN 'true' ELSE 'false' END)
											+ '}' + ',' +
											'"visit_type"' + ':' + '"SinFacturación"' -- Por cambiar si es necesario trasladar esta data a BD | Se reemplaza durante el proceso
									END
								  )
								+ '}'
								,CHAR(31),'')
							FROM
								DeliveryBackOffice.dbo.DeliveryOrder DOR WITH(NOLOCK)
								JOIN @AcceptedGuides AG
									ON DOR.Guide_Serie = AG.Guide_Serie
									AND DOR.Guide_Number = AG.Guide_Number
								JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH(NOLOCK)
									ON DOP.GuideSerie = DOR.Guide_Serie
									AND DOP.GuideNumber = DOR.Guide_Number
								JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH(NOLOCK)
									ON DOR.Guide_Serie = DOD.Guide_Serie
									AND DOR.Guide_Number = DOD.Guide_Number
									AND DOD.StatusOrderId = @Status
									AND DOD.DateCreatedInSystem >= @Date
								LEFT JOIN DeliveryBackOffice.dbo.HubLogistics HL
									ON DOR.HubDestinationId = HL.IdHubLogistic
								LEFT JOIN (
									-- Historico de ubicaciones para visitas con identificación de seguridad social
									SELECT DISTINCT
										DO1.Receiver_SocialSecurity_ID,
										DA1.Latitude,
										DA1.Longitude
									FROM
										[DeliveryBackOffice].[dbo].[DeliveryOrder] DO1 WITH(NOLOCK)
										JOIN
										[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA1 WITH(NOLOCK)
										ON DO1.Guide_Number = DA1.Guide_Number
										AND DO1.Guide_Serie = DA1.Guide_Serie
										JOIN (
										SELECT DISTINCT
											DO2.Receiver_SocialSecurity_ID,
											MIN(CAST(DA2.Accuracy AS DECIMAL)) Accuracy
											FROM
											[DeliveryBackOffice].[dbo].[DeliveryOrder] DO2 WITH(NOLOCK)
											JOIN
											[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA2 WITH(NOLOCK)
											ON DO2.Guide_Number = DA2.Guide_Number
											AND DO2.Guide_Serie = DA2.Guide_Serie
											AND DA2.Accuracy IS NOT NULL
											AND RTRIM(DA2.Accuracy) != ''
											WHERE DO2.Receiver_SocialSecurity_ID IS NOT NULL
											AND RTRIM(DO2.Receiver_SocialSecurity_ID) != ''
											GROUP BY DO2.Receiver_SocialSecurity_ID
										) DA2
										ON DO1.Receiver_SocialSecurity_ID = DA2.Receiver_SocialSecurity_ID
										AND DA1.Accuracy = DA2.Accuracy
								) SSHL
									ON DOR.Receiver_SocialSecurity_ID = SSHL.Receiver_SocialSecurity_ID
								LEFT JOIN
									(
										-- TEMPORAL: Puntos de visita los cuales son express center
										SELECT
										DISTINCT
										UPPER(VPC.DescriptionOfClient) 'DescriptionOfClient'
										,VPC.Latitude
										,VPC.Longitude
										FROM
										[DeliveryBackOffice].[dbo].[VisitPointClient] VPC
										JOIN
										(
											SELECT
											UPPER(VPC2.DescriptionOfClient) 'DescriptionOfClient'
											,MIN(CAST(VPC2.Accuracy AS DECIMAL)) 'Accuracy'
											FROM
											[DeliveryBackOffice].[dbo].[VisitPointClient] VPC2
											WHERE
											UPPER(VPC2.DescriptionOfClient) LIKE '%FD%EXC%'
											GROUP BY
											VPC2.DescriptionOfClient
										) DA2
										ON
										UPPER(VPC.DescriptionOfClient) = DA2.DescriptionOfClient
										AND
										VPC.Accuracy = DA2.Accuracy
									) EXC
									ON
									UPPER(DOR.Receiver_FirstName) LIKE '%'+EXC.DescriptionOfClient+'%'
								LEFT JOIN DeliveryBackOffice.dbo.ServiceDataForGuide SDFG WITH(NOLOCK)
									ON DOR.Guide_Serie = SDFG.GuideSerie
									AND DOR.Guide_Number = SDFG.GuideNumber
									AND SDFG.IsDelivery = 1
								LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
									ON VPC.CodeOfReference = DOR.Receiver_ID
							WHERE
								DOR.Receiver_Department = @Departamento
								AND
								DOR.StatusOrderId = @Status
								AND
								DOR.Guide_Number NOT IN ( 
										SELECT
											EXPSRG.GuideNumber
										FROM 
											DeliveryBackOffice.dbo.ExtPlatServiceRelationshipWithGuide EXPSRG
										JOIN
											DeliveryBackOffice.dbo.ExtPlatformService EPS ON EXPSRG.ExtPlatServiceId = EPS.IdExtPlatformService
										WHERE
											EPS.IsDelivery = 1
											AND
											CAST(EPS.DateCreated AS DATE) = CAST(@Date AS DATE)
								  )
							GROUP BY
								DOR.Guide_Serie
								,DOR.Guide_Number
								,DOR.Receiver_FirstName
								,DOR.Receiver_LastName
								,DOR.Receiver_Alternant_FullName
								,DOR.Receiver_Address
								,DOR.Receiver_Department
								,DOR.Receiver_Town
								,DOR.Receiver_Phone
								,DOR.IndicationsToSendDestination
								,DOR.Sender_ID
								,DOR.IdDeliveryOption
								,DOR.Receiver_Email
								,DOR.Pieces_Dry
								,DOR.Pieces_Cold
								,DOR.Package_Type
								,PriceShippment
								,DOR.Collect_OnDelivery
								,IsCollect
								,DOR.DateCreated
								,TypeService
								,SSHL.Latitude
								,SSHL.Longitude
								,SDFG.Latitude
								,SDFG.Longitude
								,VPC.Latitude
								,VPC.Longitude
								,EXC.Latitude
								,EXC.Longitude
								,StartTime
								,EndTime
								,StartTime2
								,EndTime2
							--ORDER BY CONCAT (DOR.Guide_Serie, DOR.Guide_Number) ASC
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
							) )
		IF @jsonResult IS NULL
		BEGIN
			set @jsonResult = (
								SELECT STUFF(( 
								SELECT ',{"IdResult":204,' 
								+ '"Message":" No se encontraron registros"}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )

			--EXEC [DeliveryBackOffice].[dbo].[SetExternalPlatformUpdatedServiceData] @TblSimplirouteVisits = @AcceptedGuides , @ExternalPlatform = 2, @ServiceInputType = 1, @UserToken = 'SYS-HERMESROUTES'

			PRINT 'ultimo update'
			UPDATE EPSL
				SET EPSL.RowStatus = 0, EPSL.TokenUpdated = 'SYS-HERMESROUTES', EPSL.DateUpdated = GETDATE()
				FROM [DeliveryBackOffice].[dbo].[ExternalPlatformServiceLog] EPSL
				JOIN @AcceptedGuides TSV
				ON EPSL.GuideSerie = TSV.Guide_Serie
				AND EPSL.GuideNumber = TSV.Guide_Number

		END
		--SET @CanComplete = 1;

		IF(@@TRANCOUNT > 0)
			COMMIT TRANSACTION				
		select ('[' + @jsonResult +  ']') jsonResultError 
		 

	END TRY
	BEGIN CATCH


	 select 0 [blnResult],
        ERROR_NUMBER() AS [ErrorNumber],
        ERROR_SEVERITY() AS [ErrorSeverity],
        ERROR_STATE() AS [ErrorState],
        ERROR_PROCEDURE() AS [ErrorProcedure],
        ERROR_LINE() AS [ErrorLine],
        ERROR_MESSAGE() AS [ErrorMessage];

		--set @jsonResult = (
		--					SELECT STUFF(( 
		--					SELECT ',{"IdResult":500,' 
		--					+ '"Message":"'+ERROR_MESSAGE()+'"}' 
		--					FOR XML PATH(''), TYPE
		--					).value('.', 'varchar(max)'),1,1,'') )
		ROLLBACK TRANSACTION
	END CATCH	
END