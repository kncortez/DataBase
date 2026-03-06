
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-12-06>
-- Description: <Obtener informacion para el mostrar los datos necesarios del Reporte Liquidaciones Última Milla>
-- =============================================
-- =============================================
-- Author:      <Edelman>
-- Create date: <2026-01-21>
-- Description: <Agregar parámetro Voucher y  tipos de pagos>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_LastMileSettlementsReport]
(
    @fromDate AS DATE,
    @toDate AS DATE,
    @hubsIds AS NVARCHAR(MAX)
)
AS
BEGIN
    
    DECLARE @TotalCardCollect DECIMAL(19,2) = 0;
    DECLARE @TotalTransfer DECIMAL(19,2) = 0;
    DECLARE @TotalZigi DECIMAL(19,2) = 0;
    DECLARE @AmountMoney DECIMAL(19,2) = 0;
    DECLARE @TotalVouchers DECIMAL(19,2) = 0;

    /* ================================
       FILTRO DE FECHA OPTIMIZADO
    ==================================*/

    DECLARE @DateFrom DATETIME = @fromDate;
    DECLARE @DateTo   DATETIME = DATEADD(DAY,1,@toDate);

    /* ================================
               DATOS FILTRADA
    ==================================*/

    ;WITH BaseData AS
    (
         
    SELECT dst.ID 'Manifiesto',
           cst.StationName 'Hub',
           CONVERT(DATE, dst.Date_Received) 'Fecha',
            ord.PriceShippment AS Collect,
           (CASE WHEN [ord].[IsLastMileReturn] = 1 THEN 0 ELSE ord.Collect_OnDelivery END) 'COD',
		   REPLACE(REPLACE(REPLACE(dc.Symbol,'.',''),'(',''),')','') [Currency_Symbol],
		   CASE 
		    WHEN CD.IdTypeOfMoneyCollect = 11  THEN CD.Voucher
			WHEN CD.IdTypeOfMoneyCollect = 10  THEN PZ.ZigiTransactionId
           END AS VoucherCollect,
			CASE 
		    WHEN CD.IdTypeOfMoneyCOD = 11  THEN CD.Voucher
			WHEN CD.IdTypeOfMoneyCOD = 10  THEN PZ.ZigiTransactionId
            END AS VoucherCOD,
		     cd.IdTypeOfMoneyCOD AS PaymentMethodCOD,
			 cd.IdTypeOfMoneyCollect AS PaymentMethodCollect
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dst WITH(NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd  WITH(NOLOCK)
            ON dsd.ID_DeliveryOrderBySettlement = dst.ID
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] ord WITH(NOLOCK)
            ON ord.Guide_Serie = dsd.Guide_Serie
               AND ord.Guide_Number = dsd.Guide_Number
        INNER JOIN [DeliveryBackOffice].[dbo].[CatStation] cst WITH(NOLOCK)
            ON cst.IdStation = dst.SettlementStationId
        LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] sdr WITH(NOLOCK)
            ON sdr.ID = dst.ID_Courier
		LEFT JOIN [DeliveryBackOffice].[dbo].[Cost] c WITH (NOLOCK)
            ON c.GuideSerie = ord.guide_Serie
            AND c.GuideNumber = ord.guide_number
		LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD] dc WITH (NOLOCK)
            ON dc.IdCatCurrencyCOD = ISNULL(c.ShippingCurrency,1)
        LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] cd WITH (NOLOCK)
            ON c.IdCost = cd.IdCost
		LEFT JOIN [DeliveryBackOffice].[dbo].[PaymentZigi] PZ WITH (NOLOCK)
        ON  PZ.GuideSerie  = dsd.Guide_Serie AND PZ.GuideNumber = dsd.Guide_Number
       LEFT JOIN [DeliveryBackOffice].[dbo].[PaymentZigiMulti] PZM WITH (NOLOCK)
        ON  PZM.Id_PaymentZigi  = PZ.ZigiPaymentId 
    WHERE CONVERT(DATE, dst.Date_Received)
          BETWEEN @fromDate AND @toDate
          AND dst.SettlementStationId IN
              (
                  SELECT Name FROM splitstring(@hubsIds, ',')
              )
		--  AND IIF(ord.IsCollect = 1, ord.PriceShippment + ord.Collect_OnDelivery, ord.Collect_OnDelivery) > 0
          AND dsd.Guide_Delivered = 'true'
          AND dsd.Guide_Discharged IS NOT NULL
          AND dsd.RowStatus = 1
    )

    /* ================================
  TOTALES TRANSACCIONES, PAGOS CON TARJETA Y ZIGI
    ==================================*/

    SELECT
        @TotalCardCollect = SUM(
            CASE
                WHEN PaymentMethodCOD = 2 AND PaymentMethodCollect = 2
                    THEN ISNULL(Collect,0) + ISNULL(COD,0)
                WHEN PaymentMethodCOD  = 2 AND PaymentMethodCollect <> 2
                    THEN ISNULL(COD,0)
                WHEN PaymentMethodCOD  <> 2 AND PaymentMethodCollect = 2
                    THEN ISNULL(Collect,0)
				WHEN PaymentMethodCOD  IS NULL AND PaymentMethodCollect = 2
                    THEN ISNULL(Collect,0)
				WHEN PaymentMethodCOD  = 2 AND PaymentMethodCollect IS NULL
                    THEN ISNULL(COD,0)
            END
        ),
        @TotalTransfer = SUM(
            CASE
                WHEN PaymentMethodCOD = 11 AND PaymentMethodCollect = 11
                    THEN ISNULL(Collect,0) + ISNULL(COD,0)
                WHEN PaymentMethodCOD = 11 AND PaymentMethodCollect <> 11
                    THEN ISNULL(COD,0)
                WHEN PaymentMethodCOD <> 11 AND PaymentMethodCollect = 11
                    THEN ISNULL(Collect,0)
				WHEN PaymentMethodCOD IS NULL AND PaymentMethodCollect = 11
                    THEN ISNULL(Collect,0)
            END
        ),
        @TotalZigi = SUM(
            CASE
                WHEN PaymentMethodCOD = 10 AND PaymentMethodCollect = 10
                    THEN ISNULL(Collect,0) + ISNULL(COD,0)
				WHEN PaymentMethodCOD IS NULL AND PaymentMethodCollect = 10
                    THEN ISNULL(Collect,0)
				WHEN PaymentMethodCOD = 10  AND PaymentMethodCollect IS NULL 
                    THEN ISNULL(COD,0) 
            END
        )
    FROM BaseData;

    /* ================================
       MONTO EN EFECTIVO (BILLETES)
    ==================================*/

    SELECT 
        @AmountMoney = COALESCE(SUM(mdos.Quantity * cm.Value), 0)
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dst WITH(NOLOCK)
    INNER JOIN [DeliveryBackOffice].[dbo].[MoneyByDeliveryOrderBySettlement] mdos WITH(NOLOCK)
        ON dst.ID = mdos.DeliveryOrderBySettlementId
    INNER JOIN [DeliveryBackOffice].[dbo].[CatMoney] cm WITH(NOLOCK)
        ON mdos.CatMoneyId = cm.IdCatMoney
    WHERE dst.Date_Received >= @DateFrom
      AND dst.Date_Received <= @DateTo
      AND dst.SettlementStationId IN (SELECT Name FROM splitstring(@hubsIds, ','));

    /* ================================
       TOTAL VOUCHERS
    ==================================*/

    SELECT 
        @TotalVouchers = ISNULL(SUM(rdm.AmountApplied), 0)
    FROM [DeliveryBackOffice].[dbo].[RelDepositManifest] rdm WITH(NOLOCK)
    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dst WITH(NOLOCK)
        ON rdm.DeliveryOrderBySettlementId = dst.ID
    WHERE dst.Date_Received >= @DateFrom
      AND dst.Date_Received <= @DateTo
      AND dst.SettlementStationId IN (SELECT [Name] FROM splitstring(@hubsIds, ','))
      AND rdm.RowStatus = 1;

    /* ================================
                 (DETALLE)
    ==================================*/

       SELECT dst.ID 'Manifiesto',
           cst.StationName 'Hub',
           CONVERT(DATE, dst.Date_Received) 'Fecha',
           CONCAT(dsd.Guide_Serie, dsd.Guide_Number) 'Guia',
           (CASE WHEN ord.[IsLastMileReturn] = 1 THEN CONCAT(ord.Receiver_FirstName, ' ', ord.Receiver_LastName) ELSE CONCAT(ord.[Sender_FirstName], ' ', ord.[Sender_LastName]) END) 'Remitente',
           (CASE WHEN ord.[IsLastMileReturn] = 1 THEN CONCAT(ord.[Sender_FirstName], ' ', ord.[Sender_LastName]) ELSE CONCAT(ord.Receiver_FirstName, ' ', ord.Receiver_LastName) END) 'Destinatario',
           CONCAT(sdr.First_Name, ' ', sdr.Last_Name) 'Piloto',
           --IIF(ord.IsCollect = 1, ord.PriceShippment, 0)
		   ISNULL(ord.PriceShippment, 0)'Collect',
           (CASE WHEN [ord].[IsLastMileReturn] = 1 THEN 0 ELSE ord.Collect_OnDelivery END) 'COD',
		   REPLACE(REPLACE(REPLACE(dc.Symbol,'.',''),'(',''),')','') [Currency_Symbol],
		   CASE 
		    WHEN CD.IdTypeOfMoneyCollect = 11  THEN CD.Voucher
			WHEN CD.IdTypeOfMoneyCollect = 10  THEN PZ.ZigiTransactionId
			ELSE ''
           END AS VoucherCollect,
			CASE 
		    WHEN CD.IdTypeOfMoneyCOD = 11  THEN CD.Voucher
			WHEN CD.IdTypeOfMoneyCOD = 10  THEN PZ.ZigiTransactionId
			ELSE ''
            END AS VoucherCOD,
		   CASE 
		      WHEN cd.IdTypeOfMoneyCOD = 11 THEN 'Transferencia'
			  WHEN cd.IdTypeOfMoneyCOD = 1  THEN 'Efectivo'
			  WHEN cd.IdTypeOfMoneyCOD = 2  THEN 'Pago con Tarjeta'
			  WHEN cd.IdTypeOfMoneyCOD = 10 THEN 'Zigi'
		  END PaymentMethodCOD,
		   CASE 
		      WHEN cd.IdTypeOfMoneyCollect = 11 THEN 'Transferencia'
			  WHEN cd.IdTypeOfMoneyCollect = 1  THEN 'Efectivo'
			  WHEN cd.IdTypeOfMoneyCollect = 2  THEN 'Pago con Tarjeta'
			  WHEN cd.IdTypeOfMoneyCollect = 10 THEN 'Zigi'
		  END PaymentMethodCollect,
		  ISNULL(@TotalZigi,0) AS TotalZigi,
		  ISNULL(@AmountMoney,0) AS AmountMoney,
		  ISNULL(@TotalCardCollect,0) AS TotalCardCollect,
		  ISNULL(@TotalTransfer,0) AS TotalTransfer,
		  ISNULL(@TotalVouchers,0) AS TotalVouchers
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dst WITH(NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd WITH(NOLOCK)
            ON dsd.ID_DeliveryOrderBySettlement = dst.ID
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] ord WITH(NOLOCK)
            ON ord.Guide_Serie = dsd.Guide_Serie
               AND ord.Guide_Number = dsd.Guide_Number
        INNER JOIN [DeliveryBackOffice].[dbo].[CatStation] cst WITH(NOLOCK)
            ON cst.IdStation = dst.SettlementStationId
        LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] sdr WITH(NOLOCK)
            ON sdr.ID = dst.ID_Courier
		LEFT JOIN [DeliveryBackOffice].[dbo].[Cost] c WITH (NOLOCK)
            ON c.GuideSerie = ord.guide_Serie
            AND c.GuideNumber = ord.guide_number
		LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD] dc WITH (NOLOCK)
            ON dc.IdCatCurrencyCOD = ISNULL(c.ShippingCurrency,1)
        LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] cd WITH (NOLOCK)
            ON c.IdCost = cd.IdCost
		LEFT JOIN [DeliveryBackOffice].[dbo].[PaymentZigi] PZ WITH (NOLOCK)
        ON  PZ.GuideSerie  = dsd.Guide_Serie AND PZ.GuideNumber = dsd.Guide_Number
       LEFT JOIN [DeliveryBackOffice].[dbo].[PaymentZigiMulti] PZM WITH (NOLOCK)
        ON  PZM.Id_PaymentZigi  = PZ.ZigiPaymentId 
    WHERE CONVERT(DATE, dst.Date_Received)
          BETWEEN @fromDate AND @toDate
          AND dst.SettlementStationId IN
              (
                  SELECT Name FROM splitstring(@hubsIds, ',')
              )
		--  AND IIF(ord.IsCollect = 1, ord.PriceShippment + ord.Collect_OnDelivery, ord.Collect_OnDelivery) > 0
          AND dsd.Guide_Delivered = 'true'
          AND dsd.Guide_Discharged IS NOT NULL
          AND dsd.RowStatus = 1
    ORDER BY cst.IdStation,
             dst.Date_Received,
             dst.ID,
             ord.Guide_Number;

END