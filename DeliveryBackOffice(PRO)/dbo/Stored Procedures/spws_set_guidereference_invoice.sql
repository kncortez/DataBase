
-- ==========================================================================
-- Author:		<César,Aquino>
-- Create date: <2021-06-03>
-- Description:	<Registra facturas a una factura generada>
-- ==========================================================================

CREATE PROCEDURE [dbo].[spws_set_guidereference_invoice]
	@InGuides varchar(max)
	,@IdInvoice int
AS
BEGIN

IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;

	select distinct SUBSTRING(Item, 1,2) ItemSerie,
		SUBSTRING(Item,3, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 3))) ItemNumber 
	into #listGuides
	from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')


	INSERT INTO [dbo].[invoiceDetail]
           ([dti_fk_header]
           ,[dti_fk_orderSerie]
           ,[dti_fk_orderNumber]
           ,[dti_identification]
           ,[dti_category]
           ,[dti_quantity]
           ,[dti_measurement]
           ,[dti_priceUnit]
           ,[dti_description]
           ,[dti_IVA]
           ,[dti_amount]
           ,[dti_dateRegister]
           ,[dti_tokenRegister])
	SELECT TOP 1  @IdInvoice
		,ls.ItemSerie
		,ls.ItemNumber
		,iv.dti_identification
		,iv.dti_category
		,iv.dti_quantity
		,iv.dti_measurement
		,0 -- price
		,CONCAT('TRANSPORTE PAQ. GUIA ',ls.ItemSerie,ls.ItemNumber)
		,0
		,0 -- amount
		,getdate()
		,iv.dti_tokenRegister
	FROM #listGuides ls
		left join dbo.invoiceDetail iv on iv.dti_fk_header = @IdInvoice
		left join dbo.invoiceDetail id on id.dti_fk_orderSerie = ls.ItemSerie and id.dti_fk_orderNumber = ls.ItemNumber
	where id.dti_fk_header is null
	
END