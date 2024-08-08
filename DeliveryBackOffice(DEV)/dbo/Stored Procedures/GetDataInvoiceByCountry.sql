-- =============================================
-- Author:      Daniel Ramirez
-- Create date: 2024-06-26
-- Description: Se obtiene los valores de emisor de facturas para HN
-- =============================================
CREATE PROCEDURE [dbo].[GetDataInvoiceByCountry]
    @idInvoice BIGINT
AS
BEGIN
     SELECT TOP 1 
            dpf.[inv_cmp_name],
            dpf.[inv_cmp_nameComercial],
            vpc.[Address]
       FROM invoiceHeader ih WITH(NOLOCK)
            INNER JOIN del_ParametrosFactura dpf WITH(NOLOCK) ON ih.inv_vpCodeOfReferences = dpf.dpf_VpCodeOfReference
            INNER JOIN  VisitPointClient vpc WITH(NOLOCK) ON dpf.dpf_VpCodeOfReference = vpc.CodeOfReference
      WHERE ih.inv_pk_id = @idInvoice
      ORDER BY inv_pk_id DESC
END;