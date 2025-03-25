-- =============================================  
-- Author:  <Cristian Suazo  
-- Update date: <2025-02-17>  
-- Description: <Se obtienen todos los lotes que aun no han sido procesados para el servicio>  
-- ============================================= 
CREATE PROCEDURE [dbo].[GetBatchPOD]
    @IdCountry NVARCHAR(2)= 'GT'
AS
BEGIN
	DECLARE @CreateStatus INT

	SET @CreateStatus = (SELECT IdServiceStatus FROM CatServiceStatus WITH(NOLOCK) WHERE [Name] = 'Asignado a Ruta')

	SELECT fph.SchedulePickupId,
		   fph.DateCreated
	FROM DeliveryBackOffice.dbo.FinishPickUpHeader fph WITH(NOLOCK) 
	INNER JOIN DeliveryBackOffice.dbo.SchedulePickup sp WITH(NOLOCK) 
		ON sp.SchedulePickupId = fph.SchedulePickupId
	INNER JOIN DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK) 
		ON sm.IdSchedulePickup = sp.SchedulePickupId
	INNER JOIN DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK) 
		ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
	INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK) 
		ON cr.IdRoute = ra.IdRoute 
	WHERE fph.ServiceStatusId = @CreateStatus
	AND ISNULL(cr.CountryId,'GT') =  @IdCountry
	AND fph.RowStatus = 1
	AND cr.RowStatus = 1
	ORDER BY fph.DateCreated DESC 

END