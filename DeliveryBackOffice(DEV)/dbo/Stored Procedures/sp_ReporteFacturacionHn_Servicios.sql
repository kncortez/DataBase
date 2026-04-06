/* =================================================
   SP:        dbo.sp_ReporteFacturacionHn_Servicios
   Propósito: Creacion de reporte de facturas de otros servicios para Honduras
   Autor:     Keila Cortez
   Historia:  FDAPI-5946
   Fecha:     2026-04-06
============================================
=== CHANGELOG ================================
=========================================== */
CREATE PROCEDURE [dbo].[sp_ReporteFacturacionHn_Servicios]
    @IdCountry   NVARCHAR(5),
    @FechaInicio DATE,
    @FechaFin    DATE
AS
BEGIN

    SELECT A1.inv_date,
        A1.inv_pk_id,
        A1.inv_status,
        A1.inv_certificationFEL AS [Certificacion Factura],
        A1.inv_serieFEL AS [Serie Factura],
        A1.inv_numberFEL AS [Número Factura],
        A1.inv_amount AS [Total Factura],
        A2.dti_amount AS [Total Línea],
        A2.dti_description AS [Descripción],   
        A1.inv_cli_name AS [Cliente],
        CASE 
     WHEN @IdCountry = 'GT' THEN 'NIT'
     WHEN @IdCountry = 'HN' THEN 'NRC'
     ELSE 'Identificación'
  END AS [Tipo Documento],
        A1.inv_cli_nit AS [Número Documento Factura],
        A1.inv_cli_email AS [Correo del Cliente Facturado],
        A2.dti_category AS [Categoría], 
        A8.Name AS [Tipo Factura]
        ,COALESCE(A13.tio_pk_name, A14.tio_pk_name,A10.tio_pk_name, 'Sin registro de pago') AS [Método de pago]
        ,COALESCE(A9.io_ticket,A11.[Authorization],A12.[Authorization],'') AS [Voucher]
        ,COALESCE(A15.SysNameSystem,'') [Sistema]   
        FROM DeliveryBackOffice.DBO.invoiceHeader A1 WITH(NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.invoiceDetail A2 WITH(NOLOCK)
            ON A1.inv_pk_id = A2.dti_fk_header
        LEFT JOIN DeliveryBackOffice.dbo.CatInvoiceType A8 WITH(NOLOCK)  
            ON A8.IdCatInvoiceType = A1.CatInvoiceTypeId
        OUTER APPLY (
        SELECT TOP 1 io_ticket, io_type
        FROM DeliveryBackOffice.dbo.InOutOfMoneyDetail WITH(NOLOCK)
        WHERE io_invoice = A1.inv_pk_id
        ORDER BY io_pk_id DESC
        ) A9
                LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney A10 WITH(NOLOCK)
                    ON A10.tio_pk_id = A9.io_type
        OUTER APPLY (
        SELECT TOP 1 [Authorization], TypeOfInOutOfMoneyId
        FROM DeliveryBackOffice.dbo.SubscriptionPaymentLog WITH(NOLOCK)
        WHERE SubscriptionId = A2.SubscriptionId
        ORDER BY IdSubscriptionPaymentLog DESC
        ) A11
                LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney A13 WITH(NOLOCK)
                ON A11.TypeOfInOutOfMoneyId = A13.tio_pk_id
                OUTER APPLY (
        SELECT TOP 1 [Authorization], TypeOfInOutOfMoneyId
        FROM DeliveryBackOffice.dbo.MembershipPaymentLog WITH(NOLOCK)
        WHERE MembershipId = A2.MembershipId
        ORDER BY IdMembershipPaymentLog DESC
        ) A12
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney A14 WITH(NOLOCK)
        ON A12.TypeOfInOutOfMoneyId = A14.tio_pk_id
        LEFT JOIN DeliveryBackOffice.dbo.CatSystem A15 WITH(NOLOCK)
                ON A15.SysIdSystem = A1.systemOperation
        WHERE A2.dti_fk_orderSerie IS NULL
        AND A2.dti_fk_orderNumber IS NULL
        AND CAST(A1.inv_date AS DATE) >= @FechaInicio
        AND CAST(A1.inv_date AS DATE) <= @FechaFin
        AND A1.IdCountry = @IdCountry
        AND A1.inv_status = 2
        AND A1.inv_type = 1
        ORDER BY A1.inv_date;
 
END
GO