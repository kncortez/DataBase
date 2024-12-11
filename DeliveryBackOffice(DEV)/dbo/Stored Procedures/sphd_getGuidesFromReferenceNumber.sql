-- =============================================
-- Author:		<Tito García>
-- Create date: <2024-10-29>
-- Description:	<Se obtienen las guías según el número de referencia>
-- =============================================
-- Modified:	<Brandon Pedroza>
-- Create date: <2024-12-11>
-- Description:	<Se agrega campo de nombre de cliente asociado a la guía>
-- =============================================
create PROCEDURE [dbo].[sphd_getGuidesFromReferenceNumber]
	@ReferenceNumber NVARCHAR(150),
	@IdCountry VARCHAR(2) = 'GT'
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
	
		SELECT TOP 10 CONCAT(Guide_Serie, Guide_Number) AS 'Guide',
					  ISNULL(cu.[Name], '')				AS 'CustomerName'
		FROM [dbo].[DeliveryOrder] do WITH (NOLOCK)
			INNER JOIN [dbo].[Customer] cu WITH (NOLOCK)
			ON do.IdCustomer = cu.IdCustomer
		WHERE do.Ticket_Number = @ReferenceNumber
			AND [do].SenderCountryId = @IdCountry
		ORDER BY do.DateCreated DESC

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END