USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_get_deliveryordersForCOD]    Script Date: 27/10/2021 09:52:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-11-23>
-- Description:	<Devuelve información para liquidación de COD>
-- =============================================
ALTER PROCEDURE [dbo].[spg_get_deliveryordersForCOD]
	@IdManifest INT
AS
BEGIN
	SET NOCOUNT ON;	

	--DECLARE @IdManifest AS INT = 32181;
	
	DECLARE @GuidesFound TABLE (
		Guide_Serie NVARCHAR(2),
		Guide_Number INT
	)

	INSERT INTO @GuidesFound
	SELECT DISTINCT
		dsd.Guide_Serie,
		dsd.Guide_Number
	FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement dbs
	JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail dsd ON dsd.ID_DeliveryOrderBySettlement = dbs.ID
	WHERE dbs.ID = @IdManifest 
	AND dsd.Guide_Settlement = 1
	AND dsd.Guide_Returned = 0
	AND (dsd.Guide_Discharged = 0 OR dsd.Guide_Discharged IS NULL)

	SELECT dbs.ID,
		Date_Dispatched,
		Pieces_Dry_Dispatched,
		Pieces_Cold_Dispatched,
		Guides_Dispatched,
		dbs.ID_Courier,
		isnull(sr.First_Name,'') + ' ' + isnull(sr.Last_Name,'') as Courier_Name
	FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement dbs
	JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = dbs.ID_Courier
	WHERE dbs.ID = @IdManifest

	DECLARE @GuidesDetail TABLE (
		Guide NVARCHAR(16),
		Delivered BIT,
		Price DECIMAL(18,2),
		COD DECIMAL(18,2),
		Total DECIMAL(18,2),
		Factura VARCHAR(251)
	)

	INSERT INTO @GuidesDetail
	SELECT DISTINCT
		do.Guide_Serie + CONVERT(varchar,do.Guide_Number) AS Guide,
		(ISNULL((
			SELECT TOP 1 
			1 
			FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod 
			WHERE dod.Guide_Serie = gf.Guide_Serie AND dod.Guide_Number = gf.Guide_Number AND dod.StatusOrderId = 5
		),0)) AS Delivered,
		CAST(IIF(do.IsCollect = 'TRUE', isnull(do.PriceShippment,0), 0) AS DECIMAL(18,2)) AS Price,
		CAST(isnull(do.Collect_OnDelivery,0) AS DECIMAL(18,2)) AS COD,
		CAST(IIF(do.IsCollect = 'TRUE', (isnull(do.Collect_OnDelivery,0) + isnull(do.PriceShippment,0)), isnull(do.Collect_OnDelivery,0)) AS DECIMAL(18,2)) AS Total
		,CASE WHEN ih.inv_serieFEL IS NULL OR ih.inv_serieFEL = ''
		THEN NULL ELSE CONCAT(ih.inv_serieFEL, '-', ih.inv_numberFEL) END  FEL
	FROM @GuidesFound gf
	JOIN DeliveryBackOffice.dbo.DeliveryOrder do ON do.Guide_Serie = gf.Guide_Serie AND do.Guide_Number = gf.Guide_Number
	LEFT JOIN invoiceDetail id
			ON do.Guide_Serie = id.dti_fk_orderSerie AND do.Guide_Number = id.dti_fk_orderNumber
	LEFT JOIN invoiceHeader ih
		ON id.dti_fk_header = ih.inv_pk_id
	LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vp ON do.Receiver_ID = vp.CodeOfReference
	WHERE ((do.Collect_OnDelivery > 0) 
		OR 
		(do.IsCollect=1 AND do.PriceShippment+do.Collect_OnDelivery > 0)
		) AND (vp.IdKindOfVPClient <> 1 OR vp.IdKindOfVPClient IS NULL)

	SELECT SUM(Total) as COD_Manifest
	FROM @GuidesDetail

	SELECT * FROM @GuidesDetail gd
	ORDER BY gd.Guide ASC

END
