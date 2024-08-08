-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-07-11>
-- Description:	<Se obtiene el pais de origen del cliente>
-- =============================================

CREATE PROCEDURE sp_get_customerCountry_Parser
				 @IdCustomer INT
AS
BEGIN
	
	SELECT CountryID FROM Customer WHERE IdCustomer = @IdCustomer
END