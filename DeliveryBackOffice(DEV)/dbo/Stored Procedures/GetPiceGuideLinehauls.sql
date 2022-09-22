-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-5>
-- Description:	<obtener piezas de guía para generar, Actas de justificación piezas faltantes rutas Linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[GetPiceGuideLinehauls]

@Guide AS NVARCHAR(20)
	
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT
	     B.GuideSerie + CAST(B.GuideNumber AS VARCHAR)  +'-'+ CAST(C.PieceNumber AS VARCHAR) AS Guide 
	FROM 
		[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer]            A WITH (NOLOCK) 
			INNER JOIN 
		[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainerDetail]      B WITH (NOLOCK)
				ON  A.IdLinehaulRoutePreparationContainer = B.LinehaulRoutePreparationContainerId
			INNER JOIN
		[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainerDetailPiece] C WITH (NOLOCK)
				ON	B.IdLinehaulRoutePreparationContainerDetail = C.LinehaulRoutePreparationContainerDetailId
    WHERE B.GuideSerie  + CAST(B.GuideNumber AS varchar) = @Guide
	ORDER BY C.PieceNumber

END