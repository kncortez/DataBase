-- =============================================
-- Author:      <Cristian, Azurdia>
-- Create date: <2025-01-09>
-- Description: <Retorna los datos de una factura, en base al codigo del cliente que se envía>
-- =============================================
CREATE PROCEDURE [dbo].[GetInvoiceListByClient]

    @ID NVARCHAR(16) = NULL,
    @SAPCardCode   BIT = 0, --POR DEFECTO USARA EL CODIGO DE USUARIO
    @IdCountry NVARCHAR(2) = 'GT'

AS
BEGIN

    IF(@SAPCardCode = 0)
    BEGIN
        IF NOT EXISTS(SELECT 1 FROM Customer WHERE idCustomer  = @ID)
        BEGIN
            SELECT 0 [Code], 'Cliente no existe' [Message];
            RETURN;
        END
    END
    ELSE
    BEGIN
       IF NOT EXISTS(SELECT 1 FROM Customer WHERE SAPCardCode  = @ID)
       BEGIN
           SELECT 0 [Code], 'Cliente no existe' [Message];
           RETURN;
       END
    END

    SELECT 1 [Code], 'Cliente si existe' [Message];

    SELECT INH.inv_pk_id
          ,MIN(INH.inv_serieFEL)       inv_serieFEL
          ,MIN(INH.inv_numberFEL)      inv_numberFEL
          ,MIN(INH.inv_amount)         inv_amount
          ,(MIN(INH.inv_amount) - MIN(NCI.AmountNotesCredits)) inv_balance
          ,MIN(INH.inv_descriptionFEL) inv_descriptionFEL
    FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
    INNER JOIN
    (
        SELECT  MIN(INH.inv_pk_id) inv_pk_id
               ,MIN(INH.inv_FechaHoraFel) inv_FechaHoralFel
               ,MIN(INH.inv_serieFEL) inv_serieFEL
               ,MIN(INH.inv_numberFEL) inv_numberFEL
               ,MIN(inh.inv_certificationFEL) inv_certificationFEL
               ,MIN(INH.inv_cli_nit) inv_cli_nit
               ,MIN(INH.inv_amount) inv_amount
               ,MIN(INH.inv_descriptionFEL) inv_descriptionFEL
               ,MIN(INH.inv_cli_name) inv_cli_name
               ,MIN(INH.inv_SAPDocEntry) inv_SAPDocEntry
               ,MIN(INH.systemOperation) systemOperation
               ,MAX(IIF(inh.IsManualInvoice IS NULL,0,IIF(INH.IsManualInvoice=1,1,0))) IsManualInvoice
               ,MIN(IND.dti_fk_header) dti_fk_header
               ,IND.dti_fk_orderSerie dti_fk_orderSerie
               ,IND.dti_fk_orderNumber dti_fk_orderNumber
        FROM DeliveryBackOffice.dbo.invoiceDetail IND WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
                ON IND.dti_fk_header = INH.inv_pk_id
                  AND INH.inv_certificationFEL IS NOT NULL
                  AND INH.inv_creditNote IS NULL
                  AND INH.inv_motiveCreditNote IS NULL
        GROUP BY IND.dti_fk_orderSerie,
                 IND.dti_fk_orderNumber
    ) INH
        ON INH.dti_fk_orderSerie = DOR.Guide_Serie
        AND INH.dti_fk_orderNumber = DOR.Guide_Number
    OUTER APPLY(
        --CALCULOS DE MONTOS  NOTAS DE CREDITO
        SELECT ISNULL(SUM(inv_amount),0) AmountNotesCredits
        FROM InvoiceHeader WITH (NOLOCK)
        WHERE inv_invoiceOfCreditNote = INH.inv_pk_id
           AND inv_type = 2
    ) NCI
    WHERE DOR.IdCustomer = @ID
      AND DOR.SenderCountryId = @IdCountry 
      AND DOR.DateCreated > '2025-01-25'
      AND DOR.DateCreated < '2025-01-31'
    GROUP BY INH.inv_pk_id
    ORDER BY INH.inv_pk_id

END