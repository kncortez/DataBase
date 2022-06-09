
-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 7 Octubre 2020
-- Description:	Retorna informacion de la factura
-- =============================================
CREATE PROCEDURE [dbo].[spg_InformationInvoice]
	-- Add the parameters for the stored procedure here
	@idInvoice bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select * from [dbo].[invoiceHeader] WITH(NOLOCK)
	where inv_pk_id = @idInvoice 

	select * from [dbo].[invoiceDetail] WITH(NOLOCK)
	where dti_fk_header = @idInvoice
	ORDER BY dti_dateRegister

	select
	io_pk_id 'Id',
	case when io_type = 1 then io_amount else 0 end cash,
	case when io_type = 2 then io_amount else 0 end credCard,
	iod.io_ticket 'Ticket',
	io_SAPDocEntryPaymentDetail 'docEntry'
	from InOutOfMoneyDetail iod WITH(NOLOCK)
	where io_invoice = @idInvoice
END
