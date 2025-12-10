/* =================================================
   SP:        [dbo].[sphdGetInvoiceInfoByNumberFEL]
   Propósito: Obtener datos de factura que se emitio previamente para El Salvador.
   Autor:     Brandon Pedroza
   Historia:  ---
   Fecha:     2025-07-30

=== CHANGELOG ============================

2025-11-21 | Historia/épica: FDAPI-4961   | Autor: Brandon Pedroza |

=========================================== */
CREATE PROCEDURE [dbo].[sphdGetInvoiceInfoByNumberFEL]
	@NumberFel NVARCHAR(100),
	@IdCountry NVARCHAR(2)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @TypeDocument INT = (SELECT IdRegister FROM CatTypeDocument WITH(NOLOCK) WHERE [Name] = 'Comprobante Crédito Fiscal');
	DECLARE @TypeDocumentCancel INT = (SELECT IdRegister FROM CatTypeDocument WITH(NOLOCK) WHERE [Name] = 'Anulación DTE');
	IF EXISTS(SELECT 1  FROM invoiceHeader WITH(NOLOCK) WHERE inv_numberFEL = @NumberFel AND IdCountry = @IdCountry AND inv_status = -1)
	BEGIN
		SELECT 400 AS [StatusCode],
		CONCAT('El documento solicitado cuenta con una anulación generada con código: ',IH2.inv_numberFEL)  AS [Message]
		FROM invoiceHeader IH WITH(NOLOCK)
		INNER JOIN invoiceHeader IH2 WITH(NOLOCK)
		ON IH.inv_pk_id = IH2.inv_invoiceOfCreditNote
		WHERE IH2.inv_type = @TypeDocumentCancel
		AND IH.inv_numberFEL = @NumberFel;
		RETURN;
	END
	SELECT 
		1 AS StatusCode,
		ih.inv_pk_id,
		ih.inv_numberFEL,
		ih.inv_cli_adress,
		ih.inv_cli_name,
		ih.inv_cli_nit,
		ih.inv_cli_email,
		ibi.DistrictCode,
		ibi.StateCode,
		ibi.ActivityCode,
		ibi.ActivityDescription,
		ibi.NRC,
		ibi.Phone,
		ibi.IdDocument AS TaxID,
		ibi.TypeIdentificationDocumentCode AS TaxIDType,
		CASE WHEN ih.inv_type = 4 THEN '03' ELSE '01' END TypeDocument,
		CONVERT(varchar(10), ih.inv_dateRegister, 23) AS IssueDate,
		ISNULL(ibi.OperationConditionCode,1) AS OpCondition
	FROM invoiceHeader ih WITH(NOLOCK)
	LEFT JOIN InformationBuyerInvoice ibi WITH(NOLOCK)
		ON ih.inv_pk_id = ibi.InvoiceId
	WHERE ih.inv_numberFEL = @NumberFel
		AND ih.IdCountry = @IdCountry
		AND ih.inv_type = @TypeDocument
		AND ih.inv_status = 2
END;
