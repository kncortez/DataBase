-- =============================================
-- Author:		Freddy Camposeco
-- Create date: 2025-10-17
-- Description:	Obtiene la lista de vouchers Efectibox aplicados a un manifiesto de liquidación COD
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_vouchers_by_manifest] @IdManifest INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        -- Número de voucher concatenado: TerminalSerie-TransactionCode
        CONCAT (
            d.TerminalSerie,
            '-',
            CAST(d.TransactionCode AS NVARCHAR)
            ) AS VoucherNumber,
        -- Monto aplicado de este voucher al manifiesto específico
        rdm.AmountApplied AS Amount,
        -- Información adicional para auditoría
        d.IdDeposit,
        rdm.IdRelDepositManifest,
        rdm.DateCreated AS AppliedDate,
        -- Información del voucher original
        d.Amount AS VoucherTotalAmount,
        d.Balance AS VoucherRemainingBalance
    FROM DeliveryBackOffice.dbo.RelDepositManifest rdm WITH (NOLOCK)
    INNER JOIN DeliveryBackOffice.dbo.Deposit d WITH (NOLOCK) ON rdm.IdDeposit = d.IdDeposit
    WHERE rdm.DeliveryOrderBySettlementId = @IdManifest
        AND rdm.RowStatus = 1 -- Solo registros activos
    ORDER BY rdm.DateCreated;-- Ordenar por fecha de aplicación
END
GO


