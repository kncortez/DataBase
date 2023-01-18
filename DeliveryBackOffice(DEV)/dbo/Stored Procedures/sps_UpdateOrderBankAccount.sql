
-- =============================================
-- Author:		<Aquino, Cesar>
-- Create date: <2020-10-28>
-- Description:	<Update DCBA_ID Orders>
-- =============================================
CREATE PROCEDURE [dbo].[sps_UpdateOrderBankAccount]
	@Id_BankAccount int=0,
	@Guide_Number bigint=0
AS
BEGIN
	SET NOCOUNT ON;

    update [DeliveryBackOffice].[dbo].DeliveryOrder
	set DCBA_ID= @Id_BankAccount
	where Guide_Number = @Guide_Number

	
END
