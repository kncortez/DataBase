-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <13-09-2022>
-- Description:	<Get TOP 20 guides in LinehaulRouteSettlementContainerDetail>
-- =============================================
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <23-01-2025>
-- Description:	<Obtiene el ticket number asociado a una guía.>
-- Create date: <09-05-2025>
-- Description:	<Traslado de atributos del inner al where en la consulta.>
-- =============================================
-- =============================================
-- Author:		<Cristian, Suazo>
-- Create date: <05-10-2025>
-- Description:	<Se corrige el calculo de PiecesMissing para Linehaul>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetTopGuidesLinehaulRouteSettlement]
	@LinehaulRouteSettlementId AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DOP_PIECES INT,
			@GuideSerie NVARCHAR(3),
			@GuideNumber INT

	SELECT TOP 1
		@GuideSerie = LRSCD.GuideSerie,
		@GuideNumber = LRSCD.GuideNumber
	FROM dbo.LinehaulRouteSettlementContainerDetail LRSCD WITH (NOLOCK)
	INNER JOIN dbo.LinehaulRouteSettlementContainer LRSC WITH (NOLOCK)
		ON LRSCD.LinehaulRouteSettlementContainerId = LRSC.IdLinehaulRouteSettlementContainer
	WHERE LRSC.LinehaulRouteSettlementId = @LinehaulRouteSettlementId;

	SELECT TOP 20
		LRSCD.GuideSerie,
		LRSCD.GuideNumber,
		ISNULL(DO.Ticket_Number,'') AS TicketNumber,
		LRSCD.PiecesReceived,
		ISNULL(pc.TotalPieces, 0) - ISNULL(LRSCD.PiecesReceived, 0) AS PiecesMissing,  
		CTC.TypeContainerSerie,
		C.ContainerNumber
	FROM dbo.LinehaulRouteSettlementContainerDetail LRSCD WITH (NOLOCK)
	INNER JOIN dbo.LinehaulRouteSettlementContainer LRSC WITH (NOLOCK)
		ON LRSCD.LinehaulRouteSettlementContainerId = LRSC.IdLinehaulRouteSettlementContainer
	INNER JOIN dbo.Container C WITH (NOLOCK)
		ON LRSC.ContainerId = C.IdContainer
	INNER JOIN dbo.CatTypeContainer CTC WITH (NOLOCK)
		ON C.CatTypeContainerId = CTC.IdCatTypeContainer
	LEFT JOIN dbo.DeliveryOrder DO WITH (NOLOCK)
		ON LRSCD.GuideSerie = DO.Guide_Serie
	   AND LRSCD.GuideNumber = DO.Guide_Number
	OUTER APPLY (
		SELECT COUNT(1) AS TotalPieces
		FROM dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
		WHERE DOP.GuideSerie = LRSCD.GuideSerie
		  AND DOP.GuideNumber = LRSCD.GuideNumber
	) pc
	WHERE LRSCD.RowStatus = 1
	  AND LRSC.LinehaulRouteSettlementId = @LinehaulRouteSettlementId
	  AND LRSCD.IsOpenProcess = 0
	ORDER BY LRSCD.DateCreated DESC;
    
END