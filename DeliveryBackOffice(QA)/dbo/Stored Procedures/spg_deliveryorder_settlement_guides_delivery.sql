


-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-09-17>
-- Description:	<Recupera información para generar manifiesto de despacho>
-- =============================================
CREATE PROCEDURE [dbo].[spg_deliveryorder_settlement_guides_delivery]
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
		dop.GuideSerie + cast(dop.GuideNumber as varchar(50)) + '-' + cast(dop.NoPiece as varchar(10)) as Guide_Code,
		CASE when isnull(dop.IsDry,0) = 0 then 1 else 0 end  AS Pieces_Cold,
		CASE when isnull(dop.IsDry,0) = 1 then dop.IsDry  else 0 end  AS Pieces_Dry,
		isnull(dod.Receiver_FirstName,'') + ' ' + isnull(dod.Receiver_LastName,'') as Receiver_Fullname,
		dod.Receiver_Address AS Receiver_Address,
		CONVERT(INT, ISNULL(dod.Receiver_Zone,0)) AS Receiver_Zone,
		dod.Receiver_Town AS Receiver_Town,
		dod.Receiver_Department AS  Receiver_Departament,
		CONVERT(varchar, dod.Preparation_Date, 103) + ' ' + CONVERT(varchar(5), dod.Preparation_Date, 108) as Preparation_Date,
		CONVERT(varchar, dod.Shipping_Date, 103) as Shipping_Date,
		isnull(CONVERT(varchar, dod.Delivery_Max_Date, 103),'') as Max_Date,
		dod.Receiver_Phone as Receiver_Phone,
		(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(dod.Guide_Serie, dod.Guide_Number)) as Rack_Position,
		(case when dod.IsCollect = 'TRUE' then 
			CONVERT(VARCHAR, CAST((isnull(dod.Collect_OnDelivery,0) + isnull(dod.PriceShippment,0)) AS DECIMAL), 1) 
			else 
			CONVERT(VARCHAR, CAST((isnull(dod.Collect_OnDelivery,0)) AS DECIMAL), 1) 
			end
		) AS  Collect_OnDelivery		
	FROM DeliveryBackOffice.dbo.DeliveryOrder dod
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop on dop.GuideSerie = dod.Guide_Serie and dop.GuideNumber = dod.Guide_Number
		JOIN DeliveryBackOffice.dbo.PieceByService pbs on dop.GuidePiece = pbs.GuidePieceId
		JOIN DeliveryBackOffice.dbo.SettlementByPickupDetail sbpd on dod.Guide_Number = sbpd.GuideNumber and sbpd.IsDispatched = 1
		JOIN DeliveryBackOffice.dbo.SettlementByPickup sbp on sbpd.SettlementByPickupId = sbp.Id and sbp.SequenceCode = @IdManifest and sbp.SubTypeServiceManagmentId = 2
		AND sbpd.RowStatus = 1

	SELECT * FROM @temp
	order by Receiver_Departament asc, Receiver_Town asc, Receiver_Zone asc, Receiver_Address asc

END