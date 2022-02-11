USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetRoutePickUpCODSettlement]    Script Date: 10/02/2022 17:32:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Morales, Oscar>
-- Create date: <2021-09-02>
-- Description:	<Recupera información para form RoutePickUpCODSettlement>
-- =============================================
ALTER PROCEDURE [dbo].[GetRoutePickUpCODSettlement]
		@ManifestId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Table 0
	SELECT CONCAT(sr.First_Name, ' ', sr.Last_Name) as Courier
		, CONVERT(VARCHAR,ra.DateOfRoute,103) DateCollect
		, rou.CodeRoute CodeRoute
	FROM SettlementByPickup sbp
	LEFT JOIN RouteAssigment ra 
		ON sbp.RouteAssigmentId = ra.IdRouteAssigment
	LEFT JOIN SenderReceiver sr 
		ON sbp.IdCourier = sr.ID
	LEFT JOIN CatRoute rou
		ON ra.IdRoute = rou.IdRoute
	WHERE sbp.Id = @ManifestId

	-- Table 1
	SELECT 1 Checked
		, CONCAT(do.Guide_Serie, do.Guide_Number) Guide
		, do.PriceShippment Amount
		, cu.Name Customer
		, CASE WHEN ih.inv_serieFEL IS NULL OR ih.inv_serieFEL = ''
		  THEN NULL ELSE CONCAT(ih.inv_serieFEL, '-', ih.inv_numberFEL) END  FEL
		, cu.IdCustomer
	FROM DeliveryOrder do
	INNER JOIN (
		SELECT GuideSerie, GuideNumber 
		FROM [DeliveryBackOffice].[dbo].SettlementByPickupDetail
		WHERE SettlementByPickupId = @ManifestId 
		AND IsPieceLiquidaded = 1 -- Pieza de la guia liquidada
		AND (IsCODSettlement IS NULL OR IsCODSettlement <> 1) -- Pieza no liquidada en COD
		GROUP BY GuideSerie, GuideNumber
	) sbpd 
		ON do.Guide_Serie = sbpd.GuideSerie AND do.Guide_Number = sbpd.GuideNumber
	LEFT JOIN DeliveryOrderPaymentDetail dopd
		ON do.Guide_Serie = dopd.GuideSerie AND do.Guide_Number = dopd.GuideNumber
	LEFT JOIN Customer cu
		ON do.IdCustomer = cu.IdCustomer 
	LEFT JOIN invoiceDetail id
		ON do.Guide_Serie = id.dti_fk_orderSerie AND do.Guide_Number = id.dti_fk_orderNumber
	LEFT JOIN invoiceHeader ih
		ON id.dti_fk_header = ih.inv_pk_id
	WHERE dopd.PayTypeId = 1 -- Contado
		AND dopd.TypeofInOutMoneyId IN (1,2) -- Efectivo o tarjeta
		AND dopd.TimePlaId = 2 -- Recolección
		AND do.PriceShippment > 0

	-- Table 2
	SELECT COUNT(1) IsCODSettlement
	FROM [DeliveryBackOffice].[dbo].SettlementByPickupDetail
	WHERE SettlementByPickupId = @ManifestId 
		AND IsPieceLiquidaded = 1 -- Pieza de la guia liquidada en recolección
		AND IsCODSettlement = 1 -- Pieza no liquidada en COD

	SET NOCOUNT OFF;
END