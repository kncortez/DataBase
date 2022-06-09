
CREATE PROCEDURE [dbo].[sp_get_CustomerName]

@IdCustomer int
AS

BEGIN

	SELECT Name FROM Customer
			WHERE IdCustomer = @IdCustomer

END  
