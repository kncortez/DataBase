
-- =============================================
-- Author:		<Eduardo López>
-- Create date: <19-12-2023>
-- Description:	<Obtener valores de configParams>
-- =============================================
CREATE PROCEDURE [dbo].[GetTypeCustomer] 
	@Merchant AS INT
	AS
BEGIN
	SET NOCOUNT ON;

    SELECT TOP 1	[IdCustomer],
			[Name],
			[IdCustomerType]
	FROM	[Customer] CT
	WHERE	[IdCustomer] = @Merchant

END