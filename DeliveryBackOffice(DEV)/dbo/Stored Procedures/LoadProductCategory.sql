-- Description:	< Carga de categorías del sistema MarketPlace>
CREATE PROCEDURE [dbo].[LoadProductCategory]
AS
BEGIN
	SELECT IdCatProductCategory,CatProductCategoryName,CatProductCategoryDescription,CatProductCategoryOrder 
	FROM DeliveryBackOffice.dbo.CatProductCategory
	where RowStatus = 1
END