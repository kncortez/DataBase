-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2022-03-24>
-- Description:	<Obtiene los datos detalles del manifiesto de recolecciones>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_deliveryorder_settlement_guides_pickup_detail]
	-- Add the parameters for the stored procedure here
		@idRoute AS int,
		@dateRoute AS date = ''	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  	SELECT 
		spu.SenderName [Name]
		,count(IIF(dor.Guide_Number is not null and  dor.Guide_Serie is not  null,1,null)) guide_count
		,sum(ISNULL(dor.Pieces_Cold,0)) cold_count
		,sum(ISNULL(dor.Pieces_Dry,0)) dry_count
		,spu.AddressPickup Address
		,ISNULL(dor.Sender_Zone,'0') Zone
		,(CASE
			WHEN dor.Sender_Town IS NOT NULL THEN dor.Sender_Town
			WHEN spu.TownshipId IS NOT NULL THEN twnT.TownshipName
			ELSE ''
		END) AS Town
		,ISNULL(IIF(spu.SenderPhone='NULL','',spu.SenderPhone),'') Phone		
		,ISNULL(smt.Amount,'0') total
		,ISNULL(PT.TimePlaDescription,'') TimePay

  from 
  [DeliveryBackOffice].[dbo].[RouteAssigment] as rat WITH(NOLOCK) 	
	join [DeliveryBackOffice].[dbo].[ServiceManagement] as smt WITH(NOLOCK) on smt.IdPuRouteAssigment = rat.IdRouteAssigment
	join [DeliveryBackOffice].[dbo].[SchedulePickup] as spu WITH(NOLOCK) on spu.SchedulePickupId = smt.IdSchedulePickup
	left join [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] as dop WITH(NOLOCK) ON spu.SchedulePickupId=dop.IdHeaderRecolection
	left join[DeliveryBackOffice].[dbo].[DeliveryOrder] AS dor WITH(NOLOCK) ON dor.Guide_Number = dop.GuideNumber AND dor.Guide_Serie = dop.GuideSerie
	left join [DeliveryBackOffice].[dbo].[Township] twnT WITH(NOLOCK) ON spu.TownshipId = twnT.IdTownship
	left join [DeliveryBackOffice].[dbo].[CatPaymentTime] PT WITH(NOLOCK) ON PT.TimePlaId = SMT.CatPaymentTimeId
	WHERE rat.IdRoute=@idRoute AND DateOfRoute = @dateRoute
  GROUP BY 
	spu.SenderName
	,spu.AddressPickup
	,dor.Sender_Zone
	,spu.SenderPhone
	,dor.Sender_Town
	,spu.TownshipId
	,twnT.TownshipName
	,smt.Amount
	,smt.IdServiceManagement
	,PT.TimePlaDescription
END
GO
