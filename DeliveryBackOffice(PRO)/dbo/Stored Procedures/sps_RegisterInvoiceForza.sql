-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <2022-04-21>
-- Description:	<Realiza el proceso de facturación>
-- =============================================
--drop  PROCEDURE Sps_RegisterInvoiceForza
--CREATE PROCEDURE Sps_RegisterInvoiceForza

CREATE PROCEDURE sps_RegisterInvoiceForza
	 @VpCodeOfReferences int
    ,@cmp_nit varchar(100)
    ,@cli_name varchar(500)
    ,@cli_adress varchar(1000)
    ,@cli_nit varchar(100)
    ,@cli_email varchar(500)
    ,@IVA money
    ,@amount money
    ,@tokenRegister varchar(200)
	,@type int
	,@systemOrigen int = 1
	,@TblLstDetail TblLstDetail READONLY
	,@TblInOutOfMoneyDetail TblInOutOfMoneyDetail READONLY
AS
BEGIN
	--Procesando nuevo registro para tabla invoiceHeader
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @invoiceHeaderId bigint=-1;
		IF (@systemOrigen = 0)
		BEGIN
		SET @systemOrigen = (select top 1 SysIdSystem
						from DeliveryBackOffice.dbo.CatSystem
						where SysNameSystem = 'FDExpressCenter'
						)
		END
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;
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
				,[systemOperation]
				)
			VALUES
				(@VpCodeOfReferences
				,@cmp_nit
				,@cli_name
				,@cli_adress
				,@cli_nit
				,@cli_email
				,GETDATE()
				,@IVA
				,@amount
				,1
				,GETDATE()
				,@tokenRegister
				,@type
				,@systemOrigen
				)
				SET @invoiceHeaderId= @@IDENTITY --'IDENTITY'

	--Procesando nuevo registro para tabla invoiceDetail



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
		   ,[SAPCode]
		   ,[SendToInvoice])
	SELECT	@invoiceHeaderId
			,CASE WHEN LstDtl.orderNumber <= 0 THEN NULL ELSE LstDtl.orderSerie END
			,CASE WHEN LstDtl.orderNumber <= 0 THEN NULL ELSE LstDtl.orderNumber END
			,LstDtl.identification
			,LstDtl.category
			,LstDtl.quantity
			,LstDtl.measurement
			,LstDtl.priceUnit
			,LstDtl.description
			,LstDtl.IVA
			,LstDtl.amount
			,GETDATE()
			,@tokenRegister
			,LstDtl.SAPCode
			,LstDtl.SendToInvoice
		FROM @TblLstDetail LstDtl     
			--select @@ROWCOUNT 'rowCount'

	--Procesando nuevo registro para tabla InOutOfMoneyDetail
	INSERT INTO [dbo].[InOutOfMoneyDetail]
			   (
				[io_type],
				[io_vpCodeOfReferences],
				[io_ticket],
				[io_amount],
				[io_status],
				[io_invoice],
				[io_registryToken],
				[io_registryDate]
			   )
	SELECT   MD.type
			,MD.vpCodeOfReferences
			,MD.ticket
			,MD.amount
			,MD.status
			,MD.invoice
			,@tokenRegister
			,GETDATE()
	FROM @TblInOutOfMoneyDetail MD

	SELECT @invoiceHeaderId 'IDENTITY'
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