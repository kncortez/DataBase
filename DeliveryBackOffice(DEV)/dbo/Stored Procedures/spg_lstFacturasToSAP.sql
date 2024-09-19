-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 17 Nov 2020
-- Description:	Retorna listado de facturas listas para enviar a SAP
-- =============================================
CREATE PROCEDURE [dbo].[spg_lstFacturasToSAP]
AS
BEGIN
    DECLARE @hour AS INT =
            (
                SELECT (DATEPART(HOUR, GETDATE()))
            );

      --IF (@hour IN (3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23))	
      --IF (@hour IN (3, 4, 5, 6, 7,17,18,19,20,21,22,23))	--Nuevos horarios
	--IF (@hour IN (3, 4, 5, 6, 7, 8,11,14,17,18,19,20,21,22,23))	
	--IF (@hour IN (8) and 1=0)	
    BEGIN
        SELECT 
               ihd.inv_pk_id,
               ihd.inv_vpCodeOfReferences,
               ihd.inv_type,
               ihd.inv_status,
               ihd.inv_invoiceOfCreditNote
        FROM DeliveryBackOffice.dbo.invoiceHeader ihd WITH (NOLOCK)
            LEFT JOIN dbo.InvoiceRestriction ir WITH(NOLOCK)
            ON ihd.inv_pk_id = ir.inv_pk_id
        WHERE ISNULL(ihd.IdCountry,'GT') = 'GT'
			  AND ihd.inv_status IN ( -1, 2 )
              -- 1 CREA LOCALMENTE EL REGISTRO DE FACTURA
              -- 2 CUANDO SE ENVIA FACTURA A FEL
              -- 3 CUANDO YA ESTÁ ENVIADA A SAP
              -- -1 ES ANULADA
              AND ihd.inv_type IN ( 1, 2 )			 
              AND CAST(ihd.inv_dateRegister AS DATE) >= CAST('2024-09-01' AS DATE)
			 --AND CAST(ihd.inv_dateRegister AS DATE)  <= CAST('2024-08-31' AS DATE)

			  --AND CAST(ihd.inv_dateRegister AS DATE) <= CAST('2023-09-27' AS DATE)
             -- AND cast(ihd.inv_dateRegister as date) <= CAST('2023-10-31' as date)
              AND
              (
                  ihd.inv_SAPDocEntry IS NULL
                  OR ihd.inv_SAPDocEntry = -1
              )
              AND ISNULL(ihd.inv_certificationFEL, '') != ''
              AND
              (
                  ir.invRetries IS NULL
                  OR ir.invRetries <= 3
              )
			  AND IHD.IsManualInvoice IS NULL	
			  
			  --AND ihd.inv_pk_id = 4006353 --PRIMER ENVÍO A SAP 10.0
			  --AND ihd.inv_pk_id IN (3963185,3972448,4006354,4006355)
			  --AND ihd.inv_pk_id IN (4006356,4006357,4006358,4006360,4006361)
			  --and 1= 0 --VARIABLE A UTILIZAR CADA VEZ QUE SE SUBA NUEVA VERSIÓN DEL SERVICIO
			  ORDER BY ihd.inv_pk_id ASC;

    END  
END
