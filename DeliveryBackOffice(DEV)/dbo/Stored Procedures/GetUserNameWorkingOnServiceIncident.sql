/* =================================================
   SP:        GetUserNameWorkingOnServiceIncident
   Propósito: Obtener el usuario que esta trabajando en el incidente del servicio
   Autor:     Erick Hernandez
   Historia:  FDAPI-5923
   Fecha:     2026-03-20

=== CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[GetUserNameWorkingOnServiceIncident]
    @ServiceIncidentId INT
AS
BEGIN
    DECLARE @USERNAME NVARCHAR(50) = '';
	
	SELECT TOP 1 @USERNAME = ISNULL(IU.Username, '')
	FROM DeliveryBackOffice.dbo.InternalUser IU WITH (NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.RegisterUser RU WITH (NOLOCK)
		ON RU.UsrIdUser = IU.RegisterUserID AND RU.UsrRowStatus = 1
	--INNER JOIN DeliveryBackOffice.dbo.TokenLog TL WITH (NOLOCK)
	--	ON TL.TknIdUser = RU.UsrIdUser AND TL.TknRowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.ServiceIncident SI WITH (NOLOCK)
		ON SI.CurrentAgentId = RU.UsrIdUser --TL.TknIdUser --TL.TknIdToken
	WHERE IU.RowStatus = 1
	AND SI.ServiceIncidentId = @ServiceIncidentId;

	SELECT @USERNAME AS UserName;
END;