/* =================================================
   SP:        GetServiceIncidentDetails
   Propósito: Obtener los detalles del incidente del servicio
   Autor:     Erick Hernandez
   Historia:  FDAPI-5700
   Fecha:     2026-03-20

=== CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[GetServiceIncidentDetails]
    @ServiceIncidentId INT
AS
BEGIN
	SELECT
	SI.ServiceId AS ServiceID,
	CSS.Name AS IncidentType,
	SI.IncidentId,
	TI.NameIncidence AS Incident,
	SI.DateCreated,
	SI.Latitude,
	SI.Longitude,
	SI.IncidentPicturePath AS IncidentPicture,
	SI.CourierNotes
	FROM DeliveryBackOffice.dbo.ServiceIncident SI WITH (NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.CatServiceStatus CSS WITH (NOLOCK)
		ON CSS.IdServiceStatus = SI.IncidentTypeId
	INNER JOIN DeliveryBackOffice.dbo.CatTypeIncidence TI WITH (NOLOCK)
		ON TI.IdIncidenceType = SI.IncidentId
	WHERE SI.ServiceIncidentId = @ServiceIncidentId
	AND SI.RowStatus = 1
	AND CSS.RowStatus = 1
	AND TI.RowStatus = 1;

	SELECT
	SP.SenderName AS Name, SP.SenderPhone AS Phone, SP.AddressPickup AS Address, 
	T.TownshipName AS Township, 
	P.ProvinceName AS Province
	FROM DeliveryBackOffice.dbo.ServiceManagement SM WITH(NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.SchedulePickup SP WITH(NOLOCK)
		ON SP.SchedulePickupId = SM.IdSchedulePickup
	INNER JOIN DeliveryBackOffice.dbo.Township T WITH(NOLOCK)
		ON T.IdTownship = SP.TownshipId
	INNER JOIN DeliveryBackOffice.dbo.Province P WITH(NOLOCK)
		ON P.IdProvince = T.IdProvince
	WHERE SM.IdServiceManagement = (
		SELECT ServiceId
		FROM DeliveryBackOffice.dbo.ServiceIncident WITH (NOLOCK)
		WHERE ServiceIncidentId = @ServiceIncidentId
	)
	AND SP.RowStatus = 1
	AND T.TownshipStatus = 1
	AND P.ProvinceStatus = 1
	AND SM.RowStatus = 1;
END;