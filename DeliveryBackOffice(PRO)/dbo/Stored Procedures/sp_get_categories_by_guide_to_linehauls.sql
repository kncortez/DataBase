​
CREATE PROCEDURE [dbo].[sp_get_categories_by_guide_to_linehauls]
	@GuideSerie VARCHAR(2),
	@GuideNumber INT
AS
BEGIN
​
--DECLARE @GuideSerie VARCHAR(10) = 'FD';
--DECLARE @GuideNumber INT = 200425; --60607 --200425
DECLARE @RbcRowStatus INT = 1;
DECLARE @AbcRowStatus INT = 1;
DECLARE @ShowDefault INT = 1;
DECLARE @ArtRowStatus INT = 1;
DECLARE @DecimalConstantZero DECIMAL(18, 2) = 0.00;
DECLARE @StringConstantX NVARCHAR(3) = ' x ';
DECLARE @StringConstantHyphen NVARCHAR(3) = ' - ';
DECLARE @Exist INT = 0;
​
IF OBJECT_ID('tempdb.dbo.#categoriesList', 'U') IS NOT NULL DROP TABLE #categoriesList;
​
SELECT ac.AbcId ArtId, 
	   CONCAT(ca.ArtName, @StringConstantHyphen, 
			  ac.Code, @StringConstantHyphen, 
			  ISNULL(ac.Height, @DecimalConstantZero), @StringConstantX, 
			  ISNULL(ac.Width, @DecimalConstantZero), @StringConstantX, 
			  ISNULL(ac.Length, @DecimalConstantZero)) ArtName,
	   ac.AbcIdArticle, 
	   ac.Code, 
	   ISNULL(ac.PriceDefault, @DecimalConstantZero) PriceDefault, 
	   ISNULL(ac.Height, @DecimalConstantZero) Height, 
	   ISNULL(ac.Width, @DecimalConstantZero) Width, 
	   ISNULL(ac.Length, @DecimalConstantZero) 'Length', 
	   ISNULL(ac.MassWeight, @DecimalConstantZero) MassWeight, 
	   ISNULL(ac.VolumetricWeight, @DecimalConstantZero) VolumetricWeight
INTO #categoriesList
FROM DeliveryBackOffice.dbo.DeliveryOrder ord
LEFT JOIN DeliveryBackOffice.dbo.Customer cs 
	ON cs.IdCustomer = ord.IdCustomer
LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vp 
	ON vp.CodeOfReference = ord.Sender_ID
LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer rc 
	ON rc.RbcIdCustomer = ISNULL(cs.IdCustomer, vp.CustomerID) 
	AND rc.RbcRowStatus = @RbcRowStatus
LEFT JOIN DeliveryBackOffice.dbo.RateData rd 
	ON rd.RateId = rc.RbcIdRate
INNER JOIN DeliveryBackOffice.dbo.ArticleByCustomer ac 
	ON ac.AbcId = rd.ArticleId
	AND ac.AbcRowStatus = @AbcRowStatus
INNER JOIN DeliveryBackOffice.dbo.CatArticle ca
	ON ca.ArtId = ac.AbcIdArticle
	AND ca.ArtRowStatus = @ArtRowStatus
WHERE ord.Guide_Serie = @GuideSerie 
AND ord.Guide_Number = @GuideNumber
GROUP BY ac.AbcId, ac.AbcIdArticle, ac.Code,
		 ac.PriceDefault, ac.Height, ac.Width,
		 ac.Length, ac.MassWeight, ac.VolumetricWeight,
		 ac.ShowDefault, ca.ArtName;
​
SELECT @Exist = COUNT(1)
FROM #categoriesList;
​
IF @Exist > 0
BEGIN
	SELECT *
	FROM #categoriesList;
END
ELSE
BEGIN
	SELECT ac.AbcId ArtId, 
		   CONCAT(ca.ArtName, @StringConstantHyphen, 
				  ac.Code, @StringConstantHyphen, 
				  ISNULL(ac.Height, @DecimalConstantZero), @StringConstantX, 
				  ISNULL(ac.Width, @DecimalConstantZero), @StringConstantX, 
				  ISNULL(ac.Length, @DecimalConstantZero)) ArtName,
		   ac.AbcIdArticle, 
		   ac.Code, 
		   ISNULL(ac.PriceDefault, @DecimalConstantZero) PriceDefault, 
		   ISNULL(ac.Height, @DecimalConstantZero) Height, 
		   ISNULL(ac.Width, @DecimalConstantZero) Width, 
		   ISNULL(ac.Length, @DecimalConstantZero) 'Length', 
		   ISNULL(ac.MassWeight, @DecimalConstantZero) MassWeight, 
		   ISNULL(ac.VolumetricWeight, @DecimalConstantZero) VolumetricWeight
	FROM DeliveryBackOffice.dbo.ArticleByCustomer ac
	INNER JOIN DeliveryBackOffice.dbo.CatArticle ca
		ON ca.ArtId = ac.AbcIdArticle
		AND ca.ArtRowStatus = @ArtRowStatus
	WHERE ac.ShowDefault = @ShowDefault
	AND ac.AbcRowStatus = @AbcRowStatus;
END
​
END
