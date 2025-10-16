-- =============================================
-- Author:		<Edwin Ramirez>
-- Create date: <2020-12-24>
-- Description:	<get customer forza delivery>
-- =============================================
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2025-05-01>
-- Description:	<Se implementa filtrado para multipaís.>
-- =============================================
CREATE PROCEDURE [dbo].[spw_get_customer]
	-- Add the parameters for the stored procedure here
	  @IdCustomer AS INT = -1
	, @IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CustomerID AS INT;

	SET @CustomerID = @IdCustomer;

    -- Insert statements for procedure here
	SELECT A.IdCustomer [IdCustomer] , A.CustomerName [CustomerName]
	FROM (
				SELECT -1 [IdCustomer], 'TODOS' [CustomerName]
				UNION
				SELECT client.IdCustomer [IdCustomer], UPPER(client.Name) [CustomerName]
				FROM DeliveryBackOffice.dbo.Customer  client WITH(NOLOCK)
				WHERE client.RowSatus = 1 AND client.CountryID = @IdCountry
		) A
	WHERE (A.IdCustomer = @CustomerID  OR @CustomerID = -1)
END
