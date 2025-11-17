-- =============================================
-- Author:		<Walter, Orozco>
-- Create date: <2025-09-10>
-- Description:	<Validacion de saldo disponible para un deposito.>
-- =============================================
CREATE PROCEDURE [dbo].[ValidateDepositBalance]
    @NewDeposits dbo.TblDeposit READONLY
AS
BEGIN

	--Obtener informacion de deposito/s
	SELECT 
		  d.TransactionNumber
		, d.TransactionCode
		, d.TransactionDate
		, d.TerminalSerie
		, d.Balance
	FROM @NewDeposits ND
	INNER JOIN DeliveryBackOffice.dbo.Deposit D WITH(NOLOCK)
		ON ND.TransactionNumber = D.TransactionNumber
    
END;