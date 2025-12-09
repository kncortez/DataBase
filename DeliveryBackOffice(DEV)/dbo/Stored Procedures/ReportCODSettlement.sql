
-- =============================================
-- Author:      <Cristian, Suazo>
-- Update date: <2025-09-18>
-- Description: < Reporte de integracion de liquidaciones>
-- =============================================
-- Author:      <Edelman>
-- Update date: <2025-12-09>
-- Description: <Agregar mejoras: set nocount on; y quitar cast del filtro para no interferir en uso de Index y performes por convertir fecha por cada registro>
-- =============================================
CREATE PROCEDURE [dbo].[ReportCODSettlement]
		@DateIni DATE = '2025-09-01',
		@DateFin DATE = '2025-09-30',
		@Hub NVARCHAR(5) = 'GUA'

AS
BEGIN
SET NOCOUNT ON;

    SELECT DBS.ID,
           COALESCE(HL.HubAbbreviation, VPC.DescriptionOfClient) AS HUB,
           CONVERT(DATE,DBS.Date_Dispatched) AS Date_Dispatched,
           CONCAT(SR.First_Name, ' ', SR.Last_Name) AS Piloto,
           CR.CodeRoute,
           AG.TotalCollect,
           AG.TotalCOD,
           AG.TotalCobrado,
           CASE
               WHEN CTG.Type = 'FALTANTE' THEN
                   SUM(CTG.Value)
               ELSE
                   0
           END AS Faltante,
           CASE
               WHEN CTG.Type = 'SOBRANTE' THEN
                   SUM(CTG.Value)
               ELSE
                   0
           END AS Sobrante,
           AG.Efectivo,
           AG.Zigi,
           AG.TC,
           ISNULL(SUM(RDM.AmountApplied),0) AS Efectibox
    FROM DeliveryOrderBySettlement DBS WITH (NOLOCK)
        INNER JOIN CatStation CST WITH (NOLOCK)
            ON DBS.SettlementStationId = CST.IdStation
        LEFT JOIN HubLogistics HL WITH (NOLOCK)
            ON CST.HubLogisticId = HL.IdHubLogistic
        LEFT JOIN VisitPointClient VPC WITH (NOLOCK)
            ON CST.CodeOfReference = VPC.CodeOfReference
        INNER JOIN SenderReceiver SR WITH (NOLOCK)
            ON DBS.ID_Courier = SR.ID
        INNER JOIN CatRoute CR WITH (NOLOCK)
            ON DBS.CatRouteId = CR.IdRoute
        LEFT JOIN RelDepositManifest RDM WITH (NOLOCK)
            ON RDM.DeliveryOrderBySettlementId = DBS.ID
        LEFT JOIN Contingency CTG WITH (NOLOCK)
            ON CTG.DeliveryOrderBySettlementId = DBS.ID
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
               COALESCE(DT.Cash, 0) AS Efectivo,
               DPM.Efectibox,
               COALESCE(SUM(   CASE
                                   WHEN CD.IdTypeOfMoney = 10 AND pz.ZigiLinkStatus = 'PAID' THEN
                                       pz.PaidAmount
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
            OUTER APPLY
        (
            SELECT SUM(MDS.Quantity * CM.Value) AS Cash
            FROM MoneyByDeliveryOrderBySettlement MDS WITH (NOLOCK)
                LEFT JOIN CatMoney CM WITH (NOLOCK)
                    ON CM.IdCatMoney = MDS.CatMoneyId
            WHERE MDS.DeliveryOrderBySettlementId = DSD.ID_DeliveryOrderBySettlement
        ) DT
            OUTER APPLY
        (
            SELECT SUM(RDM.AmountApplied) AS Efectibox
            FROM RelDepositManifest RDM WITH (NOLOCK)
            WHERE RDM.DeliveryOrderBySettlementId = DSD.ID_DeliveryOrderBySettlement
        ) DPM
            LEFT JOIN Cost CO WITH (NOLOCK)
                ON CO.GuideNumber = DO.Guide_Number
                   AND CO.GuideSerie = DO.Guide_Serie
            LEFT JOIN PaymentZigi pz WITH (NOLOCK)
                ON pz.GuideNumber = DO.Guide_Number
                   AND pz.GuideSerie = DO.Guide_Serie
            LEFT JOIN CostDetail CD WITH (NOLOCK)
                ON cd.IdCost = CO.IdCost
        WHERE DSD.ID_DeliveryOrderBySettlement = DBS.ID
        GROUP BY DT.Cash,
                 DPM.Efectibox
    ) AG
    WHERE HL.HubAbbreviation = @Hub
          AND DBS.Date_Dispatched >= @DateIni
          AND DBS.Date_Dispatched <= DATEADD(DAY,1,@DateFin)
    GROUP BY DBS.ID,
             HL.HubAbbreviation,
             VPC.DescriptionOfClient,
             DBS.Date_Dispatched,
             SR.First_Name,
             SR.Last_Name,
             CR.CodeRoute,
             AG.TotalCollect,
             AG.TotalCOD,
             AG.TotalCobrado,
             CTG.Type,
             AG.Efectivo,
             AG.Zigi,
             AG.TC
END
