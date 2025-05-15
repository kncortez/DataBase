
--drop procedure  [dbo].[spg_settlement_returned_guides_PickUp]
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-04-30>
-- Description:	<Recupera detalle para generar manifiesto de liquidación (Devolucion)>
-- =============================================
-- Author:		<Cristian, Azurdia>
-- Create date: <2025-05-02>
-- Description:	<Se agerga simoblo y país de la guias que conforman un manifiesto>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_Return_guides]
		@IdManifest INT
AS
BEGIN
	
	declare @manifestsequence int = (select Id from SettlementByPickup where SequenceCode = @IdManifest and SubTypeServiceManagmentId = 3)
	DECLARE @Currency INT = (SELECT IdCatCurrencyCOD FROM CatCurrencyCOD WHERE Symbol = 'Q')
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @temp TABLE (
		Guide_Code	nvarchar(max),
		Pieces_Cold int,
		Pieces_Dry int,
		Receiver_Fullname nvarchar(600),
		Receiver_Address nvarchar(600),
		Receiver_Zone int,
		Receiver_Town nvarchar(100),
		Receiver_Departament nvarchar(100),
		Preparation_Date nvarchar(50),
		Shipping_Date nvarchar(50),
		Max_Date nvarchar(50),
		Receiver_Phone nvarchar(100),
		Rack_Position nvarchar(MAX),
		Collect_on_Delivery decimal(16,2),
		ReceiverCountryId nvarchar(2),
		Symbol nvarchar(2)
	)

    -- tablix content
	INSERT INTO @temp
	SELECT
	distinct(do.Guide_Serie + isnull(convert(nvarchar,do.Guide_Number),'') + '-'+ isnull(convert(nvarchar, dsd.NoPiece),'')) as Guide_Code
	,case when (SELECT top 1 convert(int , sbp.PiecesCold ) FROM DeliveryBackOffice.dbo.SettlementByPickup sbp 
		join SettlementByPickupDetail sbpd on (sbp.Id = sbpd.SettlementByPickupId) 
		where  Id = @manifestsequence  ) >= 1 then 1 else 0  end  AS Pieces_Cold
	,case when (SELECT top 1 convert(int, sbp.PiecesDry) FROM DeliveryBackOffice.dbo.SettlementByPickup sbp
				 join SettlementByPickupDetail sbpd on (sbp.Id = sbpd.SettlementByPickupId) 
				 where Id = @manifestsequence ) >= 1 then 1 else 0 end  as Pieces_Dry
	,isnull(do.Sender_FirstName,'') + ' ' + isnull(do.Sender_LastName,'') as Receiver_Fullname
	,do.Sender_Address AS Receiver_Address
	,CONVERT(INT, ISNULL(do.Sender_Zone,0)) AS Receiver_Zone
	,do.Sender_Town AS Receiver_Town
	,do.Sender_Department AS  Receiver_Departament
	,CONVERT(varchar, do.Preparation_Date, 103) + ' ' + CONVERT(varchar(5), do.Preparation_Date, 108) as Preparation_Date
	,CONVERT(varchar, do.Shipping_Date, 103) as Shipping_Date
	,isnull(CONVERT(varchar, do.Delivery_Max_Date, 103),'') as Max_Date
	,do.Sender_Phone as Receiver_Phone
	,(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(do.Guide_Serie, do.Guide_Number)) as Rack_Position
	,Collect_OnDelivery
	,ISNULL(do.ReceiverCountryId,'GT') AS ReceiverCountryId
	,CCU.Symbol
	from [DeliveryBackOffice].[dbo].DeliveryOrder do WITH(NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.SettlementByPickupDetail dsd WITH(NOLOCK) ON 
	dsd.GuideSerie = do.Guide_Serie 
	AND dsd.GuideNumber = do.Guide_Number 
	INNER JOIN DeliveryBackOffice.dbo.Cost co WITH(NOLOCK)
		ON  do.Guide_Number = co.GuideNumber 
		AND do.Guide_Serie = co.GuideSerie
	INNER JOIN CatCurrencyCOD CCU WITH (NOLOCK)
		ON ISNULL(co.ShippingCurrency,@Currency) = CCU.IdCatCurrencyCOD
	where do.Guide_Serie = (SELECT DISTINCT TOP 1 GuideSerie FROM [DeliveryBackOffice].[dbo].[SettlementByPickupDetail] WITH(NOLOCK) WHERE SettlementByPickupId = @manifestsequence)
	and do.Guide_Number IN (SELECT GuideNumber FROM [DeliveryBackOffice].[dbo].[SettlementByPickupDetail] WHERE SettlementByPickupId = @manifestsequence)
	AND dsd.IsPieceLiquidaded = 1 -- Pieza de la guia liquidada
	AND dsd.SettlementByPickupId = @manifestsequence

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
		Collect_on_Delivery,
		ReceiverCountryId,
		Symbol
	FROM @temp
	order by Receiver_Departament asc, Receiver_Town asc, Receiver_Zone asc, Receiver_Address asc

END
