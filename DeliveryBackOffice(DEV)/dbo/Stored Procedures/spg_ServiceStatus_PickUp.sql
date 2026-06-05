/* =================================================
   SP:        [dbo].[spg_ServiceStatus_PickUp] 
   Propósito: <Validar estados de recolección por ruta, identificando que todos fueron efectivos recolectados.>
   Autor:     Caleb Loarca
   Historia:  <FDAPI-5683>
   Fecha:     <2026-04-14>
   === CHANGELOG ============================

=========================================== */

CREATE PROCEDURE [dbo].[spg_ServiceStatus_PickUp] 
@Route AS VARCHAR(100) -- = 'GUA001'
AS

BEGIN
    DECLARE @tiempo DATE =
            (
                SELECT CAST(GETDATE() AS DATE)
            );
			  
   
	/*	TABLE 0 
		Estado de los Servicios (Recolectados ó pendientes)
	*/

	SELECT 
		ra.IdRoute,
		cr.CodeRoute,
		ra.IdCurrierMan,
		sm.IdServiceManagement,
		sm.ServiceStatusId,
		css.Name
	FROM DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
            ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
		INNER JOIN DeliveryBackOffice.dbo.CatServiceStatus css WITH(NOLOCK)
			ON sm.ServiceStatusId = css.IdServiceStatus
		INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK)
			ON ra.IdRoute = cr.IdRoute
	WHERE ra.DateOfRoute = @tiempo 
		AND sm.ServiceStatusId IN (1,2)
		AND cr.CodeRoute= @Route
	
END;