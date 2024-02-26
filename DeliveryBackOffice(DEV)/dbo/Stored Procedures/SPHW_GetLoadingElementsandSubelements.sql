
-- =============================================
-- Author:		<Author Edelman>
-- Create date: <Create Date,2023-08-27>
-- Description:	<Description,Método para obetenr elementos y subelementos del sitio marketplace>
-- =============================================
-- =============================================
-- Author:		<Author Edelman>
-- Create date: <Update Date,2024-01-10>
-- Description:	<Description,integrar estructura de BD Club forza con marketplace>
-- =============================================
-- =============================================
-- Author:		<Author Edelman>
-- Create date: <Update Date,2024-01-15>
-- Description:	<Description, campo tag para etiquetar productos Club forza  marketplace>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetLoadingElementsandSubelements] 

AS
BEGIN
	
	/***************************** DETERMINAR SI HAY CONTENIDO O NO **********************************/
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
	

	/********************************************************************************
	 ************************** CATEGORIA DE PRODUCTOS ******************************
	 ********************************************************************************/
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

     UNION ALL
	 SELECT [IdCatProductCategory],
	       [CatProductCategoryName],
		   [CatProductCategoryDescription],
		   [CatProductCategoryOrder]
    FROM [dbo].[CatProductCategory] WITH (NOLOCK)
	WHERE Rowstatus=1
	AND IdCatProductCategory in( Select 
										CP.[CatProductCategoryId]
								 From [dbo].[CatMembership] CP WITH (NOLOCK)
								 INNER JOIN  
									  DeliveryBackOffice.[dbo].[MarketplaceTagsByProduct] MTP WITH (NOLOCK)
								  ON CP.IdCatMembership = MTP.CatMembershipId
								  INNER JOIN
									  DeliveryBackOffice.[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
								  ON MTP.IdMarketplaceTagsByProduct = MPT.IdMarketplaceProductTags
								WHERE CP.RowStatus=1
								  )

	/********************************************************************************
	 *********************** ENCABEZADOS ********************************************
	 ********************************************************************************/
	SELECT 
		  MPT.[MarketplaceProductTagsName],
		  MPT.[MarketplaceProductTagsDescription],
		  MPT.IdMarketplaceProductTags
    FROM  DeliveryBackOffice.[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
	WHERE MPT.Rowstatus=1

	/********************************************************************************
	 ************************ CONTENIDO *********************************************
	*********************************************************************************/
	SELECT 
			MTP.Position [CatPosition],
	        CP.IdCatSubscription [IdCatProduct] ,
	        CP.SubscriptionName [CatProductName],
			CONVERT(DECIMAL(18,2),CP.[SubscriptionCost]) [CatProductCost],
			CP.SubscriptionDescription [CatProductDescription],
			MPT.[MarketplaceProductTagsName],
			MPT.[MarketplaceProductTagsDescription],
			CP.[CatProductCategoryId],
			CP.Tag
	FROM DeliveryBackOffice.[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
	  RIGHT JOIN DeliveryBackOffice.[dbo].[MarketplaceTagsByProduct] MTP WITH (NOLOCK)
	  on MPT.IdMarketplaceProductTags=MTP.MarketplaceProductTagsId
	  INNER JOIN  [dbo].[CatSubscription] CP WITH (NOLOCK)
	  on MTP.CatSubscriptionId = CP.IdCatSubscription
	UNION ALL
	Select 
			MTP.Position [CatPosition],
	        CP.IdCatMembership [IdCatProduct] ,
	        CP.MembershipName [CatProductName],
			CONVERT(DECIMAL(18,2),CP.[MembershipCost]) [CatProductCost],
			CP.MembershipDescription [CatProductDescription],
			MPT.[MarketplaceProductTagsName],
			MPT.[MarketplaceProductTagsDescription],
			CP.[CatProductCategoryId],
			CP.Tag
	 From [dbo].[CatMembership] CP WITH (NOLOCK)
	 INNER JOIN  
	 DeliveryBackOffice.[dbo].[MarketplaceTagsByProduct] MTP WITH (NOLOCK)
	  ON CP.IdCatMembership = MTP.CatMembershipId
	  INNER JOIN DeliveryBackOffice.[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
	  ON MTP.MarketplaceProductTagsId = MPT.IdMarketplaceProductTags
	 WHERE CP.RowStatus=1
	 ORDER BY MTP.[Position] ASC

	 /********************************************************************************
	  **************************** IMAGENES ******************************************
	 *********************************************************************************/
	 SELECT 
	        CPI.[IdCatProductImage], 
	        ISNULL(CPI.CatSubscriptionId,CPI.CatMembershipId) [CatProductId], 
			CPI.[CatProductImageSmallImageURL],
			CPI.[CatProductImageLargeImageURL],
			CPI.[CatProductImageOrder]
	FROM DeliveryBackOffice.[dbo].[CatProductImage]  CPI WITH (NOLOCK)
	WHERE CPI.RowStatus = 1

	/********************************************************************************
	 ************************* DESCRIPCION ******************************************
	*********************************************************************************/
	Select 
			CPD.[Description]  [CatProductDescription],
			CPD.Title     [CatProductDescriptionTitle],
			CPD.Position     [CatProductDescriptionOrder],
			CPD.CatSubscriptionId     [CatProductId]
     From DeliveryBackOffice.[dbo].[CatSubscriptionDescription] CPD WITH (NOLOCK)
	 Where CPD.RowStatus=1
	 UNION ALL
	 Select 
			CPD.[Description]  [CatProductDescription],
			CPD.Title     [CatProductDescriptionTitle],
			CPD.Position     [CatProductDescriptionOrder],
			CPD.CatMembershipId     [CatProductId]
     From DeliveryBackOffice.[dbo].[CatMembershipDescription] CPD WITH (NOLOCK)
	 Where CPD.RowStatus=1

	 /********************************************************************************
	  ************************ ATRIBUTOS *********************************************
	 *********************************************************************************/
	 Select 
	   CPA.SubscriptionAttributeDescription   [CatProductAttributeDescription],
	   CPA.SubscriptionAttributeDescriptionLong  [CatProductAttributeDescriptionLong],
	   CPA.CatSubscriptionId [CatProductId],
	   CPA.SubscriptionAttributePosition  [CatProductAtributeOrder],
	   CS.Icon    [CatProductAttributeIcon]
	  From  DeliveryBackOffice.[dbo].[CatSubscriptionAtribute] CPA WITH(NOLOCK)
	  INNER JOIN DeliveryBackOffice.[dbo].[CatSubscription] CS WITH(NOLOCK)
	  ON CPA.CatSubscriptionId =CS.IdCatSubscription AND CS.RowStatus=1
	  Where CPA.RowStatus=1
	  UNION ALL
	  	 Select 
	   CPA.MembershipAttributeDescription   [CatProductAttributeDescription],
	   ISNULL(CPA.MembershipAttributeDescriptionLong,'N/D')  [CatProductAttributeDescriptionLong],
	   CPA.CatMembershipId [CatProductId],
	   CPA.MembershipAttributePosition  [CatProductAtributeOrder],
	   CS.Icon    [CatProductAttributeIcon]
	  From  DeliveryBackOffice.[dbo].[CatMembershipAttribute] CPA WITH(NOLOCK)
	  INNER JOIN DeliveryBackOffice.[dbo].[CatMembership] CS WITH(NOLOCK)
	  ON CPA.CatMembershipId =CS.IdCatMembership AND CS.RowStatus=1
	  Where CPA.RowStatus=1
  
 
END


