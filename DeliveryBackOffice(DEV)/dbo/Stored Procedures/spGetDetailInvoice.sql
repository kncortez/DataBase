
CREATE PROCEDURE [dbo].[spGetDetailInvoice]
(
@IdInvoice          BIGINT,
@CorrelativeInvoice NVARCHAR(15)
)
AS
BEGIN
--AS
--BEGIN
   --SELECT @IdInvoice = 3747459,
   --       @CorrelativeInvoice = '113034'

   SELECT invDet.dti_quantity,
          invDet.dti_description,
          invDet.dti_priceUnit,
          invDet.dti_amount,
          curr.Symbol AS currency
     FROM invoiceHeader invH WITH(NOLOCK)
          LEFT JOIN invoiceDetail invDet WITH(NOLOCK)
                 ON invH.inv_pk_id = invDet.dti_fk_header
          LEFT JOIN DeliveryOrder do WITH(NOLOCK)
                 ON do.Guide_Serie  = invDet.dti_fk_orderSerie
                AND do.Guide_Number = invDet.dti_fk_orderNumber
          LEFT JOIN Cost cs WITH(NOLOCK)
                 ON do.Guide_Serie  = cs.GuideSerie
                AND do.Guide_Number = cs.GuideNumber
          LEFT JOIN CatCurrencyCOD curr WITH(NOLOCK)
                 ON curr.IdCatCurrencyCOD = cs.ShippingCurrency
    WHERE invH.inv_numberFEL = @CorrelativeInvoice
      AND invH.inv_pk_id = @IdInvoice
     ORDER BY 1 DESC

END