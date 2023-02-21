



-- =============================================
-- Author:		<Carlos,Cano>
-- Create date: <04/Agosto/2020>
-- Description:	<Listado de documentos digitalizados por sede y rango de fechas>
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_hop_documents]
	-- Add the parameters for the stored procedure here
	 @IdSender INT
	,@StartDate DATETIME
	,@EndDate DATETIME
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @GuidesInDelivery as table (
		Guide_Delivery nvarchar(25),
		SenderID int,
		SenderName nvarchar(100),
		ShippedDate datetime
	)

	DECLARE @GuidesInHop as table (
		Guide_Hop nvarchar(25),
		PathFile nvarchar(256)
	)

	-- insertar en tabla temporal todos los documentos encontrados
	INSERT INTO @GuidesInDelivery
	SELECT
		do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR)
		,do.Sender_ID
		,vp.DescriptionOfClient
		,do.Shipping_Date
	FROM DeliveryBackOffice.dbo.DeliveryOrder do
	JOIN DeliveryBackOffice.dbo.VisitPointClient vp ON vp.CodeOfReference = do.Sender_ID
	WHERE do.Sender_ID = @IdSender
	AND do.Shipping_Date BETWEEN @StartDate AND @EndDate
	
	-- documentos encontrados en registros digitalizados
	INSERT INTO @GuidesInHop
	SELECT 
		I.KEYVALUECHAR
		,ISNULL(RTRIM(V.LastPath) + '\' + RTRIM(P.filepath),'') 
		--,I.itemdate
		--,I.itemdatestore
		FROM 
		[HOP_LINKEDSERVER].HOP.HOP.DOCDATAPAGE P
		INNER JOIN [HOP_LINKEDSERVER].HOP.HOP.REPOSITORIESVOLUMES V ON V.VolumeNum = P.logicalfolder AND v.RepNum=p.repnum
		INNER JOIN 
		(
		-- BUSCAR EN TABLA DE COMPROBANTES (KeyItem4)
		SELECT D.*, ki4.*
				FROM   [HOP_LINKEDSERVER].HOP.HOP.DOCDATA d ,
					[HOP_LINKEDSERVER].HOP.HOP.KEYITEM4 ki4
				WHERE  
					(d.itemid = ki4.ITEMNUM AND ki4.KEYVALUECHAR IN (SELECT Guide_Delivery FROM @GuidesInDelivery))
					AND d.status = 0
					AND ( d.doctypeid IN ( 12 ) ) -- comprobantes de entrega
		) AS I ON I.itemid = P.itemid
		INNER JOIN [HOP_LINKEDSERVER].HOP.HOP.DOCTYPES dt ON dt.DOCTYPEID = I.doctypeid 
		AND dt.DOCTYPEID IN ( 12 )

	-- resultados
	SELECT 
		COUNT(Guide_Delivery) AS Guides_Found -- guías encontradas
	FROM @GuidesInDelivery
	
	SELECT 
		COUNT(Guide_Hop) AS Guides_Digitalized -- guías digitalizadas
	FROM @GuidesInHop

	SELECT -- detalle de guías
		D.*
		,H.*
	FROM @GuidesInDelivery D
	LEFT JOIN @GuidesInHop H ON H.Guide_Hop = D.Guide_Delivery
	ORDER BY D.Guide_Delivery

END


