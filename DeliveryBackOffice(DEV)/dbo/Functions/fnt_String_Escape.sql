/*
  Name: fnt_String_Escape   
Author: Marco Jiménez
  Date: 2021-03-17
*/

CREATE FUNCTION [dbo].[fnt_String_Escape](@StringToEscape nvarchar(max), @Encoding nvarchar(10))
RETURNS nvarchar(max)
BEGIN

	DECLARE @s NVARCHAR(MAX) = @StringToEscape;

    -- Declarar la tabla de variables para almacenar los caracteres y sus reemplazos
    DECLARE @StringEncoding TABLE
    (
        StringToReplace NCHAR(1),
        StringReplacement NVARCHAR(10)
    );

    -- Insertar los datos relevantes en la tabla de variables
    INSERT INTO @StringEncoding (StringToReplace, StringReplacement)
    SELECT StringToReplace, StringReplacement
    FROM dbo.tb_StringEncoding
    WHERE EncodingType = @Encoding;

    -- Aplicar los reemplazos de manera encadenada
    SELECT @s = REPLACE(@s, StringToReplace, StringReplacement)
    FROM @StringEncoding
    ORDER BY LEN(StringToReplace) DESC; -- Asegurar que el reemplazo se haga en el orden correcto

    RETURN @s;

END
