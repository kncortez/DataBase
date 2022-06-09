
CREATE PROCEDURE [dbo].[sp_get_article_by_typearticle_from_catarticle]
	@IdTypeArticle INT
AS
BEGIN

--DECLARE @IdTypeArticle INT = 8;
DECLARE @FlagEnabledArticle INT = 1;
DECLARE @FlagShowDefaultArticle INT = 1;

SELECT ArtId, ArtName
FROM dbo.CatArticle
WHERE ArtRowStatus = @FlagEnabledArticle
AND ArtIdTypeArticle = @IdTypeArticle
--AND ArtShowDefault = @FlagShowDefaultArticle;

END
