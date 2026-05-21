/* =================================================
   SP:        GetBatchPODByHand
   Propósito: Se crea SP para obtener todos los lotes de recolección Manual que aun no han sido procesados para el servicio
   Autor:     Caleb Loarca
   Historia:  ---
   Fecha:     2026-03-30

=== CHANGELOG ============================
2026-05-21 | Historia/épica: FDAPI-6320  | Autor: Caleb Loarca | Se Agrega validación del tipo de servicio recolección  Manual para identificar solamente servicios manuales.
2026-03-30 | Historia/épica: FDAPI-5681  | Autor: Caleb Loarca | Se usa de base GetBatchPOD, Se obtienen todos los lotes de recoleccion manual que aun no han sido procesados para el servicio
=========================================== */
CREATE PROCEDURE [dbo].[GetBatchPODByHand]
    @IdCountry NVARCHAR(2)= 'GT'
AS
BEGIN
	DECLARE @CreateStatus INT;
	DECLARE @IdRecoByHand INT;
	DECLARE @FechaActual DATE =  DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0);
	DECLARE @FechaProximaSiguiente DATE = DATEADD(day, DATEDIFF(day, 0, GETDATE()), 1)

	SET @CreateStatus = (SELECT IdServiceStatus FROM DeliveryBackOffice.dbo.CatServiceStatus WITH(NOLOCK) WHERE [Name] = 'Asignado a Ruta')

	SET @IdRecoByHand = (SELECT IdSubTypeServiceManagment FROM DeliveryBackOffice.dbo.SubTypeServiceManagment WITH(NOLOCK) 
	where Name like'Recolección Manual')

	SELECT fph.SchedulePickupId,
		   fph.DateCreated,
		   sm.SubTypeServiceManagmentId
	FROM DeliveryBackOffice.dbo.FinishPickUpHeader fph WITH(NOLOCK) 
	INNER JOIN DeliveryBackOffice.dbo.SchedulePickup sp WITH(NOLOCK) 
		ON sp.SchedulePickupId = fph.SchedulePickupId
	INNER JOIN DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK) 
		ON sm.IdSchedulePickup = sp.SchedulePickupId
	INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) 
		ON fph.StationId = cs.IdStation
	WHERE 
	fph.ServiceStatusId =  @CreateStatus
    AND ISNULL(cs.CountryId,'GT') = @IdCountry
	AND sm.SubTypeServiceManagmentId = @IdRecoByHand
    AND fph.DateCreated >= @FechaActual
    AND fph.DateCreated <  @FechaProximaSiguiente
	AND fph.RowStatus = 1	
	ORDER BY fph.DateCreated ASC 

END


