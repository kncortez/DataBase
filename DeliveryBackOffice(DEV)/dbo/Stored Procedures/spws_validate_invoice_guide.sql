
-- ==========================================================================
-- Author:		<César,Aquino>
-- Create date: <2021-06-03>
-- Description:	<Valida que un listado de guias aun no esten facturadas>
-- ==========================================================================

CREATE PROCEDURE [dbo].[spws_validate_invoice_guide]
	@InGuides varchar(max)
AS
BEGIN
    DECLARE @idType INT;
	DECLARE @Result INT;
	DECLARE @Result1 INT;
	DECLARE @Result2 INT;
	DECLARE @Result3 INT;

	

	SET @idType = (SELECT IdCatInvoiceType FROM CatInvoiceType WHERE Name = 'Envío')

	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;

	select distinct SUBSTRING(Item, 1,2) ItemSerie,
		SUBSTRING(Item,3, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 1))) ItemNumber 
	into #listGuides
	from DeliveryBackOffice.dbo.SplitUnlimited(@InGuides,',')

	SET @Result1 = (SELECT COUNT(1) AS result
	FROM #listGuides ls
		left join dbo.invoiceDetail id WITH(NOLOCK) on id.dti_fk_orderSerie = ls.ItemSerie and id.dti_fk_orderNumber = ls.ItemNumber
		LEFT JOIN dbo.invoiceHeader ih WITH(NOLOCK) ON ih.inv_pk_id = id.dti_fk_header
	where id.dti_fk_header is NOT NULL AND LEN(ISNULL(ih.inv_certificationFEL,''))>0 AND IH.inv_creditNote IS NULL AND IH.inv_motiveCreditNote IS NULL
		AND IH.inv_descriptionFEL ='PROCESO REALIZADO')

	SET @Result2 = (SELECT COUNT(1) AS result2
	FROM #listGuides ls
		LEFT JOIN dbo.invoiceDetail id WITH(NOLOCK) ON id.dti_fk_orderSerie = ls.ItemSerie and id.dti_fk_orderNumber = ls.ItemNumber
		LEFT JOIN dbo.invoiceHeader ih WITH(NOLOCK) ON ih.inv_pk_id = id.dti_fk_header
	WHERE id.dti_fk_header is NOT NULL AND LEN(ISNULL(ih.inv_certificationFEL,''))>0 AND ih.CatInvoiceTypeId = @idType)

	SET @Result3 = (SELECT COUNT(1) AS result3
	FROM #listGuides ls
		LEFT JOIN dbo.invoiceDetail id WITH(NOLOCK) ON id.dti_fk_orderSerie = ls.ItemSerie and id.dti_fk_orderNumber = ls.ItemNumber
		LEFT JOIN dbo.invoiceHeader ih WITH(NOLOCK) ON ih.inv_pk_id = id.dti_fk_header
	WHERE id.dti_fk_header is NOT NULL AND LEN(ISNULL(ih.inv_certificationFEL,''))>0 AND ih.CatInvoiceTypeId = @idType AND ih.inv_creditNote is NOT NULL) 

	IF (@Result1 > 0 AND @Result2 >0 AND @Result3 > 0)
		BEGIN 
			SET @Result = 0;
		END
	ELSE IF (@Result1 >0 AND @Result2 > 0)
		BEGIN
		   SET @Result = 1;
		END
	ELSE IF(@Result2 = 0 AND @Result3 = 0)
		BEGIN
			SET @Result = 0;
		END
	ELSE
	BEGIN
		  SET @Result = @Result1;
	END

	Select @Result AS result;
end
