-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-27-01>
-- Description:	<Método obtener el AccountId de una solicitud de recolección>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_GetAccountFromPickup]
@IdPickup INT
AS
BEGIN
    SELECT ISNULL(sp.AccountId,0) AS [IdAccount],
			ISNULL(sm.IdServiceManagement,0) AS [ServiceNumber]
	FROM ServiceManagement sm
	INNER JOIN SchedulePickup sp ON sm.IdSchedulePickup = sp.SchedulePickupId
	where sp.SchedulePickupId = @IdPickup
END