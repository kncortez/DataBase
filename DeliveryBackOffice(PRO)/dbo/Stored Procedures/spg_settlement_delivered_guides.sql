

-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-11-24>
-- Description:	<Recupera detalle para generar manifiesto de liquidación (entregas)>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_delivered_guides]
		@IdManifest INT
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @temp TABLE (
		Guide_Code	nvarchar(max),
		Pieces_Cold int,
		Pieces_Dry int,
		Receiver_Fullname nvarchar(201),
		Receiver_Address nvarchar(600),
		Receiver_Zone nvarchar(100),
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
	do.Guide_Serie + isnull(convert(nvarchar,do.Guide_Number),'') as Guide_Code
	,(SELECT SUM(CAST([Cold] AS INT)) FROM DeliveryBackOffice.dbo.DeliveryAttempt where Guide_Serie = do.Guide_Serie AND Guide_Number = do.Guide_Number AND ID_DeliveryOrderBySettlement = @IdManifest GROUP BY Guide_Serie, Guide_Number, ID_DeliveryOrderBySettlement) AS Pieces_Cold
	,(SELECT SUM(CAST([Dry] AS INT)) FROM DeliveryBackOffice.dbo.DeliveryAttempt where Guide_Serie = do.Guide_Serie AND Guide_Number = do.Guide_Number AND ID_DeliveryOrderBySettlement = @IdManifest GROUP BY Guide_Serie, Guide_Number, ID_DeliveryOrderBySettlement) as Pieces_Dry
	,(CASE WHEN [do].[IsLastMileReturn] = 1 THEN isnull(do.[Sender_FirstName],'') + ' ' + isnull(do.[Sender_LastName],'') ELSE isnull(do.Receiver_FirstName,'') + ' ' + isnull(do.Receiver_LastName,'') END) as Receiver_Fullname
	,(CASE WHEN [do].[IsLastMileReturn] = 1 THEN do.[Sender_Address] ELSE do.Receiver_Address END) AS Receiver_Address
	,CONVERT(nvarchar, ISNULL((CASE WHEN do.[IsLastMileReturn] = 1 THEN do.[Sender_Zone] ELSE do.Receiver_Zone END),0)) AS Receiver_Zone
	,(CASE WHEN do.[IsLastMileReturn] = 1 THEN do.[Sender_Town] ELSE do.Receiver_Town END) AS Receiver_Town
	,(CASE WHEN do.[IsLastMileReturn] = 1 THEN do.[Sender_Department] ELSE do.Receiver_Department END) AS  Receiver_Departament
	,CONVERT(varchar, do.Preparation_Date, 103) + ' ' + CONVERT(varchar(5), do.Preparation_Date, 108) as Preparation_Date
	,CONVERT(varchar, do.Shipping_Date, 103) as Shipping_Date
	,isnull(CONVERT(varchar, do.Delivery_Max_Date, 103),'') as Max_Date
	,do.Receiver_Phone as Receiver_Phone
	,(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(do.Guide_Serie, do.Guide_Number)) as Rack_Position
	--,Collect_OnDelivery
	,(case when do.IsCollect = 'TRUE' then 
	isnull((CASE WHEN do.[IsLastMileReturn] = 1 THEN 0 ELSE do.Collect_OnDelivery END ),0)+isnull((CASE WHEN [do].[IsLastMileReturn] = 1 THEN CASE WHEN ISNULL(cdp.IdConditionOfPayment, 1) > 1 THEN 0 ELSE do.PriceShippment END ELSE do.PriceShippment END),0)
	else 
	isnull((CASE WHEN do.[IsLastMileReturn] = 1 THEN 0 ELSE do.Collect_OnDelivery END),0) 
	end
	) AS  Collect_OnDelivery
	from [DeliveryBackOffice].[dbo].DeliveryOrder do  WITH(NOLOCK) 
	INNER JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail dsd  WITH(NOLOCK)  ON dsd.Guide_Serie = do.Guide_Serie AND dsd.Guide_Number = do.Guide_Number AND dsd.ID_DeliveryOrderBySettlement = @IdManifest AND dsd.RowStatus = 1
	LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vp WITH(NOLOCK)
			ON do.Receiver_ID = vp.CodeOfReference
		LEFT JOIN [dbo].VisitPointClient vps WITH(NOLOCK)
			ON vps.CodeOfReference = do.Sender_ID
		LEFT JOIN [dbo].[Customer] cu WITH(NOLOCK)
			ON ISNULL(do.[IdCustomer], vps.CustomerID) = cu.[IdCustomer]
		LEFT JOIN dbo.CatConditionOfPayment cdp WITH (NOLOCK)
            ON cdp.IdConditionOfPayment = cu.ConditionOfPaymentID
               AND cdp.IdConditionOfPayment > 1
	WHERE do.Guide_Serie = (SELECT DISTINCT TOP 1 Guide_Serie FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] WHERE ID_DeliveryOrderBySettlement = @IdManifest)
	and do.Guide_Number IN (SELECT Guide_Number FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] WHERE ID_DeliveryOrderBySettlement = @IdManifest AND RowStatus = 1)
	AND dsd.Guide_Settlement = 1 -- guía liquidada en bodega
	AND dsd.Guide_Returned = 0  -- guía liquidada vía material devuelto
	AND dsd.Guide_Delivered = 1  -- guía liquidada vía comprobante de entrega


	SELECT * FROM @temp
	order by Receiver_Departament asc, Receiver_Town asc, Receiver_Zone asc, Receiver_Address asc

END
