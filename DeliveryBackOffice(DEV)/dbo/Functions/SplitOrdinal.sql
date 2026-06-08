CREATE FUNCTION dbo.SplitOrdinal
(
    @s          nvarchar(max),
    @delim      nchar(1),      -- p. ej. N'/'
    @maxTokens  int = 10
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
/* iTVF: Split por CTE recursivo con ordinal. Sin XML/JSON. Compat 120. */
WITH S(ordinal, startPos, nextPos) AS
(
    -- Fila base
    SELECT
        CAST(1 AS int) AS ordinal,
        CAST(1 AS int) AS startPos,
        CAST(CASE WHEN @s IS NULL
                  THEN 0
                  ELSE CHARINDEX(@delim, @s, 1)
             END AS int) AS nextPos
    WHERE @s IS NOT NULL

    UNION ALL

    -- Recursión
    SELECT
        CAST(ordinal + 1 AS int) AS ordinal,
        CAST(CASE WHEN nextPos = 0
                  THEN LEN(@s) + 1
                  ELSE nextPos + 1
             END AS int) AS startPos,
        CAST(CASE WHEN nextPos = 0
                  THEN 0
                  ELSE CHARINDEX(@delim, @s, nextPos + 1)
             END AS int) AS nextPos
    FROM S
    WHERE ordinal < @maxTokens
      AND nextPos  > 0
)
SELECT
    s.ordinal,
    value = LTRIM(RTRIM(
              SUBSTRING(
                  @s,
                  s.startPos,
                  (CASE WHEN s.nextPos = 0 THEN LEN(@s) + 1 ELSE s.nextPos END) - s.startPos
              )
          ))
FROM S AS s;
GO