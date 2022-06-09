
CREATE PROCEDURE [dbo].[sp_get_typearticle_by_package_from_cattypearticle]
	@IdPackage INT
AS
BEGIN

--DECLARE @IdPackage INT = 1;
DECLARE @FlagEnabledTypeArticle INT = 1;

SELECT TarId, TarName
FROM dbo.CatTypeArticle
WHERE TarRowStatus = @FlagEnabledTypeArticle
AND TarIdPackage = @IdPackage;

END
