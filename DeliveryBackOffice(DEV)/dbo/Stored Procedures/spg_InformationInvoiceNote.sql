
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

	--select * from [dbo].[invoiceDetail] WITH(NOLOCK)
	--where dti_fk_header = @idinvoice
	--ORDER BY dti_dateRegister

	select
	  ivd.[dti_fk_header]
      ,ivd.[dti_fk_orderSerie]
      ,ISNULL(ivd.dti_fk_orderNumber, 0) as dti_fk_orderNumber
      ,ivd.[dti_identification]
      ,ivd.[dti_category]
      ,ivd.[dti_quantity]
      ,ivd.[dti_measurement]
      ,ivd.[dti_priceUnit]
      ,ivd.[dti_description]
      ,ivd.[dti_IVA]
      ,ivd.[dti_amount]
      ,ivd.[dti_dateRegister]
      ,ivd.[dti_tokenRegister]
      ,ivd.[SAPCode]
      ,ivd.[SendToInvoice]
	  ,ISNULL(do.StatusOrderId, 0) as StatusOrderId
	from [dbo].[invoiceDetail] ivd WITH(NOLOCK)
	LEFT JOIN DeliveryOrder do WITH(NOLOCK)
	ON ivd.dti_fk_orderNumber = do.Guide_Number
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