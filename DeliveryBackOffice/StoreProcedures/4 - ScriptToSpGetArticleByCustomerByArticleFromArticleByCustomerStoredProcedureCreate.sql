USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_get_articlebycustomer_by_article_from_articlebycustomer]    Script Date: 9/07/2021 18:30:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_articlebycustomer_by_article_from_articlebycustomer]
	@IdArticle INT
AS
BEGIN

--DECLARE @IdArticle INT = 8;
DECLARE @FlagEnabledABC INT = 1;
DECLARE @FlagEnabledArticle INT = 1;
DECLARE @FlagEnabledTypeArticle INT = 1;
DECLARE @FlagShowDefault INT = 1;

SELECT 
	   ac.AbcId 'id', CONCAT(ac.Code,'  -  ', ta.TarName,' - ', ca.ArtName) 'name',
	   ac.Height 'height', ac.Width 'width', ac.Length 'length',
	   ac.MassWeight 'massWeight', ac.VolumetricWeight 'volumetricWeight',
	   IIF(ac.ShowDefault = 'True', 'Si', 'No') 'showDefaultText',
	   ac.PriceDefault 'priceDefault', ac.Code 'code',
	   IIF(ac.ShowDefault = 'True', ac.ShowDefault, 'False') 'showDefault'
FROM dbo.ArticleByCustomer ac
LEFT JOIN DBO.CatArticle ca 
	ON ca.ArtId = ac.AbcIdArticle
	AND ca.ArtRowStatus = @FlagEnabledArticle
LEFT JOIN dbo.CatTypeArticle ta 
	ON ta.TarId = ca.ArtIdTypeArticle
	AND ta.TarRowStatus = @FlagEnabledTypeArticle
WHERE AbcRowStatus = @FlagEnabledABC
--AND ShowDefault = @FlagShowDefault
AND AbcIdArticle = @IdArticle;

END

GO


