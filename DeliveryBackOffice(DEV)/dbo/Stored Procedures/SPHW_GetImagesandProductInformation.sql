
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-30-11>
-- Description:	<Description,carga de imagenes e información de un producto>
-- =============================================
CREATE PROCEDURE [SPHW_GetImagesandProductInformation]
@IdCatProduct INT, 
@ProductName NVARCHAR(300)
AS
BEGIN


IF (EXISTS( Select Top 1 1
	 From [dbo].[CatSubscription] CP WITH (NOLOCK)
	WHERE CP.[IdCatSubscription] = @IdCatProduct AND CP.RowStatus=1)
	OR 
	EXISTS( Select Top 1 1
	 From [dbo].[CatMembership] CP WITH (NOLOCK)
	WHERE CP.[IdCatMembership] = @IdCatProduct AND CP.RowStatus=1)
	)
	BEGIN

	SELECT 200 [StatusCode], 'Proceso Exitoso' [Description]

	END 
	ELSE
	BEGIN
	SELECT 201 [StatusCode], 'Sin Registros' [Description]
	END
	Select  
	        CP.IdCatSubscription   [IdCatProduct],
			CP.SubscriptionName [CatProductName],
			CP.SubscriptionDescription   [CatProductDescription],
			CP.SubscriptionCost  [CatProductCost],
			CP.SubscriptionFixedValue [CatProductDiscountValue],
			CP.[CatProductCategoryId]
From DBO.[CatSubscription] CP WITH(NOLOCK) 
WHERE CP.IdCatSubscription = @IdCatProduct
      AND   CP.RowStatus=1 AND CP.SubscriptionName = @ProductName
UNION ALL 

Select  
	        CP.IdCatMembership   [IdCatProduct],
			CP.MembershipName [CatProductName],
			CP.MembershipDescription   [CatProductDescription],
			CP.MembershipCost  [CatProductCost],
			CP.MembershipFixedValue [CatProductDiscountValue],
			CP.[CatProductCategoryId]
From [dbo].[CatMembership] CP WITH(NOLOCK) 
WHERE CP.IdCatMembership = @IdCatProduct
      AND   CP.RowStatus=1 AND CP.MembershipName  = @ProductName


 SELECT 
			CPI.[CatProductImageSmallImageURL],
			CPI.[CatProductImageLargeImageURL],
			ISNULL(CPI.CatSubscriptionId,CPI.CatMembershipId) [CatProductId]
	FROM DeliveryBackOffice.dbo.CatProductImage  CPI WITH(NOLOCK)
	  LEFT JOIN DeliveryBackOffice.dbo.CatMembership CM WITH(NOLOCK)
	  ON CPI.CatMembershipId = CM.IdCatMembership 
	WHERE CPI.RowStatus = 1 
	 AND CM.MembershipName = @ProductName
	  AND CM.IdCatMembership = @IdCatProduct
	UNION ALL
	SELECT 
			CPI.[CatProductImageSmallImageURL],
			CPI.[CatProductImageLargeImageURL],
			ISNULL(CPI.CatSubscriptionId,CPI.CatMembershipId) [CatProductId]
	FROM DeliveryBackOffice.dbo.CatProductImage  CPI WITH(NOLOCK)
	    LEFT JOIN DeliveryBackOffice.dbo.CatSubscription CS WITH(NOLOCK)
	  ON CS.IdCatSubscription = CPI.CatSubscriptionId
	WHERE CPI.RowStatus = 1 
	AND CS.SubscriptionName = @ProductName
		 AND CS.IdCatSubscription = @IdCatProduct

select 
       CPA.SubscriptionAttributeDescription [CatProductAttributeDescription],
	   ISNULL(CPA.SubscriptionAttributeDescriptionLong,'N/D') [CatProductAttributeDescriptionLong],
	   CPA.CatSubscriptionAttributeIcon   [CatProductAttributeIcon],
	   CPA.SubscriptionAttributePosition [CatProductAtributeOrder],
	   CPA.CatSubscriptionId [CatProductId]
From [dbo].[CatSubscriptionAtribute] CPA WITH(NOLOCK)
      LEFT JOIN [dbo].[CatSubscription] CS WITH(NOLOCK)
	  ON CPA.CatSubscriptionId = CS.IdCatSubscription
WHERE CPA.CatSubscriptionId = @IdCatProduct
       AND   CPA.RowStatus=1
	   AND CS.SubscriptionName = @ProductName
	   UNION ALL
	   select 
       CPA.MembershipAttributeDescription [CatProductAttributeDescription],
	   ISNULL(CPA.MembershipAttributeDescriptionLong,'N/D') [CatProductAttributeDescriptionLong],
	   CPA. CatMembershipAttributeIcon   [CatProductAttributeIcon],
	   CPA.MembershipAttributePosition [CatProductAtributeOrder],
	   CPA.CatMembershipId [CatProductId]
From [dbo].[CatMembershipAttribute] CPA WITH(NOLOCK)
      LEFT JOIN [dbo].[CatMembership] CS WITH(NOLOCK)
	  ON CPA.CatMembershipId = CS.IdCatMembership
WHERE CPA.CatMembershipId = @IdCatProduct
       AND   CPA.RowStatus=1
	   AND CS.MembershipName = @ProductName

					
select  CPD.Title [CatProductDescriptionTitle],
		CPD.[Description] [CatProductDescription],
		CPD.Position [CatProductDescriptionOrder],
		CPD.CatSubscriptionId [CatProductId]
From CatSubscriptionDescription CPD WITH(NOLOCK)
   INNER JOIN CatSubscription CS WITH(NOLOCK)
   ON CPD.CatSubscriptionId = CS.IdCatSubscription
Where CPD.CatSubscriptionId = @IdCatProduct
 AND   CPD.RowStatus=1
    AND CS.SubscriptionName = @ProductName 
 UNION ALL
 select  CPD.Title [CatProductDescriptionTitle],
		CPD.[Description] [CatProductDescription],
		CPD.Position [CatProductDescriptionOrder],
		CPD.IdCatMembershipDescription [CatProductId]
From CatMembershipDescription CPD WITH(NOLOCK)
INNER JOIN CatMembership CM WITH(NOLOCK)
ON CPD.CatMembershipId = CM.IdCatMembership
Where CPD.CatMembershipId = @IdCatProduct
 AND   CPD.RowStatus=1
 AND CM.MembershipName = CM.MembershipName



END