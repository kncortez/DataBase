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
		@idRoute AS int,
		@dateRoute AS date
AS
BEGIN
  SELECT spu.SchedulePickupId, 
		spu.SenderName [Name],
		spu.AddressPickup [Address],
		spu.SenderPhone [Phone],
		CONCAT(CONVERT(varchar(10), spu.StartDate, 108), '   ', CONVERT(varchar(10), spu.EndDate, 108)) as rangeHour,
		spu.QuantityRegularPackages,
		spu.QuantityOverDimensionedPackage,
		CONCAT(snr.First_Name,' ',snr.Last_Name) as NameCourrier,
		css.Name as NameStatus,
		ISNULL(smt.Amount,0) Amount,
		smt.IdServiceManagement IdServiceManagement,
		smt.[Order] [Order],
		spu.IsScheduled IsScheduled
  from [DeliveryBackOffice].[dbo].[SchedulePickup] as spu WITH(NOLOCK)
  inner join [DeliveryBackOffice].[dbo].[ServiceManagement] as smt WITH(NOLOCK) on spu.SchedulePickupId = smt.IdSchedulePickup
  inner join [DeliveryBackOffice].[dbo].[RouteAssigment] as rat WITH(NOLOCK) on smt.IdPuRouteAssigment = rat.IdRouteAssigment
  left join [DeliveryBackOffice].[dbo].[SenderReceiver] as snr WITH(NOLOCK) on rat.IdCurrierMan = snr.ID
  left join [DeliveryBackOffice].[dbo].[CatServiceStatus] as css WITH(NOLOCK) on css.IdServiceStatus = smt.ServiceStatusId
  where rat.IdRoute = @idRoute and rat.DateOfRoute = @dateRoute AND spu.AssigmentStatus = '1'
END
