-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2021-12-30>
-- Description:	<Actualiza la fecha asignada a los servicios pendientes de asignación de ruta, a la fecha actual
-- =============================================

CREATE PROCEDURE [dbo].[sphd_SetCheckRoutePreparationPickUp]
	@tokenuser nvarchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	----------------------------------------------------------------------------------------------------
	DECLARE @CURRENTDATE DATETIME=GETDATE();
	set @CURRENTDATE=@CURRENTDATE-cast(cast(@CURRENTDATE as time) as datetime);
	DECLARE @YESTERDAY DATETIME=@CURRENTDATE -1;	
	UPDATE SchedulePickup SET 
		StartDate=cast(@CURRENTDATE as datetime) + cast(cast(StartDate as time) as datetime),
		EndDate=cast(@CURRENTDATE as datetime) + cast(cast(EndDate as time) as datetime),
		TokenUpdated=@tokenuser,
		DateUpdated=GETDATE()		
		where	(StartDate-(cast(cast(StartDate as time) as datetime)))=@YESTERDAY AND ((AssigmentStatus = 0) OR (AssigmentStatus IS NULL)) AND RowStatus = 'true'
		AND (SchedulePickupStatus IS NULL OR SchedulePickupStatus = 1)
	----------------------------------------------------------------------------------------------------	

END
