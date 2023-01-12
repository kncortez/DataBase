-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-13>
-- Description:	<Obtiene las rutas con servicios ya asignados>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <2020-03-21>
-- Description:	< Adición de WITH(NOLOCK) para evitar bloqueos >
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_RouteServiceAssigment]
		@idRoute AS INT,
		@dateRoute AS DATE
AS
BEGIN
    SELECT spu.SchedulePickupId,
           spu.SenderName [Name],
           spu.AddressPickup [Address],
           spu.SenderPhone [Phone],
           CONCAT(CONVERT(VARCHAR(10), spu.StartDate, 108), '   ', CONVERT(VARCHAR(10), spu.EndDate, 108)) AS rangeHour,
           spu.QuantityRegularPackages,
           spu.QuantityOverDimensionedPackage,
           CONCAT(snr.First_Name, ' ', snr.Last_Name) AS NameCourrier,
           css.Name AS NameStatus,
           ISNULL(smt.Amount, 0) Amount,
           smt.IdServiceManagement IdServiceManagement,
		   smt.[Order] [Order],
		   spu.IsScheduled IsScheduled
    FROM [DeliveryBackOffice].[dbo].[SchedulePickup] AS spu WITH (NOLOCK)
        JOIN [DeliveryBackOffice].[dbo].[ServiceManagement] AS smt WITH (NOLOCK)
            ON spu.SchedulePickupId = smt.IdSchedulePickup
        JOIN [DeliveryBackOffice].[dbo].[RouteAssigment] AS rat WITH (NOLOCK)
            ON smt.IdPuRouteAssigment = rat.IdRouteAssigment
        LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] AS snr WITH (NOLOCK)
            ON rat.IdCurrierMan = snr.ID
        LEFT JOIN [DeliveryBackOffice].[dbo].[CatServiceStatus] AS css WITH (NOLOCK)
            ON css.IdServiceStatus = smt.ServiceStatusId
    WHERE rat.IdRoute = @idRoute
          AND rat.DateOfRoute = @dateRoute
          AND spu.AssigmentStatus = '1';
END;
