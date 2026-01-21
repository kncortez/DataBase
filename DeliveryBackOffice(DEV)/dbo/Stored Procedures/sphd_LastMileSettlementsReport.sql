
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-12-06>
-- Description: <Obtener informacion para el mostrar los datos necesarios del Reporte Liquidaciones Última Milla>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_LastMileSettlementsReport]
(
    @fromDate AS DATE,
    @toDate AS DATE,
    @hubsIds AS NVARCHAR(MAX)
)
AS
BEGIN
    SELECT dst.ID 'Manifiesto',
           cst.StationName 'Hub',
           CONVERT(DATE, dst.Date_Received) 'Fecha',
           CONCAT(dsd.Guide_Serie, dsd.Guide_Number) 'Guia',
           (CASE WHEN ord.[IsLastMileReturn] = 1 THEN CONCAT(ord.Receiver_FirstName, ' ', ord.Receiver_LastName) ELSE CONCAT(ord.[Sender_FirstName], ' ', ord.[Sender_LastName]) END) 'Remitente',
           (CASE WHEN ord.[IsLastMileReturn] = 1 THEN CONCAT(ord.[Sender_FirstName], ' ', ord.[Sender_LastName]) ELSE CONCAT(ord.Receiver_FirstName, ' ', ord.Receiver_LastName) END) 'Destinatario',
           CONCAT(sdr.First_Name, ' ', sdr.Last_Name) 'Piloto',
           IIF(ord.IsCollect = 1, ord.PriceShippment, 0) 'Collect',
           (CASE WHEN [ord].[IsLastMileReturn] = 1 THEN 0 ELSE ord.Collect_OnDelivery END) 'COD',
		   REPLACE(REPLACE(REPLACE(dc.Symbol,'.',''),'(',''),')','') [Currency_Symbol],
           cd.Voucher,
		   CASE 
		      WHEN cd.IdTypeOfMoney = 11 THEN 'Transferencia'
			  WHEN cd.IdTypeOfMoney = 1  THEN 'Efectivo'
			  WHEN cd.IdTypeOfMoney = 2  THEN 'Pago con Tarjeta'
			  WHEN cd.IdTypeOfMoney = 10 THEN 'Zigi'
	          ELSE 'Pago preautorizado'
		  END PaymentMethod
    FROM dbo.DeliveryOrderBySettlement dst
        INNER JOIN dbo.DeliverySettlementDetail dsd
            ON dsd.ID_DeliveryOrderBySettlement = dst.ID
        INNER JOIN dbo.DeliveryOrder ord
            ON ord.Guide_Serie = dsd.Guide_Serie
               AND ord.Guide_Number = dsd.Guide_Number
        INNER JOIN dbo.CatStation cst
            ON cst.IdStation = dst.SettlementStationId
        LEFT JOIN dbo.SenderReceiver sdr
            ON sdr.ID = dst.ID_Courier
		LEFT JOIN dbo.Cost c WITH (NOLOCK)
            ON c.GuideSerie = ord.guide_Serie
            AND c.GuideNumber = ord.guide_number
		LEFT JOIN dbo.CatCurrencyCOD dc WITH (NOLOCK)
            ON dc.IdCatCurrencyCOD = ISNULL(c.ShippingCurrency,1)
        LEFT JOIN dbo.CostDetail cd WITH (NOLOCK)
            ON c.IdCost = cd.IdCost
    WHERE CONVERT(DATE, dst.Date_Received)
          BETWEEN @fromDate AND @toDate
          AND dst.SettlementStationId IN
              (
                  SELECT Name FROM splitstring(@hubsIds, ',')
              )
		  AND IIF(ord.IsCollect = 1, ord.PriceShippment + ord.Collect_OnDelivery, ord.Collect_OnDelivery) > 0
          --dsd.Settlement_Collect_OnDelivery > 0
          AND dsd.Guide_Delivered = 'true'
          AND dsd.Guide_Discharged IS NOT NULL
          AND dsd.RowStatus = 1
    ORDER BY cst.IdStation,
             dst.Date_Received,
             dst.ID,
             ord.Guide_Number;
END;