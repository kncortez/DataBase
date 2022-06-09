CREATE procedure [dbo].[sp_get_tipoCustomer]

@IdCustomer int
AS

BEGIN

	SELECT Name FROM Customer
			WHERE IdCustomer = @IdCustomer

END  