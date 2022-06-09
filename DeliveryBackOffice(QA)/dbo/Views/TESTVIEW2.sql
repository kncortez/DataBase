
--DROP VIEW TESTVIEW
CREATE VIEW [dbo].[TESTVIEW2]
  AS SELECT spu.SchedulePickupId, 
		spu.SenderName [Name],
		spu.AddressPickup [Address],
		spu.SenderPhone [Phone],
		CONCAT(CONVERT(varchar(10), spu.StartDate, 108), '   ', CONVERT(varchar(10), spu.EndDate, 108)) as rangeHour,
		spu.QuantityRegularPackages,
		spu.QuantityOverDimensionedPackage,
		CONCAT(snr.First_Name,' ',snr.Last_Name) as NameCourrier,
		css.Name as NameStatus
		--ISNULL(smt.Amount,0) Amount
  from [DeliveryBackOffice].[dbo].[SchedulePickup] as spu WITH(NOLOCK)
  join [DeliveryBackOffice].[dbo].[ServiceManagement] as smt WITH(NOLOCK) on spu.SchedulePickupId = smt.IdSchedulePickup
  join [DeliveryBackOffice].[dbo].[RouteAssigment] as rat WITH(NOLOCK) on smt.IdPuRouteAssigment = rat.IdRouteAssigment
  left join [DeliveryBackOffice].[dbo].[SenderReceiver] as snr WITH(NOLOCK) on rat.IdCurrierMan = snr.ID
  left join [DeliveryBackOffice].[dbo].[CatServiceStatus] as css WITH(NOLOCK) on css.IdServiceStatus = smt.ServiceStatusId
