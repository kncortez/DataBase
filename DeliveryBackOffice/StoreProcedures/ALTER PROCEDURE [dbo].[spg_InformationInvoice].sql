USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_InformationInvoice]    Script Date: 11/11/2021 12:36:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 7 Octubre 2020
-- Description:	Retorna informacion de la factura
-- =============================================
ALTER PROCEDURE [dbo].[spg_InformationInvoice]
	-- Add the parameters for the stored procedure here
	@idInvoice bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select * from [dbo].[invoiceHeader]
	where inv_pk_id = @idInvoice

	select * from [dbo].[invoiceDetail]
	where dti_fk_header = @idInvoice
	ORDER BY dti_dateRegister

	select
	io_pk_id 'Id',
	case when io_type = 1 then io_amount else 0 end cash,
	case when io_type = 2 then io_amount else 0 end credCard,
	iod.io_ticket 'Ticket',
	io_SAPDocEntryPaymentDetail 'docEntry'
	from InOutOfMoneyDetail iod
	where io_invoice = @idInvoice
END
