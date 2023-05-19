-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-04-28>
-- Description:	<Obtiene las facturas para el proceso UpdateInvoiceProcessed en el servicio HermesInvoiceHelper para actualizar datos de facturas procesadas>
-- =============================================
CREATE PROCEDURE [dbo].[GetInvoiceProcessedToUpdate]
AS
BEGIN
	BEGIN TRY
		DECLARE @DaysFrom INT = 4 --Días desde donde se obtienen las guías.

		SELECT
			'1' 'StatusCode'
		   ,'Datos obtenidos correctamente.' 'Description'

		SELECT
			inv_pk_id InvoiceId
		FROM invoiceHeader WITH (NOLOCK)
		WHERE 
		inv_descriptionFEL = 'Fallo la ejecucion del comando: [POST_DOCUMENTGT], TrCode: [9], description: [Ya existe el Documento con el NIT, codigo establecimiento, tipo de documento y IDInterno, no se puede insertar un documento duplicado]'
		AND CAST(inv_dateRegister AS DATE) >= '2023-04-01 00:00:00'
		--AND inv_pk_id = 2054828
		ORDER BY InvoiceId asc

	END TRY
	BEGIN CATCH
		
		SELECT
			'-1' 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
	END CATCH
END