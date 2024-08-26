-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-08-07>
-- Description: <Genera la informacion para el detalle de la factura>
-- =============================================
CREATE PROCEDURE [dbo].[spGetDetailInvoice]
(
 @IdInvoice          BIGINT,      -- Id de factura
 @CorrelativeInvoice NVARCHAR(15) -- Id de correlativo asignado a la factura
)
AS
BEGIN
   SELECT ROW_NUMBER() OVER(ORDER BY invDet.dti_description) [row_number],
          SUM(invDet.dti_quantity) dti_quantity,
          invDet.dti_description,
          invDet.dti_priceUnit,
          SUM(invDet.dti_amount) AS dti_amount,
          MAX(curr.Symbol) AS currency
     FROM invoiceHeader invH WITH(NOLOCK)
          INNER JOIN invoiceDetail invDet WITH(NOLOCK)
                 ON invH.inv_pk_id = invDet.dti_fk_header
          LEFT JOIN CatCurrencyCOD curr WITH(NOLOCK)
                 ON curr.IdCatCurrencyCOD = invH.IdCurrency
    WHERE invH.inv_numberFEL = @CorrelativeInvoice
      AND invH.inv_pk_id = @IdInvoice
    GROUP BY invDet.dti_description, invDet.dti_priceUnit
    ORDER BY invDet.dti_description, invDet.dti_priceUnit DESC
END
