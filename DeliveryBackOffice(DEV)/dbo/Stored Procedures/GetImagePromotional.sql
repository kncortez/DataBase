CREATE PROCEDURE [dbo].[GetImagePromotional]
--@Status INT
AS
BEGIN
	SELECT XXLImageURL,XLImageURL,MDImageURL,XSImageURL,ImageOrder, HyperlinkURL
  FROM [DeliveryBackOffice].[dbo].[MarketplaceCarouselImage]
  WHERE [RowStatus] = 1

END

--exec [dbo].[GetImagePromotional]