-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-04-08>
-- Description:	<Obtiene información para el detalle del Form Monitoreo de Servicios de Recolección>
-- =============================================
CREATE PROCEDURE [dbo].[GetMonitoringPickupServicesDetail]
	-- Add the parameters for the stored procedure here
	@ServiceManagementId INT,
    @IdCountry VARCHAR(2) = 'GT'
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

	--Table 0 información del servicio
	SELECT DISTINCT
		sm.IdServiceManagement IdServiceManagement
	   ,cu.Name Customer
	   ,vpc.DescriptionOfClient VisitPoint
	   ,vpc.Department Department
	   ,vpc.Town Town
	   ,vpc.Address Address
	   ,cr.CodeRoute Route
	   ,CONCAT(sr.First_Name, ' ', sr.Last_Name) Courier
	   ,sm.Amount Amount
	FROM ServiceManagement sm WITH(NOLOCK)
	inner JOIN SchedulePickup sp WITH(NOLOCK)
		ON sp.SchedulePickupId = sm.IdSchedulePickup
	inner JOIN VisitPointClient vpc WITH(NOLOCK)
		ON vpc.CodeOfReference = sp.SenderId
	inner JOIN CatServiceStatus css WITH(NOLOCK)
		ON css.IdServiceStatus = sm.ServiceStatusId
	inner JOIN Customer cu WITH(NOLOCK)
		ON cu.IdCustomer = vpc.CustomerID
	LEFT JOIN RouteAssigment ra WITH(NOLOCK)
		ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
	LEFT JOIN CatRoute cr WITH(NOLOCK)
		ON cr.IdRoute = ra.IdRoute
	LEFT JOIN SenderReceiver sr WITH(NOLOCK)
		ON sr.ID = ra.IdCurrierMan
	WHERE sm.IdServiceManagement = @ServiceManagementId
      AND IIF(vpc.CountryId IS NULL, 'GT',vpc.CountryId) = @IdCountry

	--Table 1 Checkpoints Servicio
	SELECT
		IIF(lbt.SSN_IdUser IS NULL, CONCAT(sr.First_Name, ' ', sr.Last_Name), lbt.SSN_Username) 'User'
	   ,css.Name 'Status'
	   ,es.DateCreated 'Datetime'
	   ,es.Observations 'Incidence'
	FROM EventService es WITH (NOLOCK)
	LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt WITH (NOLOCK)
		ON lbt.SSN_IdToken = es.TokenCreated
	LEFT JOIN LogTokenPOD ltp WITH (NOLOCK)
		ON ltp.LogTokenPOD = es.TokenCreated
	LEFT JOIN SenderReceiver sr WITH (NOLOCK)
		ON sr.ID = ltp.IdCourierman
	inner JOIN CatServiceStatus css WITH(NOLOCK)
		ON css.IdServiceStatus = es.ServiceStatusId
	WHERE es.ServiceManagementId = @ServiceManagementId
	ORDER BY es.DateCreated 

	--Table 3 Guías del servicio
	SELECT
		CONCAT(do.Guide_Serie, do.Guide_Number) Guide
	   ,do.Sender_Address Address
	   ,so.OrderDescription Status
	   ,IIF(EXISTS (SELECT TOP 1
				1
			FROM DeliveryOrderAlert doa WITH (NOLOCK)
			WHERE doa.GuideSerie = do.Guide_Serie
			AND doa.GuideNumber = do.Guide_Number)
		, 'Si', 'No') Alert
	FROM ServiceManagement sm WITH (NOLOCK)
	inner JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
		ON dopd.IdHeaderRecolection = sm.IdSchedulePickup
	inner JOIN DeliveryOrder do WITH (NOLOCK)
		ON do.Guide_Serie = dopd.GuideSerie
			AND do.Guide_Number = dopd.GuideNumber
	inner JOIN StatusOrder so WITH (NOLOCK)
		ON so.StatusOrderId = do.StatusOrderId
	WHERE sm.IdServiceManagement = @ServiceManagementId
END
