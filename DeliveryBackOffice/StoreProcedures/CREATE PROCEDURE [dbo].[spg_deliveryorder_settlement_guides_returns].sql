USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_deliveryorder_settlement_guides_linehauls]    Script Date: 29/04/2021 16:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spg_deliveryorder_settlement_guides_returns]
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
	SELECT DISTINCT
		 pc.GuideSerie + cast(pc.GuideNumber as varchar(50)) + '-' + CAST(pc.NoPiece AS VARCHAR(10)) as Guide_Code
		,0 AS Pieces_Cold
		,1 AS Pieces_Dry
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
	--,Collect_OnDelivery
	,(case when do.IsCollect = 'TRUE' then 
	CONVERT(VARCHAR, CAST((isnull(do.Collect_OnDelivery,0) + isnull(do.PriceShippment,0)) AS DECIMAL), 1) 
	else 
	CONVERT(VARCHAR, CAST((isnull(do.Collect_OnDelivery,0)) AS DECIMAL), 1) 
	end
	) AS  Collect_OnDelivery
	FROM DeliveryOrder do
	INNER JOIN DeliveryOrderPiece pc
		ON pc.GuideSerie = do.Guide_Serie
			AND pc.GuideNumber = do.Guide_Number
	JOIN dbo.PieceByService pbs
		ON pc.GuidePiece = pbs.GuidePieceId
	JOIN ServiceManagement sm
		ON pbs.ServiceManagmentId = sm.IdServiceManagement
	JOIN SettlementByPickup sbp ON sm.IdServiceManagement = sbp.ServiceManagmentId AND
	sbp.SequenceCode = @IdManifest
	JOIN SettlementByPickupDetail sbpd ON sbp.Id = sbpd.SettlementByPickupId AND sbpd.IsDispatched = 1
	AND sbpd.RowStatus = 1

	SELECT * FROM @temp
	order by Receiver_Departament asc, Receiver_Town asc, Receiver_Zone asc, Receiver_Address asc

END
