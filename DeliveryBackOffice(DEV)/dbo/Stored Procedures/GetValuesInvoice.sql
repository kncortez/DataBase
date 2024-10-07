-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-08-07>
-- Description: <Obtiene el id de factura para procesarlo para portal individual>
-- =============================================
CREATE PROCEDURE [dbo].[GetValuesInvoice]
(
 @IdInvoice          NVARCHAR(50),-- Correlativo compuesto
 @Certification      NVARCHAR(50) -- Certificacion CAI del lote
)
AS
BEGIN

   SELECT @IdInvoice = LTRIM(RTRIM(@IdInvoice)),
          @Certification = LTRIM(RTRIM(@Certification))

   SELECT inv_pk_id AS IdInvoice,  
          inv_numberFEL AS IdCorrelative
     FROM invoiceHeader
    WHERE inv_numberFEL = @IdInvoice
      AND inv_serieFEL = @Certification
    ORDER BY 1 DESC
END
