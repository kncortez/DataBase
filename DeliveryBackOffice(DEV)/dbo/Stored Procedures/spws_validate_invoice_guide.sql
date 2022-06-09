
-- ==========================================================================
-- Author:		<César,Aquino>
-- Create date: <2021-06-03>
-- Description:	<Valida que un listado de guias aun no esten facturadas>
-- ==========================================================================

CREATE PROCEDURE [dbo].[spws_validate_invoice_guide]
	@InGuides varchar(max)
AS
BEGIN

	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;

	select distinct SUBSTRING(Item, 1,2) ItemSerie,
		SUBSTRING(Item,3, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 3))) ItemNumber 
	into #listGuides
	from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')

	SELECT COUNT(1) AS result
	FROM #listGuides ls
		left join dbo.invoiceDetail id on id.dti_fk_orderSerie = ls.ItemSerie and id.dti_fk_orderNumber = ls.ItemNumber
		LEFT JOIN dbo.invoiceHeader ih ON ih.inv_pk_id = id.dti_fk_header
	where id.dti_fk_header is NOT NULL AND LEN(ISNULL(ih.inv_certificationFEL,''))>0 

end
