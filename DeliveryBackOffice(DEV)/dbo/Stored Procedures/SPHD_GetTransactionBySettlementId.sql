-- =============================================
-- Author:        <Edelman>
-- Create date:   <2026-01-16>
-- Description:   obtener guías pagadas por transferencia en entrega POD
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_GetTransactionBySettlementId]
(
    @ID_DeliveryOrderBySettlement INT,
    @Country VARCHAR(5)
)
AS
BEGIN
    SET NOCOUNT ON;

    --Si no es GT, devolver estructura vacía
    IF @Country <> 'GT'
    BEGIN
        SELECT 
            CAST(NULL AS VARCHAR(20))  AS PaymentType,
            CAST(NULL AS VARCHAR(100)) AS Transaccion,
            CAST(NULL AS VARCHAR(50))  AS Voucher,
            CAST(NULL AS DECIMAL(18,2)) AS TotalAmount
        WHERE 1 = 0;

        RETURN;
    END;

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
            DSD.ID_DeliveryOrderBySettlement,
			DO.IsCollect
        FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
            ON C.GuideSerie = DSD.Guide_Serie 
           AND C.GuideNumber = DSD.Guide_Number
        LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
            ON CD.IdCost = C.IdCost
        LEFT JOIN [DeliveryBackOffice].[dbo].[PaymentZigi] PZ WITH (NOLOCK)
            ON PZ.GuideSerie  = DSD.Guide_Serie 
           AND PZ.GuideNumber = DSD.Guide_Number
        LEFT JOIN [DeliveryBackOffice].[dbo].[PaymentZigiMulti] PZM WITH (NOLOCK)
            ON PZM.Id_PaymentZigi = PZ.ZigiPaymentId 
        LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
            ON DO.Guide_Serie = DSD.Guide_Serie 
           AND DO.Guide_Number = DSD.Guide_Number
        WHERE DSD.ID_DeliveryOrderBySettlement = @ID_DeliveryOrderBySettlement
        AND DO.IsLastMileReturn = 0
		AND DSD.Guide_Returned = 0
    )

-- BLOQUE 1: COD (TRANSFERENCIAS)
  SELECT
        CASE 
            WHEN IdTypeOfMoneyCOD = 11 THEN 'Transferencia'
            WHEN IdTypeOfMoneyCollect = 11 THEN 'Transferencia'
        END AS PaymentType,

        Voucher + ProductNumber AS Transaccion,

        CASE 
            WHEN IdTypeOfMoneyCOD = 11 THEN Voucher
            WHEN IdTypeOfMoneyCollect = 11 THEN Voucher
            ELSE ''
        END AS Voucher,

        CASE
            WHEN IdTypeOfMoneyCOD IN (11) 
                 AND IdTypeOfMoneyCollect IN (11)
                THEN ISNULL(PriceShippment,0) + ISNULL(Collect_OnDelivery,0)
            WHEN IdTypeOfMoneyCOD IN (11) 
                 AND IdTypeOfMoneyCollect IS NULL
                THEN ISNULL(Collect_OnDelivery,0)
            WHEN IdTypeOfMoneyCollect IN (11) 
                 AND IdTypeOfMoneyCOD IS NULL
                THEN ISNULL(PriceShippment,0) 
			WHEN IdTypeOfMoneyCOD IN (11) 
                 AND IdTypeOfMoneyCollect <> 11
                THEN ISNULL(Collect_OnDelivery,0)
			WHEN IdTypeOfMoneyCOD <> 11 
                 AND IdTypeOfMoneyCollect = 11
                THEN ISNULL(Collect_OnDelivery,0)
        END AS TotalAmount

    FROM BaseData
    WHERE IdTypeOfMoneyCOD IN (11)
       OR IdTypeOfMoneyCollect IN (11)

  UNION ALL

-- BLOQUE: Link de pago (ID 12)
  SELECT
        CASE 
            WHEN IdTypeOfMoneyCOD = 12 THEN 'Forza Pay'
            WHEN IdTypeOfMoneyCollect = 12 THEN 'Forza Pay'
        END AS PaymentType,

        Voucher + ProductNumber AS Transaccion,

        CASE 
            WHEN IdTypeOfMoneyCOD = 12 THEN Voucher
            WHEN IdTypeOfMoneyCollect = 12 THEN Voucher
            ELSE ''
        END AS Voucher,

        CASE
            WHEN IdTypeOfMoneyCOD IN (12) 
                 AND IdTypeOfMoneyCollect IN (12)
                THEN ISNULL(PriceShippment,0) + ISNULL(Collect_OnDelivery,0)
            WHEN IdTypeOfMoneyCOD IN (12) 
                 AND IdTypeOfMoneyCollect IS NULL
                THEN ISNULL(Collect_OnDelivery,0)
            WHEN IdTypeOfMoneyCollect IN (12) 
                 AND IdTypeOfMoneyCOD IS NULL
                THEN ISNULL(PriceShippment,0) 
            WHEN IdTypeOfMoneyCOD IN (12) 
                 AND IdTypeOfMoneyCollect <> 12
                THEN ISNULL(Collect_OnDelivery,0)
            WHEN IdTypeOfMoneyCOD <> 12 
                 AND IdTypeOfMoneyCollect = 12
                THEN ISNULL(Collect_OnDelivery,0)
        END AS TotalAmount

    FROM BaseData
    WHERE IdTypeOfMoneyCOD IN (12)
       OR IdTypeOfMoneyCollect IN (12)

  UNION ALL
    -- BLOQUE 1: COD ( Zigi)
    SELECT
        CASE 
            WHEN IdTypeOfMoneyCOD = 10 THEN 'Zigi'
            WHEN IdTypeOfMoneyCollect = 10 THEN 'Zigi'
        END AS PaymentType,

        Voucher + ProductNumber AS Transaccion,

        CASE 
            WHEN IdTypeOfMoneyCOD = 10 THEN ZigiTransactionId
            WHEN IdTypeOfMoneyCollect = 10 THEN ZigiTransactionId
            ELSE ''
        END AS Voucher,

        CASE
            WHEN IdTypeOfMoneyCOD IN (10) 
                 AND IdTypeOfMoneyCollect IN (10)
                THEN ISNULL(PriceShippment,0) + ISNULL(Collect_OnDelivery,0)

            WHEN IdTypeOfMoneyCOD IN (10) 
                 AND IdTypeOfMoneyCollect IS NULL
                THEN ISNULL(PriceShippment,0) + ISNULL(Collect_OnDelivery,0)

            WHEN IdTypeOfMoneyCollect IN (10) 
                 AND IdTypeOfMoneyCOD IS NULL
                THEN ISNULL(PriceShippment,0) + ISNULL(Collect_OnDelivery,0)

            WHEN IdTypeOfMoneyCOD IN (10) 
                 AND IdTypeOfMoneyCollect NOT IN (10)
                THEN ISNULL(Collect_OnDelivery,0)

            WHEN IdTypeOfMoneyCollect IN (10) 
                 AND IdTypeOfMoneyCOD NOT IN (10)
                THEN ISNULL(PriceShippment,0)
        END AS TotalAmount

    FROM BaseData
    WHERE IdTypeOfMoneyCOD IN (10)
       OR IdTypeOfMoneyCollect IN (10)

    UNION ALL

    -- BLOQUE 2: Tarjeta
    SELECT
        'Tarjeta',
 
        Voucher + ProductNumber,
 
        '',
 
        CASE
 
            WHEN IdTypeOfMoneyCOD <> 2
                 AND IdTypeOfMoneyCollect = 2
                THEN ISNULL(PriceShippment,0)
            WHEN IdTypeOfMoneyCOD IS NULL
                 AND IdTypeOfMoneyCollect = 2  
                THEN ISNULL(PriceShippment,0)
        END
 
    FROM BaseData
    WHERE IdTypeOfMoneyCollect = 2
    AND IsCollect = 1

END