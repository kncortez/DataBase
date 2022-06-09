
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
		Receiver_Zone nvarchar(100),
		Receiver_Town nvarchar(100),
		Receiver_Departament nvarchar(100),
		Preparation_Date nvarchar(50),
		Shipping_Date nvarchar(50),
		Max_Date nvarchar(50),
		Receiver_Phone nvarchar(100),
		Price decimal(16,2)

	)


 -- tablix content
	INSERT INTO @temp
		SELECT DISTINCT
		 do.Guide_Serie + cast(do.Guide_Number as varchar(50)) as Guide_Code
		,(SELECT COUNT(*) FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop
			JOIN DeliveryBackOffice.dbo.PieceByService pbs ON pbs.GuidePieceId = dop.GuidePiece
			WHERE dop.GuideNumber=do.Guide_Number AND dop.GuideSerie =do.Guide_Serie AND dop.IsDry=0
		 ) AS Pieces_Cold
		, (SELECT COUNT(*) FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop
			JOIN DeliveryBackOffice.dbo.PieceByService pbs ON pbs.GuidePieceId = dop.GuidePiece
			WHERE dop.GuideNumber=do.Guide_Number AND dop.GuideSerie =do.Guide_Serie AND dop.IsDry=1
		 ) AS Pieces_Dry
		,isnull(do.Sender_FirstName,'') + ' ' + isnull(do.Sender_LastName,'') as Receiver_Fullname
		,do.Sender_Address AS Receiver_Address
	,CONVERT(nvarchar, ISNULL(do.Sender_Zone,0)) AS Receiver_Zone
	,do.Sender_Town AS Receiver_Town
	,do.Sender_Department AS  Receiver_Departament
	,CONVERT(varchar, do.Preparation_Date, 103) + ' ' + CONVERT(varchar(5), do.Preparation_Date, 108) as Preparation_Date
	,CONVERT(varchar, do.Shipping_Date, 103) as Shipping_Date
	,isnull(CONVERT(varchar, do.Delivery_Max_Date, 103),'') as Max_Date
	,do.Sender_Phone as Receiver_Phone
	,sbpd.Price  Price
 FROM DeliveryOrder do
	INNER JOIN DeliveryOrderPiece pc
		ON pc.GuideSerie = do.Guide_Serie
			AND pc.GuideNumber = do.Guide_Number
	JOIN dbo.PieceByService pbs
		ON pc.GuidePiece = pbs.GuidePieceId
	JOIN SettlementByPickupDetail sbpd ON do.Guide_Number = sbpd.GuideNumber and sbpd.IsDispatched = 1
	JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail dop ON dop.GuideNumber = do.Guide_Number AND dop.GuideSerie = do.Guide_Serie
	JOIN SettlementByPickup sbp ON sbpd.SettlementByPickupId = sbp.Id and	sbp.SequenceCode = @IdManifest and sbp.SubTypeServiceManagmentId = 3
	AND sbpd.RowStatus = 1

	SELECT * FROM @temp
	order by Receiver_Departament asc, Receiver_Town asc, Receiver_Zone asc, Receiver_Address asc

END
