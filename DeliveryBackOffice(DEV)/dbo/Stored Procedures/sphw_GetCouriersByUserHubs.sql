
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-10-21>
-- Description:	<Devuelve todos los couriers basado en los hubs del usuario interno>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-12-07>
-- Description:	<Asociar Usuario Interno con Courierman a travéz de tabla dbo.SenderReceiverbyUser>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_GetCouriersByUserHubs]
	@userId BIGINT = NULL

AS
BEGIN
    SET ARITHABORT ON;

	SELECT 200 'StatusCode', 
			'Registros obtenidos'	'Description';
	--INSERT INTO @tbl
	SELECT 
		SR.ID 'IdCourier',
		LTRIM(RTRIM(CONCAT(SR.First_Name,' ',SR.Last_Name))) 'CourierName',
		SR.CUI 'CourierCUI',
		SR.Phone 'CourierPhone'
	FROM dbo.SenderReceiver sr WITH(NOLOCK)
		INNER JOIN dbo.HubLogisticByUser hlbu WITH(NOLOCK)
			ON sr.HubLogisticId = hlbu.HubLogisticId
				AND hlbu.UserId = @userId
		INNER JOIN [DeliveryBackOffice].[dbo].[SenderReceiverByUser] sru WITH(NOLOCK)
		    ON sr.ID=sru.SenderReceiverId

END;