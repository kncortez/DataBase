-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2022-03-24>
-- Description:	<Obtiene los datos detalles del manifiesto de recolecciones>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Update date: <2024-06-05>
-- Description: < Adicion de filtro para mostrar moneda corecta por pais, por defect GT >
-- =============================================
CREATE PROCEDURE [dbo].[sphd_deliveryorder_settlement_guides_pickup_detail]
	-- Add the parameters for the stored procedure here
		@idRoute AS int,
		@dateRoute AS date = '',
        @IdCountry AS VARCHAR(2) = 'GT'
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
		,CONCAT(
                CASE 
                    WHEN @IdCountry = 'GT' THEN 'Q.'
                    WHEN @IdCountry = 'HN' THEN 'L.'
                END,
                CAST(ISNULL(smt.Amount,'0') AS NVARCHAR)
               ) total
		,ISNULL(PT.TimePlaDescription,'') TimePay
		,ISNULL(smt.[Order], 1) [Order]
  from 
  [DeliveryBackOffice].[dbo].[RouteAssigment] as rat WITH(NOLOCK) 	
    INNER JOIN [DeliveryBackOffice].[dbo].[ServiceManagement] as smt WITH(NOLOCK) on smt.IdPuRouteAssigment = rat.IdRouteAssigment
    INNER JOIN [DeliveryBackOffice].[dbo].[SchedulePickup] as spu WITH(NOLOCK) on spu.SchedulePickupId = smt.IdSchedulePickup
	left join [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] as dop WITH(NOLOCK) ON spu.SchedulePickupId=dop.IdHeaderRecolection
	left join[DeliveryBackOffice].[dbo].[DeliveryOrder] AS dor WITH(NOLOCK) ON dor.Guide_Serie = dop.GuideSerie AND dor.Guide_Number = dop.GuideNumber
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
	,smt.[Order]
	ORDER BY smt.[Order], spu.SenderName DESC
END