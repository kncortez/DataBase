/* =================================================
   SP:        GetAllPickupIncidents
   Propósito: Obtener todos los incidentes de tipo pickup
   Autor:     Erick Hernandez
   Historia:  FDAPI-5700
   Fecha:     2026-03-30

=== CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[GetAllPickupIncidents]
	@CountryId VARCHAR (2)
AS
BEGIN
	SELECT IdIncidenceType AS IncidentID, NameIncidence AS Incident
	FROM DeliveryBackOffice.dbo.CatTypeIncidence WITH(NOLOCK)
	WHERE ServiceType = 'PICKUP'
	AND CountryId = @CountryId
	AND RowStatus = 1;
END