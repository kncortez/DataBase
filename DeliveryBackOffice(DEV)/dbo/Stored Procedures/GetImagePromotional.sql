-- =============================================
-- Author:		<Eduardo, L�pez>
-- Create date: <2023-08-21>
-- Description:	< Obtener imagenes y datos para Carousel superior de marketplace>
-- =============================================
CREATE PROCEDURE [dbo].[GetImagePromotional]

AS
BEGIN
	SELECT 
         [IdCarouselImage]
        ,[ImageOrder]
        ,[XXLImageURL]
        ,[XLImageURL]
        ,[MDImageURL]
        ,[XSImageURL]
  FROM [DeliveryBackOffice].[dbo].[MarketplaceCarouselImage]
  WHERE [RowStatus] = 1

END

