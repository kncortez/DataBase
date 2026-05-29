/* =================================================
   SP: LoadProductCategory
   Propósito: Carga de categorías del sistema MarketPlace 
              con filtro por país.
   Autor:     Cristian Suazo
   Historia:  
   Fecha:     2024-07-17
================================================= */
/* === CHANGELOG ============================
2026-03-18 | Historia/épica: FDAPI-5843  | Autor: Pedro Macajol  | Corrección de filtro por país y adición de SV.
2024-07-17 | Historia/épica: (pendiente) | Autor: Cristian Suazo | Se agrega filtro por país.
=========================================== */
CREATE PROCEDURE [dbo].[LoadProductCategory] @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
    SELECT IdCatProductCategory,
           CatProductCategoryName,
           CatProductCategoryDescription,
           CatProductCategoryOrder,
           ImageURL
    FROM DeliveryBackOffice.dbo.CatProductCategory
    WHERE RowStatus = 1
          AND IdCountry = @IdCountry;
END;