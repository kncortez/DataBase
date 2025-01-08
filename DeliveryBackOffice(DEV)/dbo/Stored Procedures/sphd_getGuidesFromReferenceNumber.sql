-- =============================================
-- Author:		<Tito García>
-- Create date: <2024-10-29>
-- Description:	<Se obtienen las guías según el número de referencia>
-- =============================================
-- Author:		<Tito García>
-- Updated date: <2025-01-08>
-- Description:	<Se agrega filtro para obtner las guias que no estan en estados terminales>
-- =============================================
create PROCEDURE [dbo].[sphd_getGuidesFromReferenceNumber]
	@ReferenceNumber NVARCHAR(150),
	@IdCountry VARCHAR(2) = 'GT'
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
	
		SELECT TOP 10 CONCAT(Guide_Serie, Guide_Number) AS Guide
		FROM [dbo].[DeliveryOrder] do WITH (NOLOCK)
            INNER JOIN [dbo].[StatusOrder] [so] WITH (NOLOCK)
                ON [do].[StatusOrderId] = [so].[StatusOrderId]
		WHERE so.CatCheckpointTypeId <> 3
			AND so.RowStatus = 1
			AND do.Ticket_Number = @ReferenceNumber
			AND do.SenderCountryId = @IdCountry
		ORDER BY do.DateCreated DESC

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END