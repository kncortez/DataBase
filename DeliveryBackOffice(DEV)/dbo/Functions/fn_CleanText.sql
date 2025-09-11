
CREATE FUNCTION dbo.fn_CleanText(@Texto NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    -- Solo caracteres permitidos
    DECLARE @Resultado NVARCHAR(MAX) = @Texto;

    -- Quitar caracteres no deseados
    SET @Resultado = REPLACE(@Resultado, '/', '');
    SET @Resultado = REPLACE(@Resultado, '"', '');
    SET @Resultado = REPLACE(@Resultado, '\', '');
    SET @Resultado = REPLACE(@Resultado, '''', '');
	SET @Resultado = REPLACE(@Resultado, ',', '');
    SET @Resultado = REPLACE(@Resultado, CHAR(9), ''); -- Tab
    SET @Resultado = REPLACE(@Resultado, CHAR(10), ''); -- Salto de línea
    SET @Resultado = REPLACE(@Resultado, CHAR(13), ''); -- Carriage return

    RETURN @Resultado;

    RETURN @Resultado;
END