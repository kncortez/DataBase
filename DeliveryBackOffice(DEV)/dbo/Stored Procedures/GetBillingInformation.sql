-- =============================================
-- Author:		<Carlos Vicente>
-- Create date: <2024-01-30>
-- Modify:      <Luis Ardón>
-- Modify on:   <2024-02-28>
-- Description:	Este procedimiento almacenado, GetBillingInformation, se utiliza para obtener el resumen y detalle de las facturas y pagos generados, enviadas a SAP y faltantes de enviar a SAP.
-- =============================================
CREATE PROCEDURE [dbo].[GetBillingInformation]
@Method NVARCHAR(5),
@InitDate AS DATETIME,
@EndDate AS DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Verificación de la validez del método
        IF @Method NOT IN ('LST01', 'LST02', 'LST03')
        BEGIN
            SELECT 204 AS 'responseCode', 
                   'Método incorrecto, solo se admiten LST01, LST02, LST03' AS 'responseMessage';
            RETURN;
        END;

        -- Verificación de la validez de las fechas
        IF @EndDate < @InitDate
        BEGIN
            SELECT 204 AS 'responseCode', 
                   'La fecha de fin debe ser mayor a la fecha de inicio' AS 'responseMessage';
            RETURN;
        END;

		SELECT
			200 AS 'responseCode',
			'Transacción exitosa' AS 'responseMessage';
        -- Variables temporales para almacenar datos calculados
        DECLARE @FacturasEnviadasSAP INT, @PagosGenerados INT, @PagosEnviadosSAP INT;

        -- Cálculo de Facturas Enviadas a SAP
        SELECT @FacturasEnviadasSAP = COUNT(*)
        FROM [DeliveryBackOffice].[dbo].[invoiceHeader] WITH(NOLOCK)
        WHERE CAST(inv_dateRegister AS DATE) BETWEEN @InitDate AND @EndDate
        AND inv_SAPDocEntry > 0
        AND inv_type = 1
		AND IdCountry = 'GT' --SAP aún no está disponible en Honduras
        AND ISNULL(inv_certificationFEL, '') != '';

        -- Cálculo de Pagos Generados
        SELECT @PagosGenerados = COUNT(*)
        FROM [DeliveryBackOffice].[dbo].[InOutOfMoneyDetail]  AS A1 WITH(NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[invoiceHeader] AS A2 WITH(NOLOCK)
        ON A2.inv_pk_id = A1.io_invoice 
        WHERE CAST(A1.io_registryDate AS DATE) BETWEEN @InitDate AND @EndDate
        AND ISNULL(A2.inv_certificationFEL, '') != ''
		AND A2.IdCountry ='GT' --SAP aún no está disponible en Honduras
        AND A2.inv_type = 1;

        -- Cálculo de Pagos Enviados a SAP
        SELECT @PagosEnviadosSAP = COUNT(*)
        FROM [DeliveryBackOffice].[dbo].[InOutOfMoneyDetail] AS A1 WITH(NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[invoiceHeader] AS A2 WITH(NOLOCK)
        ON A2.inv_pk_id = A1.io_invoice
        WHERE CAST(A1.io_registryDate AS DATE) BETWEEN @InitDate AND @EndDate
        AND A1.io_SAPDocEntryPaymentDetail > 0
        AND A2.inv_type = 1
		AND A2.IdCountry = 'GT' --SAP aún no está disponible en Honduras
		;

-- =============================================
-- LST01: Obtiene el resumen de las facturas y pagos generados, enviadas a SAP y faltantes
-- =============================================
        IF @Method = 'LST01'
        BEGIN
            SELECT 
                COUNT(*) AS [Facturas_Generadas],
                @FacturasEnviadasSAP AS [Facturas_EnviadasSAP],
                COUNT(*) - @FacturasEnviadasSAP AS [Facturas_Faltantes],
                @PagosGenerados AS [Pagos_Generados],
                @PagosEnviadosSAP AS [Pagos_EnviadosSAP],
                @PagosGenerados - @PagosEnviadosSAP AS [Pagos_Faltantes]
            FROM [DeliveryBackOffice].[dbo].[invoiceHeader] WITH(NOLOCK)
            WHERE CAST(inv_dateRegister AS DATE) BETWEEN @InitDate AND @EndDate
            AND inv_type = 1
			AND IdCountry = 'GT' --SAP aún no está disponible en Honduras
            AND ISNULL(inv_certificationFEL, '') != '';
        END
-- =============================================
-- LST02: Obtiene el detalle de las facturas pendientes de envio a SAP
-- =============================================
        ELSE IF @Method = 'LST02'
        BEGIN
            SELECT 
                INH.inv_date, 
				INH.inv_SAPDocEntry, 
				INH.inv_SAPError, 
				INH.inv_pk_id, 
				INH.inv_vpCodeOfReferences, 
				INH.inv_cmp_name, 
				INH.inv_cmp_nameComercial, 
				INH.inv_cmp_adress, 
				INH.inv_cmp_nit, 
				INH.inv_cli_name, 
				INH.inv_cli_adress,
				INH.inv_cli_nit,
				INH.inv_cli_email,
				INH.inv_certificationFEL,
				INH.inv_serieFEL,
				INH.inv_numberFEL,
				INH.inv_descriptionFEL,
				INH.inv_RequestorFEL,
				INH.inv_TransactionFEL,
				INH.inv_CountryFEL,
				INH.inv_EntityFEL,
				INH.inv_UserFEL,
				INH.inv_UserName,
				INH.inv_Data1FEL,
				INH.inv_Data3FEL,
				INH.inv_MailSendFEL,
				INH.inv_subjectFEL,
				INH.inv_IVA,
				INH.inv_amount,
				INH.inv_status,
				INH.inv_dateRegister,
				INH.inv_tokenRegister,
				INH.inv_dateUpdate,
				INH.inv_tokenUpdate,
				INH.inv_type,
				INH.inv_invoiceOfCreditNote,
				INH.inv_motiveCreditNote,
				INH.inv_dateOriginDocument,
				INH.inv_documentOriginFEL,
				INH.inv_creditNote,
				INH.inv_establecimientoFEL,
				INH.inv_cmp_nameFEL,
				INH.inv_FechaHoraFEL,
				INH.systemOperation,
				INH.IsManualInvoice,
				INH.inv_dateFEL,
				INH.CatInvoiceTypeId,
				INH.Retries
            FROM [DeliveryBackOffice].[dbo].[invoiceHeader] AS INH WITH(NOLOCK)
            WHERE CAST(INH.inv_dateRegister AS DATE) BETWEEN @InitDate AND @EndDate
            AND ISNULL(INH.inv_certificationFEL, '') != ''
            AND (INH.inv_SAPDocEntry IS NULL OR INH.inv_SAPDocEntry <= 0)
			AND INH.inv_CountryFEL = 'GT' --SAP aún no está disponible en Honduras
            AND INH.inv_type = 1;
        END
-- =============================================
-- LST03: Obtiene el detalle de los pagos pendientes de envio a SAP
-- =============================================
        ELSE IF @Method = 'LST03'
        BEGIN
            SELECT A1.io_SAPErrorPaymentDetail, A1.*
            FROM [DeliveryBackOffice].[dbo].[InOutOfMoneyDetail] AS A1 WITH(NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[invoiceHeader] AS A2 WITH(NOLOCK)
            ON A2.inv_pk_id = A1.io_invoice
            WHERE CAST(A1.io_registryDate AS DATE) BETWEEN @InitDate AND @EndDate
            AND ISNULL(A2.inv_certificationFEL, '') != ''
            AND (A1.io_SAPErrorPaymentDetail IS NULL OR LEN(A1.io_SAPErrorPaymentDetail) > 1)
			AND A2.IdCountry = 'GT' --SAP aún no está disponible en Honduras
            AND A2.inv_type = 1;
        END
    END TRY
    BEGIN CATCH
        --Devolviendo resultado de error en caso de generarse
        SELECT 
            500 AS 'responseCode',
            ERROR_MESSAGE() AS 'responseMessage'
    END CATCH;
END;