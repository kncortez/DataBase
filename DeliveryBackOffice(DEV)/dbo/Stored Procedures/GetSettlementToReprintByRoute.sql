-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-10-22>
-- Description: <Obtenemos los manifiestos que se han despachado por ruta para la reimpresión de documentos en el modulo de despacho REF. FDD-1380>
-- =============================================
CREATE PROCEDURE [dbo].[GetSettlementToReprintByRoute]
    @IdRoute INT,
	@IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN	
	SET NOCOUNT ON;
	
	BEGIN TRY

		SELECT dobs.ID As Manifest
		FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement  dobs  WITH(NOLOCK) 
			INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK) 
				ON dobs.CatRouteId = cr.IdRoute
		WHERE dobs.CatRouteId = @IdRoute
			AND ISNULL(cr.CountryId, 'GT') = @IdCountry
			AND CAST(dobs.Date_Dispatched AS DATE) = CAST(GETDATE() AS DATE)
		ORDER BY dobs.ID DESC		

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END;