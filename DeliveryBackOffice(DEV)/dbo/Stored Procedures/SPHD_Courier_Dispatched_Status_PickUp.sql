


-- =============================================
-- Author:		 <Edelman Vasquez>
-- Create date:  <08/Junio/2023>
-- Description:	 <Listado de afiliados y su status actual sobre recolección>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_Courier_Dispatched_Status_PickUp]
	@DispatchedDate DATE
AS
BEGIN
	SET NOCOUNT ON;


SELECT 
	[CourierRoutesData].[ID_Courier],
    MAX([CourierRoutesData].[Nombre_Courier]) [Nombre_Courier],
    SUM(ISNULL([CourierRoutesData].[Cantidad_de_Servicios], 0)) [Cantidad_de_Servicios],
    SUM(ISNULL([CourierRoutesData].[Servicios_Recolectados], 0)) [Servicios_Recolectados],
    SUM(ISNULL([CourierRoutesData].[Guías_Recolectadas], 0)) [Guías_Recolectadas],
    SUM(ISNULL([CourierRoutesData].[Servicio_con_Incidencias], 0)) [Servicio_con_Incidencias],
    SUM(ISNULL([CourierRoutesData].[Piezas_Recolectadas], 0) ) [Piezas_Recolectadas]
FROM
	(
		SELECT 
		SR.ID AS ID_Courier,
		SR.First_Name + ' ' + SR.Last_Name AS Nombre_Courier,
		COUNT(DISTINCT SM.IdServiceManagement) AS Cantidad_de_Servicios,
		COUNT(DISTINCT   CASE
		WHEN SM.ServiceStatusId = 3 THEN
		SM.IdServiceManagement
		ELSE
		NULL
		END
		) AS Servicios_Recolectados,
		COUNT(DISTINCT   CASE
		WHEN SM.ServiceStatusId = 3 THEN
		DOPD.GuideNumber
		ELSE
		NULL
		END
		) AS Guías_Recolectadas,

		COUNT(DISTINCT   CASE
		WHEN SM.ServiceStatusId = 4 THEN
		SM.IdServiceManagement
		ELSE
		NULL
		END
		) AS Servicio_con_Incidencias,
		COUNT(DOPaux.Detail) AS Piezas_Recolectadas
		FROM [DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH (NOLOCK)
		INNER JOIN [DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH (NOLOCK)
		ON SP.SchedulePickupId = SM.IdSchedulePickup 
		INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
		ON SP.SchedulePickupId = DOPD.IdHeaderRecolection
		INNER JOIN [DeliveryBackOffice].[DBO].[SenderReceiver] SR WITH (NOLOCK)
		ON SM.IdPuCourrier = SR.ID
		INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOPaux WITH (NOLOCK)
		ON                [DOPaux].[GuideSerie] = [DOPD].[GuideSerie]
		AND
		[DOPaux].[GuideNumber] = [DOPD].[GuideNumber]
		WHERE CONVERT(DATE,SM.DateCreated)= @DispatchedDate
		GROUP BY 
		SR.ID,
		SR.First_Name,
		SR.Last_Name,
		SM.ServiceStatusId ,
		SM.IdServiceManagement
	) CourierRoutesData
GROUP BY
	[CourierRoutesData].[ID_Courier]
END