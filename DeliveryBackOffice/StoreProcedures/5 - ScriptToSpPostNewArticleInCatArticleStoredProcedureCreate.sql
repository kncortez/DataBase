USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_post_new_article_in_catarticle]    Script Date: 9/07/2021 19:39:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_post_new_article_in_catarticle]
	@IdTypeArticle INT,
	@ArticleName VARCHAR(50),
	@Token VARCHAR(50)
AS
BEGIN

--DECLARE @IdTypeArticle INT = 8;
--DECLARE @ArticleName VARCHAR(50) = 'Nuevo';
--DECLARE @Token VARCHAR(50) = 'AJORTIZP';
DECLARE @FlagEnabledArticle INT = 1;
DECLARE @FlagShowDefaultArticle INT = 0;
DECLARE @DateCreated DATETIME = GETDATE();

INSERT INTO dbo.CatArticle
(
	ArtIdTypeArticle,
	ArtName,
	ArtShowDefault,
	ArtRowStatus,
	ArtTokenCreated,
	ArtDateCreated
)
VALUES
(
	@IdTypeArticle,
	@ArticleName,
	@FlagShowDefaultArticle,
	@FlagEnabledArticle,
	@Token,
	@DateCreated
);

END
GO


