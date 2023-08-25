CREATE PROCEDURE GetImagePromotional
--@Status INT
AS
BEGIN
	SELECT [IdCarouselImage]
      ,[ImageURL]
      ,[ImageResolutionX]
      ,[ImageResolutionY]
      ,[ImageOrder]
  FROM [DeliveryBackOffice].[dbo].[MarketplaceCarouselImage]
  WHERE [RowStatus] = 1

END