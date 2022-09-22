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
	     B.GuideSerie + CAST(B.GuideNumber AS VARCHAR)  +'-'+ CAST(B.NoPiece AS VARCHAR) AS Guide 
	FROM [dbo].[DeliveryOrderPiece] B WITH (NOLOCK)
	INNER JOIN
	      [dbo].StatusOrder C WITH (NOLOCK)
	ON  B.StatusOrderId =C.StatusOrderId
    WHERE B.GuideSerie  + CAST(B.GuideNumber AS varchar) = RTRIM(LTRIM(@Guide)) AND 
		  C.OrderDescription NOT IN('Entregado','Anulado','Entregado En Express Center')
	ORDER BY B.NoPiece

END