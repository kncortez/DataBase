-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,29-08-2025>
-- Description:	<Description,Obtener el Transactionidentifier de una transacción de pasarela de pago PowerTranz3DS>
-- =============================================
CREATE PROCEDURE SPHW_GetTransactionidentifier 
@OrderNumber NVARCHAR(50)

AS
BEGIN

	SET NOCOUNT ON;

    SELECT TOP 1
		[TransactionStain] Transactionidentifier 
	FROM [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] WITH (NOLOCK)
	WHERE OrderNumber=@OrderNumber
	ORDER BY DateCreated DESC
END
GO
