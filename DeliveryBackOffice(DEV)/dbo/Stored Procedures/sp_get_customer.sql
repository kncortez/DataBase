
      
Create PROCEDURE sp_get_customer
@IdCliente AS int
AS

declare @Customer int
BEGIN

	set @Customer = (select CustomerID FROM VisitPointClient
	WHERE CodeOfReference = @IdCliente)

	Select IdCustomer, Name, RegexEmail, RegexFilename, Abbreviation from Customer
	       where IdCustomer = @Customer


END
