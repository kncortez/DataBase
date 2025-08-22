
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-08-22>
-- Description:	<TRAE EL CODIGO DE REFERENCIA REGISTRADO EN LA FACTURA>
-- =============================================   
-- Author:		<Brandon Pedroza>
-- Create date: <2025-07-18>
-- Description:	<Facturacion SV - Se agrega filtro para SV>
-- =============================================  
CREATE PROCEDURE [dbo].[GetCodeOfReferenceofInvoice] @NumberFel NVARCHAR(50),
 @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
IF (@IdCountry = 'SV')
BEGIN
    SELECT inv_vpCodeOfReferences AS CodeOfReference  
         , inv_pk_id              AS IdInvoice  
         , inv_numberFEL          AS CorrelativeInvoice  
    FROM invoiceHeader WITH(NOLOCK)  
    WHERE inv_numberFEL = @NumberFel 
END
ELSE
BEGIN
    SELECT inv_vpCodeOfReferences AS CodeOfReference
         , inv_pk_id              AS IdInvoice
         , inv_numberFEL          AS CorrelativeInvoice
    FROM invoiceHeader WITH(NOLOCK)
    WHERE inv_certificationFEL = @NumberFel
	ORDER BY inv_pk_id desc;
END;