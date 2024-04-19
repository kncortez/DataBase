-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-09-12>
-- Description:	<Description,Validar estado de una transacción en proceso de pago>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetResponseFacTransactionProcessStatus] 
	@OrderNumber VARCHAR(100) = NULL, 
	@AccountId INT = 0,
	@Token NVARCHAR(50) = '',
	@SystemId INT = NULL
AS
BEGIN

	SET NOCOUNT ON;

	  SELECT Top 1       
		 CTC.ReasonCode, 
         CTC.ReasonDescription,
		 CTC.StatusSend,
		 CTC.ReferenceNumber
	    FROM [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] CTC WITH(NOLOCK)
							WHERE
							OrderNumber = @OrderNumber

   
END