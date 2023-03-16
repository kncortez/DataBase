
-- =============================================
-- Author:		<Andrés, Ruíz>
-- Create date: <2023-02-17>
-- Description:	< Devuelve los datos de incidencias en ruta y visitas para portal web interno >
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2023-02-27>
-- Description:	<Agregar nuevos campos: Courier quien marcó la visita fallida, Fecha de visita fallida, Ubicación del mapa de la visita fallida (punto de entrega y punto de courier), Foto que tomó el courier >
-- =============================================
CREATE PROCEDURE [dbo].[spHW_GetServiceIncidenceForMonitoring]

	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@UserId BIGINT,
	@CourierId INT = NULL

AS 
BEGIN

	DECLARE @SACWebRoleId INT = (SELECT TOP 1 CR.RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'SAC web' COLLATE Latin1_General_CI_AI AND CR.RolRowStatus = 1);
	DECLARE @OPWebRoleId INT = (SELECT TOP 1 CR.RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'Operaciones web' COLLATE Latin1_General_CI_AI AND CR.RolRowStatus = 1);

	IF(@EndDate IS NULL)
	BEGIN

		SET @EndDate = DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(GETDATE() AS DATE) AS DATETIME)))

	END
	ELSE 
	BEGIN

		SET @EndDate = DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(@EndDate AS DATE) AS DATETIME)))

	END

	IF(@StartDate IS NULL)
	BEGIN

		SET @StartDate = CAST(CAST(DATEADD(DAY,-7,@EndDate) AS DATE) AS DATETIME)

	END
	ELSE
	BEGIN

		SET @StartDate = CAST(CAST(@StartDate AS DATE) AS DATETIME)

	END

	IF(DATEDIFF(DAY,@StartDate, @EndDate) > 30)
	BEGIN

		SET @StartDate = CAST(CAST(DATEADD(DAY,-30,@EndDate) AS DATE) AS DATETIME)

	END

	BEGIN TRY

	IF OBJECT_ID('tempdb.dbo.#HubServiceCoverage', 'U') IS NOT NULL 
		DROP TABLE #HubServiceCoverage;

	CREATE TABLE #HubServiceCoverage(
		HeaderCode NVARCHAR(50),
		Hub INT
	);

	INSERT INTO #HubServiceCoverage
	(
	    [HeaderCode],
	    [Hub]
	)
	SELECT
		DSC.[HeaderCode],
		MAX(HL.IdHubLogistic) 'Hub'
	FROM
		[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
		INNER JOIN
			[DeliveryBackOffice].[dbo].[HubLogistics] HL WITH(NOLOCK)
			ON
				DSC.Hub = HL.HubAbbreviation
	GROUP BY
		DSC.HeaderCode

	-- SAC Web
	IF
	(
		EXISTS
		(
			SELECT
				TOP 1
					1
			FROM
				[DeliveryBackOffice].[dbo].[RolByModuleBySystem] RBMBS WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[RolByUserBySystem] RBUBS WITH(NOLOCK)
					ON
						RBMBS.RmsIdRol = RBUBS.RusIdRol
						AND
						RBMBS.RmsIdSystem = RBUBS.RusIdSystem
						AND
						RBUBS.RusIdUser = @UserId
			WHERE
				RBMBS.RmsIdRol = @SACWebRoleId
		)
	)
	BEGIN

		SELECT
			200 'resultCode',
			'Datos obtenidos exitosamente' 'resultMessage'

		SELECT
			CONCAT(DA.Guide_Serie, DA.Guide_Number) 'Service'
			,(
				CASE
					WHEN DO.IsLastMileReturn = 1 THEN LTRIM(RTRIM(CONCAT(DO.Sender_FirstName,' ',DO.Sender_LastName)))
					WHEN ISNULL(DO.IsLastMileReturn, 0) = 0 THEN LTRIM(RTRIM(CONCAT(DO.Receiver_FirstName,' ',DO.Receiver_LastName)))
					ELSE LTRIM(RTRIM(CONCAT(DO.Receiver_FirstName,' ',DO.Receiver_LastName)))
				END
			) 'ServiceCustomer'
			,(
				CASE
					WHEN DO.IsLastMileReturn = 1 THEN DO.Sender_Address
					WHEN ISNULL(DO.IsLastMileReturn, 0) = 0 THEN DO.Receiver_Address
					ELSE DO.Receiver_Address
				END
			) 'ServiceAddress'
			,(
				CASE
					WHEN DO.IsLastMileReturn = 1 THEN DO.Sender_Town
					WHEN ISNULL(DO.IsLastMileReturn, 0) = 0 THEN DO.Receiver_Town
					ELSE DO.Receiver_Town
				END
			) 'ServiceTownship'
			,(
				CASE
					WHEN DO.IsLastMileReturn = 1 THEN DO.Sender_Department
					WHEN ISNULL(DO.IsLastMileReturn, 0) = 0 THEN DO.Receiver_Department
					ELSE DO.Receiver_Department
				END
			) 'ServiceProvince'
			,(
				CASE
					WHEN DO.IsLastMileReturn = 1 THEN DO.Sender_Phone
					WHEN ISNULL(DO.IsLastMileReturn, 0) = 0 THEN DO.Receiver_Phone
					ELSE DO.Receiver_Phone
				END
			) 'ServiceCustomerPhone'
			,SO.OrderDescription 'Tipo de incidencia'
			,CTI.NameIncidence 'Incidencia indicada'
			,DO.Guide_Serie 'GuideSerie'
			,DO.Guide_Number 'GuideNumber'
			,CAST(ISNULL(DO.IsLastMileReturn, 0) AS BIT) 'IsLastMileReturn'
			,COI.ConfirmationOfIncidentToken 'IncidenceToken'
			,ISNULL(SR.First_Name,'') +' '+ ISNULL(SR.Last_Name,'') AS 'CourierFailedVisit'
			,COI.DateCreated AS 'Failedvisitdate'
			,DA.Latitude AS 'LatitudeIncidence'
			,DA.Longitude AS 'LongitudeIncidence'
			,(SELECT TOP 1 Path_Incident
						FROM [dbo].[DeliveryProof] WITH(NOLOCK)
						WHERE ID = DA.ID_Proof) AS  'IncidenceImage'
            ,VPC.Latitude AS 'LatitudeVisitPointClient'
			,VPC.Longitude AS 'LongitudeVisitPintClient'

		FROM
			[DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
				ON
					COI.StatusOrderId = SO.StatusOrderId
			INNER JOIN
				[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH(NOLOCK)
				ON
					COI.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH(NOLOCK)
				ON
					DA.ID_Incident = CTI.IdIncidenceType
			INNER JOIN
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
				ON
					DA.Guide_Serie = DO.Guide_Serie
					AND
					DA.Guide_Number = DO.Guide_Number
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Township] TwnByIdOri WITH(NOLOCK)
				ON
					DO.SenderIdTownship = TwnByIdOri.IdTownship
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Township] TwnByNameOri WITH(NOLOCK)
				ON
					DO.Sender_Town = TwnByNameOri.TownshipName
			LEFT JOIN #HubServiceCoverage DSCOri
				ON
					[DSCOri].[HeaderCode] = ISNULL([TwnByIdOri].[HeaderCode], [TwnByNameOri].[HeaderCode])
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[HubLogisticByUser] HLBUOri WITH(NOLOCK)
				ON
					DSCOri.Hub = HLBUOri.HubLogisticId
					AND
					HLBUOri.UserId = @UserId
			LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] SR
			     ON DA.ID_Courier = SR.ID
			LEFT JOIN [dbo].[VisitPointClient] VPC
				ON VPC.CodeOfReference = CASE WHEN  DO.IsLastMileReturn = 1 AND DO.Sender_ID != 0 THEN DO.Sender_ID ELSE DO.Receiver_ID END
		WHERE
			COI.ConfirmationOfIncidentToken NOT LIKE '%TIMEOUT'
			AND
			COI.DateCreated BETWEEN @StartDate AND @EndDate
			AND
			COI.IsConfirmed = 0
			AND
			COI.RowStatus = 1
			AND
			(
				HLBUOri.IdHubLogisticByUser IS NOT NULL
			)
		UNION
		SELECT
			CONCAT(DA.Guide_Serie, DA.Guide_Number) 'Service'
			,(
				CASE
					WHEN DO.IsLastMileReturn = 1 THEN LTRIM(RTRIM(CONCAT(DO.Sender_FirstName,' ',DO.Sender_LastName)))
					WHEN ISNULL(DO.IsLastMileReturn, 0) = 0 THEN LTRIM(RTRIM(CONCAT(DO.Receiver_FirstName,' ',DO.Receiver_LastName)))
					ELSE LTRIM(RTRIM(CONCAT(DO.Receiver_FirstName,' ',DO.Receiver_LastName)))
				END
			) 'ServiceCustomer'
			,(
				CASE
					WHEN DO.IsLastMileReturn = 1 THEN DO.Sender_Address
					WHEN ISNULL(DO.IsLastMileReturn, 0) = 0 THEN DO.Receiver_Address
					ELSE DO.Receiver_Address
				END
			) 'ServiceAddress'
			,(
				CASE
					WHEN DO.IsLastMileReturn = 1 THEN DO.Sender_Town
					WHEN ISNULL(DO.IsLastMileReturn, 0) = 0 THEN DO.Receiver_Town
					ELSE DO.Receiver_Town
				END
			) 'ServiceTownship'
			,(
				CASE
					WHEN DO.IsLastMileReturn = 1 THEN DO.Sender_Department
					WHEN ISNULL(DO.IsLastMileReturn, 0) = 0 THEN DO.Receiver_Department
					ELSE DO.Receiver_Department
				END
			) 'ServiceProvince'
			,(
				CASE
					WHEN DO.IsLastMileReturn = 1 THEN DO.Sender_Phone
					WHEN ISNULL(DO.IsLastMileReturn, 0) = 0 THEN DO.Receiver_Phone
					ELSE DO.Receiver_Phone
				END
			) 'ServiceCustomerPhone'
			,SO.OrderDescription 'Tipo de incidencia'
			,CTI.NameIncidence 'Incidencia indicada'
			,DO.Guide_Serie 'GuideSerie'
			,DO.Guide_Number 'GuideNumber'
			,CAST(ISNULL(DO.IsLastMileReturn, 0) AS BIT) 'IsLastMileReturn'
			,COI.ConfirmationOfIncidentToken 'IncidenceToken'
			,ISNULL(SR.First_Name,'') +' '+ ISNULL(SR.Last_Name,'') AS 'CourierFailedVisit'
			,COI.DateCreated AS 'Failedvisitdate'
			,DA.Latitude AS 'LatitudeIncidence'
			,DA.Longitude AS 'LongitudeIncidence'
			,(SELECT TOP 1 Path_Incident
						FROM [dbo].[DeliveryProof] WITH(NOLOCK)
						WHERE ID = DA.ID_Proof) AS  'IncidenceImage'
            ,VPC.Latitude AS 'LatitudeVisitPointClient'
			,VPC.Longitude AS 'LongitudeVisitPintClient'

		FROM
			[DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
				ON
					COI.StatusOrderId = SO.StatusOrderId
			INNER JOIN
				[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH(NOLOCK)
				ON
					COI.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH(NOLOCK)
				ON
					DA.ID_Incident = CTI.IdIncidenceType
			INNER JOIN
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
				ON
					DA.Guide_Serie = DO.Guide_Serie
					AND
					DA.Guide_Number = DO.Guide_Number
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Township] TwnByIdDes WITH(NOLOCK)
				ON
					DO.ReceiverIdTownship = TwnByIdDes.IdTownship
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Township] TwnByNameDes WITH(NOLOCK)
				ON
					DO.Receiver_Town = TwnByNameDes.TownshipName
			LEFT JOIN #HubServiceCoverage DSCDes
				ON
					[DSCDes].[HeaderCode] = ISNULL([TwnByIdDes].[HeaderCode], [TwnByNameDes].[HeaderCode])
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[HubLogisticByUser] HLBUDes WITH(NOLOCK)
				ON
					DSCDes.Hub = HLBUDes.HubLogisticId
					AND
					HLBUDes.UserId = @UserId
			LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] SR
			     ON DA.ID_Courier = SR.ID
			LEFT JOIN [dbo].[VisitPointClient] VPC
				ON VPC.CodeOfReference = Case when  DO.IsLastMileReturn = 1 And DO.Sender_ID != 0 Then DO.Sender_ID Else DO.Receiver_ID End
		WHERE
			COI.ConfirmationOfIncidentToken NOT LIKE '%TIMEOUT'
			AND
			COI.DateCreated BETWEEN @StartDate AND @EndDate
			AND
			COI.IsConfirmed = 0
			AND
			COI.RowStatus = 1
			AND
			(
				HLBUDes.IdHubLogisticByUser IS NOT NULL
			)

	END
	-- OP
	ELSE 
	IF
	(
		EXISTS
		(
			SELECT
				TOP 1
					1
			FROM
				[DeliveryBackOffice].[dbo].[RolByModuleBySystem] RBMBS WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[RolByUserBySystem] RBUBS WITH(NOLOCK)
					ON
						RBMBS.RmsIdRol = RBUBS.RusIdRol
						AND
						RBMBS.RmsIdSystem = RBUBS.RusIdSystem
						AND
						RBUBS.RusIdUser = @UserId
			WHERE
				RBMBS.RmsIdRol = @OPWebRoleId
		)
	)
	BEGIN

		SELECT
			200 'resultCode',
			'Datos obtenidos exitosamente' 'resultMessage'

		SELECT
			CONCAT(DA.Guide_Serie, DA.Guide_Number) 'Service'
			,SR.ID 'CourierId'
			,LTRIM(RTRIM(CONCAT(SR.First_Name, ' ', SR.Last_Name))) 'Courier'
			,SR.Phone 'CourierPhone'
			,SO.OrderDescription 'Tipo de incidencia'
			,CTI.NameIncidence 'Incidencia indicada'
			,DA.Guide_Serie 'GuideSerie'
			,DA.Guide_Number 'GuideNumber'
			,ISNULL(COI.IsActionIssued, 0) 'IsActionIssued'
			,COI.IdConfirmationOfIncidence 'ConfirmationOfIncidenceId'
		FROM
			[DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH(NOLOCK)
				ON
					COI.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH(NOLOCK)
				ON
					DA.ID_Incident = CTI.IdIncidenceType
			INNER JOIN
				[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH(NOLOCK)
				ON
					DA.ID_Courier = SR.ID
			INNER JOIN
				[DeliveryBackOffice].[dbo].[HubLogisticByUser] HLBU WITH(NOLOCK)
				ON
					SR.HubLogisticId = HLBU.HubLogisticId
					AND
					HLBU.UserId = @UserId
			INNER JOIN
				[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
				ON
					COI.StatusOrderId = SO.StatusOrderId
		WHERE
			COI.ConfirmationOfIncidentToken NOT LIKE '%TIMEOUT'
			AND
			COI.DateCreated BETWEEN @StartDate AND @EndDate
			AND
			COI.IsConfirmed = 0
			AND
			COI.RowStatus = 1
			AND
			(ISNULL(@CourierId, 0) = 0 OR DA.ID_Courier = @CourierId)

	END

	END TRY
	BEGIN CATCH

		SELECT
			500 'resultCode',
			ERROR_MESSAGE() 'resultMessage'

	END CATCH
	
	IF OBJECT_ID('tempdb.dbo.#HubServiceCoverage', 'U') IS NOT NULL 
		DROP TABLE #HubServiceCoverage;

END