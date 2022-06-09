
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-02-23>
-- Description:	<Recupera información para la liquidación COD de devoluciones>
-- =============================================
CREATE PROCEDURE [dbo].[GetReturnsCODSettlement]
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
	WHERE sbp.SequenceCode = @ManifestId
		AND sbp.SubTypeServiceManagmentId = 3

	-- Table 1
	SELECT 1 Checked
		, CONCAT(do.Guide_Serie, do.Guide_Number) Guide
		, do.PriceShippment Amount
		, cu.Name Customer
		, CASE WHEN invh.inv_serieFEL IS NULL OR invh.inv_serieFEL = ''
		  THEN NULL ELSE CONCAT(invh.inv_serieFEL, '-', invh.inv_numberFEL) END  FEL
		, cu.IdCustomer
	FROM DeliveryOrder do
	INNER JOIN (
		SELECT sbpd.GuideSerie, sbpd.GuideNumber, sbpd.Price
		FROM SettlementByPickupDetail sbpd
		JOIN SettlementByPickup sbp
			ON sbp.Id = sbpd.SettlementByPickupId
		WHERE sbp.SequenceCode = @ManifestId 
		AND sbp.SubTypeServiceManagmentId = 3
		AND IsPieceLiquidaded = 1 -- Pieza de la guia liquidada
		AND (IsCODSettlement IS NULL OR IsCODSettlement <> 1) -- Pieza no liquidada en COD
		GROUP BY GuideSerie, GuideNumber, Price
	) sbpd 
		ON do.Guide_Serie = sbpd.GuideSerie AND do.Guide_Number = sbpd.GuideNumber
	LEFT JOIN DeliveryOrderPaymentDetail dopd
		ON do.Guide_Serie = dopd.GuideSerie AND do.Guide_Number = dopd.GuideNumber
	LEFT JOIN Customer cu
		ON do.IdCustomer = cu.IdCustomer 
	LEFT JOIN (SELECT
			MAX(invh1.inv_serieFEL) inv_serieFEL
			,MAX(invh1.inv_numberFEL) inv_numberFEL
			,invd.dti_fk_orderSerie dti_fk_orderSerie
			,invd.dti_fk_orderNumber dti_fk_orderNumber
		FROM DeliveryBackOffice.dbo.invoiceDetail invd
		JOIN DeliveryBackOffice.dbo.invoiceHeader invh1
			ON invh1.inv_pk_id = invd.dti_fk_header
			AND invh1.inv_descriptionFEL = 'PROCESO REALIZADO'
			AND invh1.inv_invoiceOfCreditNote IS NULL
		GROUP BY invd.dti_fk_orderSerie
				,invd.dti_fk_orderNumber) invh
		ON invh.dti_fk_orderSerie = do.Guide_Serie
			AND invh.dti_fk_orderNumber = do.Guide_Number
	WHERE sbpd.Price > 0

	-- Table 2
	SELECT COUNT(1) IsCODSettlement
	FROM SettlementByPickupDetail sbpd
	JOIN SettlementByPickup sbp
		ON sbp.Id = sbpd.SettlementByPickupId
	WHERE sbp.SequenceCode = @ManifestId 
		AND sbp.SubTypeServiceManagmentId = 3
		AND IsPieceLiquidaded = 1 -- Pieza de la guia liquidada en devoluciones
		AND IsCODSettlement = 1 -- Pieza no liquidada en COD

	SET NOCOUNT OFF;
END