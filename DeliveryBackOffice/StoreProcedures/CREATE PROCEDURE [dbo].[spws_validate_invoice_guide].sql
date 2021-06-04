USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_guide_pending_payment]    Script Date: 3/06/2021 16:58:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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

	SELECT count(*) as result
	FROM #listGuides ls
		left join dbo.invoiceDetail id on id.dti_fk_orderSerie = ls.ItemSerie and id.dti_fk_orderNumber = ls.ItemNumber
	where id.dti_fk_header is NOT null

end
