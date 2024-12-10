-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2024-12-10>
-- Description:	<Devuelve listado de puntos de visita por cliente>
-- =============================================
CREATE PROCEDURE [dbo].[GetVisitPointsByCustomer] 
	@CustomerId AS INT
AS
BEGIN	
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT vpc.IdVisitPointClient AS Id, vpc.DescriptionOfClient AS Name
		FROM dbo.VisitPointClient vpc WITH (NOLOCK)
			INNER JOIN dbo.Customer cu WITH (NOLOCK)
				ON vpc.CustomerID = cu.IdCustomer
		WHERE vpc.StatusClient = 1
			AND cu.IdCustomer = @CustomerId
		ORDER BY vpc.DescriptionOfClient ASC;

		SELECT 1 AS 'StatusCode', 'SUCCESS' AS 'Description' 

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END;