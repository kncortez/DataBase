
-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 7 Octubre 2020
-- Description:	Retorna informacion de la factura
-- =============================================
CREATE PROCEDURE [dbo].[spg_InformationInvoice]
    -- Add the parameters for the stored procedure here
    @idInvoice BIGINT
  , @IncreaseRetries BIT = 0
  , @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	IF @IdCountry = 'GT'
	BEGIN
		IF @IncreaseRetries = 1
			UPDATE ih
			SET ih.Retries += 1
			FROM invoiceHeader ih WITH (NOLOCK)
			WHERE ih.inv_pk_id = @idInvoice
			AND ih.IdCountry = @IdCountry;

		-- Insert statements for procedure here
		SELECT ih.*
		FROM [dbo].[invoiceHeader] ih WITH (NOLOCK)
		WHERE inv_pk_id = @idInvoice
			AND IdCountry = @IdCountry;

		SELECT *
		FROM [dbo].[invoiceDetail] WITH (NOLOCK)
		WHERE dti_fk_header = @idInvoice
		ORDER BY dti_dateRegister;

		SELECT TOP 1
			   io_pk_id                    'Id'
			 , CASE
				   WHEN io_type = 1 THEN
					   io_amount
				   ELSE
					   0
			   END                         cash
			 , CASE
				   WHEN io_type = 2 THEN
					   io_amount
				   ELSE
					   0
			   END                         credCard
			 , iod.io_ticket               'Ticket'
			 , io_SAPDocEntryPaymentDetail 'docEntry'
			 , del.dpf_WarehouseCode       'WarehouseCode'
		FROM InOutOfMoneyDetail              iod WITH (NOLOCK)
			INNER JOIN invoiceHeader         inh WITH (NOLOCK)
				ON iod.io_invoice = inh.inv_pk_id
			INNER JOIN invoiceDetail         ind WITH (NOLOCK)
				ON inh.inv_pk_id = ind.dti_fk_header
			LEFT JOIN CatArticleSAP          cts WITH (NOLOCK)
				ON ind.SAPCode = cts.SAPCode
			INNER JOIN del_ParametrosFactura del
				ON inh.inv_vpCodeOfReferences = del.dpf_VpCodeOfReference
		WHERE iod.io_invoice = @idInvoice
			  AND cts.RowSatus = 1
			  AND ind.SAPCode = cts.SAPCode
			  AND inh.IdCountry = @IdCountry;
	END
	ELSE 
	BEGIN
		
		IF @IncreaseRetries = 1
			UPDATE ih
			SET ih.Retries += 1
			FROM invoiceHeader ih WITH (NOLOCK)
			LEFT JOIN InvoiceBatchHeader ibh WITH (NOLOCK) ON ibh.CAI = ih.inv_serieFEL
			WHERE ih.inv_pk_id = @idInvoice
			AND ih.IdCountry = @IdCountry
			AND ibh.RowStatus = 1
			AND ibh.TypeDocument = 1;

		-- Insert statements for procedure here
		SELECT ih.*
		FROM [dbo].[invoiceHeader] ih WITH (NOLOCK)
		LEFT JOIN InvoiceBatchHeader ibh WITH (NOLOCK) ON ibh.CAI = ih.inv_serieFEL
		WHERE ih.inv_pk_id = @idInvoice
			AND ih.IdCountry = @IdCountry
			AND ibh.RowStatus = 1
			AND ibh.TypeDocument = 1;

		SELECT *
		FROM [dbo].[invoiceDetail] WITH (NOLOCK)
		WHERE dti_fk_header = @idInvoice
		ORDER BY dti_dateRegister;

		SELECT TOP 1
			   io_pk_id                    'Id'
			 , CASE
				   WHEN io_type = 1 THEN
					   io_amount
				   ELSE
					   0
			   END                         cash
			 , CASE
				   WHEN io_type = 2 THEN
					   io_amount
				   ELSE
					   0
			   END                         credCard
			 , iod.io_ticket               'Ticket'
			 , io_SAPDocEntryPaymentDetail 'docEntry'
			 , del.dpf_WarehouseCode       'WarehouseCode'
		FROM InOutOfMoneyDetail              iod WITH (NOLOCK)
			INNER JOIN invoiceHeader         inh WITH (NOLOCK)
				ON iod.io_invoice = inh.inv_pk_id
			INNER JOIN invoiceDetail         ind WITH (NOLOCK)
				ON inh.inv_pk_id = ind.dti_fk_header
			LEFT JOIN CatArticleSAP          cts WITH (NOLOCK)
				ON ind.SAPCode = cts.SAPCode
			INNER JOIN del_ParametrosFactura del
				ON inh.inv_vpCodeOfReferences = del.dpf_VpCodeOfReference
			LEFT JOIN InvoiceBatchHeader ibh WITH (NOLOCK) 
				ON ibh.CAI = inh.inv_serieFEL
		WHERE iod.io_invoice = @idInvoice
			  AND cts.RowSatus = 1
			  AND ind.SAPCode = cts.SAPCode
			  AND inh.IdCountry = @IdCountry
			  AND ibh.RowStatus = 1
			  AND ibh.TypeDocument = 1;
	END

END;
