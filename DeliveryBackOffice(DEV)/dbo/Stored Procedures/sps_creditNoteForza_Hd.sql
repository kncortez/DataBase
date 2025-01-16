-- =============================================
-- Author:		Eduardo López
-- Create date: 26 Agosto 2022
-- Description:	Registra en base de datos local nueva nota de credito correspondiente a factura enviada
-- =============================================
CREATE PROCEDURE [dbo].[sps_creditNoteForza_Hd]
	-- Add the parameters for the stored procedure here
    @idInvoice INT,
    @Amount Decimal(18,2) = 0,
    @motivoNotaCredito VARCHAR(2000),
    @token VARCHAR(50)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Variables para el manejo de IVA 
    DECLARE @IdCountry AS NVARCHAR(8);
    DECLARE @IVA AS DECIMAL(18,2)= 1.12;

    --Variables para validaciones si la factura ya fue cancelada
    DECLARE @InvoideStatus INT = 0;
    DECLARE @AmountInvoice DECIMAL(18,2) = 0;
    DECLARE @AmountNotesCredits DECIMAL(18,2) = 0;

    --Variables para la generacion de la nota de credito
    DECLARE @idNotaCredito AS INT = NULL;
    DECLARE @vpCodeOfReferences NVARCHAR(10);

    BEGIN TRANSACTION;
    BEGIN TRY

        --CACULO DEL IVA
        SELECT @IdCountry = IdCountry,
               @AmountInvoice = inv_amount,
               @InvoideStatus = inv_status
        FROM invoiceHeader WITH (NOLOCK)
        WHERE inv_pk_id = @idInvoice;

        SELECT @Iva = ISNULL([Value],1.12)
          FROM ConfigParams
        WHERE [Name] = 'TaxPercentage'
           AND IdCountry = @IdCountry

        --CALCULOS DE MONTOS  NOTAS DE CREDITO
        SELECT @AmountNotesCredits = SUM(ISNULL(inv_amount,0))
        FROM InvoiceHeader
        WHERE inv_invoiceOfCreditNote = @idInvoice

        IF(@InvoideStatus <> -1 AND @AmountInvoice >= @AmountNotesCredits)
        BEGIN
            -- Inserción del encabezado de la nota de créditos
            INSERT INTO [dbo].[invoiceHeader]
            (
                [inv_vpCodeOfReferences],
                [inv_cmp_nit],
                [inv_cli_name],
                [inv_cli_adress],
                [inv_cli_nit],
                [inv_cli_email],
                [inv_date],
                [inv_IVA],
                [inv_amount],
                [inv_status],
                [inv_dateRegister],
                [inv_tokenRegister],
                [inv_type],
                inv_invoiceOfCreditNote,
                inv_motiveCreditNote,
                inv_dateOriginDocument,
                inv_documentOriginFEL,
                IdCurrency,
                IdCountry
            )
            SELECT [inv_vpCodeOfReferences],
                   [inv_cmp_nit],
                   [inv_cli_name],
                   [inv_cli_adress],
                   [inv_cli_nit],
                   [inv_cli_email],
                   GETDATE(),
                   CASE WHEN @Amount > 0 THEN (@Amount - (@Amount/@IVA)) ELSE [inv_amount] END inv_IVA,
                   CASE WHEN @Amount > 0 THEN @Amount ELSE [inv_amount] END inv_amount,
                   [inv_status],
                   GETDATE(),
                   @token,
                   2,
                   @idInvoice,
                   @motivoNotaCredito,
                   inv_date,
                   inv_certificationFEL,
                   IdCurrency,
                   IdCountry
            FROM invoiceHeader WITH (NOLOCK)
            WHERE inv_pk_id = @idInvoice;

            --Obteer pk de la nota de credito recien creada
            SET @idNotaCredito = @@IDENTITY;

            INSERT INTO [dbo].[invoiceDetail]
            (
                [dti_fk_header],
                [dti_fk_orderSerie],
                [dti_fk_orderNumber],
                [dti_identification],
                [dti_category],
                [dti_quantity],
                [dti_measurement],
                [dti_priceUnit],
                [dti_description],
                [dti_IVA],
                [dti_amount],
                [dti_dateRegister],
                [dti_tokenRegister],
                [SAPCode]
            )
            SELECT @idNotaCredito,
                   [dti_fk_orderSerie],
                   [dti_fk_orderNumber],
                   [dti_identification],
                   [dti_category],
                   1 [dti_quantity],
                   [dti_measurement],
                   CASE WHEN @Amount > 0 THEN @Amount ELSE [dti_priceUnit] END dti_priceUnit,
                   [dti_description],
                   CASE WHEN @Amount > 0 THEN (@Amount - (@Amount/@IVA)) ELSE [dti_IVA] END dti_IVA,
                   CASE WHEN @Amount > 0 THEN @Amount ELSE [dti_amount] END dti_amount,
                   GETDATE(),
                   @token,
                   [SAPCode]
            FROM [DeliveryBackOffice].[dbo].[invoiceDetail] WITH (NOLOCK)
            WHERE [dti_fk_header] = @idInvoice;

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
            SELECT [io_type],
                   [io_vpCodeOfReferences],
                   [io_ticket],
                   CASE WHEN @Amount > 0 THEN @Amount ELSE [io_amount] END io_amount,
                   [io_status],
                   @idNotaCredito,
                   @token,
                   GETDATE()
            FROM [DeliveryBackOffice].[dbo].[InOutOfMoneyDetail] WITH (NOLOCK)
            WHERE [io_invoice] = @idInvoice;

            DECLARE @detalles AS INT = @@rowcount;
            SET @vpCodeOfReferences =
            (
                SELECT inv_vpCodeOfReferences
                FROM invoiceHeader WITH (NOLOCK)
                WHERE inv_pk_id = @idNotaCredito
            );

            SET @Amount = @AmountNotesCredits + @Amount;
            IF(@AmountInvoice = @Amount)
            BEGIN
                UPDATE invoiceHeader
                SET inv_creditNote = @idNotaCredito,
                    inv_status = -1
                WHERE inv_pk_id = @idInvoice;
            END

            SELECT @idNotaCredito 'id',
                   @@ROWCOUNT 'Detalles',
                   @vpCodeOfReferences 'vpCodeOfReference',
                   inv_numberFEL 'Correlative'
            FROM InvoiceHeader IH
            WHERE inv_pk_id = @idNotaCredito;

            COMMIT TRANSACTION;
        END
        ELSE
        BEGIN
            SELECT 0'id',
                   0 'Detalles',
                   0 'vpCodeOfReference',
                   0'Correlative'
            COMMIT TRANSACTION;
        END

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

    END CATCH;

END;