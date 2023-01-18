
-- =============================================
-- Description:	<SP para obtener el nombre de un cliente desde la tabla Customer por medio del ID del cliente>
-- Nota: Este SP solamente es utilizado por el parser
-- =============================================

CREATE PROCEDURE [dbo].[sp_get_CustomerName]

@IdCustomer int
AS

BEGIN

	SELECT Name FROM Customer
			WHERE IdCustomer = @IdCustomer

END