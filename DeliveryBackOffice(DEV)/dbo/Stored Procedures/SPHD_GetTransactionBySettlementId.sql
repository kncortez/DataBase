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
        CD.Voucher,
        C.CODAmount,
        C.TotalAmount + C.CODAmount AS 'TotalAmount',
		 'Transferencia' AS 'Tipo'
    FROM dbo.DeliverySettlementDetail DSD WITH (NOLOCK)
    INNER JOIN DeliveryBackOffice.dbo.Cost C WITH (NOLOCK)
        ON C.GuideSerie = DSD.Guide_Serie AND C.GuideNumber = DSD.Guide_Number
    INNER JOIN DeliveryBackOffice.dbo.CostDetail CD WITH (NOLOCK)
        ON CD.IdCost = C.IdCost
    WHERE
        DSD.ID_DeliveryOrderBySettlement = @ID_DeliveryOrderBySettlement
        AND CD.IdTypeOfMoney = 11;
END
GO
