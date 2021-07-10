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

SELECT AbcId, Code, PriceDefault, 
	   Height, Width, Length,
	   MassWeight, VolumetricWeight
FROM dbo.ArticleByCustomer
WHERE AbcRowStatus = @FlagEnabledABC
AND AbcIdArticle = @IdArticle;

END

GO


