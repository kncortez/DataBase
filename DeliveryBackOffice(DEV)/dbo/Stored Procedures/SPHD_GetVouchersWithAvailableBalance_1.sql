-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,2024-10-24>
-- Description:	<Description,Obtener Vouchers con saldo disponible deposito Efectibox>
-- =============================================
create PROCEDURE [dbo].[SPHD_GetVouchersWithAvailableBalance]
@DateFROM DATE,
@DateTo DATE
AS
BEGIN
	SET NOCOUNT ON;
	SELECT
		MAX(D.Amount) AS TotalAmount,
		MAX(D.Amount) - SUM(RDM.AmountApplied) AS Balance,
		MAX(D.TransactionDate) AS TransactionDate,
		MAX(D.TransactionCode) AS TransactionCodes,
		MAX(D.UserNickNameDeposit) AS UserNickNames,
		MAX(D.TerminalSerie) AS TerminalSerie,
		MAX(CR.CodeRoute) AS CodeRoute
	FROM [DeliveryBackOffice].[dbo].[Deposit] D WITH (NOLOCK)
	INNER JOIN [DeliveryBackOffice].[dbo].[RelDepositManifest] RDM WITH (NOLOCK)
		ON D.IdDeposit = RDM.IdDeposit
	INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOS WITH(NOLOCK)
		ON RDM.DeliveryOrderBySettlementId = DOS.ID
	INNER JOIN [DeliveryBackOffice].[dbo].[CatRoute] CR WITH(NOLOCK)
		ON DOS.CatRouteId = CR.IdRoute
	WHERE D.TransactionDate >= @DateFrom AND
	      D.TransactionDate <= @DateTo   AND
		  D.Balance>0
	GROUP BY D.TransactionCode
	HAVING MAX(D.Amount) - SUM(RDM.AmountApplied) > 0
	ORDER BY D.TransactionCode DESC
END