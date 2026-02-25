/* =================================================
   SP:        [dbo].[GetManifestByRoute]
   Propósito: <Obtiene los manifiestos por ruta>
   Autor:     Erick Hernandez
   Historia:  <FDAPI-5599>
   Fecha:     <2026-02-19>
   === CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[GetManifestByRoute]
    @IdRoute INT,
	@IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Date DATE = '2024-10-18'; -- Fecha de deploy a producción????

	BEGIN TRY
		SELECT 
			DOBS.ID As Manifest,
			CASE 
				--WHEN MSI.isCOD = 0 AND MSI.CatManifestSettlementIncidenceTypeId IS NOT NULL AND MSI.CatManifestSettlementIncidenceTypeId > 0 THEN 'Liquidado con incidencia'
				WHEN MSI.isCOD = 0 AND MSI.CatManifestSettlementIncidenceTypeId > 0 THEN 'Liquidado con incidencia'
				WHEN DOBS.User_received IS NOT NULL AND DOBS.Date_Received IS NOT NULL THEN 'Liquidado'
				ELSE 'Pendiente'
			END AS Status
		FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOBS WITH(NOLOCK) 
		INNER JOIN DeliveryBackOffice.dbo.CatRoute CR WITH(NOLOCK) 
			ON DOBS.CatRouteId = CR.IdRoute
		LEFT JOIN DeliveryBackOffice.dbo.ManifestSettlementIncidence MSI WITH(NOLOCK)
			ON DOBS.ID = MSI.ManifestNumber
		WHERE DOBS.CatRouteId = @IdRoute
		AND ISNULL(CR.CountryId, 'GT') = @IdCountry
		AND DOBS.Date_Dispatched = CAST(GETDATE() AS DATE)
		UNION
		SELECT DOBS.ID As Manifest,	'Pendiente' AS Status
		FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOBS WITH(NOLOCK) 
		INNER JOIN DeliveryBackOffice.dbo.CatRoute CR WITH(NOLOCK) 
			ON DOBS.CatRouteId = CR.IdRoute
		WHERE DOBS.CatRouteId = @IdRoute
		AND DOBS.Date_Received IS NULL
		AND DOBS.User_Received IS NULL
		AND ISNULL(CR.CountryId, 'GT') = @IdCountry
		AND DOBS.Date_Dispatched > @Date
		AND DOBS.Date_Dispatched < CAST(GETDATE() AS DATE)
		UNION
		SELECT
			DSD.ID_DeliveryOrderBySettlement [id],
			CASE
				WHEN MSI.CatManifestSettlementIncidenceTypeId IS NOT NULL AND MSI.CatManifestSettlementIncidenceTypeId > 0 AND MSI.isCOD = 1 THEN 'Liquidado con Incidencia'
				WHEN DOBS.User_Received_COD IS NOT NULL AND DOBS.Date_Received_COD IS NOT NULL THEN 'Liquidado'
				ELSE 'Pendiente'
			END AS [StatusDesCRiption]
		FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOBS WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail DSD WITH (NOLOCK)
			ON DSD.ID_DeliveryOrderBySettlement = DOBS.ID
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
			ON DOR.Guide_Number = DSD.Guide_Number AND DOR.Guide_Serie = DSD.Guide_Serie
		LEFT JOIN DeliveryBackOffice.dbo.ManifestSettlementIncidence MSI WITH (NOLOCK)
			ON DOBS.ID = MSI.ManifestNumber
		LEFT JOIN DeliveryBackOffice.dbo.CatStation CS
			ON CS.IdStation = DOBS.DispatchedStationId
		WHERE DOBS.Date_Dispatched = CAST(GETDATE() AS DATE)
		AND DSD.RowStatus = 1
		AND DOBS.CatRouteId = @IdRoute
		AND DSD.Guide_Settlement = 1
		AND DSD.Guide_Delivered = 1
		AND (DOR.IsLastMileReturn = 0 OR (DOR.IsLastMileReturn = 1 AND DOR.IsCollect = 1));
    END TRY 
	BEGIN CATCH
        SELECT 0 AS 'ID', ERROR_MESSAGE() AS 'Status' 
	END CATCH
END;
