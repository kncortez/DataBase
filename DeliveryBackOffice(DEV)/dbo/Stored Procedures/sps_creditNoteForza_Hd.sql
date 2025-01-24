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
        FROM ConfigParams WITH (NOLOCK)
        WHERE [Name] = 'TaxPercentage'
           AND IdCountry = @IdCountry

        --CALCULOS DE MONTOS  NOTAS DE CREDITO
        SELECT @AmountNotesCredits = ISNULL(SUM(inv_amount),0)
        FROM InvoiceHeader WITH (NOLOCK)
        WHERE inv_invoiceOfCreditNote = @idInvoice
        --PRINT 'Monto de la factura: ' + CONVERT(NVARCHAR(20),@AmountINvoice) + ' Monto de las Notas de Credito: ' + CONVERT(NVARCHAR(20),@AmountNotesCredits);
        --Validación si la factura esta anulada o si el monto de la notas de crédito ya sobrepaso a la factura
        IF(@InvoideStatus <> -1 AND @AmountInvoice >= @AmountNotesCredits)
        BEGIN

        --CALCULOS DE MONTOS APLICADOS A GUIAS POR MEDIO DE NOTAS DE CREDITO
        DECLARE @GuideNoteCredit TABLE
         (
             dti_fk_orderSerie NVARCHAR(2),
             dti_fk_orderNumber INT,
             dti_amount DECIMAL(18,2),
             RemainingAmount DECIMAL(18, 2)
         );

        INSERT INTO @GuideNoteCredit (dti_fk_orderSerie, dti_fk_orderNumber, dti_amount)
        SELECT id.dti_fk_orderSerie,
               id.dti_fk_orderNumber,
               ISNULL(SUM(id.dti_amount),0) [dti_amount]
        FROM InvoiceHeader ih WITH (NOLOCK)
        INNER JOIN invoiceDetail id WITH (NOLOCK)
            ON ih.inv_pk_id = id.dti_fk_header
        WHERE inv_invoiceOfCreditNote = @idInvoice
        GROUP BY id.dti_fk_orderSerie, id.dti_fk_orderNumber;

        -- Declaración de tabla temporal para almacenar los detalles procesados
        DECLARE @InvoiceDetailProcess TABLE
        (
            dti_pk_id INT,
            dti_fk_header INT,
            dti_fk_orderSerie NVARCHAR(50),
            dti_fk_orderNumber INT,
            dti_identification NVARCHAR(50),
            dti_category NVARCHAR(50),
            dti_quantity DECIMAL(18, 2),
            dti_measurement NVARCHAR(50),
            dti_priceUnit DECIMAL(18, 2),
            dti_description NVARCHAR(255),
            dti_IVA DECIMAL(18, 2),
            dti_amount DECIMAL(18, 2),
            dti_dateRegister DATETIME,
            dti_tokenRegister NVARCHAR(50),
            SAPCode NVARCHAR(50)
        );

        -- Crear una tabla temporal para manejar el estado de las líneas procesadas
        DECLARE @TempInvoiceDetail TABLE (
            dti_fk_header INT,
            dti_fk_orderSerie NVARCHAR(50),
            dti_fk_orderNumber NVARCHAR(50),
            dti_identification NVARCHAR(50),
            dti_category NVARCHAR(50),
            dti_quantity DECIMAL(18, 5),
            dti_measurement NVARCHAR(50),
            dti_priceUnit DECIMAL(18, 5),
            dti_description NVARCHAR(MAX),
            dti_IVA DECIMAL(18, 5),
            dti_amount DECIMAL(18, 5),
            SAPCode NVARCHAR(50),
            RemainingAmount DECIMAL(18, 5),
            GuideCreditNote DECIMAL(18,5),
            IsProcessed BIT DEFAULT 0
        );

        -- Insertar datos iniciales desde invoiceDetail en la tabla temporal
        INSERT INTO @TempInvoiceDetail
        SELECT 
            id.dti_fk_header,
            id.dti_fk_orderSerie,
            id.dti_fk_orderNumber,
            id.dti_identification,
            id.dti_category,
            id.dti_quantity,
            id.dti_measurement,
            id.dti_priceUnit,
            id.dti_description,
            id.dti_IVA,
            id.dti_amount,
            id.SAPCode,
            id.dti_amount AS RemainingAmount,
            (SELECT ISNULL(dti_amount,0.00) from @GuideNoteCredit where dti_fk_orderSerie = id.dti_fk_orderSerie AND dti_fk_orderNumber = id.dti_fk_orderNumber ) discount,
            0 AS IsProcessed
        FROM invoiceDetail id WITH (NOLOCK)
        WHERE id.dti_fk_header = @idInvoice;

        -- Inserción de encabezado de la nota de crédito
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
            [inv_invoiceOfCreditNote],
            [inv_motiveCreditNote],
            [inv_dateOriginDocument],
            [inv_documentOriginFEL],
            [IdCurrency],
            [IdCountry]
        )
        SELECT [inv_vpCodeOfReferences],
               [inv_cmp_nit],
               [inv_cli_name],
               [inv_cli_adress],
               [inv_cli_nit],
               [inv_cli_email],
               GETDATE(),
               CASE WHEN @Amount > 0 THEN (@Amount - (@Amount / @IVA)) ELSE [inv_amount] END inv_IVA,
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

        -- Obtener el ID de la nota de crédito recién creada
        SET @idNotaCredito = @@IDENTITY;
        
        -- Declarar variables para iteración
        DECLARE @RemainingAmount DECIMAL(18, 2) = @Amount;
        DECLARE @LineSerie NVARCHAR(50);
        DECLARE @LineNumber INT;
        DECLARE @SAPCode nvarchar(50);
        DECLARE @LineAmount DECIMAL(18, 2);
        DECLARE @InsertAmount DECIMAL(18, 2);
        
        -- Declarar tabla temporal para evitar duplicados
        DECLARE @ProcessedLines TABLE (
            LineSerie NVARCHAR(50),
            LineNumber INT,
            SAPCode NVARCHAR(50)
        );

        -- Iterar sobre las líneas de detalle
        WHILE EXISTS (SELECT 1 FROM @TempInvoiceDetail WHERE RemainingAmount > 0 AND IsProcessed = 0 AND @RemainingAmount > 0)
        BEGIN 
            -- Seleccionar la siguiente línea con monto pendiente
            SELECT TOP 1
                @LineSerie = dti_fk_orderSerie,
                @LineNumber = dti_fk_orderNumber,
                @SAPCode = SAPCode,
                @LineAmount = ISNULL(RemainingAmount,0.00) - ISNULL(GuideCreditNote,0.00)
            FROM @TempInvoiceDetail
            WHERE IsProcessed = 0
                AND NOT EXISTS (
                    SELECT 1
                    FROM @ProcessedLines pl
                    WHERE pl.LineSerie = dti_fk_orderSerie
                      AND pl.LineNumber = dti_fk_orderNumber
                      AND pl.SAPCode = SAPCode
                )
            ORDER BY dti_fk_orderSerie, dti_fk_orderNumber, SAPCode;
            --PRINT CONVERT(NVARCHAR(25),@LineNumber);
            --PRINT CONVERT(NVARCHAR(25),@SAPCode)
            --PRINT CONVERT(NVARCHAR(25),@LineAmount);
            -- Validar si no hay más líneas por procesar
            IF @LineNumber IS NULL OR @LineAmount IS NULL OR @RemainingAmount <= 0
            BEGIN
                IF @SAPCode IS NULL OR @LineAmount IS NULL OR @RemainingAmount <= 0
                BEGIN
                    BREAK;
                END
            END;

            -- Calcular el monto a insertar
            SET @InsertAmount = CASE 
                                    WHEN @LineAmount <= @RemainingAmount THEN @LineAmount
                                    ELSE @RemainingAmount
                                END;
            -- Insertar la línea procesada en @InvoiceDetail
            INSERT INTO @InvoiceDetailProcess
            (
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
                SAPCode
            )
            SELECT
                @idNotaCredito,
                dti_fk_orderSerie,
                dti_fk_orderNumber,
                dti_identification,
                dti_category,
                1 dti_quantity,
                dti_measurement,
                CASE WHEN @Amount = 0 THEN dti_priceUnit ELSE @InsertAmount END dti_priceUnit,
                dti_description,
                CASE WHEN @Amount = 0 THEN dti_IVA ELSE @InsertAmount - (@InsertAmount/@IVA) END dti_IVA,
                CASE WHEN @Amount = 0 THEN dti_Amount ELSE @InsertAmount END dti_amount,
                GETDATE(),
                @token,
                SAPCode
            FROM @TempInvoiceDetail
            WHERE  (@LineSerie IS NOT NULL AND dti_fk_orderSerie = @LineSerie)
               AND (@LineNumber IS NOT NULL AND dti_fk_orderNumber = @LineNumber)
               AND SAPCode = @SAPCode AND @InsertAmount > 0
               OR (@LineSerie IS NULL OR @LineNumber IS NULL) AND SAPCode = @SAPCode AND @InsertAmount > 0;
        
            -- Reducir el monto restante de la línea procesada
            UPDATE @TempInvoiceDetail
            SET 
                RemainingAmount = RemainingAmount - @InsertAmount,
                IsProcessed = CASE WHEN RemainingAmount - @InsertAmount <= 0 THEN 1 ELSE 0 END
            WHERE dti_fk_orderSerie = @LineSerie 
              AND dti_fk_orderNumber = @LineNumber
              AND SAPCode = @SAPCode;
        
            -- Registrar la línea procesada para evitar duplicados
            INSERT INTO @ProcessedLines (LineSerie, LineNumber,SAPCode)
            VALUES (@LineSerie, @LineNumber,@SAPCode);
        
            -- Actualizar el monto restante global
            SET @RemainingAmount = @RemainingAmount - @InsertAmount;
        
            -- Validación para evitar valores negativos
            IF @RemainingAmount < 0
                SET @RemainingAmount = 0;
        
            -- (Opcional) Imprimir valores de depuración
            PRINT 'Processed Line: ' + @LineSerie + ' - ' + CAST(@LineNumber AS NVARCHAR(50)) + ' --   ' + CAST(@SAPCode AS NVARCHAR(50));
            PRINT 'InsertAmount: ' + CAST(@InsertAmount AS NVARCHAR(50));
            PRINT 'RemainingAmount: ' + CAST(@RemainingAmount AS NVARCHAR(50));
        END;

        -- Insertar todas las líneas procesadas en la tabla final
        INSERT INTO [dbo].[invoiceDetail]
        (
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
            SAPCode
        )
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
            SAPCode
        FROM @InvoiceDetailProcess;

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

        SET @Amount = ISNULL(@AmountNotesCredits,0.00) + @Amount;
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
               inv_serieFEL 'Serie',
               inv_numberFEL 'Correlative',
               inv_certificationFEL 'CAI'
        FROM InvoiceHeader IH WITH (NOLOCK)
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