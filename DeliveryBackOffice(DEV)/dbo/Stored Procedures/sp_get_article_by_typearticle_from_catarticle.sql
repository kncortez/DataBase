
CREATE PROCEDURE [dbo].[sp_get_article_by_typearticle_from_catarticle]
	@IdTypeArticle INT,
	@IdCountry AS NVARCHAR(2)= 'GT'
AS
BEGIN

--DECLARE @IdTypeArticle INT = 8;
DECLARE @FlagEnabledArticle INT = 1;
DECLARE @FlagShowDefaultArticle INT = 1;

SELECT ArtId, ArtName
FROM dbo.CatArticle
WHERE ArtRowStatus = @FlagEnabledArticle
AND ArtIdTypeArticle = @IdTypeArticle
AND IIF(IdCountry IS NULL,'GT',IdCountry)= @IdCountry
--AND ArtShowDefault = @FlagShowDefaultArticle;

END
