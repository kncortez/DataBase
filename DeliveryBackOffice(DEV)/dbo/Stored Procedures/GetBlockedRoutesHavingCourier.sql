-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-09-26>
-- Description: <obtiene las rutas que estan bloqueadas por incidencias en donde esta asignado el courier>
-- =============================================
CREATE PROCEDURE [dbo].[GetBlockedRoutesHavingCourier]
    @CUI NVARCHAR(25),
	@IdCountry NVARCHAR(2) = 'GT'

AS
BEGIN	
	SET NOCOUNT ON;
	DECLARE @Date DATETIME = '2024-09-25 00:00:00.000';
	BEGIN TRY

		SELECT DISTINCT cr.CodeRoute AS RouteWithIncidence
		FROM [DeliveryBackOffice].[dbo].[SenderReceiver] sr WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement  dobs  WITH(NOLOCK)
				ON sr.ID = dobs.ID_Courier
			INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK) 
				ON dobs.CatRouteId = cr.IdRoute
			INNER JOIN DeliveryBackOffice.dbo.ManifestSettlementIncidence msi WITH(NOLOCK)
				ON dobs.ID = msi.ManifestNumber
		WHERE msi.IncidenceApproved = 0
			AND dobs.Date_Dispatched > @Date
			AND sr.CUI = @CUI
			AND IIF(sr.IdCountry IS NULL, 'GT', sr.IdCountry) = @IdCountry

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
	
	SET NOCOUNT OFF;
END;
