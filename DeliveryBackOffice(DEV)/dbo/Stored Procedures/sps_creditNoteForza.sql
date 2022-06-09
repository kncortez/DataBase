-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 19 Octubre 2020
-- Description:	Registra en base de datos local nueva nota de credito correspondiente a factura enviada
-- =============================================
CREATE PROCEDURE [dbo].[sps_creditNoteForza]
	-- Add the parameters for the stored procedure here
	@idInvoice int,
	@motivoNotaCredito varchar(2000),
	@token varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @idNotaCredito as int = null;
    -- Insert statements for procedure here
	INSERT INTO [dbo].[invoiceHeader]
           ([inv_vpCodeOfReferences]
           ,[inv_cmp_nit]
           ,[inv_cli_name]
           ,[inv_cli_adress]
           ,[inv_cli_nit]
           ,[inv_cli_email]
           ,[inv_date]
           ,[inv_IVA]
           ,[inv_amount]
           ,[inv_status]
           ,[inv_dateRegister]
           ,[inv_tokenRegister]
           ,[inv_type]
		   ,inv_invoiceOfCreditNote
		   ,inv_motiveCreditNote
		   ,inv_dateOriginDocument
		   ,inv_documentOriginFEL)
		select [inv_vpCodeOfReferences]
           ,[inv_cmp_nit]
           ,[inv_cli_name]
           ,[inv_cli_adress]
           ,[inv_cli_nit]
           ,[inv_cli_email]
           ,GETDATE()
           ,[inv_IVA]
           ,[inv_amount]
           ,[inv_status]
           ,GETDATE()
           ,@token
           ,2
		   ,@idInvoice
		   ,@motivoNotaCredito
		   ,inv_date
		   ,inv_certificationFEL
		from invoiceHeader
		where inv_pk_id = @idInvoice

		set @idNotaCredito = @@IDENTITY

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
		SELECT @idNotaCredito
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
           ,GETDATE()
           ,@token
		FROM [DeliveryBackOffice].[dbo].[invoiceDetail]
		WHERE [dti_fk_header] = @idInvoice

		declare @detalles as int = @@rowcount

		update invoiceHeader
		set inv_creditNote = @idNotaCredito,
		inv_status = -1
		where inv_pk_id = @idInvoice

		select @idNotaCredito 'id',@@ROWCOUNT 'Detalles'
END
