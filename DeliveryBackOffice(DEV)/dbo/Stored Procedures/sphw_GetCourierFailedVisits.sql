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

		SELECT
			do.Guide_Serie GuideSerie
		   ,do.Guide_Number GuideNumber
		   ,CONCAT(do.Guide_Serie, do.Guide_Number) Guide
		   ,cr.CodeRoute RouteCode
		   ,CONCAT(sr.First_Name, ' ', sr.Last_Name) CourierName
		   ,CASE
				WHEN do.IsLastMileReturn = 1 THEN CONCAT(do.Sender_FirstName, ' ', do.Sender_LastName)
				ELSE CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName)
			END CustomerName
		   ,CASE
				WHEN do.IsLastMileReturn = 1 THEN do.Sender_Phone
				ELSE do.Receiver_Phone
			END CustomerPhone
		   ,CASE
				WHEN do.IsLastMileReturn = 1 THEN do.Sender_Address
				ELSE do.Receiver_Address
			END CustomerAddress
		FROM ConfirmationOfIncidence coi WITH (NOLOCK)
		INNER JOIN CatTypeConfirmationOfIncidence ctcoi WITH (NOLOCK)
			ON coi.CatTypeConfirmationOfIncidenceId = ctcoi.IdCatTypeConfirmationOfIncidence
			AND ctcoi.[Name] = 'Visita Fallida'
		INNER JOIN DeliveryAttempt da WITH (NOLOCK)
			ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
		INNER JOIN DeliveryOrderBySettlement dobs WITH (NOLOCK)
			ON da.ID_DeliveryOrderBySettlement = dobs.ID
		INNER JOIN SenderReceiver sr WITH (NOLOCK)
			ON dobs.ID_Courier = sr.ID
		INNER JOIN CatRoute cr WITH (NOLOCK)
			ON dobs.CatRouteId = cr.IdRoute
		INNER JOIN DeliveryOrder do WITH (NOLOCK)
			ON da.Guide_Serie = do.Guide_Serie
				AND da.Guide_Number = do.Guide_Number
		INNER JOIN StatusOrder so WITH (NOLOCK)
			ON do.StatusOrderId = so.StatusOrderId
		INNER JOIN Township twn WITH (NOLOCK)
			ON CASE
					WHEN do.IsLastMileReturn = 1 THEN do.SenderIdTownship
					ELSE do.ReceiverIdTownship
				END = twn.IdTownship
				OR CASE
					WHEN do.IsLastMileReturn = 1 THEN do.Sender_Town
					ELSE do.Receiver_Town
				END = twn.TownshipName
		INNER JOIN (SELECT
				dsc.HeaderCode
			   ,MAX(dsc.Hub) hub
			FROM dbo.DumpServiceCoverage dsc WITH (NOLOCK)
			GROUP BY dsc.HeaderCode) sub1
			ON sub1.HeaderCode = twn.HeaderCode
		INNER JOIN dbo.HubLogistics hub WITH (NOLOCK)
			ON hub.HubAbbreviation = sub1.hub
		WHERE @FinishDate >= @StartDate
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