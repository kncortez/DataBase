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
		--inv_descriptionFEL = 'Fallo la ejecucion del comando: [POST_DOCUMENTGT], TrCode: [9], description: [Ya existe el Documento con el NIT, codigo establecimiento, tipo de documento y IDInterno, no se puede insertar un documento duplicado]'
  --      OR 
		--inv_documentRecieved ='TimeOut' 
		--)
		--  AND 
		  inv_dateRegister >='2024-09-01 00:00:00'
		 AND inv_dateRegister <='2024-09-30 23:59:59'
		 AND 		 
		 (inv_certificationFEL IS NULL OR inv_certificationFEL = '')
		 AND
		 inv_pk_id IN (4334615
,4334628
,4334636
,4334639
,4334644
,4334651
,4334653
,4334655
,4334661
,4334666
,4334670
,4334672
,4334696
,4334704
,4334766
,4334822
,4334866
,4334914
,4334917
,4334972
,4334976
,4334981
,4334989
,4334993
,4334995
,4335032
,4335051
,4335063
,4335070
,4335094
,4335119
,4335120
,4335132
,4335152
,4335167
,4335173
,4335192
,4335207
,4335226
,4335232
,4335242
,4335275
,4335284
,4335302
,4335312
,4335313
,4335317
,4335318
,4335328
,4335331
,4335370
,4335371
,4335381
,4335421
,4335437
,4335484
,4335520
)
    END TRY
    BEGIN CATCH

        SELECT '-1'            'StatusCode'
             , ERROR_MESSAGE() 'Description';
    END CATCH;
END;