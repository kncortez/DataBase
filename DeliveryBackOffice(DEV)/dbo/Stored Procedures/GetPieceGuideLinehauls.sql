-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-5>
-- Description:	<obtener piezas de guía para generar, Actas de justificación piezas faltantes rutas Linehauls>
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-06-05>
-- Description:	<Se agrega parametro para filtrar guias por pais de origen>
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-06-27>
-- Description:	<Se valida si la guia consultada es internacion o domestica>
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
    WHERE B.GuideSerie = @Serie AND B.GuideNumber = @GuideNumber AND
		  C.OrderDescription NOT IN('Entregado','Anulado','Entregado En Express Center')
		  AND (ISNULL(O.GuideType,'DOM')='INT' OR (ISNULL(O.SenderCountryId,'GT')=@IdCountry AND ISNULL(O.GuideType,'DOM')='DOM'))
	ORDER BY B.NoPiece

	---TABLA RESPUESTA
	SELECT 'La guía que intentas procesar pertenece a otro pais. Por favor, revísala e intenta de nuevo.' AS [Description]
	FROM DeliveryOrder do WITH (NOLOCK)
	WHERE do.Guide_Number=@GuideNumber and do.Guide_Serie = @Serie
	AND 		
	ISNULL(do.SenderCountryId,'GT')<>@IdCountry AND ISNULL(do.GuideType,'DOM')='DOM'

END