
-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 7 Octubre 2020
-- Description:	Retorna informacion de la factura
-- =============================================
CREATE PROCEDURE [dbo].[spg_InformationInvoice]
	-- Add the parameters for the stored procedure here
	@idInvoice bigint
	,@IncreaseRetries bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @IncreaseRetries = 1
		UPDATE invoiceHeader
		SET Retries += 1
		WHERE inv_pk_id = @idInvoice

    -- Insert statements for procedure here
	select * from [dbo].[invoiceHeader] WITH(NOLOCK)
	where inv_pk_id = @idInvoice 

	select * from [dbo].[invoiceDetail] WITH(NOLOCK)
	where dti_fk_header = @idInvoice
	ORDER BY dti_dateRegister

select top 1
	io_pk_id 'Id',
	case when io_type = 1 then io_amount else 0 end cash,
	case when io_type = 2 then io_amount else 0 end credCard,
	iod.io_ticket 'Ticket',
	io_SAPDocEntryPaymentDetail 'docEntry',
	del.dpf_WarehouseCode 'WarehouseCode'
	from InOutOfMoneyDetail iod WITH(NOLOCK)
	inner join invoiceHeader inh WITH(NOLOCK)
	on iod.io_invoice = inh.inv_pk_id
	inner join invoiceDetail ind WITH(NOLOCK)
	on inh.inv_pk_id = ind.dti_fk_header
	left join CatArticleSAP cts WITH(NOLOCK)
	on ind.SAPCode = cts.SAPCode
	inner join del_ParametrosFactura del
	on inh.inv_vpCodeOfReferences = del.dpf_VpCodeOfReference
	where iod.io_invoice = @idInvoice
	and cts.RowSatus = 1 and ind.SAPCode = cts.SAPCode
	
END
