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
        AND ISNULL(inv_certificationFEL, '') != '';

        -- Cálculo de Pagos Generados
        SELECT @PagosGenerados = COUNT(*)
        FROM [DeliveryBackOffice].[dbo].[InOutOfMoneyDetail]  AS A1 WITH(NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[invoiceHeader] AS A2 WITH(NOLOCK)
        ON A2.inv_pk_id = A1.io_invoice 
        WHERE CAST(A1.io_registryDate AS DATE) BETWEEN @InitDate AND @EndDate
        AND ISNULL(A2.inv_certificationFEL, '') != ''
        AND A2.inv_type = 1;

        -- Cálculo de Pagos Enviados a SAP
        SELECT @PagosEnviadosSAP = COUNT(*)
        FROM [DeliveryBackOffice].[dbo].[InOutOfMoneyDetail] AS A1 WITH(NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[invoiceHeader] AS A2 WITH(NOLOCK)
        ON A2.inv_pk_id = A1.io_invoice
        WHERE CAST(A1.io_registryDate AS DATE) BETWEEN @InitDate AND @EndDate
        AND A1.io_SAPDocEntryPaymentDetail > 0
        AND A2.inv_type = 1;

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
            AND ISNULL(inv_certificationFEL, '') != '';
        END
-- =============================================
-- LST02: Obtiene el detalle de las facturas pendientes de envio a SAP
-- =============================================
        ELSE IF @Method = 'LST02'
        BEGIN
            SELECT INH.inv_date, INH.inv_SAPDocEntry, INH.inv_SAPError, *
            FROM [DeliveryBackOffice].[dbo].[invoiceHeader] AS INH WITH(NOLOCK)
            WHERE CAST(INH.inv_dateRegister AS DATE) BETWEEN @InitDate AND @EndDate
            AND ISNULL(INH.inv_certificationFEL, '') != ''
            AND (INH.inv_SAPDocEntry IS NULL OR INH.inv_SAPDocEntry <= 0)
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
            AND (A1.io_SAPErrorPaymentDetail IS NULL OR A1.io_SAPErrorPaymentDetail <= 0)
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
