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
            );

			
    IF (@hour IN ( 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,13,14, 15, 16, 17, 18, 19 ))
    BEGIN
		SELECT ihd.inv_pk_id,
		   inv_vpCodeOfReferences,
		   inv_type,
		   ihd.inv_status,
		   ihd.inv_invoiceOfCreditNote
		   ,IOMD.io_SAPDocEntryPaymentDetail
		   ,IOMD.io_SAPErrorPaymentDetail
	FROM DeliveryBackOffice.dbo.invoiceHeader ihd WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.InOutOfMoneyDetail IOMD WITH (NOLOCK)
			ON IOMD.io_invoice = ihd.inv_pk_id
	WHERE IOMD.io_SAPDocEntryPaymentDetail = -1
	--(IOMD.io_SAPDocEntryPaymentDetail = -1 OR IOMD.io_SAPDocEntryPaymentDetail IS NULL)
	AND ihd.inv_SAPDocEntry != -1
	AND ihd.inv_SAPDocEntry IS NOT NULL
		  AND CAST(ihd.inv_dateRegister AS DATE) >= CAST('2022-03-01' AS DATE)
              AND cast(ihd.inv_dateRegister as date) < CAST('2022-03-31' as date)
	
	--AND ihd.inv_vpCodeOfReferences <> 4278
	--AND ihd.inv_pk_id = 603228
	--AND ihd.inv_pk_id = 597046
	--AND IOMD.io_SAPErrorPaymentDetail = 'Para generar este documento, primero defina la serie de numeración en el módulo Gestión '
	--AND ihd.inv_pk_id = 257950 --257949
	--AND 1=0
	--6466
	--6186
	--6155
	END
END









