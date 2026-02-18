USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SPHD_GetTransactionBySettlementId]    Script Date: 15/02/2026 23:01:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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

    SELECT 
        CD.Voucher + '-' + C.ProductNumber AS Transaccion,
		 CASE 
		    WHEN CD.IdTypeOfMoney = 11  THEN CD.Voucher
			WHEN CD.IdTypeOfMoney = 10  THEN PZ.ZigiTransactionId
			ELSE CD.Voucher
        END AS Voucher,
		 CASE
		     WHEN CD.IdTypeOfMoneyCOD = 10 AND CD.IdTypeOfMoneyCollect = 10 THEN (ISNULL(DO.priceShippment,0) + ISNULL(DO.Collect_OnDelivery,0))
			 WHEN CD.IdTypeOfMoneyCOD = 11 AND CD.IdTypeOfMoneyCollect = 11 THEN (ISNULL(DO.PriceShippment,0) + ISNULL(DO.Collect_OnDelivery,0))
             WHEN CD.IdTypeOfMoneyCOD = 11 AND CD.IdTypeOfMoneyCollect <> 11 THEN  ISNULL(DO.Collect_OnDelivery,0)
             WHEN CD.IdTypeOfMoneyCOD = 11 AND CD.IdTypeOfMoneyCollect IS NULL THEN ISNULL(DO.Collect_OnDelivery,0)
			 ELSE 0 END
			 AS 'TotalAmount',
		 CASE 
		    WHEN CD.IdTypeOfMoneyCOD = 11  THEN 'Transferencia'
			WHEN CD.IdTypeOfMoneyCOD = 10  THEN 'Zigi'
			ELSE 'N/A'
        END AS 'PaymentType'
    FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
    INNER JOIN [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
        ON C.GuideSerie = DSD.Guide_Serie AND C.GuideNumber = DSD.Guide_Number
    LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
        ON CD.IdCost = C.IdCost
    LEFT JOIN [DeliveryBackOffice].[dbo].[PaymentZigi] PZ WITH (NOLOCK)
        ON  PZ.GuideSerie  = DSD.Guide_Serie AND PZ.GuideNumber = DSD.Guide_Number
    LEFT JOIN [DeliveryBackOffice].[dbo].[PaymentZigiMulti] PZM WITH (NOLOCK)
        ON  PZM.Id_PaymentZigi  = PZ.ZigiPaymentId 
	LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
	    ON DO.Guide_Serie = DSD.Guide_Serie AND DO.Guide_Number = DSD.Guide_Number
    WHERE
        DSD.ID_DeliveryOrderBySettlement = @ID_DeliveryOrderBySettlement
        AND CD.IdTypeOfMoneyCOD IN (10,11)
	UNION ALL
	   SELECT 
        CD.Voucher + '-' + C.ProductNumber AS Transaccion,
		 CASE 
		    WHEN CD.IdTypeOfMoney = 11  THEN CD.Voucher
			WHEN CD.IdTypeOfMoney = 10  THEN PZ.ZigiTransactionId
			ELSE ''
        END AS Voucher,
         ISNULL(DO.PriceShippment,0) AS 'TotalAmount',
		 CASE 
		    WHEN CD.IdTypeOfMoneyCOD = 11  THEN 'Transferencia'
			WHEN CD.IdTypeOfMoneyCOD = 10  THEN 'Zigi'
			WHEN CD.IdTypeOfMoneyCollect = 2  THEN 'Tarjeta'
			ELSE 'N/A'
        END AS 'PaymentType'
    FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
    INNER JOIN [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
        ON C.GuideSerie = DSD.Guide_Serie AND C.GuideNumber = DSD.Guide_Number
    LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
        ON CD.IdCost = C.IdCost
    LEFT JOIN [DeliveryBackOffice].[dbo].[PaymentZigi] PZ WITH (NOLOCK)
        ON  PZ.GuideSerie  = DSD.Guide_Serie AND PZ.GuideNumber = DSD.Guide_Number
    LEFT JOIN [DeliveryBackOffice].[dbo].[PaymentZigiMulti] PZM WITH (NOLOCK)
        ON  PZM.Id_PaymentZigi  = PZ.ZigiPaymentId 
	LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
	    ON DO.Guide_Serie = DSD.Guide_Serie AND DO.Guide_Number = DSD.Guide_Number
    WHERE
        DSD.ID_DeliveryOrderBySettlement = @ID_DeliveryOrderBySettlement
        AND CD.IdTypeOfMoneyCollect IN (2)
	
END
