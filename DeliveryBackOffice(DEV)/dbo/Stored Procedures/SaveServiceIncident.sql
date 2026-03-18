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
	@SenderReceiverId INT,
	@CatServiceStatusId INT,
	@CatTypeIncidenceId INT,
	@Comments NVARCHAR(500),
	@CatCountryId VARCHAR (2),
	@HubLogisticsId INT,
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
			Observations,
			CountryId,
			HubId,
			IncidentStatusId,
			DateCreated,
			TokenCreated,
			RowStatus
		)
		VALUES(
			@ServiceManagementId,
			@SenderReceiverId,
			@CatServiceStatusId,
			@CatTypeIncidenceId,
			@Comments,
			@CatCountryId,
			@HubLogisticsId,
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