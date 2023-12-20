-- =============================================
-- Author:		<Eduardo López>
-- Create date: <19-12-2023>
-- Description:	<Obtener tipo de cliente>
-- =============================================
CREATE PROCEDURE [dbo].[GetTypeCustomer] 
	@Merchant AS INT
	AS
BEGIN
	SET NOCOUNT ON;

    SELECT TOP 1	[IdCustomer],
			[Name],
			[IdCustomerType]
	FROM	[Customer] CT With(Nolock)
	WHERE	[IdCustomer] = @Merchant

END
