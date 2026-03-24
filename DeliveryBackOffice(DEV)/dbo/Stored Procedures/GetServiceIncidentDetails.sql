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
	--SI.ServiceIncidentId,
	SI.ServiceId AS ServiceID,
	CSS.Name AS IncidentType,
	TI.NameIncidence AS Incident,
	SI.DateCreated,
	SI.Latitude,
	SI.Longitude,
	SI.IncidentPicturePath AS IncidentPicture,
	SI.CourierNotes
	FROM DeliveryBackOffice.dbo.ServiceIncident SI WITH (NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.CatServiceStatus CSS WITH (NOLOCK)
		ON CSS.IdServiceStatus = SI.IncidentTypeId AND CSS.RowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.CatTypeIncidence TI WITH (NOLOCK)
		ON TI.IdIncidenceType = SI.IncidentId AND TI.RowStatus = 1
	WHERE SI.ServiceIncidentId = @ServiceIncidentId
	AND SI.RowStatus = 1;

	SELECT --SM.IdServiceManagement, SM.IdSchedulePickup, SP.SenderId, 
	SP.SenderName AS Name, SP.SenderPhone AS Phone, SP.AddressPickup AS Address, 
	--T.IdTownship, 
	T.TownshipName AS Township, 
	--P.IdProvince, 
	P.ProvinceName AS Province
	--VPC.DescriptionOfClient, VPC.Department, VPC.Phone, VPC.Town, VPC.Address
	FROM DeliveryBackOffice.dbo.ServiceManagement SM WITH(NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.SchedulePickup SP WITH(NOLOCK)
		ON SP.SchedulePickupId = SM.IdSchedulePickup AND SP.RowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.Township T WITH(NOLOCK)
		ON T.IdTownship = SP.TownshipId AND T.TownshipStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.Province P WITH(NOLOCK)
		ON P.IdProvince = T.IdProvince AND P.ProvinceStatus = 1
	--INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
	--	ON VPC.CodeOfReference = SP.SenderId AND VPC.StatusClient = 1
	WHERE SM.IdServiceManagement = (
		SELECT ServiceId
		FROM DeliveryBackOffice.dbo.ServiceIncident WITH (NOLOCK)
		WHERE ServiceIncidentId = @ServiceIncidentId
	)
	AND SM.RowStatus = 1;
END;