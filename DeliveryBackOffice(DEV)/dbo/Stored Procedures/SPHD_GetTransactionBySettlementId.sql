-- =============================================
-- Author:		<Edelman>
-- Create date: <2026-01-16>
-- Description:	<obtener guías pagadas por transferencia en entrega POD>
-- =============================================
CREATE PROCEDURE SPHD_GetTransactionBySettlementId
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
         ISNULL(C.TotalAmount,0) + ISNULL(C.CODAmount,0) AS 'TotalAmount',
        C.TotalAmount + C.CODAmount AS 'TotalAmount',
		 CASE 
		    WHEN CD.IdTypeOfMoney = 11  THEN 'Transferencia'
			WHEN CD.IdTypeOfMoney = 10  THEN 'Zigi'
			WHEN CD.IdTypeOfMoney = 2  THEN 'Tarjeta'
			ELSE 'N/A'
        END AS 'PaymentType'
    FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
    INNER JOIN [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
        ON C.GuideSerie = DSD.Guide_Serie AND C.GuideNumber = DSD.Guide_Number
    INNER JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
        ON CD.IdCost = C.IdCost
    LEFT JOIN [DeliveryBackOffice].[dbo].[PaymentZigi] PZ WITH (NOLOCK)
        ON  PZ.GuideSerie  = DSD.Guide_Serie
    AND PZ.GuideNumber = DSD.Guide_Number
    LEFT JOIN [DeliveryBackOffice].[dbo].[PaymentZigiMulti] PZM WITH (NOLOCK)
        ON  PZM.Id_PaymentZigi  = PZ.ZigiPaymentId 
    WHERE
        DSD.ID_DeliveryOrderBySettlement = @ID_DeliveryOrderBySettlement
        AND CD.IdTypeOfMoney IN (11,10,2);
END
GO
