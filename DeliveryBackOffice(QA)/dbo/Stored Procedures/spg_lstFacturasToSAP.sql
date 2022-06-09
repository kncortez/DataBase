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

			
    IF (@hour IN ( 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,13,14, 15, 16, 17, 18, 19 ))
    BEGIN
        SELECT --TOP 1000
               ihd.inv_pk_id,
               inv_vpCodeOfReferences,
               inv_type,
               ihd.inv_status,
               ihd.inv_invoiceOfCreditNote
        FROM DeliveryBackOffice.dbo.invoiceHeader ihd WITH (NOLOCK)
            --join DeliveryBackOffice.dbo.VisitPointClient vpc with(nolock) on vpc.CodeOfReference = ihd.inv_vpCodeOfReferences
            LEFT JOIN InvoiceRestriction ir WITH(NOLOCK)
                ON ihd.inv_pk_id = ir.inv_pk_id
        WHERE ihd.inv_status IN ( -1, 2 )
              -- 1 CREA LOCALMENTE EL REGISTRO DE FACTURA
              -- 2 CUANDO SE ENVIA FACTURA A FEL
              -- 3 CUANDO YA ESTÁ ENVIADA A SAP
              -- -1 ES ANULADA
              AND inv_type IN ( 1, 2 )
			 
              AND CAST(ihd.inv_dateRegister AS DATE) >= CAST('2022-04-01' AS DATE)
              --AND cast(ihd.inv_dateRegister as date) <= CAST('2022-04-30' as date)
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
			 -- AND ihd.inv_pk_id = 588460
        --and 1= 0 --VARIABLE A UTILIZAR CADA VEZ QUE SE SUBA NUEVA VERSIÓN DEL SERVICIO
        --AND ihd.inv_pk_id IN (517557)	
        ORDER BY inv_pk_id;

    END;
    --ELSE
    --BEGIN


    --    IF (@hour IN ( 20,21,22,23 ))
    --    BEGIN

    --        SELECT ihd.inv_pk_id,
    --               inv_vpCodeOfReferences,
    --               inv_type,
    --               ihd.inv_status,
    --               ihd.inv_invoiceOfCreditNote
    --        FROM DeliveryBackOffice.dbo.invoiceHeader ihd WITH (NOLOCK)
    --            --join DeliveryBackOffice.dbo.VisitPointClient vpc with(nolock) on vpc.CodeOfReference = ihd.inv_vpCodeOfReferences
    --            LEFT JOIN InvoiceRestriction ir
    --                ON ihd.inv_pk_id = ir.inv_pk_id
    --        WHERE ihd.inv_status IN ( -1, 2 )
    --              -- 1 CREA LOCALMENTE EL REGISTRO DE FACTURA
    --              -- 2 CUANDO SE ENVIA FACTURA A FEL
    --              -- 3 CUANDO YA ESTÁ ENVIADA A SAP
    --              -- -1 ES ANULADA
    --              AND inv_type IN ( 1, 2 )
    --              AND CAST(ihd.inv_dateRegister AS DATE) >= CAST('2022-01-01' AS DATE)
    --              --AND cast(ihd.inv_dateRegister as date) <= CAST('2021-11-30' as date)
    --              AND
    --              (
    --                  ihd.inv_SAPDocEntry IS NULL
    --                  OR ihd.inv_SAPDocEntry = -1
    --              )
    --              AND ISNULL(ihd.inv_certificationFEL, '') != ''
    --              AND
    --              (
    --                  ir.invRetries IS NULL
    --                  OR ir.invRetries <= 3
    --              )
    --        --and 1= 0 --VARIABLE A UTILIZAR CADA VEZ QUE SE SUBA NUEVA VERSIÓN DEL SERVICIO
    --        --AND ihd.inv_pk_id IN (325606)	
    --        ORDER BY inv_pk_id;
    --    END;

    --    ELSE
    --    BEGIN

    --        SELECT ihd.inv_pk_id,
    --               inv_vpCodeOfReferences,
    --               inv_type,
    --               ihd.inv_status,
    --               ihd.inv_invoiceOfCreditNote
    --        FROM DeliveryBackOffice.dbo.invoiceHeader ihd WITH (NOLOCK)
    --            --join DeliveryBackOffice.dbo.VisitPointClient vpc with(nolock) on vpc.CodeOfReference = ihd.inv_vpCodeOfReferences
    --            LEFT JOIN InvoiceRestriction ir
    --                ON ihd.inv_pk_id = ir.inv_pk_id
    --        WHERE ihd.inv_status IN ( -1, 2 )
    --              -- 1 CREA LOCALMENTE EL REGISTRO DE FACTURA
    --              -- 2 CUANDO SE ENVIA FACTURA A FEL
    --              -- 3 CUANDO YA ESTÁ ENVIADA A SAP
    --              -- -1 ES ANULADA
    --              AND inv_type IN ( 1, 2 )
    --              AND CAST(ihd.inv_dateRegister AS DATE) >= CAST('2022-01-01' AS DATE)
    --              --AND cast(ihd.inv_dateRegister as date) <= CAST('2021-11-30' as date)
    --              AND
    --              (
    --                  ihd.inv_SAPDocEntry IS NULL
    --                  OR ihd.inv_SAPDocEntry = -1
    --              )
    --              AND ISNULL(ihd.inv_certificationFEL, '') != ''
    --              AND
    --              (
    --                  ir.invRetries IS NULL
    --                  OR ir.invRetries <= 3
    --              )
    --              AND 1 = 0 --VARIABLE A UTILIZAR CADA VEZ QUE SE SUBA NUEVA VERSIÓN DEL SERVICIO
    --        --AND ihd.inv_pk_id IN (325606)	
    --        ORDER BY inv_pk_id;
    --    END;

    --END;


END;








