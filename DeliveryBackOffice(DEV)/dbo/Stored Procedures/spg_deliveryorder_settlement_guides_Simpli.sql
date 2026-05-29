


-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-09-17>
-- Description:	<Recupera información para generar manifiesto de despacho>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-09-24>
-- Description:	<Recupera información para generar manifiesto de despacho con orden dada por simpliroute>
-- =============================================
CREATE PROCEDURE [dbo].[spg_deliveryorder_settlement_guides_Simpli]
		@IdManifest INT
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	-- EXEC [spg_deliveryorder_settlement_guides_Simpli] @idManifest=32103;

	SET NOCOUNT ON;

	DECLARE @temp TABLE (
		Guide_Code	nvarchar(max),
		Pieces_Cold int,
		Pieces_Dry int,
		Receiver_Fullname nvarchar(201),
		Receiver_Address nvarchar(600),
		Receiver_Zone int,
		Receiver_Town nvarchar(100),
		Receiver_Departament nvarchar(100),
		Preparation_Date nvarchar(50),
		Shipping_Date nvarchar(50),
		Max_Date nvarchar(50),
		Receiver_Phone nvarchar(100),
		Rack_Position nvarchar(MAX),
		Collect_on_Delivery decimal(16,2)
		,GuideOrder INT
	)

    -- tablix content
	INSERT INTO @temp
	SELECT
	do.Guide_Serie + isnull(convert(nvarchar,do.Guide_Number),'') as Guide_Code
	,(SELECT SUM(CAST([Cold] AS INT)) FROM DeliveryBackOffice.dbo.DeliveryAttempt where Guide_Serie = do.Guide_Serie AND Guide_Number = do.Guide_Number AND ID_DeliveryOrderBySettlement = @IdManifest GROUP BY Guide_Serie, Guide_Number, ID_DeliveryOrderBySettlement) AS Pieces_Cold
	,(SELECT SUM(CAST([Dry] AS INT)) FROM DeliveryBackOffice.dbo.DeliveryAttempt where Guide_Serie = do.Guide_Serie AND Guide_Number = do.Guide_Number AND ID_DeliveryOrderBySettlement = @IdManifest GROUP BY Guide_Serie, Guide_Number, ID_DeliveryOrderBySettlement) as Pieces_Dry
	,isnull(do.Receiver_FirstName,'') + ' ' + isnull(do.Receiver_LastName,'') as Receiver_Fullname
	,do.Receiver_Address AS Receiver_Address
	--,CONVERT(INT, ISNULL(do.Receiver_Zone,0)) AS Receiver_Zone
	,CONVERT(INT,ISNULL(REPLACE(RTRIM(REPLACE(do.Receiver_Zone,'.','')),CHAR(160),''),0)) AS Receiver_Zone
	,do.Receiver_Town AS Receiver_Town
	,do.Receiver_Department AS  Receiver_Departament
	,CONVERT(varchar, do.Preparation_Date, 103) + ' ' + CONVERT(varchar(5), do.Preparation_Date, 108) as Preparation_Date
	,CONVERT(varchar, do.Shipping_Date, 103) as Shipping_Date
	,isnull(CONVERT(varchar, do.Delivery_Max_Date, 103),'') as Max_Date
	,do.Receiver_Phone as Receiver_Phone
	,(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(do.Guide_Serie, do.Guide_Number)) as Rack_Position
	--,Collect_OnDelivery
	,(case when do.IsCollect = 'TRUE' then 
	CONVERT(VARCHAR, CAST((isnull(do.Collect_OnDelivery,0) + isnull(do.PriceShippment,0)) AS DECIMAL), 1) 
	else 
	CONVERT(VARCHAR, CAST((isnull(do.Collect_OnDelivery,0)) AS DECIMAL), 1) 
	end
	) AS  Collect_OnDelivery
	,IIF(ISNULL(DSD.GuideOrder,0) > 0, DSD.GuideOrder, 999)
	from [DeliveryBackOffice].[dbo].DeliveryOrder do with (nolock) 
	left join DeliveryBackOffice.dbo.DeliverySettlementDetail dsd with (nolock)  
	on do.Guide_Serie = dsd.Guide_Serie and do.Guide_Number = dsd.Guide_Number and dsd.ID_DeliveryOrderBySettlement = @IdManifest and dsd.RowStatus = 1
	where do.Guide_Serie = (SELECT DISTINCT TOP 1 Guide_Serie FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] WHERE ID_DeliveryOrderBySettlement = @IdManifest)
	and do.Guide_Number IN (SELECT Guide_Number FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] WHERE ID_DeliveryOrderBySettlement = @IdManifest and RowStatus = 1)

	SELECT * FROM @temp
	order by
	GuideOrder asc,
	Receiver_Departament asc,
	Receiver_Town asc,
	Receiver_Zone asc, 
	Receiver_Address asc

END