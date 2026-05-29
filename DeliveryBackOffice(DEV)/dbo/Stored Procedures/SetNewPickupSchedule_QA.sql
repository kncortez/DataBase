CREATE PROCEDURE [dbo].[SetNewPickupSchedule_QA]
  @StarDate DATETIME,
  @EndDate DATETIME,
  @ServiceId INT
AS 
BEGIN 
	DECLARE @IdSchedulePickup INT = (SELECT IdSchedulePickup FROM dbo.ServiceManagement sv WITH(NOLOCK) WHERE sv.IdServiceManagement = @ServiceId)

	UPDATE dbo.SchedulePickup
	SET StartDate = @StarDate
	, EndDate = @EndDate
	WHERE SchedulePickupId = @IdSchedulePickup

	IF(@@ROWCOUNT > 0)
	BEGIN
		SELECT '1' AS [Status], 'Cambio realizado exitosamente' AS [Message] 
	END
	ELSE
	BEGIN
		SELECT '0' AS [Status], 'No se pudo actualizar correctamente' AS [Message] 
	END
END;