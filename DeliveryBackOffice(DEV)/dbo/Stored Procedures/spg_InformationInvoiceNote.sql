-- =============================================
-- Author:		Eduardo López
-- Create date: 22 Agost 2022
-- Description:	Retorna informacion de la factura para la creacion de Nota de Credito
-- =============================================
CREATE procedure [dbo].[spg_InformationInvoiceNote]
    -- Add the parameters for the stored procedure here
    @fel nvarchar(100)
as
declare @idinvoice int;
begin
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    set nocount on;

    set @idinvoice =
    (
        select inv_pk_id
        from [dbo].[invoiceHeader] with (nolock)
        where inv_certificationFEL = @fel
    );
    -- Insert statements for procedure here
    select [inv_pk_id]
         , [inv_vpCodeOfReferences]
         , [inv_cmp_name]
         , [inv_cmp_nameComercial]
         , [inv_cmp_adress]
         , [inv_cmp_nit]
         , [inv_cli_name]
         , [inv_cli_adress]
         , [inv_cli_nit]
         , [inv_cli_email]
         , [inv_date]
         , [inv_documentSend]
         , [inv_documentRecieved]
         , [inv_certificationFEL]
         , [inv_serieFEL]
         , [inv_numberFEL]
         , [inv_descriptionFEL]
         , [inv_RequestorFEL]
         , [inv_TransactionFEL]
         , [inv_CountryFEL]
         , [inv_EntityFEL]
         , [inv_UserFEL]
         , [inv_UserName]
         , [inv_Data1FEL]
         , [inv_Data3FEL]
         , [inv_MailSendFEL]
         , [inv_subjectFEL]
         , [inv_IVA]
         , [inv_amount]
         , [inv_status]
         , [inv_dateRegister]
         , [inv_tokenRegister]
         , [inv_dateUpdate]
         , [inv_tokenUpdate]
         , [inv_type]
         , [inv_invoiceOfCreditNote]
         , [inv_motiveCreditNote]
         , [inv_dateOriginDocument]
         , [inv_documentOriginFEL]
         , [inv_creditNote]
         , [inv_establecimientoFEL]
         , [inv_cmp_nameFEL]
         , [inv_FechaHoraFEL]
         , [inv_SAPDocEntry]
         , [inv_SAPError]
         , [systemOperation]
         , [IsManualInvoice]
         , [inv_dateFEL]
    from [dbo].[invoiceHeader] with (nolock)
    where inv_pk_id = @idinvoice;

    select ivd.[dti_fk_header]
         , ivd.[dti_fk_orderSerie]
         , isnull(ivd.dti_fk_orderNumber, 0) as dti_fk_orderNumber
         , ivd.[dti_identification]
         , ivd.[dti_category]
         , ivd.[dti_quantity]
         , ivd.[dti_measurement]
         , ivd.[dti_priceUnit]
         , ivd.[dti_description]
         , ivd.[dti_IVA]
         , ivd.[dti_amount]
         , ivd.[dti_dateRegister]
         , ivd.[dti_tokenRegister]
         , ivd.[SAPCode]
         , ivd.[SendToInvoice]
         --, isnull(do.StatusOrderId, 0)       as StatusOrderId
         , 7       as StatusOrderId
    from [dbo].[invoiceDetail]  ivd with (nolock)
        left join DeliveryOrder do with (nolock)
            on ivd.dti_fk_orderNumber = do.Guide_Number
    where dti_fk_header = @idinvoice
    order by dti_dateRegister;

    select io_pk_id                    'Id'
         , case
               when io_type = 1 then
                   io_amount
               else
                   0
           end                         cash
         , case
               when io_type = 2 then
                   io_amount
               else
                   0
           end                         credCard
         , iod.io_ticket               'Ticket'
         , io_SAPDocEntryPaymentDetail 'docEntry'
    from InOutOfMoneyDetail iod with (nolock)
    where io_invoice = @idinvoice;
end;