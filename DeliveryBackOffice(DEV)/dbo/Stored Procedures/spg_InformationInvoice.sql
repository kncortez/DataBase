
-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 7 Octubre 2020
-- Description:	Retorna informacion de la factura
-- =============================================
CREATE PROCEDURE [dbo].[spg_InformationInvoice]
    -- Add the parameters for the stored procedure here
    @idInvoice BIGINT
  , @IncreaseRetries BIT = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    IF @IncreaseRetries = 1
        UPDATE invoiceHeader
        SET Retries += 1
        WHERE inv_pk_id = @idInvoice;

    -- Insert statements for procedure here
    SELECT  
	     inv_pk_id,
		inv_vpCodeOfReferences,
		inv_cmp_name,
		inv_cmp_nameComercial,
		inv_cmp_adress,
		inv_cmp_nit,
		inv_cli_name,
		inv_cli_adress,
		inv_cli_nit,
		inv_cli_email,
		inv_date,
		inv_documentSend,
		inv_documentRecieved,
		inv_certificationFEL,
		inv_serieFEL,
		inv_numberFEL,
		inv_descriptionFEL,
		inv_RequestorFEL,
		inv_TransactionFEL,
		inv_CountryFEL,
		inv_EntityFEL,
		inv_UserFEL,
		inv_UserName,
		inv_Data1FEL,
		inv_Data3FEL,
		inv_MailSendFEL,
		inv_subjectFEL,
		inv_IVA,
		inv_amount,
		inv_status,
		inv_dateRegister,
		inv_tokenRegister,
		inv_dateUpdate,
		inv_tokenUpdate,
		inv_type,
		inv_invoiceOfCreditNote,
		inv_motiveCreditNote,
		inv_dateOriginDocument,
		inv_documentOriginFEL,
		inv_creditNote,
		inv_establecimientoFEL,
		inv_cmp_nameFEL,
		inv_FechaHoraFEL,
		inv_SAPDocEntry,
		inv_SAPError,
		systemOperation,
		IsManualInvoice,
		inv_dateFEL,
		CatInvoiceTypeId,
		Retries,
		IdCurrency,
		IdCountry
    FROM [dbo].[invoiceHeader] WITH (NOLOCK)
    WHERE inv_pk_id =  @idInvoice;

    SELECT 
	        dti_fk_header,
			dti_fk_orderSerie,
			dti_fk_orderNumber,
			dti_identification,
			dti_category,
			dti_quantity,
			dti_measurement,
			dti_priceUnit,
			dti_description,
			dti_IVA,
			dti_amount,
			dti_dateRegister,
			dti_tokenRegister,
			SAPCode,
			SendToInvoice,
			MembershipId,
			SubscriptionId
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
          AND ind.SAPCode = cts.SAPCode;

END;
