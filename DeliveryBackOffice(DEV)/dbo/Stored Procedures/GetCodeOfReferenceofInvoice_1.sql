   
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-08-22>
-- Description:	<TRAE EL CODIGO DE REFERENCIA REGISTRADO EN LA FACTURA>
-- =============================================   
CREATE PROCEDURE GetCodeOfReferenceofInvoice
@NumberFel NVARCHAR(50)
AS
BEGIN
	SELECT inv_vpCodeOfReferences AS CodeOfReference
	FROM invoiceHeader WHERE inv_certificationFEL = @NumberFel
END