
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-17>
-- Description:	<Muestra los pilotos asignados a una ruta en determinada fecha>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_RoutePilotAssigment]
		@idRoute as int,
		@dateRoute as date
AS
BEGIN
	SELECT rta.IdRoute,
	rta.IdCurrierMan,
	CONCAT(snr.First_Name, ' ', snr.Last_Name) as Name
	FROM [DeliveryBackOffice].[dbo].[RouteAssigment] as rta
	JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] as snr ON snr.ID = rta.IdCurrierMan
	WHERE rta.DateOfRoute = @dateRoute AND rta.IdRoute = @idRoute
END