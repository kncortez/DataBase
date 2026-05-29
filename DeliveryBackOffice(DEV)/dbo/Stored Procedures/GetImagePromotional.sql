/* =================================================
   SP:GetImagePromotional
   Propósito: Obtener imágenes y datos para carousel superior de marketplace, incluyendo hipervínculos, ordenamiento y filtro por país.
   Autor:     Eduardo López / Edelman / Cristian Suazo
   Historia:  (Agregar código de historia si aplica)
   Fecha:     2024-07-16*/
/* === CHANGELOG ============================
2026-03-18 | Historia/épica: FDAPI-5840  | Autor: Pedro Macajol   | correccion de filtro por pais y adicion de SV
2024-07-16 | Historia/épica: (pendiente) | Autor: Cristian Suazo  | Se agrega filtro por país
2023-08-21 | Historia/épica: (pendiente) | Autor: Edelman         | Se agrega hipervínculo y ordenamiento de imágenes
2023-08-21 | Historia/épica: (pendiente) | Autor: Eduardo López   | Creación inicial
===========================================*/

CREATE PROCEDURE [dbo].[GetImagePromotional]  
    @IdCountry NVARCHAR(2) = 'GT'  
AS  
BEGIN  
    SELECT   
        [IdCarouselImage],
        [ImageOrder],
        [XXLImageURL],
        [XLImageURL],
        [MDImageURL],
        [XSImageURL],
        [HyperlinkURL],
        [XXXLImageURL]
    FROM [DeliveryBackOffice].[dbo].[MarketplaceCarouselImage]  
    WHERE [RowStatus] = 1 
    AND IdCountry = @IdCountry
    ORDER BY ImageOrder ASC
END
