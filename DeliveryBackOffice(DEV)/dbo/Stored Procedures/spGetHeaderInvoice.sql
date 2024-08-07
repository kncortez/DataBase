-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-08-07>
-- Description: <Genera la informacion para los encabezados de la factura>
-- =============================================
CREATE PROCEDURE [dbo].[spGetHeaderInvoice]
(
 @IdInvoice          BIGINT,      -- Id de factura
 @CorrelativeInvoice NVARCHAR(15) -- Id de correlativo asignado a la factura
)
AS
BEGIN
   SELECT parFac.inv_cmp_nameComercial, 
          parFac.dpf_FELEntity,
          parFac.dpf_FELCorreoCCO,
          vPointCli.[Address],
          CONCAT(RIGHT('000' + CAST(invHe.Establishment AS VARCHAR), 3), '-',
          RIGHT('000' + CAST(invHe.Emision_Point AS VARCHAR), 3),'-',
          RIGHT('00' + CAST(invHe.TypeDocument AS VARCHAR), 2),'-',
          --- --Primer bloque
          RIGHT('00000000' + CAST(invBD.ProcessedCorrelative AS VARCHAR), 8)) AS NoInvoice,
          FORMAT(invH.inv_date,'dd/MM/yyyy') AS InvoiceDate,
          FORMAT(invHe.LimitDateEmision,'dd/MM/yyyy') AS LimitDateEmision,
          invHe.CAI AS CAI,
          CONCAT(RIGHT('000' + CAST(invHe.Establishment AS VARCHAR), 3), '-',
          RIGHT('000' + CAST(invHe.Emision_Point AS VARCHAR), 3),'-',
          RIGHT('00' + CAST(invHe.TypeDocument AS VARCHAR), 2),'-',
          RIGHT('00000000' + CAST(invHe.InitialRange AS VARCHAR), 8)) AS RangoInit,
          CONCAT(RIGHT('000' + CAST(invHe.Establishment AS VARCHAR), 3), '-',
          RIGHT('000' + CAST(invHe.Emision_Point AS VARCHAR), 3),'-',
          RIGHT('00' + CAST(invHe.TypeDocument AS VARCHAR), 2),'-',
          RIGHT('00000000' + CAST(invHe.FinalRange AS VARCHAR), 8)) AS FinalRange,
          --Segundo bloque
          invH.inv_cli_nit AS RTNClient,
          '' AS codClient,
          invH.inv_cli_name AS NameClient,
          invH.inv_cli_adress AS AddressClient,
          invH.inv_amount - inv_IVA AS SubTotal,
          '' AS descuentos,
          '' AS ImpExento,
          '' AS ImpExonerado,
          invH.inv_IVA AS Isv,
          invH.inv_amount AS TotalPay,
          dbo.[CantidadEnLetras](inv_amount,'LEMPIRAS') AS PayInLetters
     FROM invoiceHeader invH WITH(NOLOCK)
          LEFT JOIN InvoiceBatchDetail invBD WITH(NOLOCK) 
                  ON invH.inv_pk_id = invBD.inv_pk_id 
          LEFT JOIN InvoiceBatchHeader invHe WITH(NOLOCK) 
                  ON invBD.Id_Lote = invHe.Id_Lote
          LEFT JOIN del_ParametrosFactura parFac WITH(NOLOCK)
                  ON parFac.dpf_VpCodeOfReference = invH.inv_vpCodeOfReferences
          LEFT JOIN VisitPointClient vPointCli WITH(NOLOCK)
                  ON vPointCli.CodeOfReference = parFac.dpf_VpCodeOfReference
    WHERE invH.inv_numberFEL = @CorrelativeInvoice
      AND invH.inv_pk_id = @IdInvoice
     ORDER BY 1 DESC
END
