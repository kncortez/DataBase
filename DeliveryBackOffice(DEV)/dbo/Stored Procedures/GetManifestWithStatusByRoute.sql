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
	DECLARE @Date DATE = '2024-10-18'; -- Fecha de deploy a producción
	
	BEGIN TRY
	
		SELECT dobs.ID As Manifest
			,CASE WHEN msi.isCOD = 0 AND msi.CatManifestSettlementIncidenceTypeId IS NOT NULL AND msi.CatManifestSettlementIncidenceTypeId > 0 THEN 'Liquidado con incidencia'
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
			AND CAST(dobs.Date_Dispatched AS DATE) = CAST(GETDATE() AS DATE)
		UNION
		SELECT dobs.ID As Manifest,	'Pendiente' AS Status
		FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement  dobs  WITH(NOLOCK) 
			INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK) 
				ON dobs.CatRouteId = cr.IdRoute
		WHERE dobs.CatRouteId = @IdRoute
			AND dobs.Date_Received IS NULL
			AND dobs.User_Received IS NULL
			AND ISNULL(cr.CountryId, 'GT') = @IdCountry
			AND CAST(dobs.Date_Dispatched AS DATE) < CAST(GETDATE() AS DATE)
			AND CAST(dobs.Date_Dispatched AS DATE) > @Date
		ORDER BY 1 DESC

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END;
