
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-08-22>
-- Description:	<TRAE EL CODIGO DE REFERENCIA REGISTRADO EN LA FACTURA>
-- =============================================   
CREATE PROCEDURE [dbo].[GetCodeOfReferenceofInvoice] @NumberFel NVARCHAR(50), @SerieFel NVARCHAR(50)
AS
BEGIN
    SELECT inv_vpCodeOfReferences AS CodeOfReference
         , inv_pk_id              AS IdInvoice
         , inv_numberFEL          AS CorrelativeInvoice
    FROM invoiceHeader WITH(NOLOCK)
    WHERE inv_certificationFEL = @NumberFel AND inv_serieFEL = @SerieFel
END;
