CREATE PROCEDURE [dbo].[sp_get_articlebycustomer_by_article_from_articlebycustomer]
	@IdArticle INT,
	@IdCountry AS NVARCHAR(2)='GT'
AS
BEGIN

--DECLARE @IdArticle INT = 8;
DECLARE @FlagEnabledABC INT = 1;
DECLARE @FlagEnabledArticle INT = 1;
DECLARE @FlagEnabledTypeArticle INT = 1;
DECLARE @FlagShowDefault INT = 1;

SELECT 
	   ac.AbcId 'id', CONCAT(ac.Code,'  -  ', ta.TarName,' - ', ca.ArtName) 'name',
	   ISNULL(ac.Height, 0) 'height', ISNULL(ac.Width, 0) 'width', ISNULL(ac.Length, 0) 'length',
	   ISNULL(ac.MassWeight, 0) 'massWeight', ISNULL(ac.VolumetricWeight, 0) 'volumetricWeight',
	   IIF(ac.ShowDefault = 'True', 'Si', 'No') 'showDefaultText',
	   ISNULL(ac.PriceDefault, 0) 'priceDefault', ac.Code 'code',
	   IIF(ac.ShowDefault = 'True', ac.ShowDefault, 'False') 'showDefault',
	   ISNULL(ac.IdCurrency,1) 'IdCurrency'
FROM dbo.ArticleByCustomer ac
LEFT JOIN DBO.CatArticle ca 
	ON ca.ArtId = ac.AbcIdArticle
	AND ca.ArtRowStatus = @FlagEnabledArticle
LEFT JOIN dbo.CatTypeArticle ta 
	ON ta.TarId = ca.ArtIdTypeArticle
	AND ta.TarRowStatus = @FlagEnabledTypeArticle
WHERE AbcRowStatus = @FlagEnabledABC
--AND ShowDefault = @FlagShowDefault
AND AbcIdArticle = @IdArticle
AND IIF(ca.IdCountry IS NULL, 'GT',ca.IdCountry)=@IdCountry;

END

