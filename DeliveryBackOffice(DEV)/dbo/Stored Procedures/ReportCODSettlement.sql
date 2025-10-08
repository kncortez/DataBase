
-- =============================================
-- Author:      <Cristian, Suazo>
-- Update date: <2025-09-18>
-- Description: < Reporte de integracion de liquidaciones>
-- =============================================

CREATE PROCEDURE [dbo].[ReportCODSettlement]
		@DateIni DATE = '2025-09-01',
		@DateFin DATE = '2025-09-30',
		@Hub NVARCHAR(5) = 'GUA'

AS
BEGIN
	SELECT DBS.ID,
		   HL.HubAbbreviation,
		   DBS.Date_Dispatched,
		   CONCAT(SR.First_Name, ' ', SR.Last_Name) AS Piloto,
		   CR.CodeRoute,
		   AG.TotalCollect,
		   AG.TotalCOD,
		   AG.TotalCobrado,
		   AG.Faltante,
		   AG.Sobrante,
		   AG.Efectivo,
		   AG.Zigi,
		   AG.TC,
		   SUM(RDM.AmountApplied) AS Efectibox
	FROM DeliveryOrderBySettlement DBS WITH (NOLOCK)
		INNER JOIN CatStation CST WITH (NOLOCK)
			ON DBS.DispatchedStationId = CST.IdStation
		INNER JOIN HubLogistics HL WITH (NOLOCK)
			ON CST.HubLogisticId = HL.IdHubLogistic
		INNER JOIN SenderReceiver SR WITH (NOLOCK)
			ON DBS.ID_Courier = SR.ID
		INNER JOIN CatRoute CR WITH (NOLOCK)
			ON DBS.CatRouteId = CR.IdRoute
		INNER JOIN RelDepositManifest RDM WITH (NOLOCK)
			ON RDM.DeliveryOrderBySettlementId = DBS.ID
		OUTER APPLY
	(
		SELECT COALESCE(SUM(   CASE
								   WHEN DO.StatusOrderId = 5
										AND DO.IsCollect = 1 THEN
									   DO.PriceShippment
								   ELSE
									   0
							   END
						   ), 0) AS TotalCollect,
			   COALESCE(SUM(DSD.Settlement_Collect_OnDelivery), 0) AS TotalCOD,
			   COALESCE(SUM(   CASE
								   WHEN DO.StatusOrderId = 5
										AND DO.IsCollect = 1 THEN
									   DO.PriceShippment
								   ELSE
									   0
							   END
						   ), 0) + COALESCE(SUM(DSD.Settlement_Collect_OnDelivery), 0) AS TotalCobrado,
			   COALESCE(SUM(MDS.Quantity * CM.Value), 0) AS Efectivo,
			   CASE
				   WHEN COALESCE(SUM(DSD.Settlement_Collect_OnDelivery), 0) - COALESCE(SUM(MDS.Quantity * CM.Value), 0) < 0 THEN
					   COALESCE(SUM(DSD.Settlement_Collect_OnDelivery), 0) - COALESCE(SUM(MDS.Quantity * CM.Value), 0)
				   ELSE
					   0
			   END AS Faltante,
			   CASE
				   WHEN COALESCE(SUM(DSD.Settlement_Collect_OnDelivery), 0) - COALESCE(SUM(MDS.Quantity * CM.Value), 0) > 0 THEN
					   COALESCE(SUM(DSD.Settlement_Collect_OnDelivery), 0) - COALESCE(SUM(MDS.Quantity * CM.Value), 0)
				   ELSE
					   0
			   END AS Sobrante,
			   COALESCE(SUM(   CASE
								   WHEN CD.IdTypeOfMoney = 10 THEN
									   CO.TotalAmountPaid
								   ELSE
									   0
							   END
						   ), 0) AS Zigi,
			   COALESCE(SUM(   CASE
								   WHEN CD.IdTypeOfMoney = 2 THEN
									   CO.TotalAmountPaid
								   ELSE
									   0
							   END
						   ), 0) AS TC
		FROM DeliverySettlementDetail DSD WITH (NOLOCK)
			LEFT JOIN DeliveryOrder DO WITH (NOLOCK)
				ON DSD.Guide_Number = DO.Guide_Number
				   AND DSD.Guide_Serie = DO.Guide_Serie
			LEFT JOIN MoneyByDeliveryOrderBySettlement MDS WITH (NOLOCK)
				ON MDS.DeliveryOrderBySettlementId = DSD.ID_DeliveryOrderBySettlement
			LEFT JOIN CatMoney CM WITH (NOLOCK)
				ON CM.IdCatMoney = MDS.CatMoneyId
			LEFT JOIN Cost CO WITH (NOLOCK)
				ON CO.GuideNumber = DO.Guide_Number
				   AND CO.GuideSerie = DO.Guide_Serie
			LEFT JOIN CostDetail CD WITH (NOLOCK)
				ON cd.IdCost = CO.IdCost
		WHERE DSD.ID_DeliveryOrderBySettlement = DBS.ID
	) AG
	WHERE HL.HubAbbreviation = @Hub 
	AND CAST(DBS.Date_Dispatched AS DATE) >= @DateIni AND CAST(DBS.Date_Dispatched AS DATE) < @DateFin
	GROUP BY DBS.ID,
			 HL.HubAbbreviation,
			 DBS.Date_Dispatched,
			 SR.First_Name,
			 SR.Last_Name,
			 CR.CodeRoute,
			 AG.TotalCollect,
			 AG.TotalCOD,
			 AG.TotalCobrado,
			 AG.Faltante,
			 AG.Sobrante,
			 AG.Efectivo,
			 AG.Zigi,
			 AG.TC
END
