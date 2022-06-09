
--EXEC [dbo].[GetGuidesForExternalService]
--	@Date = NULL,
--	@Hub = 'GUA',
--	@Municipalidad  = 'Guatemala',
--	@Departamento  = 'Guatemala',
--	@Status = 11

-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-12-27>
-- Description:	< Recupera datos de guías para ingresar a una plataforma externa, las cuales no han sido procesadas para ingreso a Simpliroute de forma automatizada. Adicional intenta tomar guías indiscriminadamente y revisar la información de las mismas, corrigiendo: Hubs. >
-- =============================================
CREATE PROCEDURE [dbo].[GetGuidesForExternalService_TEST]
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
				ON DOR.Guide_Number = DOD.Guide_Number
				AND DOR.Guide_Serie = DOD.Guide_Serie
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
		
		SELECT 
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
							FROM
								DeliveryBackOffice.dbo.DeliveryOrder DOR WITH(NOLOCK)
								JOIN @AcceptedGuides AG
									ON DOR.Guide_Serie = AG.Guide_Serie
									AND DOR.Guide_Number = AG.Guide_Number
								JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH(NOLOCK)
									ON DOP.GuideSerie = DOR.Guide_Serie
									AND DOP.GuideNumber = DOR.Guide_Number
								JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH(NOLOCK)
									ON DOR.Guide_Number = DOD.Guide_Number
									AND DOR.Guide_Serie = DOD.Guide_Serie
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
							--FOR XML PATH(''), TYPE
							--).value('.', 'varchar(max)'),1,1,''
							--) )
		IF @jsonResult IS NULL
		BEGIN
			set @jsonResult = (
								SELECT STUFF(( 
								SELECT ',{"IdResult":204,' 
								+ '"Message":" No se encontraron registros"}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )

			--EXEC [DeliveryBackOffice].[dbo].[SetExternalPlatformUpdatedServiceData] @TblSimplirouteVisits = @AcceptedGuides , @ExternalPlatform = 2, @ServiceInputType = 1, @UserToken = 'SYS-HERMESROUTES'

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
