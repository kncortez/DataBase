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
	DECLARE @Date DATE = '2024-10-18';
	BEGIN TRY

		-- TABLA 0 Ruta con manifiestos sin liquidar

		SELECT COUNT(*) AS NumberOfManifestWithoutSettlement
		FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement  dobs  WITH(NOLOCK) 
			INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK) 
				ON dobs.CatRouteId = cr.IdRoute
		WHERE dobs.User_received IS NULL
			AND dobs.Date_Received IS NULL
			AND CAST(dobs.Date_Dispatched AS DATE) < CAST(GETDATE() AS DATE)
			AND CAST(dobs.Date_Dispatched AS DATE) > @Date
			AND dobs.CatRouteId = @IdRoute
			AND ISNULL(cr.CountryId, 'GT') = @IdCountry;
			
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
			AND ISNULL(cr.CountryId, 'GT') = @IdCountry;

		-- TABLA 2
		SELECT 1 AS 'StatusCode',
			'Registros obtenidos' AS 'Description';

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description'; 
	
	END CATCH
	
	SET NOCOUNT OFF;
END;