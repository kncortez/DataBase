USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_get_article_by_typearticle_from_catarticle]    Script Date: 9/07/2021 17:10:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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
AND ArtShowDefault = @FlagShowDefaultArticle;

END
GO


