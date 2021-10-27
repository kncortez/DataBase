USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_deliveryorder_settlement_guides]    Script Date: 27/10/2021 11:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-09-17>
-- Description:	<Recupera información para generar manifiesto de despacho>
-- =============================================
ALTER PROCEDURE [dbo].[spg_deliveryorder_settlement_guides]
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
		Receiver_Zone NVARCHAR(50),
		Receiver_Town nvarchar(100),
		Receiver_Departament nvarchar(100),
		Preparation_Date nvarchar(50),
		Shipping_Date nvarchar(50),
		Max_Date nvarchar(50),
		Receiver_Phone nvarchar(100),
		Rack_Position nvarchar(MAX),
		Price decimal(16,2),
		Collect_on_Delivery decimal(16,2),
		Total decimal(16,2)

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
	,CONVERT(NVARCHAR,ISNULL(REPLACE(RTRIM(do.Receiver_Zone),CHAR(160),''),0)) AS Receiver_Zone
	,do.Receiver_Town AS Receiver_Town
	,do.Receiver_Department AS  Receiver_Departament
	,CONVERT(varchar, do.Preparation_Date, 103) + ' ' + CONVERT(varchar(5), do.Preparation_Date, 108) as Preparation_Date
	,CONVERT(varchar, do.Shipping_Date, 103) as Shipping_Date
	,isnull(CONVERT(varchar, do.Delivery_Max_Date, 103),'') as Max_Date
	,do.Receiver_Phone as Receiver_Phone
	,(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(do.Guide_Serie, do.Guide_Number)) as Rack_Position
	--,Collect_OnDelivery
	,ISNULL((CASE WHEN do.IsCollect = 'TRUE' THEN do.PriceShippment ELSE 0 END), 0) Price
	,ISNULL(do.Collect_OnDelivery, 0) Collect_on_Delivery
	,(CASE WHEN do.IsCollect = 'TRUE' THEN 
	ISNULL(do.Collect_OnDelivery, 0) + ISNULL(do.PriceShippment,0)
	ELSE 
	ISNULL(do.Collect_OnDelivery, 0)
	END
	) AS  Total
	from [DeliveryBackOffice].[dbo].DeliveryOrder do
	where do.Guide_Serie = (SELECT DISTINCT TOP 1 Guide_Serie FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] WHERE ID_DeliveryOrderBySettlement = @IdManifest)
	and do.Guide_Number IN (SELECT Guide_Number FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] WHERE ID_DeliveryOrderBySettlement = @IdManifest)

	SELECT * FROM @temp
	order by Receiver_Departament asc, Receiver_Town asc, Receiver_Zone asc, Receiver_Address asc

END
