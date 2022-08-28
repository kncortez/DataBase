
-- =============================================
-- Author:		Eduardo López
-- Create date: 22 Agost 2022
-- Description:	Retorna informacion de la factura para la creacion de Nota de Credito
-- =============================================
CREATE PROCEDURE [dbo].[spg_InformationInvoiceNote]
	-- Add the parameters for the stored procedure here
	@fel nvarchar(100)
AS
Declare @idinvoice int;
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Set @idinvoice = (select inv_pk_id from [dbo].[invoiceHeader] WITH(NOLOCK)
	where inv_certificationFEL = @fel)
    -- Insert statements for procedure here
	select * from [dbo].[invoiceHeader] WITH(NOLOCK)
	where inv_pk_id = @idinvoice

	select * from [dbo].[invoiceDetail] WITH(NOLOCK)
	where dti_fk_header = @idinvoice
	ORDER BY dti_dateRegister

	select
	io_pk_id 'Id',
	case when io_type = 1 then io_amount else 0 end cash,
	case when io_type = 2 then io_amount else 0 end credCard,
	iod.io_ticket 'Ticket',
	io_SAPDocEntryPaymentDetail 'docEntry'
	from InOutOfMoneyDetail iod WITH(NOLOCK)
	where io_invoice = @idinvoice
END