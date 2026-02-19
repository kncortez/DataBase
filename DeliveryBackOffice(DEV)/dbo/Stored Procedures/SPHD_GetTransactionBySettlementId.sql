-- =============================================
-- Author:		<Edelman>
-- Create date: <2026-01-16>
-- Description:	<obtener guías pagadas por transferencia en entrega POD>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_GetTransactionBySettlementId]
(
@ID_DeliveryOrderBySettlement INT
)
AS
BEGIN
SET NOCOUNT ON;

;WITH BaseData AS
(
    SELECT
        CD.Voucher,
        C.ProductNumber,
        CD.IdTypeOfMoneyCOD,
        CD.IdTypeOfMoneyCollect,
        PZ.ZigiTransactionId,
        ISNULL(DO.PriceShippment,0)      AS PriceShippment,
        ISNULL(DO.Collect_OnDelivery,0)  AS Collect_OnDelivery,
        DSD.ID_DeliveryOrderBySettlement
    FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
    INNER JOIN [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
        ON C.GuideSerie = DSD.Guide_Serie 
       AND C.GuideNumber = DSD.Guide_Number
    LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
        ON CD.IdCost = C.IdCost
    LEFT JOIN [DeliveryBackOffice].[dbo].[PaymentZigi] PZ WITH (NOLOCK)
        ON PZ.GuideSerie  = DSD.Guide_Serie 
       AND PZ.GuideNumber = DSD.Guide_Number
    LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
        ON DO.Guide_Serie = DSD.Guide_Serie 
       AND DO.Guide_Number = DSD.Guide_Number
    WHERE DSD.ID_DeliveryOrderBySettlement = @ID_DeliveryOrderBySettlement
    AND DO.IsLastMileReturn = 0
)

--BLOQUE 1: COD (Transferencia / Zigi)
					SELECT
					  CASE 
							WHEN IdTypeOfMoneyCOD = 11 THEN 'Transferencia'
							WHEN IdTypeOfMoneyCOD = 10 THEN 'Zigi'
						END AS PaymentType,
						Voucher + ProductNumber AS Transaccion,
						CASE 
							WHEN IdTypeOfMoneyCOD = 11 THEN Voucher
							WHEN IdTypeOfMoneyCOD = 10 THEN ZigiTransactionId
							ELSE ''
						END AS Voucher,
						CASE
							WHEN IdTypeOfMoneyCOD = 10 AND IdTypeOfMoneyCollect = 10 
								THEN PriceShippment + Collect_OnDelivery
							WHEN IdTypeOfMoneyCOD = 11 AND IdTypeOfMoneyCollect = 11 
								THEN PriceShippment + Collect_OnDelivery
							WHEN IdTypeOfMoneyCOD = 11 
								THEN Collect_OnDelivery
							WHEN IdTypeOfMoneyCOD = 10
								THEN Collect_OnDelivery
						END AS TotalAmount
					FROM BaseData
					WHERE IdTypeOfMoneyCOD IN (10,11)
			UNION ALL
			-- BLOQUE 2: Tarjeta (Collect = 2)
			SELECT
			    'Tarjeta',
				Voucher + ProductNumber,
				'',
				PriceShippment
			FROM BaseData
			WHERE IdTypeOfMoneyCollect = 2
			UNION ALL
			-- BLOQUE 3: Transferencia solo en Collect
			SELECT
			    'Transferencia',
				Voucher + ProductNumber,
				Voucher,
				PriceShippment
			FROM BaseData
			WHERE IdTypeOfMoneyCollect = 11
			  AND IdTypeOfMoneyCOD IS NULL
			  ORDER BY 1 DESC;
END
