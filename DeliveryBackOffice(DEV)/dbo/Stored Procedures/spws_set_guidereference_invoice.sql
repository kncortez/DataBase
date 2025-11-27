
-- ==========================================================================
-- Author:		<César,Aquino>
-- Create date: <2021-06-03>
-- Description:	<Registra facturas a una factura generada>
-- ==========================================================================
CREATE PROCEDURE [dbo].[spws_set_guidereference_invoice]
    @InGuides VARCHAR(MAX),
    @IdInvoice INT
AS
BEGIN
    IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
        DROP TABLE #listGuides;

    -- Crear la tabla con estructura definida primero
    CREATE TABLE #listGuides
    (
        ItemSerie VARCHAR(2),
        ItemNumber VARCHAR(15)
    );

    -- Insertar datos solo si @InGuides no está vacío
    IF LTRIM(RTRIM(@InGuides)) <> ''
    BEGIN
        INSERT INTO #listGuides
        SELECT DISTINCT
               SUBSTRING(Item, 1, 2) ItemSerie,
               SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',');
    END;
    ELSE
    BEGIN
        -- Insertar al menos una fila con valores por defecto
        INSERT INTO #listGuides
        (
            ItemSerie,
            ItemNumber
        )
        SELECT 'FD' ItemSerie,
               '0' ItemNumber		
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',');
    END;

    CREATE NONCLUSTERED INDEX tempSerie
    ON #listGuides (
                       ItemSerie,
                       ItemNumber
                   );

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
        [dti_tokenRegister]
    )
    SELECT TOP 1
           @IdInvoice,
           ls.ItemSerie,
           ls.ItemNumber,
           iv.dti_identification,
           iv.dti_category,
           iv.dti_quantity,
           iv.dti_measurement,
           0, -- price
           CONCAT('TRANSPORTE PAQ. GUIA ', ls.ItemSerie, ls.ItemNumber),
           0,
           0, -- amount
           GETDATE(),
           iv.dti_tokenRegister
    FROM #listGuides ls
        LEFT JOIN dbo.invoiceDetail iv WITH (NOLOCK)
            ON iv.dti_fk_header = @IdInvoice
        LEFT JOIN dbo.invoiceDetail id WITH (NOLOCK)
            ON id.dti_fk_orderSerie = ls.ItemSerie
               AND id.dti_fk_orderNumber = ls.ItemNumber
    WHERE id.dti_fk_header IS NULL;
END;
