/* =================================================
   SP:        SaveServiceIncident
   Propósito: Se guarda un incidente del servicio
   Autor:     Erick Hernandez
   Historia:  FDAPI-5699
   Fecha:     2026-03-13

=== CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[SaveServiceIncident]
	@ServiceManagementId INT,
	@CourierId INT,
	@CatServiceStatusId INT,
	@CatTypeIncidenceId INT,
	@Comments NVARCHAR(500),
	@CatCountryId VARCHAR (2),
	@HubLogisticsId INT,
	@Latitude NVARCHAR (40),
	@Longitude NVARCHAR (40),
	@IncidentPicturePath NVARCHAR (500),
	@Token NVARCHAR(50)
AS
BEGIN
	DECLARE @PendingStatusId INT = 1;
	BEGIN TRY
		INSERT INTO DeliveryBackOffice.dbo.ServiceIncident
		(
			ServiceId,
			CourierId,
			IncidentTypeId,
			IncidentId,
			CourierNotes,
			CountryId,
			HubId,
			Latitude,
			Longitude,
			IncidentPicturePath,
			IncidentStatusId,
			DateCreated,
			TokenCreated,
			RowStatus
		)
		VALUES(
			@ServiceManagementId,
			@CourierId,
			@CatServiceStatusId,
			@CatTypeIncidenceId,
			@Comments,
			@CatCountryId,
			@HubLogisticsId,
			@Latitude,
			@Longitude,
			@IncidentPicturePath,
			@PendingStatusId,
			GETDATE(),
			@Token,
			1
		);
		
		SELECT CAST(SCOPE_IDENTITY() AS BIGINT);
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END;