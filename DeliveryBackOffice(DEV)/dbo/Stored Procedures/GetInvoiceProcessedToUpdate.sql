-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-04-28>
-- Description:	<Obtiene las facturas para el proceso UpdateInvoiceProcessed en el servicio HermesInvoiceHelper para actualizar datos de facturas procesadas>
-- =============================================
CREATE PROCEDURE [dbo].[GetInvoiceProcessedToUpdate]
AS
BEGIN
    BEGIN TRY
        DECLARE @DaysFrom INT = 4; --Días desde donde se obtienen las guías.

        SELECT '1'                              'StatusCode'
             , 'Datos obtenidos correctamente.' 'Description';
             
        SELECT inv_pk_id InvoiceId,inv_descriptionFEL
        FROM invoiceHeader WITH (NOLOCK)
        WHERE 
		--(
		inv_descriptionFEL = 'Fallo la ejecucion del comando: [POST_DOCUMENTGT], TrCode: [9], description: [Ya existe el Documento con el NIT, codigo establecimiento, tipo de documento y IDInterno, no se puede insertar un documento duplicado]'
  --      OR 
		--inv_documentRecieved ='TimeOut' 
		--)
		  AND 
		  inv_dateRegister >=   '2026-04-01 00:00:00'
		 --AND inv_dateRegister <='2025-12-30 23:59:59'
		 AND 		 
		 (inv_certificationFEL IS NULL OR inv_certificationFEL = '')
		--AND  inv_pk_id IN (7730592)

		
    END TRY
    BEGIN CATCH

        SELECT '-1'            'StatusCode'
             , ERROR_MESSAGE() 'Description';
    END CATCH;
END;