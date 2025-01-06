-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2025-01-06>
-- Description:	<Retorna la ruta y el hub desde un poblado dado>
-- =============================================
CREATE PROCEDURE [dbo].[spws_GetRouteHubBySettlement]
	@IdSettlement AS INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		cr.CodeRoute, 
		cr.IdRoute, 
		hub.IdHubLogistic, 
		hub.HubAbbreviation
	FROM dbo.DumpServiceCoverage dsc  WITH (NOLOCK)
		INNER JOIN dbo.Settlement setl    WITH (NOLOCK)
			ON setl.IdSettlement=dsc.IdSettlement 
		INNER JOIN dbo.CatRoute cr WITH (NOLOCK)
			ON dsc.RouteCode = cr.CodeRoute
		INNER JOIN DeliveryBackOffice.dbo.HubLogistics hub WITH(NOLOCK)  
			ON RTRIM(LTRIM(hub.HubAbbreviation)) = RTRIM(LTRIM(dsc.Hub))
	WHERE dsc.RowStatus=1
		AND setl.SettlementSatus = 1
		AND hub.HubStatus = 1
		AND cr.RowStatus = 1
		AND setl.IdSettlement = @IdSettlement;
END;