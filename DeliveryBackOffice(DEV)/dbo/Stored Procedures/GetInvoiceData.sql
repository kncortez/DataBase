-- =============================================
-- Author:      <Cristian, Azurdia>
-- Create date: <2025-01-09>
-- Description: <Retorna los datos de una factura, asi como su detalle y guías>
-- =============================================
ALTER PROCEDURE [dbo].[GetInvoiceData]

    @Inv_SerieFEL NVARCHAR(200) = NULL,
    @Inv_NumberFEL NVARCHAR(200) = NULL,
    @idCountry NVARCHAR(2) = 'GT'

AS
BEGIN

DECLARE @pk_id INT = 0;

    IF(@idCountry = 'GT')
    BEGIN
        SELECT
              @pk_id = inv_pk_id
        FROM  InvoiceHeader
        WHERE inv_SerieFEL = @Inv_SerieFEL
          AND inv_numberFEL = @Inv_NumberFEL
          AND IdCountry = @idCountry
    END
    ELSE IF(@idCountry = 'HN')
    BEGIN
        SELECT
              @pk_id = inv_pk_id
        FROM  InvoiceHeader
        WHERE inv_SerieFEL = @Inv_SerieFEL
          AND inv_certificationFEL = @Inv_NumberFEL
          AND IdCountry = @idCountry
    END

    SELECT
            inv_pk_id
           ,inv_FechaHoraFEL
           ,inv_serieFEL
           ,inv_numberFEL
           ,inv_certificationFEL
           ,inv_amount
           --,*
    FROM invoiceHeader 
    WHERE inv_pk_id = @pk_id;

    SELECT
            dti_fk_header
           ,dti_fk_orderSerie
           ,dti_fk_orderNumber
           ,dti_amount
           --,*
    FROM invoiceDetail
    WHERE dti_fk_header = @pk_id;

END