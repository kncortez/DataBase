
-- =============================================
-- Author:		<Bidcar Herrera>
-- Description:	<Método para obtener productos por categoría>
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Description:	<Modificación para incorporar a estructura de club forza con columna nueva en CatSuscription>
-- =============================================
CREATE PROCEDURE [dbo].[GetProductsByCategory] @IdCategory INT
AS
BEGIN


	  SELECT CS.[IdCatSubscription] [IdCatProduct],
			 CS.[SubscriptionName]  [CatProductName],
			 CS.[SubscriptionCost]  [CatProductCost],
			 CS.[SubscriptionDescription] [CatProductDescription],
			 CS.[CatProductCategoryId] [CatProductCategoryId]
  FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH (NOLOCK)
   WHERE CS.RowStatus = 1
	AND CS.CatProductCategoryId = @IdCategory
	  UNION ALL
	  SELECT CS.[IdCatMembership] [IdCatProduct],
			 CS.[MembershipName]  [CatProductName],
			 CS.[MembershipCost]  [CatProductCost],
			 CS.[MembershipDescription] [CatProductDescription],
			 CS.[CatProductCategoryId] [CatProductCategoryId]
  FROM [DeliveryBackOffice].[dbo].[CatMembership] CS WITH (NOLOCK)
  WHERE CS.RowStatus = 1
	AND CS.CatProductCategoryId = @IdCategory

    SELECT CPI.[IdCatProductImage],
              CPI.CatSubscriptionId   [CatProductId],
           CPI.[CatProductImageSmallImageURL],
           CPI.[CatProductImageLargeImageURL],
           CPI.[CatProductImageOrder]
    FROM DeliveryBackOffice.dbo.CatProductImage CPI
    INNER JOIN DeliveryBackOffice.dbo.CatSubscription A2
	ON CPI.CatSubscriptionId  = A2.IdCatSubscription 
	WHERE CPI.RowStatus = 1
	AND A2.CatProductCategoryId = @IdCategory
	UNION  ALL
	 SELECT CPI.[IdCatProductImage],
           CPI.CatMembershipId [CatProductId],
           CPI.[CatProductImageSmallImageURL],
           CPI.[CatProductImageLargeImageURL],
           CPI.[CatProductImageOrder]
    FROM DeliveryBackOffice.dbo.CatProductImage CPI
    INNER JOIN DeliveryBackOffice.dbo.CatMembership A2
	ON A2.IdCatMembership = CPI.CatMembershipId AND A2.RowStatus = 1
	WHERE CPI.RowStatus = 1
	AND A2.CatProductCategoryId = @IdCategory

END;