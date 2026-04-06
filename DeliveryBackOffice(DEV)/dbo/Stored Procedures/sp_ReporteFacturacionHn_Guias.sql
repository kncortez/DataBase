/* =================================================
   SP:        dbo.sp_ReporteFacturacionHn_Guias
   Propósito: Creacion de reporte de facturas con guia para Honduras
   Autor:     Keila Cortez
   Historia:  FDAPI-5946
   Fecha:     2026-04-06
============================================
=== CHANGELOG ================================
=========================================== */
CREATE PROCEDURE [dbo].[sp_ReporteFacturacionHn_Guias]
    @IdCountry   NVARCHAR(5),
    @FechaInicio DATE,
    @FechaFin    DATE
AS
BEGIN

    SELECT A1.inv_date, 
        A1.inv_pk_id, 
        CONCAT(A2.dti_fk_orderSerie, CAST(A2.dti_fk_orderNumber AS NVARCHAR(20))) AS [Número de Guía],
        A1.inv_certificationFEL AS [Certificacion Factura],
        A1.inv_serieFEL AS [Serie Factura],
        A1.inv_numberFEL AS [Número Factura],
        A1.inv_amount AS [Total Factura],
        A2.dti_amount AS [Total Guía],
        RTRIM(
            CASE 
                WHEN CHARINDEX(' FD', A2.dti_description) > 0 
                    THEN LEFT(A2.dti_description, CHARINDEX(' FD', A2.dti_description) - 1)
                ELSE A2.dti_description
            END
        ) AS [Descripción],
        A1.inv_cli_name AS [Facturado a nombre de],
        CASE 
            WHEN @IdCountry = 'GT' THEN 'NIT'
            WHEN @IdCountry = 'HN' THEN 'NRC'
            ELSE 'Identificación'
        END AS [Tipo Documento],
                A1.inv_cli_nit AS [Número Documento Factura],
                A1.inv_cli_email AS [Correo del Cliente Facturado],
                COALESCE(A5.ConditionOfPayment,'CONTADO')AS [Condición de Pago],
                A7.Description AS [Tipo Cliente Guía],  
                IIF(A4.IdCustomerType = 2,A12.DescriptionOfClient,A4.Name) AS [Nombre Cliente Guía],               
                CASE 
                    WHEN ISNULL(A3.IsCollect, 0) = 1 THEN 'COLLECT'
                    ELSE 'NO COLLECT'
                END AS [Es Collect]
                ,A8.Name AS [Tipo Factura]
        ,CASE 
        WHEN A7.IdCustomerType = 1
            AND ISNULL(A3.IsCollect, 0) = 0
        THEN 'Crédito'
        WHEN COALESCE(NULLIF(A19.Voucher,''), NULLIF(A9.io_ticket,'')) IS NOT NULL
        THEN 'pago con tarjeta'
        ELSE COALESCE(A16.tio_pk_name,'Sin registro de pago')
        END AS [Método de pago]
        ,COALESCE(NULLIF(A19.Voucher,''),NULLIF(A9.io_ticket,''),'')  [Voucher] 
        ,CASE 
        WHEN A7.IdCustomerType = 1
            AND COALESCE(A5.ConditionOfPayment,'credito') LIKE '%credito%'
            AND ISNULL(A3.IsCollect, 0) = 0
        THEN 'Hermes Desktop'
        ELSE COALESCE(A11.SysNameSystem,'')
        END AS [Sistema]
    FROM DeliveryBackOffice.DBO.invoiceHeader A1 WITH(NOLOCK)
    INNER JOIN DeliveryBackOffice.dbo.invoiceDetail A2 WITH(NOLOCK)
        ON A1.inv_pk_id = A2.dti_fk_header
    INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder A3 WITH(NOLOCK)
        ON A3.Guide_Serie = A2.dti_fk_orderSerie
        AND A3.Guide_Number = A2.dti_fk_orderNumber
    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient A6 WITH(NOLOCK)
        ON A6.CodeOfReference = A3.Sender_ID
        AND A3.IdCustomer IS NULL
    LEFT JOIN DeliveryBackOffice.dbo.Customer A4 WITH(NOLOCK)
        ON A4.IdCustomer = COALESCE(A3.IdCustomer, A6.CustomerID)
    LEFT JOIN DeliveryBackOffice.dbo.CatConditionOfPayment A5 WITH(NOLOCK)
        ON A5.IdConditionOfPayment = A4.ConditionOfPaymentID
    LEFT JOIN DeliveryBackOffice.dbo.CustomerType A7 WITH(NOLOCK) 
        ON A7.IdCustomerType = A4.IdCustomerType
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
    LEFT JOIN DeliveryBackOffice.dbo.CatSystem A11 WITH(NOLOCK)
        ON A11.SysIdSystem = A1.systemOperation
    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient A12 WITH(NOLOCK)
        ON A12.CodeOfReference = A3.Sender_ID
    OUTER APPLY (
    SELECT TOP 1 OrderNumber
    FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomerDetail WITH(NOLOCK)
    WHERE SerieNumber   = A2.dti_fk_orderSerie
      AND ProductNumber = A2.dti_fk_orderNumber
    ORDER BY OrderNumber DESC
    ) A13
    OUTER APPLY (
        SELECT TOP 1 OrderNumber
        FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer WITH(NOLOCK)
        WHERE OrderNumber = A13.OrderNumber
        AND ReasonCode  = '00'
        ORDER BY OrderNumber DESC
    ) A14
    OUTER APPLY (
        SELECT TOP 1 TypeofInOutMoneyId
        FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail WITH(NOLOCK)
        WHERE GuideSerie   = A3.Guide_Serie
        AND GuideNumber  = A3.Guide_Number
        ORDER BY TypeofInOutMoneyId DESC
    ) A15
    LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney A16 WITH(NOLOCK)
        ON A15.TypeofInOutMoneyId = A16.tio_pk_id
    LEFT JOIN DeliveryBackOffice.dbo.Cost A17 WITH(NOLOCK)
    ON A17.GuideSerie = A3.Guide_Serie
    AND A17.GuideNumber = A3.Guide_Number 
    OUTER APPLY(
            SELECT TOP 1 IdCost,Voucher,IdTypeOfMoney
            FROM DeliveryBackOffice.dbo.CostDetail A18 WITH(NOLOCK)
            WHERE A18.IdCost = A17.IdCost
            ORDER BY A18.DateCreated DESC
    ) A19
    WHERE CAST(A1.inv_date AS DATE) >= @FechaInicio
    AND CAST(A1.inv_date AS DATE) <= @FechaFin
    AND A3.SenderCountryId = @IdCountry
    AND A1.inv_status = 2
    AND A1.inv_type = 1
    AND A1.inv_amount <> 0.00
    ORDER BY A1.inv_date;
 
END
GO