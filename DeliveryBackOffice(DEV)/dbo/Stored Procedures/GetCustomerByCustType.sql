-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2024-12-10>
-- Description:	<Devuelve listado de clientes por tipo de cliente y país de origen>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomerByCustType] 
	@CountryId AS VARCHAR(2)='GT',
	@CustomerTypeID AS INT = 1  --Corporativos
AS
BEGIN	
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT IdCustomer AS Id, Name
		FROM Customer WITH (NOLOCK)
		WHERE idCustomerType = @CustomerTypeID
			AND CountryID = @CountryId
			AND RowSatus = 1
		ORDER BY Name ASC 
        
		SELECT 1 AS 'StatusCode', 
        'SUCCESS' AS 'Description'

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END;