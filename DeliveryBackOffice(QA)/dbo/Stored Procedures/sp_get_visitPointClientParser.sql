CREATE PROCEDURE [dbo].[sp_get_visitPointClientParser]
@IdVisitClient AS int
AS
BEGIN

	SELECT CodeOfReference, CustomerID, Address, Zone, Town, Department, Phone, FirstName, LastName FROM VisitPointClient_Parser
	WHERE CodeOfReference = @IdVisitClient

END