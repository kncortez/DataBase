-- =============================================
-- Author:		<Eduardo, L�pez>
-- Create date: <2023-08-21>
-- Description:	< Obtener imagenes y datos para Carousel superior de marketplace>
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Create date: <2023-08-21>
-- Description:	< Obtener Hipervinculo de imagenes y ordenamiento de imagenes>
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
        , HyperlinkURL
  FROM [DeliveryBackOffice].[dbo].[MarketplaceCarouselImage]
  WHERE [RowStatus] = 1
   Order by  ImageOrder Asc;

END 

