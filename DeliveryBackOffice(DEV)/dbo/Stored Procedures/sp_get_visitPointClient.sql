CREATE PROCEDURE sp_get_visitPointClient
@IdCliente AS int
AS
BEGIN

	SELECT CodeOfReference, CustomerID, Address, Zone, Town, Department, Phone, FirstName, LastName FROM VisitPointClient
	WHERE CodeOfReference = @IdCliente

END