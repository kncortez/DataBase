-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-09-24>
-- Description: <Se obtienen por ruta los manifiestos con incidencias pendientes de validar>
-- =============================================
CREATE PROCEDURE [dbo].[GetManifestWithIncidenceByRoute]
    @IdRoute INT,
	@IdCountry NVARCHAR(2) = 'GT'

AS
BEGIN	
	SET NOCOUNT ON;
	DECLARE @Date DATETIME = '2024-09-25 00:00:00.000';
	BEGIN TRY

		-- TABLA 0 Ruta con manifiestos sin liquidar

		SELECT COUNT(*) AS NumberOfManifestWithoutSettlement
		FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement  dobs  WITH(NOLOCK) 
			INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK) 
				ON dobs.CatRouteId = cr.IdRoute
		WHERE dobs.User_received IS NOT NULL
			AND dobs.Date_Received IS NOT NULL
			AND dobs.Date_Dispatched > @Date
			AND dobs.CatRouteId = @IdRoute
			AND ISNULL(cr.CountryId, 'GT') = @IdCountry
			
		-- TABLA 1 Ruta con manifiestos pendientes de aprobar la incidencia

		SELECT DISTINCT ctp.NameIncidence AS RouteIncidenceName
		FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement  dobs  WITH(NOLOCK) 
			INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK) 
				ON dobs.CatRouteId = cr.IdRoute
			INNER JOIN DeliveryBackOffice.dbo.ManifestSettlementIncidence msi WITH(NOLOCK)
				ON dobs.ID = msi.ManifestNumber
			INNER JOIN DeliveryBackOffice.dbo.CatTypeIncidence ctp WITH(NOLOCK)
				ON msi.CatManifestSettlementIncidenceTypeId = ctp.IdIncidenceType
		WHERE msi.IncidenceApproved = 0  
			AND dobs.CatRouteId = @IdRoute
			AND ISNULL(cr.CountryId, 'GT') = @IdCountry

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
	
	SET NOCOUNT OFF;
END;
