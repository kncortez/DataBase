-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2024-12-10>
-- Description:	<Devuelve listado de clientes corporativos por país de origen>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomerByCountry] 
	@CountryId AS VARCHAR(2)='GT'
AS
BEGIN	
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @CorporativeCustomerID INT

		SELECT TOP 1 @CorporativeCustomerID = idCustomerType 
		FROM customerType WITH (NOLOCK)
		WHERE CustomerTypeStatus = 1
			AND Description = 'CORPORATIVO';

		IF @CorporativeCustomerID IS NULL
        BEGIN
            SELECT 0 AS 'StatusCode', 'No se encontró tipo de cliente corporativo' AS Description;
            RETURN;
        END;

		SELECT IdCustomer AS Id, Name
		FROM Customer WITH (NOLOCK)
		WHERE idCustomerType = @CorporativeCustomerID
			AND CountryID = @CountryId
			AND RowSatus = 1
		ORDER BY Name ASC;

		SELECT 1 AS 'StatusCode', 'SUCCESS' AS 'Description' 

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END;