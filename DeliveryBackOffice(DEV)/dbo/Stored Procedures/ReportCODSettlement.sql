
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
		   SR.First_Name + ' ' + SR.Last_Name AS Piloto,
		   CR.CodeRoute,
		   CASE WHEN DO.StatusOrderId = 5 AND DO.IsCollect = 1 THEN SUM(DO.PriceShippment) ELSE 0 END AS TotalCollect,
		   COALESCE(SUM(DSD.Settlement_Collect_OnDelivery),0) TotalCOD,
		   CASE WHEN DO.StatusOrderId = 5 AND DO.IsCollect = 1 THEN SUM(DO.PriceShippment) ELSE 0 END + COALESCE(SUM(DSD.Settlement_Collect_OnDelivery),0) AS TotalCobrado,
		   CASE WHEN COALESCE(SUM(DSD.Settlement_Collect_OnDelivery) - SUM(MDS.Quantity * CM.Value),0) < 0 THEN SUM(DSD.Settlement_Collect_OnDelivery) - SUM(MDS.Quantity * CM.Value) ELSE 0 END AS Faltante, 
		   CASE WHEN COALESCE(SUM(DSD.Settlement_Collect_OnDelivery) - SUM(MDS.Quantity * CM.Value),0) > 0 THEN SUM(DSD.Settlement_Collect_OnDelivery) - SUM(MDS.Quantity * CM.Value) ELSE 0 END AS Sobrante, 
		   COALESCE(SUM(MDS.Quantity * CM.Value),0) AS Efectivo,
		   CASE WHEN CD.IdTypeOfMoney = 10 THEN SUM (CD.Amount) ELSE 0 END Zigi,
		   CASE WHEN CD.IdTypeOfMoney = 2 THEN SUM(CD.Amount) ELSE 0 END TC,
		   SUM(DP.Amount) AS Efectibox
	FROM  DeliveryOrderBySettlement DBS WITH (NOLOCK)
	INNER JOIN DeliverySettlementDetail DSD WITH (NOLOCK)
		ON DSD.ID_DeliveryOrderBySettlement = DBS.ID
	INNER JOIN RelDepositManifest RDM WITH (NOLOCK)
		ON RDM.DeliveryOrderBySettlementId = DBS.ID
	INNER JOIN Deposit DP WITH (NOLOCK)
		ON DP.IdDeposit = RDM.IdDeposit
	LEFT JOIN MoneyByDeliveryOrderBySettlement MDS WITH (NOLOCK)
		ON MDS.DeliveryOrderBySettlementId = DBS.ID
	LEFT JOIN CatMoney CM WITH (NOLOCK)
		ON CM.IdCatMoney = MDS.CatMoneyId
	INNER JOIN DeliveryOrder DO WITH(NOLOCK)
		ON DSD.Guide_Number = DO.Guide_Number
			AND DSD.Guide_Serie = DO.Guide_Serie
	INNER JOIN Cost C WITH (NOLOCK)
		ON C.GuideNumber = DO.Guide_Number
		AND C.GuideSerie = DO.Guide_Serie
	LEFT JOIN CostDetail CD WITH (NOLOCK)
		ON CD.IdCost = C.IdCost
	INNER JOIN CatStation CST WITH (NOLOCK)
		ON DBS.DispatchedStationId = CST.IdStation
	INNER JOIN HubLogistics HL WITH (NOLOCK)
		ON CST.HubLogisticId = HL.IdHubLogistic
	INNER JOIN SenderReceiver SR WITH (NOLOCK)
		ON DBS.ID_Courier = SR.ID
	INNER JOIN CatRoute CR WITH (NOLOCK)
		ON DBS.CatRouteId = CR.IdRoute
	WHERE HL.HubAbbreviation = @Hub AND DSD.RowStatus = 1
	AND DSD.Guide_Discharged = 1
	AND DBS.Date_Dispatched BETWEEN @DateIni AND @DateFin
	GROUP BY DBS.ID,
		   HL.HubAbbreviation,
		   DBS.Date_Dispatched,
		   SR.First_Name,
		   SR.Last_Name,
		   CR.CodeRoute,
		   DO.StatusOrderId,
		   DO.IsCollect,
		   CD.IdTypeOfMoney,
		   MDS.Quantity,
		   CM.Value,
		   DP.Amount
END


