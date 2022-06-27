



-- =============================================
-- Author:		<Andre, Ruiz>
-- Create date: <2022-01-21>
-- Description:	<Recupera información para generar manifiesto de despacho tomando en cuenta las piezas escaneadas en la preparación>
-- =============================================
CREATE PROCEDURE [dbo].[GetDeliveryOrderSettlementDataUnderRoutePrepration_CRAS]
	@IdManifest INT
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @temp TABLE (
		GuideOrder int,
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

	INSERT INTO @temp
	SELECT
		dsd.GuideOrder
		, do.Guide_Serie + isnull(convert(nvarchar,do.Guide_Number),'') as Guide_Code
		,(DO.Pieces_Cold
		) AS Pieces_Cold
		,( DO.Pieces_Dry
			
		) as Pieces_Dry
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
	from 
		[DeliveryBackOffice].[dbo].DeliveryOrder do WITH (NOLOCK)
	JOIN 
		DeliverySettlementDetail dsd WITH (NOLOCK)
		ON 
			do.Guide_Serie = dsd.Guide_Serie 
			AND 
			do.Guide_Number = dsd.Guide_Number
			AND 
			dsd.ID_DeliveryOrderBySettlement = @IdManifest 
			AND 
			dsd.RowStatus = 1

	SELECT 
		* 
	FROM 
		@temp
	ORDER BY 
		COALESCE(GuideOrder,999999) ASC
		,Receiver_Departament asc
		,Receiver_Town asc
		,Receiver_Zone asc
		,Receiver_Address asc

END