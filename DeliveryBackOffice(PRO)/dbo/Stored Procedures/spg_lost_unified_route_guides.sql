-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-10-17>
-- Description:	<Obtiene información de las guías de los paquetes perdidos de rutas unificadas>
-- =============================================
CREATE PROCEDURE [dbo].[spg_lost_unified_route_guides] 
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
					WHEN do.IsLastMileReturn IS NULL
							OR do.IsLastMileReturn = 0 THEN 'Entrega'
					ELSE 'Devolución'
				END
			ELSE 'N/A'
		END) [Type]
	   ,CASE
			WHEN do.IsInsuarance = 1 THEN ursd.ServiceSettlementAmount + ISNULL(do.InsuranceAmount, 0)
			ELSE ursd.ServiceSettlementAmount + ursd.ServiceCODSettlementAmount
		END Amount
	FROM UnifiedRouteSettlement urs WITH (NOLOCK)
	INNER JOIN UnifiedRouteSettlementDetail ursd WITH (NOLOCK)
		ON urs.IdUnifiedRouteSettlement = ursd.UnifiedRouteSettlementId
			AND ursd.RowStatus = 1
			AND ursd.IsLost = 1
	INNER JOIN DeliveryOrder do WITH (NOLOCK)
		ON ursd.GuideSerie = do.Guide_Serie
			AND ursd.GuideNumber = do.Guide_Number
	WHERE urs.RowStatus = 1
	AND urs.UserSettlement IS NOT NULL
	AND urs.IdUnifiedRouteSettlement IN (SELECT
			Id
		FROM @UnifiedRouteSettlementId)
END