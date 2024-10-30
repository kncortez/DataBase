-- =============================================
-- Author:		<Tito García>
-- Create date: <2024-10-29>
-- Description:	<Se obtienen las guías según el número de referencia>
-- =============================================
ALTER PROCEDURE [dbo].[sphd_getGuidesFromReferenceNumber]
	@ReferenceNumber NVARCHAR(150),
	@IdCountry VARCHAR(2) = 'GT'
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
	
		SELECT TOP 10 CONCAT(Guide_Serie, Guide_Number) AS Guide
		FROM [dbo].[DeliveryOrder] do WITH (NOLOCK)
		WHERE do.Ticket_Number = @ReferenceNumber
			AND ISNULL([do].SenderCountryId,'GT') = @IdCountry
		ORDER BY DateCreated DESC

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END