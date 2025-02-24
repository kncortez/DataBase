-- =============================================
-- Author:		<Tito Garcia>
-- Create date: 01/08/2024
-- Description:	Devuelve el listado de comprobantes de entregas y devoluciones de guías
-- =============================================
CREATE PROCEDURE [dbo].[spg_deliveryorders_by_number_delivery_returns]
	@_serie nvarchar(2) = 'FD'
	,@_number nvarchar(max) 
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
			DROP TABLE #listGuides;

	SELECT
		CAST(SUBSTRING(Item, 1, IIF(CHARINDEX('-', Item) = 0, (LEN(item)), (CHARINDEX('-', Item) - 1))) AS INT) ItemNumber
	INTO #listGuides
	FROM DeliveryBackOffice.dbo.SplitUnlimited(@_number, ',')

	CREATE NONCLUSTERED INDEX Temp_GuideList_Guide ON #listGuides (ItemNumber)

    SELECT
		do.Ticket_Number
		,(do.pieces_Dry + do.Pieces_Cold) AS Pieces
		,ISNULL(do.NameOfReceiver,'')  AS receiver_name
		,ISNULL(do.Receiver_FirstName,'') + ' ' + ISNULL(do.Receiver_LastName,'') AS receiver_namepod
		,do.Receiver_Address AS Receiver_Address
		,do.Receiver_Phone
		,do.Sender_FirstName + ' ' + do.Sender_LastName AS sender_name
		,do.Sender_Address + ', Zona ' + do.Sender_Zone + ' ' + do.Sender_Town + ', ' + do.Sender_Department AS sender_address
		,'Tel. ' + do.Sender_Phone AS sender_phone
		,do.Guide_Serie + isnull(convert(nvarchar,do.Guide_Number),'') AS Guide
		,'<BR/><B>Fecha de Preparación:</B> ' + CONVERT(VARCHAR, do.Preparation_Date, 103) + ' ' + CONVERT(VARCHAR(5), do.Preparation_Date, 108) AS preparation_date
		,'<BR/><B>Fecha de Envío:</B> ' + CONVERT(VARCHAR, do.Shipping_Date, 103) AS shipping_date
		,'<BR/><B>Fecha Máxima Entrega:</B> ' + ISNULL(CONVERT(VARCHAR, do.Delivery_Max_Date, 103),'') AS max_date
		,do.Guide_Number AS Guide_Number
		,do.Courier_Route AS Courier_Route
		,CONVERT(VARCHAR, do.Dispatched_Date, 103) AS Dispatched_Date
		,do.Courier_Name AS Courier_Name
		,do.Package_Description AS Package_Description
		,do.Sender_ID AS Sender_ID
		,do.Recipe_Number AS Recipe_Number
		,'<B>Manifiesto:</B> ' + do.Manifest_Serie + CONVERT(NVARCHAR, do.Manifest_Number) AS Manifest
		,CASE WHEN do.IsCollect = 'TRUE' THEN 
		CONVERT(VARCHAR, CAST((ISNULL(do.Collect_OnDelivery,0) + ISNULL(do.PriceShippment,0)) AS MONEY), 1) 
		ELSE 
		CONVERT(VARCHAR, CAST((ISNULL(do.Collect_OnDelivery,0)) AS MONEY), 1) 
		end AS  Collect_OnDelivery
		,do.Contact_Confirmed
		,do.Contact_Instructions
		,ISNULL(do.Receiver_CUI,' ') AS Receiver_CUI
		,CASE 
			WHEN do.Receiver_CUI IS NULL THEN ''
			WHEN do.ReceiverCountryId = 'GT' THEN CONCAT('DPI ', do.Receiver_CUI)
			WHEN do.ReceiverCountryId = 'HN' THEN CONCAT('DNI ', do.Receiver_CUI)
		END AS ReceiverCUIAndLabel
		,do.IsLastMileReturn
		,dod.StatusOrderId
		,dp.PathSignature
		,CONVERT(VARCHAR, dod.DateCreated, 103) AS Delivery_Date
		,CONVERT(VARCHAR(5), dod.DateCreated, 108) as Delivery_Time
		,CAST( CAST( SUBSTRING(dp.PathSignature, CHARINDEX('id=', dp.PathSignature) + 3, LEN(dp.PathSignature) - CHARINDEX('id=', dp.PathSignature) + 3 + 1) AS XML ).value('text()[1]','VARBINARY(MAX)') AS VARCHAR(MAX) ) AS SignatureFileName
	FROM [DeliveryBackOffice].[dbo].DeliveryOrder do WITH(NOLOCK)
		INNER JOIN [DeliveryBackOffice].[dbo].deliveryorderdetail dod WITH(NOLOCK) 
			ON do.Guide_Serie = dod.Guide_Serie AND do.Guide_Number = dod.Guide_Number   
		LEFT JOIN [DeliveryBackOffice].[dbo].DeliveryProof dp WITH(NOLOCK) 
			ON do.Guide_Serie = dp.Guide_Serie AND do.Guide_Number = dp.Guide_Number AND dp.PathSignature IS NOT NULL
	WHERE dod.StatusOrderId IN (SELECT StatusOrderId FROM statusOrder WHERE OrderDescription IN('Entregado','Devuelto'))
		AND dod.RowStatus = 1
		AND do.Guide_Serie = @_serie
		AND do.Guide_Number IN (SELECT ItemNumber FROM #listGuides)
	ORDER BY dod.StatusOrderId ASC, do.Guide_Number DESC;

	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
			DROP TABLE #listGuides;
END