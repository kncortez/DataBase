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
-- Author:		<Cristian Suazo>
-- Create date: <2024-07-16>
-- Description:	< Se agrega el filtro por pais>
-- =============================================
CREATE PROCEDURE [dbo].[GetImagePromotional]
				 @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
	SELECT 
         [IdCarouselImage]
        ,[ImageOrder]
        ,[XXLImageURL]
        ,[XLImageURL]
        ,[MDImageURL]
        ,[XSImageURL]
        ,[HyperlinkURL]
        ,[XXXLImageURL]
  FROM [DeliveryBackOffice].[dbo].[MarketplaceCarouselImage]
  WHERE [RowStatus] = 1 AND ISNULL(IdCountry, 'GT') = @IdCountry
   Order by  ImageOrder Asc;

END