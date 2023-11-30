
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-30-11>
-- Description:	<Description,carga de imagenes e información de un producto>
-- =============================================
CREATE PROCEDURE [SPHW_GetImagesandProductInformation]
@IdCatProduct INT 
AS
BEGIN


IF (EXISTS( Select Top 1 1
	 From [dbo].[CatProduct] CP WITH (NOLOCK)
	WHERE CP.[IdCatProduct] = @IdCatProduct AND CP.RowStatus=1))
	BEGIN

	SELECT 200 [StatusCode], 'Proceso Exitoso' [Description]

	END 
	ELSE
	BEGIN
	SELECT 201 [StatusCode], 'Sin Registros' [Description]
	END
	Select  
	        CP.[IdCatProduct],
			CP.[CatProductName],
			CP.[CatProductDescription],
			CP.[CatProductCost],
			CP.[CatProductDiscountValue],
			CP.[CatProductCategoryId]
From DBO.[CatProduct] CP WITH(NOLOCK) 
WHERE CP.[IdCatProduct] = @IdCatProduct

 SELECT 
			CPI.[CatProductImageSmallImageURL],
			CPI.[CatProductImageLargeImageURL],
			CPI.CatProductId
	FROM DeliveryBackOffice.dbo.CatProductImage  CPI WITH(NOLOCK)
	WHERE CPI.RowStatus = 1 AND CPI.[CatProductId] = @IdCatProduct

select 
       CPA.CatProductAttributeDescription,
	   CPA.CatProductAttributeDescriptionLong,
	   CPA.CatProductAttributeIcon,
	   CPA.CatProductAtributeOrder,
	   CPA.CatProductId
From CatProductAttribute CPA WITH(NOLOCK)
WHERE CPA.CatProductId = @IdCatProduct


					
select CPD.CatProductDescriptionTitle,
		CPD.CatProductDescription,
		CPD.CatProductDescriptionOrder,
		CPD.CatProductId
From CatProductDescription CPD WITH(NOLOCK)
Where CPD.CatProductId=@IdCatProduct
 AND   CPD.RowStatus=1
END
GO
