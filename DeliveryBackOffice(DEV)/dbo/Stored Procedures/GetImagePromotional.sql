CREATE PROCEDURE [dbo].[GetImagePromotional]
--@Status INT
AS
BEGIN


	SELECT  [IdCarouselImage],XXLImageURL,XLImageURL,MDImageURL,XSImageURL,ImageOrder, HyperlinkURL, XXXLImageURL
         FROM [DeliveryBackOffice].[dbo].[MarketplaceCarouselImage]
  WHERE [RowStatus] = 1
       Order by  ImageOrder Asc;

END