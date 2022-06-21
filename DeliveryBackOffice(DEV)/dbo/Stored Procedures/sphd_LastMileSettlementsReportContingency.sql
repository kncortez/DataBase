
-- =============================================
-- Author:      <Oscar,Morales>
-- Create date: <2021-12-15>
-- Description: <Obtener informacion de contingencias para el Reporte Liquidaciones Última Milla>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_LastMileSettlementsReportContingency] 
	@fromDate AS DATE,
	@toDate AS DATE,
	@hubsIds AS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @Faltante DECIMAL(10,2);
	DECLARE @Sobrante DECIMAL(10,2);

	SELECT
	   @Faltante =SUM(CASE WHEN cn.TYPE = 'FALTANTE' THEN cn.Value ELSE 0 END)
	   ,@Sobrante = SUM(CASE WHEN cn.TYPE = 'SOBRANTE' THEN cn.Value ELSE 0 END)
	FROM dbo.DeliveryOrderBySettlement dst
	JOIN dbo.Contingency cn
		ON dst.ID = cn.DeliveryOrderBySettlementId
	WHERE CONVERT(DATE, dst.Date_Received)
	BETWEEN @fromDate AND @toDate
	AND dst.SettlementStationId IN (SELECT
			Name
		FROM splitstring(@hubsIds, ','))
	AND EXISTS(
		SELECT 1
		FROM DeliverySettlementDetail dsd
		JOIN dbo.DeliveryOrder ord
			ON ord.Guide_Serie = dsd.Guide_Serie
				AND ord.Guide_Number = dsd.Guide_Number
        WHERE dsd.ID_DeliveryOrderBySettlement = dst.ID
		AND IIF(ord.IsCollect = 1, ord.PriceShippment, 0) + ord.Collect_OnDelivery > 0
        AND dsd.Guide_Delivered = 'true'
        AND dsd.Guide_Discharged IS NOT NULL
	)
	
	IF @Faltante > 0 OR @Sobrante > 0
	BEGIN
		SELECT
			dst.id Manifiesto
		   ,cn.Type
		   ,cn.Value
		   ,cn.Description
		   ,@Faltante Faltante
		   ,@Sobrante Sobrante
		FROM dbo.DeliveryOrderBySettlement dst
		JOIN dbo.Contingency cn
			ON dst.ID = cn.DeliveryOrderBySettlementId
		WHERE CONVERT(DATE, dst.Date_Received)
		BETWEEN @fromDate AND @toDate
		AND dst.SettlementStationId IN (SELECT
				Name
			FROM splitstring(@hubsIds, ','))
		AND EXISTS(
			SELECT 1
			FROM DeliverySettlementDetail dsd
			JOIN dbo.DeliveryOrder ord
				ON ord.Guide_Serie = dsd.Guide_Serie
					AND ord.Guide_Number = dsd.Guide_Number
			WHERE dsd.ID_DeliveryOrderBySettlement = dst.ID
			AND IIF(ord.IsCollect = 1, ord.PriceShippment, 0) + ord.Collect_OnDelivery > 0
			AND dsd.Guide_Delivered = 'true'
			AND dsd.Guide_Discharged IS NOT NULL
		)
		ORDER BY dst.ID
	END
	ELSE
	BEGIN
		SELECT
			'' Manifiesto
			,'' Type
			,'' Value
			,'No se encontraron contingencias.' Description
			,0 Faltante
			,0 Sobrante
	END
	
END