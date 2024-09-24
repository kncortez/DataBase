-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-09-13>
-- Description: <Se obtienen los manifiestos relacionados a una ruta con su respectivo estado>
-- =============================================
CREATE PROCEDURE [dbo].[GetManifestWithStatusByRoute]
    @IdRoute INT,
	@IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN	
	SET NOCOUNT ON;
	
	BEGIN TRY
	
		SELECT dobs.ID As Manifest
			,CASE WHEN msi.CatManifestSettlementIncidenceTypeId IS NOT NULL AND msi.CatManifestSettlementIncidenceTypeId > 0 THEN 'Liquidado con incidencia'
				 WHEN dobs.User_received IS NOT NULL AND dobs.Date_Received IS NOT NULL THEN 'Liquidado'
				 ELSE 'Pendiente'
			END AS Status
		FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement  dobs  WITH(NOLOCK) 
			INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK) 
				ON dobs.CatRouteId = cr.IdRoute
			LEFT JOIN DeliveryBackOffice.dbo.ManifestSettlementIncidence msi WITH(NOLOCK)
				ON dobs.ID = msi.ManifestNumber
		WHERE dobs.CatRouteId = @IdRoute
			AND ISNULL(cr.CountryId, 'GT') = @IdCountry
		ORDER BY dobs.ID DESC

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH

    SET NOCOUNT OFF;
END;