-- =============================================
-- Author:      Cristian Azurdia
-- Create date: 2024-07-25
-- Description: Se obtiene los valores de emisor de facturas para HN
-- =============================================
CREATE PROCEDURE [dbo].[GetBatchInvoiceByCountry]
    @idInvoice BIGINT
AS
BEGIN

	DECLARE @Batch BIGINT;
	DECLARE @InitialRange BIGINT;
	DECLARE @FinalRange BIGINT;
	DECLARE @CAI NVARCHAR(100);
	DECLARE @LastProcessed BIGINT;

	   /*
			InvoiceBatchHeader
			status = 1 y enable = 1 es cuando el lote esta habilidado y activo
			status = 0 y enable = 1 es un error - no contemplado
			status = 1 y enable = 0 es cuando no se puede facturar, porque se detuvo facturación (Ya viene lote nuevo ejemplo)
		*/

	SELECT	@Batch = Id_Lote
			,@InitialRange = InitialRange
			,@FinalRange = FinalRange
			,@CAI = CAI
			,@LastProcessed = Last_Process
	FROM	InvoiceBatchHeader
	WHERE	TypeDocument = 1
		AND	[STATUS] = 1
		AND [ENABLE] = 1

	--Asignamos a la factura el número de certificación del lote
	/*UPDATE invoiceHeader
	SET inv_certificationFEL = @LastProcessed
		,inv_subjectFEL = 'Forza Delivery - Factura Electrónica'
		,inv_FechaHoraFEL = GETDATE()
		,inv_descriptionFEL = 'PROCESO REALIZADO'
		,inv_TransactionFEL = 'SYSTEM_REQUEST'
		,inv_status = 2
	WHERE inv_pk_id = @idInvoice*/

	--Actualizamos el último procesado 
	UPDATE InvoiceBatchHeader
	SET Last_Process = @LastProcessed + 1
	WHERE Id_Lote = @Batch

	--Insertamos Factura Procesada
	INSERT INTO InvoiceBatchDetail (Id_Lote, ProcessedCorrelative, inv_pk_id, SendEmail, RowStatus, TokenCreated, DateCreated)
	VALUES(@Batch, @LastProcessed, @idInvoice, 0, 1, 'CAZURDIA-SYS', GETDATE());

	SELECT '' 'inv_certificationFEL', @LastProcessed'inv_numberFEL'

END;