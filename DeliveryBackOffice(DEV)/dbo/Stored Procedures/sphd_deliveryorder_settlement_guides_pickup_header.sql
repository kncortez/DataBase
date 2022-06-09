-- ==========================================j=
-- Author:		<Alberto,,Ixchop>
-- Create date: <2022-03-24>
-- Description:	<Obtiene los datos generales del manifiesto de recolecciones>
-- ============================================= 
CREATE PROCEDURE [dbo].[sphd_deliveryorder_settlement_guides_pickup_header]
	-- Add the parameters for the stored procedure here
		@idRoute AS int,
		@dateRoute AS date = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  
	SELECT 
		rat.IdRouteAssigment,
		CONCAT(snr.First_Name,' ',snr.Last_Name) as Courier,		
		rat.DateOfRoute,
		--count(IIF(dor.Guide_Number is not null and  dor.Guide_Serie is not  null,1,null)) guide_count,
		sum(smt.guide_count)guide_count,
		--sum(ISNULL(dor.Pieces_Cold,0)) cold_count,
		sum(smt.cold_count) cold_count,
		--sum(ISNULL(dor.Pieces_Dry,0)) dry_count,
		sum(smt.dry_count) dry_count,
		sum(smt.Amount) total,
		COUNT(1) TotalServices
		--,smt.IdServiceManagement
		--,smt.IdPuRouteAssigment
		--,smt.IdSchedulePickup
		 --,*
  from 
  [DeliveryBackOffice].[dbo].[RouteAssigment] as rat WITH(NOLOCK) 	
	join 
	(
		select  IdServiceManagement,IdPuRouteAssigment,IdSchedulePickup, (ISNULL(sm.Amount,0)) Amount,  
		count(IIF(dor.Guide_Number is not null and  dor.Guide_Serie is not  null,1,null)) guide_count,
		sum(ISNULL(dor.Pieces_Cold,0)) cold_count,
		sum(ISNULL(dor.Pieces_Dry,0)) dry_count
		from [DeliveryBackOffice].[dbo].[ServiceManagement]sm
		join [DeliveryBackOffice].[dbo].[SchedulePickup] as spu WITH(NOLOCK) on spu.SchedulePickupId = IdSchedulePickup 
		left join [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] as dop WITH(NOLOCK) ON sm.IdSchedulePickup=dop.IdHeaderRecolection
		left join[DeliveryBackOffice].[dbo].[DeliveryOrder] AS dor WITH(NOLOCK) ON dor.Guide_Number = dop.GuideNumber AND dor.Guide_Serie = dop.GuideSerie
		group by sm.Amount,IdServiceManagement,IdSchedulePickup,IdPuRouteAssigment
	)smt on smt.IdPuRouteAssigment = rat.IdRouteAssigment
	left join [DeliveryBackOffice].[dbo].[SenderReceiver] as snr WITH(NOLOCK) on rat.IdCurrierMan = snr.ID
	WHERE rat.IdRoute=@idRoute AND rat.DateOfRoute = @dateRoute
  
   GROUP BY 
	rat.IdRouteAssigment
	,rat.DateOfRoute
	,snr.First_Name
	,snr.Last_Name


END
