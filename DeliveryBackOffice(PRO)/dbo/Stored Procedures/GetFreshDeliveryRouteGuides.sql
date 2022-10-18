
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <01/09/2022>
-- Description:	< Obtener guías ingresadas por Fresh Delivery ordenadas por ruta >
-- =============================================
CREATE PROCEDURE [dbo].[GetFreshDeliveryRouteGuides]
	@FilterDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@FilterDate = NULL)
		SET @FilterDate = GETDATE()

	SELECT
		DOR.Route 'GuideRoute',
		CONCAT(DOP.GuideSerie, DOP.GuideNumber, '-', ISNULL(DOP.NoPiece,1)) 'Guide',
		DO.Receiver_Address 'GuideAddress',
		CONCAT(DO.Receiver_Town,', ', DO.Receiver_Department) 'GuideArea'
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrderRoute] DOR WITH(NOLOCK)
		INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			ON
				DOR.GuideSerie = DO.Guide_Serie
				AND
				DOR.GuideNumber = DO.Guide_Number
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
			ON
				DOR.GuideSerie = DOP.GuideSerie
				AND
				DOR.GuideNumber = DOP.GuideNumber
	WHERE
		DOR.RowStatus = 1
		AND
		CAST(DOR.DateCreated  AS DATE) = CAST(@FilterDate AS DATE)
	ORDER BY
		DOR.[Route] ASC,
		DO.Guide_Number DESC,
		DOP.NoPiece ASC

END