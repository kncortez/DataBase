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
    --IF (@hour IN (3, 4, 5, 6, 7, 8,10,11,13,14,15,16,17,18,19,20,21,22,23))	
	IF (@hour IN (3, 4, 5, 6, 7,17,18,19,20,21,22,23))	--Nuevos horarios
	--IF (@hour IN (23))
    BEGIN
		SELECT ihd.inv_pk_id,
		   ihd.inv_vpCodeOfReferences,
		   ihd.inv_type,
		   ihd.inv_status,
		   ihd.inv_invoiceOfCreditNote
		   ,IOMD.io_SAPDocEntryPaymentDetail
		   ,IOMD.io_SAPErrorPaymentDetail
	FROM DeliveryBackOffice.dbo.invoiceHeader ihd WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.InOutOfMoneyDetail IOMD WITH (NOLOCK)
			ON IOMD.io_invoice = ihd.inv_pk_id
	WHERE 
	(IOMD.io_SAPDocEntryPaymentDetail = -1 OR IOMD.io_SAPDocEntryPaymentDetail IS NULL)
	AND ihd.inv_SAPDocEntry <> -1
	AND ihd.inv_SAPDocEntry IS NOT NULL
		  AND CAST(ihd.inv_dateRegister AS DATE) >= CAST('2022-10-26' AS DATE)  
		  AND 1=0 --deshabilitado
	--AND ihd.inv_pk_id IN (1013437
	--					 ,1013438
	--					 ,1013439
	--					 ,1013440
	--					 ,1013441
	--					 ,1013442
	--					 ,1013443
	--					 ,1013444
	--					 ,1013445
	--					 ,1013446
	--					 ,1013447
	--					 ,1013448)
	END
END









