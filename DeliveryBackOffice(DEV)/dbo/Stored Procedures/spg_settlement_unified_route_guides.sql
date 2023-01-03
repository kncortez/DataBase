-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-10-14>
-- Description:	<Obtiene información de las guías de la liquidación de rutas unificadas>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_unified_route_guides] 
	-- Add the parameters for the stored procedure here
	@ManifestId VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @UnifiedRouteSettlementId TABLE(
		Id INT
	)

	INSERT INTO @UnifiedRouteSettlementId
		SELECT
			su.Item
		FROM dbo.SplitUnlimited(@ManifestId, ',') su

	SELECT
		CONCAT(ursd.GuideSerie, ursd.GuideNumber) Guide
	   ,ursd.PiecesSettled Pieces
	   ,(CASE
			WHEN EXISTS (SELECT
						1
					FROM ServiceManagement sm WITH (NOLOCK)
					WHERE sm.IdServiceManagement = ursd.ServiceManagementId
					AND sm.IdSchedulePickup IS NOT NULL) THEN 'Recolección'
			WHEN EXISTS (SELECT
						1
					FROM ServiceManagement sm WITH (NOLOCK)
					INNER JOIN ServiceManagementDetail smd WITH (NOLOCK)
						ON sm.IdServiceManagement = smd.ServiceManagement
					WHERE sm.IdServiceManagement = ursd.ServiceManagementId) THEN CASE
					WHEN EXISTS (SELECT
								1
							FROM DeliveryOrder do WITH (NOLOCK)
							WHERE do.Guide_Serie = ursd.GuideSerie
							AND do.Guide_Number = ursd.GuideNumber
							AND (do.IsLastMileReturn IS NULL
							OR do.IsLastMileReturn = 0)) THEN 'Entrega'
					ELSE 'Devolución'
				END
			ELSE 'N/A'
		END) [Type]
	   ,ursd.ServiceSettlementAmount + ursd.ServiceCODSettlementAmount Amount
	FROM UnifiedRouteSettlement urs WITH (NOLOCK)
	INNER JOIN UnifiedRouteSettlementDetail ursd WITH (NOLOCK)
		ON urs.IdUnifiedRouteSettlement = ursd.UnifiedRouteSettlementId
			AND ursd.RowStatus = 1
			AND ursd.IsLost = 0
	WHERE urs.RowStatus = 1
	AND urs.UserSettlement IS NOT NULL
	AND urs.IdUnifiedRouteSettlement IN (SELECT
			Id
		FROM @UnifiedRouteSettlementId)
END