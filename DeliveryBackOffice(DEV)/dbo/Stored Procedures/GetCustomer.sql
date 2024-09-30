-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2021-29-10>
-- Description:	<Obtiene el listado de clientes>
-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-06-06>
-- Description: <Se agrego filtro por pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomer]
	-- Add the parameters for the stored procedure here
	@IdCustomer INT = -1,
	@Country NVARCHAR(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT DISTINCT cu.[IdCustomer]
		, cu.[Name]
		, cu.[Description]
		, cu.[CountryID]
		, IIF(ct.Description = 'CORPORATIVO' OR ru.UsrEmail IS NULL OR ru.UsrEmail = '', cu.RegexEmail, ru.UsrEmail) [RegexEmail]
	FROM Customer cu WITH(NOLOCK)
	LEFT JOIN Account ac WITH(NOLOCK)
		ON ac.IdCustomer = cu.IdCustomer
	LEFT JOIN RolByUserByAccount rua WITH(NOLOCK)
		ON rua.RuaIdAccount = ac.AccIdAccount
	LEFT JOIN RegisterUser ru WITH(NOLOCK)
		ON ru.UsrIdUser = rua.RuaIdUser
	LEFT JOIN CustomerType ct WITH(NOLOCK)
		ON ct.IdCustomerType = cu.IdCustomerType
	WHERE (@IdCustomer = -1 OR cu.IdCustomer = @IdCustomer)
        AND IIF(cu.CountryID IS NULL,'GT',cu.CountryID ) = @Country
		AND (cu.RowSatus = 1 OR cu.RowSatus IS NULL)
	ORDER BY cu.[Name];
END
