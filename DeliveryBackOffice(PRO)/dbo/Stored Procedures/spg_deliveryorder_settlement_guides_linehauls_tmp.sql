
CREATE PROCEDURE [dbo].[spg_deliveryorder_settlement_guides_linehauls_tmp]
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
	
	--INSERT INTO @temp
	SELECT 
	/*DISTINCT
		 pc.GuideSerie + cast(pc.GuideNumber as varchar(50)) + '-' + CAST(pc.NoPiece AS VARCHAR(10)) as Guide_Code
		,CASE when isnull(pc.IsDry,0) = 0 then 1 else 0 end  AS Pieces_Cold
		,CASE when isnull(pc.IsDry,0) = 1 then pc.IsDry  else 0 end  AS Pieces_Dry
		,isnull(do.Receiver_FirstName,'') + ' ' + isnull(do.Receiver_LastName,'') as Receiver_Fullname
		,do.Receiver_Address AS Receiver_Address
	,CONVERT(VARCHAR, ISNULL(do.Receiver_Zone,0)) AS Receiver_Zone
	,do.Receiver_Town AS Receiver_Town
	,do.Receiver_Department AS  Receiver_Departament
	,CONVERT(varchar, do.Preparation_Date, 103) + ' ' + CONVERT(varchar(5), do.Preparation_Date, 108) as Preparation_Date
	,CONVERT(varchar, do.Shipping_Date, 103) as Shipping_Date
	,isnull(CONVERT(varchar, do.Delivery_Max_Date, 103),'') as Max_Date
	,do.Receiver_Phone as Receiver_Phone
	,(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(do.Guide_Serie, do.Guide_Number)) as Rack_Position
	--,Collect_OnDelivery
	,(case when isnull(do.Collect_OnDelivery,0) != 0 then --do.IsCollect = 'TRUE' then 
	--CAST(CAST((isnull(do.Collect_OnDelivery,0.00) + isnull(do.PriceShippment,0.00)) AS DECIMAL) as VARCHAR) 
	CAST((isnull(do.Collect_OnDelivery,0.00) + isnull(do.PriceShippment,0.00)) AS VARCHAR) 
	else 
	'0.00'
	end
	) AS  Collect_OnDelivery
	*/
	*
	FROM DeliveryOrder do
	INNER JOIN DeliveryOrderPiece pc
		ON pc.GuideSerie = do.Guide_Serie
			AND pc.GuideNumber = do.Guide_Number
	JOIN dbo.PieceByService pbs
		ON pc.GuidePiece = pbs.GuidePieceId
	JOIN ServiceManagement sm
		ON pbs.ServiceManagmentId = sm.IdServiceManagement
	JOIN SettlementByPickup sbp ON sm.IdServiceManagement = sbp.ServiceManagmentId AND
	sbp.SequenceCode = @IdManifest and sbp.SubTypeServiceManagmentId = 4
	JOIN SettlementByPickupDetail sbpd ON sbp.Id = sbpd.SettlementByPickupId AND sbpd.IsDispatched = 1
	AND sbpd.RowStatus = 1

	--SELECT * FROM @temp
	--order by Receiver_Departament asc, Receiver_Town asc, Receiver_Zone asc, Receiver_Address asc

END
