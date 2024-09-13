-- =============================================
-- Author:		Marco Jiménez
-- Create date: 15/11/2021
-- Description:	Retorna listado de facturas pendientes de pago para enviar a SAP
-- =============================================
CREATE PROCEDURE [dbo].[spg_lstFacturasToSAPPaymentRecovery]
AS
BEGIN
DECLARE @hour AS INT =
            (
                SELECT (DATEPART(HOUR, GETDATE()))
            )	
	--IF (1=0)
   -- IF (@hour IN (3, 4, 5, 6, 7, 8,10,11,13,14,15,16,17,18,19,20,21,22,23))	
	--IF (@hour IN (3, 4, 5, 6, 7,17,18,19,20,21,22,23))	--Nuevos horarios
	--IF (@hour IN (23))
    BEGIN
		SELECT ihd.inv_pk_id,
		   ihd.inv_vpCodeOfReferences,
		   ihd.inv_type,
		   ihd.inv_status,
		   ihd.inv_invoiceOfCreditNote
		   ,IOMD.io_SAPDocEntryPaymentDetail
		   ,IOMD.io_SAPErrorPaymentDetail
		   ,ihd.inv_date
	FROM DeliveryBackOffice.dbo.invoiceHeader ihd WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.InOutOfMoneyDetail IOMD WITH (NOLOCK)
			ON IOMD.io_invoice = ihd.inv_pk_id
	WHERE 
	(IOMD.io_SAPDocEntryPaymentDetail = -1 OR IOMD.io_SAPDocEntryPaymentDetail IS NULL)
	AND ihd.inv_SAPDocEntry <> -1
	AND ihd.inv_SAPDocEntry IS NOT NULL
		  AND CAST(ihd.inv_dateRegister AS DATE) >= CAST('2024-09-01' AS DATE)     
		  --AND CAST(ihd.inv_dateRegister AS DATE) <= CAST('2024-08-31' AS DATE)     
		  --AND 1=0
	--AND ihd.inv_pk_id in (3715041)
	--AND io_SAPErrorPaymentDetail LIKE '%10000104 - En el campo "Fecha de contabilización", introduzca la fecha de contabilización que es igual o anterior a la fecha del sistema%'
	AND IHD.inv_SAPDocEntry <> 1
	AND IHD.inv_type <> 2 --no enviar pagos de notas de crédito
	--AND 1=0
	--AND IOMD.io_SAPErrorPaymentDetail = 'Falta especificación para medio de pago  [RCT3.VoucherNum][line: 0]'
	--AND ihd.inv_pk_id = 2384510
--	AND IOMD.io_invoice IN (3963185
--,3972448
--)
	--AND 1= 0
	ORDER BY ihd.inv_date ASC
	END
END









