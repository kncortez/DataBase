-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-11-22>
-- Description:	<Obtiene información de visitas fallidas de couriers para pantalla de monitoreo de visitas faliidas SAC web>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_GetCourierFailedVisits]
	-- Add the parameters for the stored procedure here
	@StartDate DATE,
	@FinishDate DATE,
	@UserId BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY

	;WITH DO_EXT AS (
			SELECT 
				do.StatusOrderId,
				do.Guide_Serie,
				do.Guide_Number,
				CASE WHEN do.IsLastMileReturn = 1 THEN do.SenderIdTownship ELSE do.ReceiverIdTownship END AS IdTwn,
				CASE WHEN do.IsLastMileReturn = 1 THEN do.Sender_Town ELSE do.Receiver_Town END AS TownName,
				CASE WHEN do.IsLastMileReturn = 1 THEN CONCAT(do.Sender_FirstName, ' ', do.Sender_LastName)
					 ELSE CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName) END AS CustomerName,
				CASE WHEN do.IsLastMileReturn = 1 THEN do.Sender_Phone ELSE do.Receiver_Phone END AS CustomerPhone,
				CASE WHEN do.IsLastMileReturn = 1 THEN do.Sender_Address ELSE do.Receiver_Address END AS CustomerAddress,
				ISNULL(do.IsLastMileReturn, 0) AS IsReturnS
			FROM DeliveryOrder do WITH (NOLOCK)
		)
		SELECT 
			do.Guide_Serie AS GuideSerie,
			do.Guide_Number AS GuideNumber,
			CONCAT(do.Guide_Serie, do.Guide_Number) AS Guide,
			cr.CodeRoute AS RouteCode,
			CONCAT(sr.First_Name, ' ', sr.Last_Name) AS CourierName,
			do.CustomerName,
			do.CustomerPhone,
			do.CustomerAddress,
			do.IsReturnS AS IsReturn,
			cti.NameIncidence AS IncidenceDescription,
			da.Date_Created AS IncidenceDate,
			da.Latitude AS IncidenceLatitude,
			da.Longitude AS IncidenceLongitude
		FROM ConfirmationOfIncidence coi WITH (NOLOCK)
		INNER JOIN CatTypeConfirmationOfIncidence ctcoi WITH (NOLOCK)
			ON coi.CatTypeConfirmationOfIncidenceId = ctcoi.IdCatTypeConfirmationOfIncidence
		INNER JOIN DeliveryAttempt da WITH (NOLOCK)
			ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
		INNER JOIN CatTypeIncidence cti WITH (NOLOCK)
			ON da.ID_Incident = cti.IdIncidenceType
		INNER JOIN DeliveryOrderBySettlement dobs WITH (NOLOCK)
			ON da.ID_DeliveryOrderBySettlement = dobs.ID
		INNER JOIN SenderReceiver sr WITH (NOLOCK)
			ON dobs.ID_Courier = sr.ID
		INNER JOIN CatRoute cr WITH (NOLOCK)
			ON dobs.CatRouteId = cr.IdRoute
		INNER JOIN DO_EXT do
			ON da.Guide_Serie = do.Guide_Serie AND da.Guide_Number = do.Guide_Number
		INNER JOIN StatusOrder so WITH (NOLOCK)
			ON do.StatusOrderId = so.StatusOrderId
		INNER JOIN Township twn WITH (NOLOCK)
			ON do.IdTwn = twn.IdTownship OR do.TownName = twn.TownshipName
		INNER JOIN (
			SELECT HeaderCode, MAX(Hub) AS hub
			FROM dbo.DumpServiceCoverage WITH (NOLOCK)
			GROUP BY HeaderCode
		) sub1 ON sub1.HeaderCode = twn.HeaderCode
		INNER JOIN dbo.HubLogistics hub WITH (NOLOCK)
			ON hub.HubAbbreviation = sub1.hub
	WHERE @FinishDate >= @StartDate
			AND ctcoi.[Name] = 'Visita Fallida'
			AND coi.RowStatus = 1
			AND CAST(coi.DateCreated AS DATE) >= @StartDate
			AND CAST(coi.DateCreated AS DATE) <= @FinishDate
			AND so.OrderDescription NOT IN ('Anulado', 'Entregado', 'Devuelto', 'Traslado a Express Center', 'Entregado En Express Center', 'Devuelto en Express Center', 'COD liquidado', 'COD pagado', 'Paquete destruido')
		AND hub.IdHubLogistic IN (SELECT
				hlbu.HubLogisticId
			FROM HubLogisticByUser hlbu WITH (NOLOCK)
			WHERE hlbu.UserId = @UserId)
	END TRY
	BEGIN CATCH
		SELECT
			0 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
	END CATCH
END