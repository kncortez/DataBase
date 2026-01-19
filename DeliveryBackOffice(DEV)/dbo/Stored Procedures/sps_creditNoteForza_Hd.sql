-- =============================================
-- Author:		Eduardo López
-- Create date: 26 Agosto 2022
-- Description:	Registra en base de datos local nueva nota de credito correspondiente a factura enviada
-- =============================================
-- Author:		<Brandon Pedroza>
-- Modified:	<30 Julio 2025>
-- Description:	<Facturacion SV - Se inserta registro para nota de credito y aumenta el secuencial>
-- =============================================
CREATE PROCEDURE [dbo].[sps_creditNoteForza_Hd]
    -- Add the parameters for the stored procedure here
    @idInvoice INT,
    @Amount DECIMAL(18, 2) = 0,
    @motivoNotaCredito VARCHAR(2000),
    @token VARCHAR(50),
    @TblCreditNoteData TblResponseCreditNoteSV READONLY
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @detalles AS INT;
    DECLARE @idNotaCredito AS INT = NULL;
    DECLARE @vpCodeOfReferences NVARCHAR(10);
	DECLARE @TypeDocumentCreditNote INT = (SELECT IdRegister FROM CatTypeDocument WHERE [Name] = 'Nota de crédito')
    DECLARE @Establishment         NVARCHAR(150);

    DECLARE @Country NVARCHAR(2) = 'GT';
    SET @Country =
    (
        SELECT IdCountry
        FROM DeliveryBackOffice.dbo.invoiceHeader WITH (NOLOCK)
        WHERE inv_pk_id = @idInvoice
    );

    IF (@Country = 'GT')
    BEGIN

        --codigo anterior
        --SET NOCOUNT ON;


        BEGIN TRANSACTION;
        BEGIN TRY
            -- Insert statements for procedure here
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
                   [inv_IVA],
                   [inv_amount],
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
                   [dti_quantity],
                   [dti_measurement],
                   [dti_priceUnit],
                   [dti_description],
                   [dti_IVA],
                   [dti_amount],
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
                   [io_amount],
                   [io_status],
                   @idNotaCredito,
                   @token,
                   GETDATE()
            FROM [DeliveryBackOffice].[dbo].[InOutOfMoneyDetail] WITH (NOLOCK)
            WHERE [io_invoice] = @idInvoice;


            SET @vpCodeOfReferences =
            (
                SELECT inv_vpCodeOfReferences
                FROM invoiceHeader WITH (NOLOCK)
                WHERE inv_pk_id = @idNotaCredito
            );

            UPDATE invoiceHeader
            SET inv_creditNote = @idNotaCredito,
                inv_status = -1
            WHERE inv_pk_id = @idInvoice;

            SELECT @idNotaCredito 'id',
                   @@ROWCOUNT 'Detalles',
                   @vpCodeOfReferences 'vpCodeOfReference';
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

        END CATCH;

    --codigo anterior

    END;
    ELSE
    BEGIN

        --Variables para el manejo de IVA 
        DECLARE @IdCountry AS NVARCHAR(8);
        DECLARE @IVA AS DECIMAL(18, 2) = 1.12;
        DECLARE @secuencia BIGINT, @rowcount  INT;  

        --Variables para validaciones si la factura ya fue cancelada
        DECLARE @InvoideStatus INT = 0;
        DECLARE @AmountInvoice DECIMAL(18, 2) = 0;
        DECLARE @AmountNotesCredits DECIMAL(18, 2) = 0;

        ----Variables para la generacion de la nota de credito
        --DECLARE @idNotaCredito AS INT = NULL;
        --DECLARE @vpCodeOfReferences NVARCHAR(10);

        BEGIN TRANSACTION;
        BEGIN TRY

            --CACULO DEL IVA
            SELECT @IdCountry = IdCountry,
                   @AmountInvoice = inv_amount,
                   @InvoideStatus = inv_status
            FROM invoiceHeader WITH (NOLOCK)
            WHERE inv_pk_id = @idInvoice;

            SELECT @IVA = ISNULL([Value], 1.12)
            FROM ConfigParams WITH (NOLOCK)
            WHERE [Name] = 'TaxPercentage'
                  AND IdCountry = @IdCountry;

            --CALCULOS DE MONTOS  NOTAS DE CREDITO
            SELECT @AmountNotesCredits = ISNULL(SUM(inv_amount), 0)
            FROM invoiceHeader WITH (NOLOCK)
            WHERE inv_invoiceOfCreditNote = @idInvoice
                  AND inv_type = 2;
            --PRINT 'Monto de la factura: ' + CONVERT(NVARCHAR(20),@AmountINvoice) + ' Monto de las Notas de Credito: ' + CONVERT(NVARCHAR(20),@AmountNotesCredits);
            --Validación si la factura esta anulada o si el monto de la notas de crédito ya sobrepaso a la factura
            IF (@InvoideStatus <> -1 AND @AmountInvoice >= @AmountNotesCredits)
            BEGIN

                --CALCULOS DE MONTOS APLICADOS A GUIAS POR MEDIO DE NOTAS DE CREDITO
                DECLARE @GuideNoteCredit TABLE
                (
                    dti_fk_orderSerie NVARCHAR(2),
                    dti_fk_orderNumber INT,
                    dti_amount DECIMAL(18, 2),
                    RemainingAmount DECIMAL(18, 2)
                );

                INSERT INTO @GuideNoteCredit
                (
                    dti_fk_orderSerie,
                    dti_fk_orderNumber,
                    dti_amount
                )
                SELECT id.dti_fk_orderSerie,
                       id.dti_fk_orderNumber,
                       ISNULL(SUM(id.dti_amount), 0) [dti_amount]
                FROM invoiceHeader ih WITH (NOLOCK)
                    INNER JOIN invoiceDetail id WITH (NOLOCK)
                        ON ih.inv_pk_id = id.dti_fk_header
                WHERE inv_invoiceOfCreditNote = @idInvoice
                GROUP BY id.dti_fk_orderSerie,
                         id.dti_fk_orderNumber;

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
                DECLARE @TempInvoiceDetail TABLE
                (
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
                    GuideCreditNote DECIMAL(18, 5),
                    IsProcessed BIT
                        DEFAULT 0
                );

                -- Insertar datos iniciales desde invoiceDetail en la tabla temporal
                INSERT INTO @TempInvoiceDetail
                SELECT id.dti_fk_header,
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
                       (
                           SELECT ISNULL(dti_amount, 0.00)
                           FROM @GuideNoteCredit
                           WHERE dti_fk_orderSerie = id.dti_fk_orderSerie
                                 AND dti_fk_orderNumber = id.dti_fk_orderNumber
                       ) discount,
                       0 AS IsProcessed
                FROM invoiceDetail id WITH (NOLOCK)
                WHERE id.dti_fk_header = @idInvoice;

                -- Inserción de encabezado de la nota de crédito
                IF(@IdCountry = 'SV')
                BEGIN 
                    INSERT INTO [dbo].[invoiceHeader]
                    (
                        [inv_vpCodeOfReferences],
                        [inv_cmp_nit],
                        [inv_cmp_name],
                        [inv_cmp_nameComercial],
                        [inv_cmp_adress],
                        [inv_cli_name],
                        [inv_cli_adress],
                        [inv_cli_nit],
                        [inv_cli_email],
                        [inv_date],
                        [inv_documentSend],
                        [inv_documentRecieved],
                        [inv_certificationFEL],
                        [inv_serieFEL],
                        [inv_numberFEL],
                        [inv_descriptionFEL],
                        [inv_RequestorFEL],
                        [inv_TransactionFEL],
                        [inv_CountryFEL],
                        [inv_EntityFEL],
                        [inv_UserFEL],
                        [inv_UserName],
                        [inv_Data1FEL],
                        [inv_Data3FEL],
                        [inv_MailSendFEL],
                        [inv_subjectFEL],
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
                        [inv_establecimientoFEL],
                        [inv_cmp_nameFEL],
                        [inv_FechaHoraFEL],
                        [systemOperation],
                        [inv_dateFEL],
                        [CatInvoiceTypeId],
                        [IdCurrency],
                        [IdCountry]
                    )
                    SELECT [ih].[inv_vpCodeOfReferences],
                           [ih].[inv_cmp_nit],
                           [ih].[inv_cmp_name],
                           [ih].[inv_cmp_nameComercial],
                           [ih].[inv_cmp_adress],
                           [ih].[inv_cli_name],
                           [ih].[inv_cli_adress],
                           [ih].[inv_cli_nit],
                           [ih].[inv_cli_email],
                           GETDATE(),
                           [ih].[inv_documentSend],
                           cn.[ResponesJson],
                           cn.[CertificationFel],
                           cn.[Serial],
                           cn.[NumberFel],
                           [ih].[inv_descriptionFEL],
                           [ih].[inv_RequestorFEL],
                           [ih].[inv_TransactionFEL],
                           [ih].[inv_CountryFEL],
                           [ih].[inv_EntityFEL],
                           [ih].[inv_UserFEL],
                           [ih].[inv_UserName],
                           [ih].[inv_Data1FEL],
                           [ih].[inv_Data3FEL],
                           [ih].[inv_MailSendFEL],
                           [ih].[inv_subjectFEL],
                           CASE
                               WHEN @Amount > 0 THEN
                           (@Amount - (@Amount / @IVA))
                               ELSE
                                   [ih].[inv_amount]
                           END inv_IVA,
                           CASE
                               WHEN @Amount > 0 THEN
                                   @Amount
                               ELSE
                                   [ih].[inv_amount]
                           END inv_amount,
                           2,
                           GETDATE(),
                           @token,
                           @TypeDocumentCreditNote,
                           @idInvoice,
                           @motivoNotaCredito,
                           [ih].inv_date,
                           [ih].inv_certificationFEL,
                           [ih].[inv_establecimientoFEL],
                           [ih].[inv_cmp_nameFEL],
                           cn.IssueDate,
                           [ih].[systemOperation],
                           GETDATE(),
                           [ih].[CatInvoiceTypeId],
                           [ih].IdCurrency,
                           [ih].IdCountry
                    FROM invoiceHeader ih WITH (NOLOCK)
                          INNER JOIN @TblCreditNoteData cn
                          ON ih.inv_pk_id = cn.InvoiceId
                    WHERE inv_pk_id = @idInvoice;

                    SET @rowcount = @@rowcount  
  
                    IF(@rowcount > 0)  
                    BEGIN   
                          SELECT @vpCodeOfReferences = ih.inv_vpCodeOfReferences 
                           FROM invoiceHeader ih WITH (NOLOCK)
                          WHERE inv_pk_id = @idInvoice;

                        SELECT @Establishment = [Value]
                          FROM DeliveryBackOffice.dbo.AddInfoByCodeOfReference WITH (NOLOCK)
                         WHERE RowStatus = 1
                           AND CodeOfReference = @vpCodeOfReferences
                           AND [Name] = 'CodEstablecimientoMH'

                        SELECT @secuencia = CAST(A1.[Sequence] AS INT)
                          FROM dbo.InvoiceSequenceByEstablishment A1 WITH (NOLOCK)
                         WHERE A1.RowStatus = 1
                           AND A1.Establishment = @Establishment
                           AND A1.TypeDocument = 2

                        UPDATE DeliveryBackOffice.dbo.InvoiceSequenceByEstablishment
                           SET [Sequence] = @secuencia + 1
                         WHERE RowStatus = 1
                           AND TypeDocument = 2
                           AND Establishment = @Establishment
                    END  
                END
                ELSE
                BEGIN
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
                           CASE
                               WHEN @Amount > 0 THEN
                           (@Amount - (@Amount / @IVA))
                               ELSE
                                   [inv_amount]
                           END inv_IVA,
                           CASE
                               WHEN @Amount > 0 THEN
                                   @Amount
                               ELSE
                                   [inv_amount]
                           END inv_amount,
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
                END

                -- Obtener el ID de la nota de crédito recién creada
                SET @idNotaCredito = @@IDENTITY;

                -- Declarar variables para iteración
                DECLARE @RemainingAmount DECIMAL(18, 2) = @Amount;
                DECLARE @LineSerie NVARCHAR(50);
                DECLARE @LineNumber INT;
                DECLARE @SAPCode NVARCHAR(50);
                DECLARE @LineAmount DECIMAL(18, 2);
                DECLARE @InsertAmount DECIMAL(18, 2);

                -- Declarar tabla temporal para evitar duplicados
                DECLARE @ProcessedLines TABLE
                (
                    LineSerie NVARCHAR(50),
                    LineNumber INT,
                    SAPCode NVARCHAR(50)
                );

                -- Iterar sobre las líneas de detalle
                WHILE EXISTS
            (
                SELECT 1
                FROM @TempInvoiceDetail
                WHERE RemainingAmount > 0
                      AND IsProcessed = 0
                      AND @RemainingAmount > 0
            )
                BEGIN
                    -- Seleccionar la siguiente línea con monto pendiente
                    SELECT TOP 1
                           @LineSerie = dti_fk_orderSerie,
                           @LineNumber = dti_fk_orderNumber,
                           @SAPCode = SAPCode,
                           @LineAmount = ISNULL(RemainingAmount, 0.00) - ISNULL(GuideCreditNote, 0.00)
                    FROM @TempInvoiceDetail
                    WHERE IsProcessed = 0
                          AND NOT EXISTS
                    (
                        SELECT 1
                        FROM @ProcessedLines pl
                        WHERE pl.LineSerie = dti_fk_orderSerie
                              AND pl.LineNumber = dti_fk_orderNumber
                              AND pl.SAPCode = SAPCode
                    )
                    ORDER BY dti_fk_orderSerie,
                             dti_fk_orderNumber,
                             SAPCode;
                    --PRINT CONVERT(NVARCHAR(25),@LineNumber);
                    --PRINT CONVERT(NVARCHAR(25),@SAPCode)
                    --PRINT CONVERT(NVARCHAR(25),@LineAmount);
                    -- Validar si no hay más líneas por procesar
                    IF @LineNumber IS NULL
                       OR @LineAmount IS NULL
                       OR @RemainingAmount <= 0
                    BEGIN
                        IF @SAPCode IS NULL
                           OR @LineAmount IS NULL
                           OR @RemainingAmount <= 0
                        BEGIN
                            BREAK;
                        END;
                    END;

                    -- Calcular el monto a insertar
                    SET @InsertAmount = CASE
                                            WHEN @LineAmount <= @RemainingAmount THEN
                                                @LineAmount
                                            ELSE
                                                @RemainingAmount
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
                    SELECT @idNotaCredito,
                           dti_fk_orderSerie,
                           dti_fk_orderNumber,
                           dti_identification,
                           dti_category,
                           1 dti_quantity,
                           dti_measurement,
                           CASE
                               WHEN @Amount = 0 THEN
                                   dti_priceUnit
                               ELSE
                                   @InsertAmount
                           END dti_priceUnit,
                           dti_description,
                           CASE
                               WHEN @Amount = 0 THEN
                                   dti_IVA
                               ELSE
                                   @InsertAmount - (@InsertAmount / @IVA)
                           END dti_IVA,
                           CASE
                               WHEN @Amount = 0 THEN
                                   dti_amount
                               ELSE
                                   @InsertAmount
                           END dti_amount,
                           GETDATE(),
                           @token,
                           SAPCode
                    FROM @TempInvoiceDetail
                    WHERE (
                              @LineSerie IS NOT NULL
                              AND dti_fk_orderSerie = @LineSerie
                          )
                          AND
                          (
                              @LineNumber IS NOT NULL
                              AND dti_fk_orderNumber = @LineNumber
                          )
                          AND SAPCode = @SAPCode
                          AND @InsertAmount > 0
                          OR (
                                 @LineSerie IS NULL
                                 OR @LineNumber IS NULL
                             )
                             AND SAPCode = @SAPCode
                             AND @InsertAmount > 0;

                    -- Reducir el monto restante de la línea procesada
                    UPDATE @TempInvoiceDetail
                    SET RemainingAmount = RemainingAmount - @InsertAmount,
                        IsProcessed = CASE
                                          WHEN RemainingAmount - @InsertAmount <= 0 THEN
                                              1
                                          ELSE
                                              0
                                      END
                    WHERE dti_fk_orderSerie = @LineSerie
                          AND dti_fk_orderNumber = @LineNumber
                          AND SAPCode = @SAPCode;

                    -- Registrar la línea procesada para evitar duplicados
                    INSERT INTO @ProcessedLines
                    (
                        LineSerie,
                        LineNumber,
                        SAPCode
                    )
                    VALUES
                    (@LineSerie, @LineNumber, @SAPCode);

                    -- Actualizar el monto restante global
                    SET @RemainingAmount = @RemainingAmount - @InsertAmount;

                    -- Validación para evitar valores negativos
                    IF @RemainingAmount < 0
                        SET @RemainingAmount = 0;

                    -- (Opcional) Imprimir valores de depuración
                    PRINT 'Processed Line: ' + @LineSerie + ' - ' + CAST(@LineNumber AS NVARCHAR(50)) + ' --   '
                          + CAST(@SAPCode AS NVARCHAR(50));
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
                SELECT dti_fk_header,
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
                       CASE
                           WHEN @Amount > 0 THEN
                               @Amount
                           ELSE
                               [io_amount]
                       END io_amount,
                       [io_status],
                       @idNotaCredito,
                       @token,
                       GETDATE()
                FROM [DeliveryBackOffice].[dbo].[InOutOfMoneyDetail] WITH (NOLOCK)
                WHERE [io_invoice] = @idInvoice;

                --DECLARE @detalles AS INT = @@ROWCOUNT;
                SET @detalles = @@ROWCOUNT;
                SET @vpCodeOfReferences =
                (
                    SELECT inv_vpCodeOfReferences
                    FROM invoiceHeader WITH (NOLOCK)
                    WHERE inv_pk_id = @idNotaCredito
                );

                SET @Amount = ISNULL(@AmountNotesCredits, 0.00) + @Amount;
                IF (@AmountInvoice = @Amount)
                BEGIN
                    UPDATE invoiceHeader
                    SET inv_creditNote = @idNotaCredito,
                        inv_status = -1
                    WHERE inv_pk_id = @idInvoice;
                END;

                SELECT @idNotaCredito 'id',
                       @@ROWCOUNT 'Detalles',
                       @vpCodeOfReferences 'vpCodeOfReference',
                       inv_serieFEL 'Serie',
                       inv_numberFEL 'Correlative',
                       inv_certificationFEL 'CAI'
                FROM invoiceHeader IH WITH (NOLOCK)
                WHERE inv_pk_id = @idNotaCredito;

                COMMIT TRANSACTION;

            END;
            ELSE
            BEGIN
                SELECT 0 'id',
                       0 'Detalles',
                       0 'vpCodeOfReference',
                       0 'Correlative';
                COMMIT TRANSACTION;
            END;

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

END;