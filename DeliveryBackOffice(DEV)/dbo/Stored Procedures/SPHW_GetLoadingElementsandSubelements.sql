
-- =============================================
-- Author:		<Author Edelman>
-- Create date: <Create Date,2023-08-27>
-- Description:	<Description,Método para obetenr elementos y subelementos del sitio marketplace>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetLoadingElementsandSubelements] 

AS
BEGIN
	
	IF (EXISTS(   Select Top 1 1
						 From [dbo].[CatSubscription] CP WITH (NOLOCK)
						 Left JOIN  
							  [dbo].[CatSubscriptionDescription] CPD WITH (NOLOCK)
						  ON CP.IdCatSubscription = CPD.CatSubscriptionId
						  Left JOIN 
							  [dbo].[CatSubscriptionAtribute] CPA WITH(NOLOCK)
						  ON CPA.CatSubscriptionId = CPD.CatSubscriptionId
						  Left JOIN  
							  [dbo].[MarketplaceTagsByProduct] MTP WITH (NOLOCK)
						  ON CP.IdCatSubscription = MTP.CatSubscriptionId
						  Left JOIN 
							  [dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
						  ON MTP.MarketplaceProductTagsId = MPT.IdMarketplaceProductTags
				WHERE CP.RowStatus=1
			))
	BEGIN

	SELECT 200 [StatusCode], 'Proceso Exitoso' [Description]

	END 
	ELSE
	BEGIN
	SELECT 201 [StatusCode], 'Sin Registros' [Description]
	END
	
	SELECT [IdCatProductCategory],
	       [CatProductCategoryName],
		   [CatProductCategoryDescription],
		   [CatProductCategoryOrder]
    FROM [dbo].[CatProductCategory] WITH (NOLOCK)
	WHERE Rowstatus=1
	AND IdCatProductCategory in( Select 
										CP.[CatProductCategoryId]
								 From [dbo].[CatSubscription] CP WITH (NOLOCK)
								 INNER JOIN  
									  DeliveryBackOffice.[dbo].[MarketplaceTagsByProduct] MTP WITH (NOLOCK)
								  ON CP.IdCatSubscription = MTP.CatSubscriptionId
								  INNER JOIN
									  DeliveryBackOffice.[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
								  ON MTP.IdMarketplaceTagsByProduct = MPT.IdMarketplaceProductTags
								WHERE CP.RowStatus=1
								  )

	SELECT 
		  MPT.[MarketplaceProductTagsName],
		  MPT.[MarketplaceProductTagsDescription],
		  MPT.IdMarketplaceProductTags
    FROM  DeliveryBackOffice.[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
	WHERE MPT.Rowstatus=1

	 Select 
	        CP.IdCatSubscription [CatProductId] ,
	        CP.SubscriptionName [CatProductName],
			CONVERT(DECIMAL(18,2),CP.[SubscriptionCost]) [CatProductCost],
			CP.SubscriptionDescription [CatProductDescription],
			MPT.[MarketplaceProductTagsName],
			MPT.[MarketplaceProductTagsDescription],
			CP.[CatProductCategoryId]
	 From [dbo].[CatSubscription] CP WITH (NOLOCK)
	 INNER JOIN  
	      DeliveryBackOffice.[dbo].[MarketplaceTagsByProduct] MTP WITH (NOLOCK)
	  ON CP.IdCatSubscription = MTP.CatSubscriptionId
	  INNER JOIN
	      DeliveryBackOffice.[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
	  ON MTP.IdMarketplaceTagsByProduct = MPT.IdMarketplaceProductTags
	WHERE CP.RowStatus=1
	  ORDER BY MPT.MarketplaceProductTagsName ASC

	  
	  


	 SELECT CPI.[IdCatProductImage], 
	        CPI.CatSubscriptionId [CatProductId], 
			CPI.[CatProductImageSmallImageURL],
			CPI.[CatProductImageLargeImageURL],
			CPI.[CatProductImageOrder]
	FROM DeliveryBackOffice.[dbo].[CatProductImage]  CPI WITH (NOLOCK)
	WHERE CPI.RowStatus = 1


		   Select 
			CPD.[Description]  [CatProductDescription],
			CPD.Title     [CatProductDescriptionTitle],
			CPD.Position     [CatProductDescriptionOrder],
			CPD.CatSubscriptionId     [CatProductId]
     From DeliveryBackOffice.[dbo].[CatSubscriptionDescription] CPD WITH (NOLOCK)
	 Where CPD.RowStatus=1

	 Select 
	   CPA.SubscriptionAttributeDescription   [CatProductAttributeDescription],
	   CPA.SubscriptionAttributeDescriptionLong  [CatProductAttributeDescriptionLong],
	   CPA.CatSubscriptionId [CatProductId],
	   CPA.SubscriptionAttributePosition  [CatProductAtributeOrder],
	   CS.Icon    [CatProductAttributeIcon]
	  From  DeliveryBackOffice.[dbo].[CatSubscriptionAtribute] CPA WITH(NOLOCK)
	  INNER JOIN DeliveryBackOffice.[dbo].[CatSubscription] CS WITH(NOLOCK)
	  ON CPA.CatSubscriptionId =CS.IdCatSubscription
	  Where CPA.RowStatus=1
	
    
END
