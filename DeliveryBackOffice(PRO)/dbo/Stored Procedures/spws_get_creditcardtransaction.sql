-- =============================================
CREATE PROCEDURE [dbo].[spws_get_creditcardtransaction]	
	@OrderNumber as nvarchar(38)
AS
BEGIN	
select [IdTransaction], [System], [CardNumber], [TypeCardNumber], [Ammount], [Currency], [OrderNumber], [Signature], [CustomerReference], [ReferenceNumber], [ECIIndicator], [Authenticationresult], [TransactionStain], [CAVV], [DatetimeCreated], [DatetimeUpdated], [ReasonCode], [ReasonCodeDescription] 
from DeliveryBackOffice.dbo.CreditCardTransaction
where OrderNumber = @OrderNumber
END
