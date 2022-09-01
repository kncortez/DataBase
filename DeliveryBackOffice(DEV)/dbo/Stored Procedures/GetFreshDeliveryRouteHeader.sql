
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <01/09/2022>
-- Description:	< Obtener guías ingresadas por Fresh Delivery ordenadas por ruta >
-- =============================================
CREATE PROCEDURE [dbo].[GetFreshDeliveryRouteHeader]
	@FilterDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@FilterDate = NULL)
		SET @FilterDate = GETDATE()

	SELECT
		ISNULL(COUNT(DISTINCT DOR.GuideNumber),0) 'Guides',
		ISNULL(COUNT(DISTINCT DOR.[Route]),0) 'Route',
		ISNULL(SUM(DO.Pieces_Dry + DO.Pieces_Cold), 0) 'TotalPieces'
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrderRoute] DOR WITH(NOLOCK)
		INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			ON
				DOR.GuideSerie = DO.Guide_Serie
				AND
				DOR.GuideNumber = DO.Guide_Number
	WHERE
		DOR.RowStatus = 1
		AND
		CAST(DOR.DateCreated  AS DATE) = CAST(@FilterDate AS DATE)

END