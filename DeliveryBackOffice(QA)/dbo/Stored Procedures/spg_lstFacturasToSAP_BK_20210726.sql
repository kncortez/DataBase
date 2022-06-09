-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 17 Nov 2020
-- Description:	Retorna listado de facturas listas para enviar a SAP
-- =============================================
CREATE PROCEDURE [dbo].[spg_lstFacturasToSAP_BK_20210726]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select inv_pk_id,inv_vpCodeOfReferences,inv_type,ihd.inv_status,ihd.inv_invoiceOfCreditNote
	from DeliveryBackOffice.dbo.invoiceHeader ihd with(nolock)
	--join DeliveryBackOffice.dbo.VisitPointClient vpc with(nolock) on vpc.CodeOfReference = ihd.inv_vpCodeOfReferences
	where 
	ihd.inv_status in(-1,2)
	-- 1 CREA LOCALMENTE EL REGISTRO DE FACTURA
	-- 2 CUANDO SE ENVIA FACTURA A FEL
	-- 3 CUANDO YA ESTÁ ENVIADA A SAP
	-- -1 ES ANULADA
	and inv_type in (1,2)
	--and cast(ihd.inv_dateRegister as date) = CAST(GETDATE() as date)
	and cast(ihd.inv_dateRegister as date) >= CAST('2021-02-01' as date) --CAST(GETDATE() as date)
	and ihd.inv_SAPDocEntry is null
	and isnull(ihd.inv_certificationFEL,'') != ''
	
	--inv_pk_id =  12557
	--and 1= 0
	order by inv_pk_id asc
END