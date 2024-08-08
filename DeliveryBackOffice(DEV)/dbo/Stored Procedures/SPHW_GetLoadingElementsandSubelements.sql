
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
-- =============================================
-- Author:		<Author Cristian Suazo>
-- Create date: <Update Date,2024-07-24>
-- Description:	<Se agrega filtro de pais para todas las consultas>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetLoadingElementsandSubelements] 
				@IdCountry NVARCHAR(2) = 'GT'

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
	AND ISNULL(IdCountry,'GT') = @IdCountry
	AND IdCatProductCategory in(Select 
										CP.[CatProductCategoryId]
								 From [dbo].[CatSubscription] CP WITH (NOLOCK)
								 INNER JOIN  
									  DeliveryBackOffice.[dbo].[MarketplaceTagsByProduct] MTP WITH (NOLOCK)
								  ON CP.IdCatSubscription = MTP.CatSubscriptionId
								  INNER JOIN
									  DeliveryBackOffice.[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
								  ON MTP.MarketplaceProductTagsId = MPT.IdMarketplaceProductTags
								WHERE CP.RowStatus=1 AND ISNULL(CP.IdCountry,'GT') = @IdCountry 
								  )

     UNION ALL
	 SELECT [IdCatProductCategory],
	       [CatProductCategoryName],
		   [CatProductCategoryDescription],
		   [CatProductCategoryOrder]
    FROM [dbo].[CatProductCategory] WITH (NOLOCK)
	WHERE Rowstatus=1
	AND ISNULL(IdCountry,'GT') = @IdCountry
	AND IdCatProductCategory in( Select 
										CP.[CatProductCategoryId]
								 From [dbo].[CatMembership] CP WITH (NOLOCK)
								 INNER JOIN  
									  DeliveryBackOffice.[dbo].[MarketplaceTagsByProduct] MTP WITH (NOLOCK)
								  ON CP.IdCatMembership = MTP.CatMembershipId
								  INNER JOIN
									  DeliveryBackOffice.[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
								  ON MTP.MarketplaceProductTagsId = MPT.IdMarketplaceProductTags
								WHERE CP.RowStatus=1 AND ISNULL(CP.IdCountry,'GT') = @IdCountry 
								  )

	/********************************************************************************
	 *********************** ENCABEZADOS ********************************************
	 ********************************************************************************/
	SELECT 
		  MPT.[MarketplaceProductTagsName],
		  MPT.[MarketplaceProductTagsDescription],
		  MPT.IdMarketplaceProductTags
    FROM  DeliveryBackOffice.[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
	WHERE MPT.Rowstatus=1 AND ISNULL(MPT.IdCountry,'GT') = @IdCountry

	/********************************************************************************
	 ************************ CONTENIDO *********************************************
	*********************************************************************************/
	SELECT 
			MTP.Position [CatPosition],
	        CP.IdCatSubscription [IdCatProduct] ,
	        CP.SubscriptionName [CatProductName],
			CONVERT(DECIMAL(18,2),CP.[SubscriptionCost]) [CatProductCost],
			CASE WHEN ISNULL(CP.IdCountry,'GT') = 'GT' THEN 'Q.' ELSE 'L.' END AS CurrencySymbol,
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
	WHERE CP.RowStatus = 1 AND ISNULL(CP.IdCountry,'GT') = @IdCountry
	UNION ALL
	Select 
			MTP.Position [CatPosition],
	        CP.IdCatMembership [IdCatProduct] ,
	        CP.MembershipName [CatProductName],
			CONVERT(DECIMAL(18,2),CP.[MembershipCost]) [CatProductCost],
			CASE WHEN ISNULL(CP.IdCountry,'GT') = 'GT' THEN 'Q.' ELSE 'L.' END AS CurrencySymbol,
			CP.MembershipDescription [CatProductDescription],
			MPT.[MarketplaceProductTagsName],
			MPT.[MarketplaceProductTagsDescription],
			CP.[CatProductCategoryId],
			CP.Tag
	 From [dbo].[CatMembership] CP WITH (NOLOCK)
	 INNER JOIN  DeliveryBackOffice.[dbo].[MarketplaceTagsByProduct] MTP WITH (NOLOCK)
	  ON CP.IdCatMembership = MTP.CatMembershipId
	  INNER JOIN DeliveryBackOffice.[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
	  ON MTP.MarketplaceProductTagsId = MPT.IdMarketplaceProductTags
	 WHERE CP.RowStatus=1 AND ISNULL(CP.IdCountry,'GT') = @IdCountry
	 ORDER BY MTP.[Position] ASC

	 /********************************************************************************
	  **************************** IMAGENES ******************************************
	 *********************************************************************************/
	 SELECT 
	        CPI.[IdCatProductImage], 
	        ISNULL(CPI.CatSubscriptionId,CPI.CatMembershipId) [CatProductId], 
			CPI.[CatProductImageSmallImageURL],
			CPI.[CatProductImageLargeImageURL],
			CPI.CatProductImageBigImageURL,
			CPI.[CatProductImageOrder]
	FROM DeliveryBackOffice.[dbo].[CatProductImage]  CPI WITH (NOLOCK)
	INNER JOIN CatSubscription CP WITH (NOLOCK)
		ON CPI.CatSubscriptionId = CP.IdCatSubscription 
	WHERE CPI.RowStatus = 1 AND ISNULL(CP.IdCountry,'GT') = @IdCountry 
	UNION ALL
	SELECT 
	        CPI.[IdCatProductImage], 
	        ISNULL(CPI.CatSubscriptionId,CPI.CatMembershipId) [CatProductId], 
			CPI.[CatProductImageSmallImageURL],
			CPI.[CatProductImageLargeImageURL],
			CPI.CatProductImageBigImageURL,
			CPI.[CatProductImageOrder]
	FROM DeliveryBackOffice.[dbo].[CatProductImage]  CPI WITH (NOLOCK)
	INNER JOIN CatMembership CTS WITH (NOLOCK)
	ON CPI.CatMembershipId = CTS.IdCatMembership
	WHERE CPI.RowStatus = 1 AND ISNULL(CTS.IdCountry,'GT') = @IdCountry 



	/********************************************************************************
	 ************************* DESCRIPCION ******************************************
	*********************************************************************************/
	Select 
			CPD.[Description]  [CatProductDescription],
			CPD.Title     [CatProductDescriptionTitle],
			CPD.Position     [CatProductDescriptionOrder],
			CPD.CatSubscriptionId     [CatProductId]
     From DeliveryBackOffice.[dbo].[CatSubscriptionDescription] CPD WITH (NOLOCK)
	 INNER JOIN DeliveryBackOffice.dbo.CatSubscription CP WITH (NOLOCK)
		ON CPD.CatSubscriptionId = CP.IdCatSubscription
	 Where CPD.RowStatus=1 AND ISNULL(CP.IdCountry,'GT') = @IdCountry
	 UNION ALL
	 Select 
			CPD.[Description]  [CatProductDescription],
			CPD.Title     [CatProductDescriptionTitle],
			CPD.Position     [CatProductDescriptionOrder],
			CPD.CatMembershipId     [CatProductId]
     From DeliveryBackOffice.[dbo].[CatMembershipDescription] CPD WITH (NOLOCK)
	 INNER JOIN DeliveryBackOffice.dbo.CatMembership CP WITH (NOLOCK)
		ON CPD.CatMembershipId = CP.IdCatMembership
	 Where CPD.RowStatus=1 AND ISNULL(CP.IdCountry,'GT') = @IdCountry

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
	  ON CPA.CatSubscriptionId =CS.IdCatSubscription 
	  Where CPA.RowStatus=1 AND CS.RowStatus=1 AND ISNULL(CS.IdCountry,'GT') = @IdCountry
	  UNION ALL
	  	 Select 
	   CPA.MembershipAttributeDescription   [CatProductAttributeDescription],
	   ISNULL(CPA.MembershipAttributeDescriptionLong,'N/D')  [CatProductAttributeDescriptionLong],
	   CPA.CatMembershipId [CatProductId],
	   CPA.MembershipAttributePosition  [CatProductAtributeOrder],
	   CS.Icon    [CatProductAttributeIcon]
	  From  DeliveryBackOffice.[dbo].[CatMembershipAttribute] CPA WITH(NOLOCK)
	  INNER JOIN DeliveryBackOffice.[dbo].[CatMembership] CS WITH(NOLOCK)
	  ON CPA.CatMembershipId =CS.IdCatMembership 
	  Where CPA.RowStatus=1 AND CS.RowStatus=1 AND ISNULL(CS.IdCountry,'GT') = @IdCountry
	   ORDER BY CPA.SubscriptionAttributePosition ASC
  
 
END


