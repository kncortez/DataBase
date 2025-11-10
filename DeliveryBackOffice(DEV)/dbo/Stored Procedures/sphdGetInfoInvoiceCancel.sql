-- =============================================      
-- Author:      <Brandon, Pedroza>      
-- Create date: <2025-07-18>      
-- Description: <Facturacion SV - Obtener datos para cancelar factura>      
-- =============================================      
CREATE PROCEDURE [dbo].[sphdGetInfoInvoiceCancel]
	@Guid VARCHAR(50),
	@IdCountry VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TypeDocumentCreditNote INT,
			@IssueDate DATE,
			@CancelTypeId INT,
            @CodeOfReference INT;
	
	SET @TypeDocumentCreditNote = (SELECT IdRegister FROM CatTypeDocument WITH(NOLOCK) WHERE [Name] = 'Nota de Crédito');

	-- Obtener el ID del estado 'Anulada'
	SELECT @CancelTypeId = ist_pk_id 
	FROM ctg_statusInvoice WITH(NOLOCK) 
	WHERE ist_nombre = 'Anulada';

	-- Validar si el documento existe
	IF NOT EXISTS (
		SELECT 1
		FROM invoiceHeader WITH(NOLOCK)
		WHERE IdCountry = @IdCountry AND inv_numberFEL = @Guid
	)
	BEGIN
		SELECT 404 AS [Code],
			   'El número de documento no existe' AS [Message];
		RETURN;
	END

	-- Validar si el documento ya ha sido anulado
	IF EXISTS (
		SELECT 1
		FROM invoiceHeader WITH(NOLOCK)
		WHERE IdCountry = @IdCountry AND inv_numberFEL = @Guid AND inv_status = @CancelTypeId
	)
	BEGIN
		SELECT 400 AS [Code],
			CONCAT('El documento: ',@Guid,' ya ha sido anulado previamente.') AS [Message];
		RETURN;
	END

	IF EXISTS(
			SELECT 1  
			FROM invoiceHeader IH WITH(NOLOCK)
			INNER JOIN invoiceHeader IH2 WITH(NOLOCK)
			ON IH.inv_pk_id = IH2.inv_invoiceOfCreditNote
			WHERE IH2.inv_type = @TypeDocumentCreditNote
				AND IH.inv_numberFEL = @Guid AND IH.IdCountry = @IdCountry
				AND IH2.inv_status = 2
	)
	BEGIN
		SELECT 401 AS [Code],  
			CONCAT('El documento: ',@Guid,' no puede anularse ya que cuenta con notas de crédito asociadas.') AS [Message];
		RETURN;
	END

	-- Obtener los datos del documento
	SELECT	
		1 AS [Code],
		'Datos obtenidos' AS [Message],
		INV.inv_numberFEL AS [docGUID],
		CASE INV.inv_type
			WHEN '1' THEN '01'--FACTURA ELECTRONICA
			WHEN '4' THEN '03'--COMPROBANTE DE CREDITO
			ELSE '0' 
		END					AS [TypeDocument],
		INV.inv_FechaHoraFEL AS [IssueDate],
		DPF.inv_cmp_nameComercial AS [nombreEstablecimiento],
		DPF.dpf_FELEntity AS [nit]
	FROM invoiceHeader INV WITH(NOLOCK)
	INNER JOIN del_ParametrosFactura DPF WITH(NOLOCK) 
		ON INV.inv_vpCodeOfReferences = DPF.dpf_VpCodeOfReference
	WHERE INV.IdCountry = @IdCountry
	  AND INV.inv_numberFEL = @Guid;

    SELECT @CodeOfReference = inv.inv_vpCodeOfReferences
	FROM invoiceHeader INV WITH(NOLOCK)
	WHERE INV.IdCountry = @IdCountry
	  AND INV.inv_numberFEL = @Guid;

	-- Obtener datos adicionales de configuración
	SELECT [Name], [Value]
	  FROM AddInfoByCodeOfReference WITH(NOLOCK)
	 WHERE RowStatus = 1 
       AND [Node] = 'CancelDTE'
       AND CodeOfReference = @CodeOfReference;

	SELECT	[Name],[Value] 
	FROM AddInfoByConfigSV WITH(NOLOCK)
	WHERE RowStatus = 1
      AND [Node] = 'CreateDTE' 
      AND [Name] = 'USERNAME'

END;
