-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-04-08>
-- Description:	<Obtiene información para el detalle del Form Monitoreo de Servicios de Recolección>
-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-08-27>
-- Description:	<Se cambia la dirección del servicio de recolección en la tabla 0>
-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-06-06>
-- Description: <Se agrego filtro por pais, por defecto GT>
-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-08-27>
-- Description:	<Se cambia la dirección del servicio de recolección en la tabla 0>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Update date: <2025-05-07>
-- Description:	<Se agrega el estado cancelado para monitoreo de servicios de recoleccion>
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
	DECLARE @Status INT = (SELECT IdServiceStatus FROM CatServiceStatus WITH(NOLOCK) WHERE [Name] = 'Cancelado')
	--Table 0 información del servicio
	SELECT DISTINCT
		sm.IdServiceManagement IdServiceManagement
	   --,cu.Name Customer
	   ,sp.SenderName Customer
	   ,vpc.DescriptionOfClient VisitPoint
	   ,p.ProvinceName Department
	   ,ts.TownshipName Town
	   ,sp.AddressPickup Address
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
	LEFT JOIN Township ts WITH(NOLOCK)
		ON ts.IdTownship = sp.TownshipId
	LEFT JOIN Province p WITH(NOLOCK)
		ON ts.IdProvince = p.IdProvince
	WHERE sm.IdServiceManagement = @ServiceManagementId
      AND IIF(vpc.CountryId IS NULL, 'GT',vpc.CountryId) = @IdCountry

	--Table 1 Checkpoints Servicio
	IF EXISTS
	(
		SELECT TOP 1 1
		FROM ServiceManagement WITH(NOLOCK)
		WHERE IdServiceManagement = @ServiceManagementId
			  AND ServiceStatusId = @Status
	)
	BEGIN
		;WITH CTE
		 AS (SELECT css.IdServiceStatus,
					IIF(lbt.SSN_IdUser IS NULL, CONCAT(sr.First_Name, ' ', sr.Last_Name), lbt.SSN_Username) 'User',
					css.Name 'Status',
					es.DateCreated 'Datetime',
					es.Observations 'Incidence'
			 FROM EventService es WITH (NOLOCK)
				 LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt WITH (NOLOCK)
					 ON lbt.SSN_IdToken = es.TokenCreated
				 LEFT JOIN LogTokenPOD ltp WITH (NOLOCK)
					 ON ltp.LogTokenPOD = es.TokenCreated
				 LEFT JOIN SenderReceiver sr WITH (NOLOCK)
					 ON sr.ID = ltp.IdCourierman
				 INNER JOIN CatServiceStatus css WITH (NOLOCK)
					 ON css.IdServiceStatus = es.ServiceStatusId
			 WHERE es.ServiceManagementId = @ServiceManagementId
			 UNION ALL
			 --SE HIZO OTRA CONSULTA A LA LOG POR QUE LA EventService NO ALMACENA EL ESTADO CANCELADO
			SELECT TOP 1 CS.IdServiceStatus,
					IIF(lbt.SSN_IdUser IS NULL, CONCAT(sr.First_Name, ' ', sr.Last_Name), lbt.SSN_Username) 'User',
					CS.Name 'Status',
					SM.DateCreated 'Datetime',
					NULL AS 'Incidence'
			 FROM ServiceManagementStatusLog SM WITH (NOLOCK)
				 INNER JOIN CatServiceStatus CS WITH (NOLOCK)
					 ON SM.ServiceStatusIdNew = CS.IdServiceStatus
				 LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt WITH (NOLOCK)
					 ON lbt.SSN_IdToken = SM.TokenCreated
				 LEFT JOIN LogTokenPOD ltp WITH (NOLOCK)
					 ON ltp.LogTokenPOD = SM.TokenCreated
				 LEFT JOIN SenderReceiver sr WITH (NOLOCK)
					 ON sr.ID = ltp.IdCourierman
			 WHERE SM.ServiceManagementId = @ServiceManagementId
			 AND ServiceStatusIdNew = @Status
			 ORDER BY SM.DateCreated DESC
			)
		SELECT [User],
			   [Status],
			   [Datetime],
			   [Incidence]
		FROM CTE
		ORDER BY IdServiceStatus ASC
	END
	ELSE
	BEGIN
		SELECT IIF(lbt.SSN_IdUser IS NULL, CONCAT(sr.First_Name, ' ', sr.Last_Name), lbt.SSN_Username) 'User',
			   css.Name 'Status',
			   es.DateCreated 'Datetime',
			   es.Observations 'Incidence'
		FROM EventService es WITH (NOLOCK)
			LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt WITH (NOLOCK)
				ON lbt.SSN_IdToken = es.TokenCreated
			LEFT JOIN LogTokenPOD ltp WITH (NOLOCK)
				ON ltp.LogTokenPOD = es.TokenCreated
			LEFT JOIN SenderReceiver sr WITH (NOLOCK)
				ON sr.ID = ltp.IdCourierman
			INNER JOIN CatServiceStatus css WITH (NOLOCK)
				ON css.IdServiceStatus = es.ServiceStatusId
		WHERE es.ServiceManagementId = @ServiceManagementId
		ORDER BY es.DateCreated ASC
	END

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
