/* =================================================
   SP:        GetAllServiceIncidents
   Propósito: Se obtienen todos los incidentes del servicio
   Autor:     Erick Hernandez
   Historia:  FDAPI-5699
   Fecha:     2026-03-13

=== CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[GetAllServiceIncidents]
	@CountryList NVARCHAR(MAX) = NULL,
    @HubList NVARCHAR(MAX) = NULL,
	@IncidentTypeList NVARCHAR(MAX) = NULL
AS
BEGIN

	DECLARE @Countries TABLE (CountryId VARCHAR(2));
	DECLARE @Hubs TABLE (HubId INT);
	DECLARE @IncidentTypes TABLE (IncidentTypeId INT);
	DECLARE @PendingIncidentStatusID INT = 1;
	DECLARE @ResolvedIncidentStatusID INT = 3;
	DECLARE @Today DATE = CAST(GETDATE() AS DATE);

	INSERT INTO @Countries
	SELECT LTRIM(RTRIM(value))
	FROM STRING_SPLIT(@CountryList, ',');

	INSERT INTO @Hubs
	SELECT LTRIM(RTRIM(value))
	FROM STRING_SPLIT(@HubList, ',');
	
	INSERT INTO @IncidentTypes
	SELECT LTRIM(RTRIM(value))
	FROM STRING_SPLIT(@IncidentTypeList, ',');
	
SELECT
	SI.ServiceIncidentId,
	SR.First_Name + ' ' + SR.Last_Name  AS Courier,
	SR.Phone AS CourierPhone,
	SI.ServiceId AS ServiceID,
	CSS.Name AS IncidentType,
	TI.NameIncidence AS Incident,
	SI.CourierNotes AS Comments
	FROM DeliveryBackOffice.dbo.ServiceIncident SI WITH (NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.SenderReceiver SR WITH (NOLOCK)
		ON SR.ID = SI.CourierId
	INNER JOIN DeliveryBackOffice.dbo.CatServiceStatus CSS WITH (NOLOCK)
		ON CSS.IdServiceStatus = SI.IncidentTypeId
	INNER JOIN DeliveryBackOffice.dbo.CatTypeIncidence TI WITH (NOLOCK)
		ON TI.IdIncidenceType = SI.IncidentId
	INNER JOIN DeliveryBackOffice.dbo.IncidentStatus IST WITH(NOLOCK)
		ON IST.IncidentStatusId = SI.IncidentStatusId
	WHERE IST.IncidentStatusId NOT IN (@ResolvedIncidentStatusID)
	AND SI.RowStatus = 1
	AND SI.DateCreated >= @Today
	AND SI.DateCreated < DATEADD(DAY, 1, @Today)
	AND
	(
		--filter is applied
		--all rows passed
		SI.CountryId IN (SELECT CountryId FROM @Countries)
		OR NOT EXISTS (SELECT 1 FROM @Countries)
	)
	AND
	(
		--Return the row if the hub was explicitly requested.
		--Are there any hubs in the hub list that belong to this row's country?
		SI.HubId IN (SELECT HubId FROM @Hubs)
		OR NOT EXISTS ( 
			SELECT 1
			FROM DeliveryBackOffice.dbo.HubLogistics H WITH(NOLOCK)
			WHERE H.IdHubLogistic IN (SELECT HubId FROM @Hubs)
			AND H.IdCountry = SI.CountryId
		)
	)
	AND (
		--If incident types were passed = filter them
		--If no incident types were passed = return all rows
		SI.IncidentTypeId IN (SELECT IncidentTypeId FROM @IncidentTypes)
		OR NOT EXISTS (SELECT 1 FROM @IncidentTypes)
	)
	ORDER BY SI.DateCreated DESC;
END;