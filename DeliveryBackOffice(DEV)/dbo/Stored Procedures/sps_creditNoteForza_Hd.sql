-- =============================================
-- Author:		Eduardo López
-- Create date: 26 Agosto 2022
-- Description:	Registra en base de datos local nueva nota de credito correspondiente a factura enviada
-- =============================================
CREATE PROCEDURE [dbo].[sps_creditNoteForza_Hd]
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
	declare @vpCodeOfReferences nvarchar(10);

		BEGIN TRANSACTION
	BEGIN TRY
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
				from invoiceHeader WITH (NOLOCK)
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
				   ,[dti_tokenRegister]
				   ,[SAPCode])   
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
				   ,[SAPCode]
				FROM [DeliveryBackOffice].[dbo].[invoiceDetail] WITH (NOLOCK)
				WHERE [dti_fk_header] = @idInvoice

				declare @detalles as int = @@rowcount
				Set @vpCodeOfReferences =(Select inv_vpCodeOfReferences from invoiceHeader WITH (NOLOCK) where inv_pk_id = @idNotaCredito)

				update invoiceHeader
				set inv_creditNote = @idNotaCredito,
				inv_status = -1
				where inv_pk_id = @idInvoice

				select @idNotaCredito 'id',@@ROWCOUNT 'Detalles',@vpCodeOfReferences 'vpCodeOfReference'
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
	
        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

		ROLLBACK TRANSACTION;

	END CATCH

END