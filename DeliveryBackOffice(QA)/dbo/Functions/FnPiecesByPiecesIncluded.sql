-- =============================================
-- Author:		<Sazo,César>
-- Create date: <27/01/2022>
-- Description:	<Devuelve la cantidad de piezas que se deben cobrar según la configuración del atributo PiecesIncluded>
-- =============================================

CREATE FUNCTION FnPiecesByPiecesIncluded(
	@PIECES DECIMAL(12,2)
	,@PIECES_INCLUDED DECIMAL(12,2)
)
RETURNS DECIMAL(12,2) AS
BEGIN
	DECLARE @return_value DECIMAL(12,2);
	
	IF	(@PIECES>@PIECES_INCLUDED)
		BEGIN			
			SET @return_value = CEILING(@PIECES/@PIECES_INCLUDED)
		END
	ELSE
		BEGIN
			SET @return_value = 1
		END

    RETURN @return_value
END;