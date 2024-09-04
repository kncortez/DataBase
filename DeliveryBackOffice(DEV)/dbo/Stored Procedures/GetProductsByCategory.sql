-- =============================================
-- Author:		<Bidcar Herrera>
-- Description:	<Método para obtener productos por categoría>
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Description:	<Modificación para incorporar a estructura de club forza con columna nueva en CatSuscription>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Description:	<Se agrega la moneda correspondiente>
-- =============================================
CREATE PROCEDURE [dbo].[GetProductsByCategory] @IdCategory INT
AS
BEGIN


		  SELECT           
	        CS.[IdCatSubscription] [IdCatProduct],
			CS.[SubscriptionName]  [CatProductName],
			CS.[SubscriptionCost]  [CatProductCost],
			CASE WHEN ISNULL(CS.IdCountry,'GT') = 'GT' THEN 'Q.' ELSE 'L.' END AS CurrencySymbol,
			CS.[SubscriptionDescription] [CatProductDescription],
			CS.[CatProductCategoryId] [CatProductCategoryId],
			CS.Tag,
			CS.Position
	FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH (NOLOCK)
	WHERE CS.RowStatus = 1
	 AND CS.CatProductCategoryId = @IdCategory
	UNION ALL
	SELECT  
			 CS.[IdCatMembership] [IdCatProduct],
			 CS.[MembershipName]  [CatProductName],
			 CS.[MembershipCost]  [CatProductCost],
			 CASE WHEN ISNULL(CS.IdCountry,'GT') = 'GT' THEN 'Q.' ELSE 'L.' END AS CurrencySymbol,
			 CS.[MembershipDescription] [CatProductDescription],
			 CS.[CatProductCategoryId] [CatProductCategoryId],
			 CS.Tag,
			 CS.Position
	FROM [DeliveryBackOffice].[dbo].[CatMembership] CS WITH (NOLOCK)
	WHERE CS.RowStatus = 1
	  AND CS.CatProductCategoryId = @IdCategory
	  Order By CS.Position ASC

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
	ON A2.IdCatMembership = CPI.CatMembershipId 
	WHERE CPI.RowStatus = 1
	  AND A2.CatProductCategoryId = @IdCategory
	  AND A2.RowStatus = 1
END;
