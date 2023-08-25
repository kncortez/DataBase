

-- =============================================
-- Author:		<Eduardo, López>
-- Create date: <2023-08-22>
-- Description:	<Retorna las categorías de productos>
-- =============================================
CREATE PROCEDURE GetCategoryProduct

AS
BEGIN
	SELECT
	   [CatProductCategoryName]
      ,[CatProductCategoryDescription]
      ,[CategoryOrder]
  FROM [DeliveryBackOffice].[dbo].[CatProductCategory]
  WHERE RowStatus = 1
END