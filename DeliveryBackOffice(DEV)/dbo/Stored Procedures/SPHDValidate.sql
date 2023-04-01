-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2023-03-31>
-- Description:	<vALIDAR SI FACTURA TIENE NOTA DE CREDITO>
-- =============================================
CREATE PROCEDURE [dbo].[SPHDValidate]
@GuideSerie Nvarchar(2),
@GuideNumber Int
AS
BEGIN

	SET NOCOUNT ON;

   IF ( EXISTS(SELECT  1 FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
                     INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
					 ON IH.inv_pk_id = ID.dti_fk_header
					 WHERE ID.dti_fk_orderSerie = @GuideSerie AND 
					 ID.dti_fk_orderNumber = @GuideNumber AND IH.inv_invoiceOfCreditNote IS NULL))
   BEGIN

   Select 1 'HaveaCreditNote'

   END
   ELSE
   BEGIN
    Select 0 'HaveaCreditNote'
   END

   END