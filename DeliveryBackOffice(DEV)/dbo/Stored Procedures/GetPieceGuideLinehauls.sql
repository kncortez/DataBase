-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-5>
-- Description:	<obtener piezas de guía para generar, Actas de justificación piezas faltantes rutas Linehauls>
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-06-05>
-- Description:	<Se agrega parametro para filtrar guias por pais de origen>
-- =============================================
CREATE PROCEDURE [dbo].[GetPieceGuideLinehauls]

@Guide AS NVARCHAR(20),
@IdCountry AS NVARCHAR (2) = 'GT'
	
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @Serie NVARCHAR(10),
			@Number NVARCHAR(10),
			@GuideNumber INT
    
    SET @Serie = LEFT(@Guide, 2)

    SET @Number = RIGHT(@Guide, LEN(@Guide) - 2)
	--valida que el que number sera numererico
	SET @GuideNumber = IIF(ISNUMERIC(@Number) = 1 AND @Number NOT LIKE '%[^0-9]%',CAST(@Number AS INT),0)

	SELECT
	     B.GuideSerie + CAST(B.GuideNumber AS VARCHAR)  +'-'+ CAST(B.NoPiece AS VARCHAR) AS Guide 
	FROM [dbo].[DeliveryOrder] O WITH(NOLOCK)
	INNER JOIN 
		  [dbo].[DeliveryOrderPiece] B WITH (NOLOCK)
	ON O.Guide_Serie = B.GuideSerie AND O.Guide_Number = B.GuideNumber
	INNER JOIN
	      [dbo].StatusOrder C WITH (NOLOCK)
	ON  B.StatusOrderId =C.StatusOrderId
    WHERE B.GuideSerie  + CAST(B.GuideNumber AS varchar) = RTRIM(LTRIM(@Guide)) AND 
		  C.OrderDescription NOT IN('Entregado','Anulado','Entregado En Express Center')
		  AND IIF(O.SenderCountryId IS NULL, 'GT', O.SenderCountryId)=@IdCountry
	ORDER BY B.NoPiece

END