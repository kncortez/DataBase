
--drop procedure  [dbo].[spg_settlement_returned_guides_PickUp]
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-03-11>
-- Description:	<Recupera detalle para generar manifiesto de liquidación (PickUp)>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_not_arrived_guides_Linehauls]
		@IdManifest INT
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @manifestsequence int = (select Id from SettlementByPickup where SequenceCode = @IdManifest and SubTypeServiceManagmentId = 4)

	DECLARE @temp TABLE (
		Guide_Code	nvarchar(max),
		Pieces_Cold int,
		Pieces_Dry int,
		Receiver_Fullname nvarchar(201),
		Receiver_Address nvarchar(200),
		Receiver_Zone int,
		Receiver_Town nvarchar(100),
		Receiver_Departament nvarchar(100),
		Preparation_Date nvarchar(50),
		Shipping_Date nvarchar(50),
		Max_Date nvarchar(50),
		Receiver_Phone nvarchar(100),
		Rack_Position nvarchar(MAX),
		Collect_on_Delivery decimal(16,2)
	)

    -- tablix content
	INSERT INTO @temp
	SELECT
	do.Guide_Serie + isnull(convert(nvarchar,do.Guide_Number),'')+ '-'+ isnull(convert(nvarchar, dsd.NoPiece),'') as Guide_Code
	,(SELECT top 1 convert(int , sbp.PiecesCold ) FROM DeliveryBackOffice.dbo.SettlementByPickup sbp join SettlementByPickupDetail sbpd on (sbp.Id = sbpd.SettlementByPickupId) where  Id = @manifestsequence  ) AS Pieces_Cold
	,(SELECT top 1 convert(int, sbp.PiecesDry) FROM DeliveryBackOffice.dbo.SettlementByPickup sbp join SettlementByPickupDetail sbpd on (sbp.Id = sbpd.SettlementByPickupId) where Id = @manifestsequence ) as Pieces_Dry
	,isnull(do.Receiver_FirstName,'') + ' ' + isnull(do.Receiver_LastName,'') as Receiver_Fullname
	,do.Receiver_Address AS Receiver_Address
	,CONVERT(INT, ISNULL(do.Receiver_Zone,0)) AS Receiver_Zone
	,do.Receiver_Town AS Receiver_Town
	,do.Receiver_Department AS  Receiver_Departament
	,CONVERT(varchar, do.Preparation_Date, 103) + ' ' + CONVERT(varchar(5), do.Preparation_Date, 108) as Preparation_Date
	,CONVERT(varchar, do.Shipping_Date, 103) as Shipping_Date
	,isnull(CONVERT(varchar, do.Delivery_Max_Date, 103),'') as Max_Date
	,do.Receiver_Phone as Receiver_Phone
	,(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(do.Guide_Serie, do.Guide_Number)) as Rack_Position
	,Collect_OnDelivery
	from [DeliveryBackOffice].[dbo].DeliveryOrder do
	JOIN DeliveryBackOffice.dbo.SettlementByPickupDetail dsd ON dsd.GuideSerie = do.Guide_Serie AND dsd.GuideNumber = do.Guide_Number AND dsd.SettlementByPickupId = @manifestsequence
	where do.Guide_Serie = (SELECT DISTINCT TOP 1 GuideSerie FROM [DeliveryBackOffice].[dbo].[SettlementByPickupDetail] WHERE SettlementByPickupId = @manifestsequence)
	and do.Guide_Number IN (SELECT GuideNumber FROM [DeliveryBackOffice].[dbo].[SettlementByPickupDetail] WHERE SettlementByPickupId = @manifestsequence)
	AND dsd.IsPieceLiquidaded = 0 or dsd.IsPieceLiquidaded = NULL-- Pieza de la guia liquidada

	SELECT 
		Guide_Code,
		Pieces_Cold,
		Pieces_Dry,
		Receiver_Fullname,
		Receiver_Address,
		Receiver_Zone,
		Receiver_Town,
		Receiver_Departament,
		Preparation_Date,
		Shipping_Date,
		Max_Date,
		Receiver_Phone,
		Rack_Position,
		Collect_on_Delivery
	 FROM @temp
	order by Receiver_Departament asc, Receiver_Town asc, Receiver_Zone asc, Receiver_Address asc

END


--select * from DeliveryOrderPiece