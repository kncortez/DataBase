-- =============================================
-- Author:      <Cristian, Azurdia>
-- Create date: <2025-01-09>
-- Description: <Retorna los datos de una factura, asi como su detalle y guías>
-- =============================================
-- =============================================
-- Author:      <Brandon, Pedroza>
-- Create date: <2025-07-30>
-- Description: <Facturacion SV - Se agrega validacion para obtener información para SV>
-- =============================================

CREATE PROCEDURE [dbo].[GetInvoiceData]

    @Inv_SerieFEL NVARCHAR(200) = NULL,
    @Inv_NumberFEL NVARCHAR(200) = NULL,
    @idCountry NVARCHAR(2) = 'GT'

AS
BEGIN

DECLARE @pk_id INT = 0;
DECLARE @InvoiceBalance DECIMAL(18,2) = 0;
DECLARE @AmountNotesCredits DECIMAL(18,2) = 0;

    IF(@idCountry = 'GT')
    BEGIN

        SELECT
              @pk_id = inv_pk_id
             ,@InvoiceBalance = inv_amount
      FROM  InvoiceHeader WITH(NOLOCK)
        WHERE inv_SerieFEL = @Inv_SerieFEL
          AND inv_numberFEL = @Inv_NumberFEL
          AND IdCountry = @idCountry

    END
    ELSE IF(@idCountry = 'HN')
    BEGIN

        SELECT
              @pk_id = inv_pk_id
             ,@InvoiceBalance = inv_amount
        FROM  InvoiceHeader WITH(NOLOCK)
        WHERE inv_SerieFEL = @Inv_SerieFEL
          AND inv_certificationFEL = @Inv_NumberFEL
          AND IdCountry = @idCountry

        --CALCULOS DE MONTOS  NOTAS DE CREDITO
        SELECT @AmountNotesCredits = ISNULL(SUM(inv_amount),0)
        FROM InvoiceHeader WITH (NOLOCK)
        WHERE inv_invoiceOfCreditNote = @pk_id
           AND inv_type = 2;

       SET @InvoiceBalance = @InvoiceBalance - @AmountNotesCredits;

    END
    ELSE IF(@idCountry = 'SV')
    BEGIN

        DECLARE @TypeDocument INT = (SELECT IdRegister FROM CatTypeDocument WITH(NOLOCK) WHERE [Name] = 'Comprobante Crédito Fiscal')

        SELECT
              @pk_id = inv_pk_id
             ,@InvoiceBalance = inv_amount
        FROM  InvoiceHeader WITH (NOLOCK)
        WHERE inv_numberFEL = @Inv_NumberFEL
          AND IdCountry = @idCountry
          AND inv_type = @TypeDocument --comprobante de credito fiscal

        --CALCULOS DE MONTOS  NOTAS DE CREDITO
        SELECT @AmountNotesCredits = ISNULL(SUM(inv_amount),0)
        FROM InvoiceHeader WITH (NOLOCK)
        WHERE inv_invoiceOfCreditNote = @pk_id
           AND inv_type = 2;

       SET @InvoiceBalance = @InvoiceBalance - @AmountNotesCredits;
    END


    SELECT
            inv_pk_id
           ,inv_FechaHoraFEL
           ,inv_serieFEL
           ,inv_numberFEL
           ,inv_certificationFEL
           ,inv_amount
           ,@InvoiceBalance inv_balance
           --,*
    FROM invoiceHeader WITH(NOLOCK)
    WHERE inv_pk_id = @pk_id;

    SELECT
            dti_fk_header
           ,dti_fk_orderSerie
           ,dti_fk_orderNumber
           ,dti_amount
           --,*
    FROM invoiceDetail WITH(NOLOCK)
    WHERE dti_fk_header = @pk_id;

END