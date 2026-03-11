-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-08-07>
-- Description: <Genera la informacion para los encabezados de la factura>
-- =============================================
-- Author:        <Daniel, Ramirez>
-- Create date:   <2024-08-21>
-- Description:   <Ajuste para obtener info para tienda virtual desde Invoice Helper>
-- ============================================
-- Create date:   <2024-11-07>
-- Description:   <Obtener tipo de cliente para mostrar condiciones de pago>
-- =============================================
CREATE PROCEDURE [dbo].[spGetHeaderInvoice]
(
 @IdInvoice          BIGINT,      -- Id de factura
 @CorrelativeInvoice NVARCHAR(15) -- Id de correlativo asignado a la factura
)
AS
BEGIN
     DECLARE @IdCountry    NVARCHAR(2),
             @Pbx          NVARCHAR(15),
             @EmailSup     NVARCHAR(35),
             @CodeArea     NVARCHAR(5),
             @VoucherPhone NVARCHAR(35)

   SELECT @IdCountry = IdCountry
     FROM invoiceHeader invH WITH(NOLOCK)
    WHERE invH.inv_numberFEL = @CorrelativeInvoice
      AND invH.inv_pk_id = @IdInvoice

   SELECT @CodeArea     = MAX(AreaCode),
          @EmailSup     = MAX(SupportEmailByCountry),
          @Pbx          = MAX(PBX),
          @VoucherPhone = MAX(VoucherPhone)
     FROM (
           SELECT 
                   CASE
                       WHEN [Name] = 'AreaCode' THEN [Value]
                       ELSE ''
                   END AS [AreaCode],
                   CASE
                       WHEN [Name] = 'SupportEmailByCountry' THEN [Value]
                       ELSE ''
                   END AS [SupportEmailByCountry],
                   CASE
                       WHEN [Name] = 'PBX' THEN [Value]
                       ELSE ''
                   END AS [PBX],
                   CASE
                       WHEN [Name] = 'VoucherPhone' THEN [Value]
                       ELSE ''
                   END AS [VoucherPhone]
            FROM ConfigParams
           WHERE [Name] IN ('AreaCode', 'SupportEmailByCountry','PBX','VoucherPhone')
             AND IdCountry = @IdCountry
     ) AS T

   SELECT parFac.inv_cmp_nameComercial, 
          parFac.dpf_FELEntity,
          parFac.dpf_FELCorreoCCO,
          vPointCli.[Address],
          -- Primer bloque
          CONCAT(RIGHT('000' + CAST(invHe.Establishment AS VARCHAR), 3), '-',
          RIGHT('000' + CAST(invHe.Emision_Point AS VARCHAR), 3),'-',
          RIGHT('00' + CAST(invHe.TypeDocument AS VARCHAR), 2),'-',
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
          dbo.[CantidadEnLetras](inv_amount,'LEMPIRAS') AS PayInLetters,
          ISNULL(LTRIM(RTRIM(@CodeArea)),'') AS [CodeArea],
          ISNULL(LTRIM(RTRIM(@EmailSup)),'') AS [EmailSup],
          ISNULL(LTRIM(RTRIM(@Pbx)),'') AS [Pbx],
          ISNULL(LTRIM(RTRIM(@VoucherPhone)),'') AS [VoucherPhone],
          ISNULL(cus.IdCustomerType,0) AS IdCustomerType,
          ISNULL(cust.[Description],'') AS DescriptionCustomerType, 
          ISNULL(cus.[ConditionOfPaymentID],0) AS ConditionOfPaymentID,
          ISNULL(cOfPay.ConditionOfPayment,'') AS ConditionOfPayment
     FROM invoiceHeader invH WITH(NOLOCK)
          INNER JOIN InvoiceBatchDetail invBD WITH(NOLOCK) 
                  ON invH.inv_pk_id = invBD.inv_pk_id 
                  AND invH.inv_numberFEL = invBD.ProcessedCorrelative
          INNER JOIN InvoiceBatchHeader invHe WITH(NOLOCK) 
                  ON invBD.Id_Lote = invHe.Id_Lote
          INNER JOIN del_ParametrosFactura parFac WITH(NOLOCK)
                  ON parFac.dpf_VpCodeOfReference = invH.inv_vpCodeOfReferences
          INNER JOIN VisitPointClient vPointCli WITH(NOLOCK)
                  ON vPointCli.CodeOfReference = parFac.dpf_VpCodeOfReference
          LEFT JOIN customer cus WITH(NOLOCK) 
                  ON cus.idCustomer = vPointCli.CustomerID
          LEFT JOIN CustomerType cust WITH(NOLOCK) 
                  ON cus.IdCustomerType = cust.IdCustomerType
          LEFT JOIN CatConditionOfPayment cOfPay WITH(NOLOCK) 
                  ON cus.[ConditionOfPaymentID] = cOfPay.IdConditionOfPayment
    WHERE invH.inv_numberFEL = @CorrelativeInvoice
      AND invH.inv_pk_id = @IdInvoice
     ORDER BY 1 DESC
END
