
-- =============================================
-- Author:		<César, Aquino>
-- Create date: <2021-07-03>
-- Description:	<Devuelve un listado de articulos>
--				0 Default para catalogo articulos; 1 para carga standar de catalogo articulos 
-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2024-06-03>
-- Description:	<Se agrega parametro para filtrar por pais. Por defecto GT>
-- =============================================
 CREATE PROCEDURE [dbo].[sphd_get_ArticleList]
	@option AS INT = 0,
	@IdCountry AS NVARCHAR(2)='GT'
AS
BEGIN
IF (@option = 0)
BEGIN
	SELECT ac.AbcId Id
		, CONCAT( ac.Code,'  -  ', ta.TarName,'-', ca.ArtName) Name
	FROM dbo.ArticleByCustomer ac
		LEFT JOIN DBO.CatArticle ca ON ca.ArtId = ac.AbcIdArticle
		LEFT JOIN dbo.CatTypeArticle ta ON ta.TarId =ca.ArtIdTypeArticle
	WHERE ac.AbcRowStatus ='TRUE'
	AND IIF(ca.IdCountry IS NULL, 'GT',ca.IdCountry) = @IdCountry
END 

IF (@option = 1)
BEGIN
	
	SELECT ac.AbcId IdValue
		, CONCAT( ac.Code,'  -  ', ta.TarName,'-', ca.ArtName) NameValue
	FROM dbo.ArticleByCustomer ac
		LEFT JOIN DBO.CatArticle ca ON ca.ArtId = ac.AbcIdArticle
		LEFT JOIN dbo.CatTypeArticle ta ON ta.TarId =ca.ArtIdTypeArticle
				AND ta.TarRowStatus = 'TRUE'
				AND ca.ArtRowStatus = 'TRUE'
	WHERE ac.AbcRowStatus ='TRUE'
	AND IIF(ca.IdCountry IS NULL, 'GT',ca.IdCountry) = @IdCountry
END

END