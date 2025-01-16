CREATE FUNCTION dbo.SplitStrings
(
    @List       NVARCHAR(MAX),
    @Delimiter  NVARCHAR(255)
)
RETURNS TABLE
AS
    RETURN (SELECT y.b FROM (select 1 b) AS y);
