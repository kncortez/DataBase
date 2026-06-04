/* =================================================
   SP:        [dbo].[SPHDValidate]
   Propósito: <VALIDAR SI FACTURA EXISTE Y VER SUS DATOS>
   Autor:     <Edelman Vasquez>
   Historia:  <FDAPI-1743>
   Fecha:     2023-03-31
============================================
=== CHANGELOG ================================
-- 2023-03-31 | Historia/épica: FDAPI-1743 | Autor: Edelman Vásquez  | VALIDAR SI FACTURA TIENE NOTA DE CREDITO
-- 2024-08-23 | Historia/épica: FDAPI-2440 | Autor: Cristian Suazo   | Se agrega el IdCountry de la factura en la respuesta
-- 2025-07-18 | Historia/épica: FDAPI-4148 | Autor: Brandon Pedroza  | Facturacion SV - se obtiene factura por numberfel para SV
-- 2025-09-11 | Historia/épica: FDAPI-4456 | Autor: Brandon Pedroza  | Facturacion SV - se quita validacion isnull al consultar tabla invoiceHeader
-- 2026-06-03 | Historia/épica: FDAPI-5721 | Autor: Cristian Azurdia | Facturacion HN - obtención de datos nuevos de facturas con error 2025
=========================================== */

CREATE PROCEDURE [dbo].[SPHDValidate]
@Guide     Nvarchar(25)=null,
@DateOf    Datetime=null,
@DateTo    DateTime=null,
@NumberFel Nvarchar(40)=null,
@Membership int=null,
@Subscription INT=null,
@TipoEnvio AS INT =0,
@TipoComisionCOD AS INT=0,
@IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @Envio INT =0
    DECLARE @ComisionCOD INT=0
    DECLARE @dti_fk_header INT =0;

    -- IF(@TipoEnvio > 0)
    SET @Envio =(Select IdCatInvoiceType From [dbo].[CatInvoiceType] CIT  WHERE [Name]='Envío')

    --IF(@TipoComisionCOD>0)
    SET @ComisionCOD =(Select IdCatInvoiceType From [dbo].[CatInvoiceType] CIT  WHERE [Name]='Comisión COD')

    IF CHARINDEX('-', @Guide) > 0
    BEGIN
        SET  @Guide=  SUBSTRING(@Guide, 0, IIF(CHARINDEX('-', @Guide) = 0, (LEN(@Guide)), (CHARINDEX('-', @Guide) - 0)))
    END


    IF (@Guide IS NOT NULL) 
    BEGIN

        SELECT TOP 1 @dti_fk_header = dti_fk_header 
        FROM [dbo].[invoiceDetail]	WITH(NOLOCK)
        WHERE dti_fk_orderSerie + Cast(dti_fk_orderNumber as varchar)  = @Guide


        IF (@TipoEnvio = 1 And @TipoComisionCOD = 0)
        BEGIN

            SELECT
                Top 1
                ISNULL(IH.inv_creditNote,0) 'HaveaCreditNote'
                ,ID.dti_description
                ,IH.inv_pk_id
                ,IH.inv_serieFEL
                ,IH.inv_numberFEL
                ,IH.inv_certificationFEL
                ,IH.inv_cli_name
                ,IH.IdCountry
            FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
            INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
                ON IH.inv_pk_id = ID.dti_fk_header
            WHERE 
                ID.dti_fk_header = @dti_fk_header
                AND   IH.inv_invoiceOfCreditNote IS NULL
                AND   inv_certificationFEL IS NOT NULL
                AND (IH.CatInvoiceTypeId IS NULL OR IH.CatInvoiceTypeId IN (@Envio))
                AND IH.inv_creditNote IS NULL
                AND   IH.inv_invoiceOfCreditNote IS  NULL
            ORDER BY IH.inv_pk_id DESC

        END
        ELSE IF (@TipoComisionCOD = 1 And @TipoEnvio=0)
        BEGIN

            SELECT
                 TOP 1
                 ISNULL(IH.inv_creditNote,0) 'HaveaCreditNote'
                ,ID.dti_description
                ,IH.inv_pk_id
                ,IH.inv_serieFEL
                ,IH.inv_numberFEL
                ,IH.inv_certificationFEL
                ,IH.inv_cli_name
                ,IH.IdCountry
            FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
            INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
                ON IH.inv_pk_id = ID.dti_fk_header
            WHERE 
                ID.dti_fk_header = @dti_fk_header
                AND IH.inv_invoiceOfCreditNote IS NULL
                AND inv_certificationFEL IS NOT NULL
                AND (IH.CatInvoiceTypeId IS NULL OR IH.CatInvoiceTypeId IN (@ComisionCOD))
                AND IH.inv_creditNote IS NULL
                AND IH.inv_invoiceOfCreditNote IS   NULL
            ORDER BY IH.inv_pk_id DESC

        END
        ELSE IF (@TipoEnvio = 1  And @TipoComisionCOD =1)
        BEGIN

            SELECT
             ISNULL(IH.inv_creditNote,0) 'HaveaCreditNote'
            ,ID.dti_description
            ,IH.inv_pk_id
            ,IH.inv_serieFEL
            ,IH.inv_numberFEL
            ,IH.inv_certificationFEL
            ,IH.inv_cli_name
            ,IH.IdCountry
            FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
            INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
                ON IH.inv_pk_id = ID.dti_fk_header
            WHERE
                ID.dti_fk_header = @dti_fk_header
                AND   inv_certificationFEL IS NOT NULL
                AND IH.inv_creditNote IS NULL
                AND  IH.inv_invoiceOfCreditNote IS  NULL

        END
        ELSE
        BEGIN

            SELECT
                ISNULL(IH.inv_creditNote,0) 'HaveaCreditNote'
                ,ID.dti_description
                ,IH.inv_pk_id
                ,IH.inv_serieFEL
                ,IH.inv_numberFEL
                ,IH.inv_certificationFEL
                ,IH.inv_cli_name
                ,IH.IdCountry
            FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
            INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
                ON IH.inv_pk_id = ID.dti_fk_header
            WHERE
                ID.dti_fk_header = @dti_fk_header
                AND   inv_certificationFEL IS NOT NULL
                AND IH.inv_creditNote IS NULL
                AND  IH.inv_invoiceOfCreditNote IS NULL

        END

    END
    ELSE IF (@NumberFel IS NOT NULL)
    BEGIN

        IF(@IdCountry ='SV')
        BEGIN

            DECLARE @TypeCF INT = (SELECT IdRegister FROM CatTypeDocument WITH(NOLOCK) WHERE [Name] = 'Comprobante Crédito Fiscal');
            DECLARE @TypeInvoice INT = (SELECT IdRegister FROM CatTypeDocument WITH(NOLOCK) WHERE [Name] = 'Factura');

            Select
                 0 'HaveaCreditNote'
                ,ID.dti_description
                ,IH.inv_pk_id
                ,IH.inv_serieFEL
                ,IH.inv_numberFEL
                ,IH.inv_certificationFEL
                ,IH.inv_cli_name
                ,IH.IdCountry
            FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
            INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
                ON IH.inv_pk_id = ID.dti_fk_header
            WHERE
                inv_numberFEL = @NumberFel
                AND IH.inv_type in (@TypeInvoice,@TypeCF)
            ORDER BY IH.inv_pk_id DESC

        END
        ELSE
        BEGIN

            DECLARE @ResolvedFel VARCHAR(50) = COALESCE(
                (SELECT TOP 1 inv_certificationFEL
                 FROM dbo.invoiceHeader WITH (NOLOCK)
                 WHERE inv_certificationFEL = @NumberFel),
            
                (SELECT TOP 1 inv_certificationFEL_new
                 FROM dbo.InvoiceDataFixHN WITH (NOLOCK)
                 WHERE inv_certificationFEL_old = @NumberFel),
            
                (SELECT TOP 1 inv_certificationFEL_new
                 FROM dbo.InvoiceDataFixHn2 WITH (NOLOCK)
                 WHERE inv_certificationFEL_old = @NumberFel)
            );
            
            -- =====================================================================
            -- Consulta final usando el FEL resuelto
            -- =====================================================================
            SELECT
                 ISNULL(IH.inv_creditNote,0) 'HaveaCreditNote'
                ,ID.dti_description
                ,IH.inv_pk_id
                ,IH.inv_serieFEL
                ,IH.inv_numberFEL
                ,IH.inv_certificationFEL
                ,IH.inv_cli_name
                ,IH.IdCountry
            FROM dbo.invoiceHeader IH WITH (NOLOCK)
            INNER JOIN dbo.invoiceDetail ID WITH (NOLOCK)
                ON IH.inv_pk_id = ID.dti_fk_header
            WHERE IH.inv_certificationFEL    = @ResolvedFel
              AND IH.inv_invoiceOfCreditNote IS NULL
              AND IH.inv_creditNote          IS NULL
            ORDER BY IH.inv_pk_id DESC;

        END
    END
    ELSE IF (@Membership IS NOT NULL)
    BEGIN

        SELECT
             ISNULL(IH.inv_creditNote,0) 'HaveaCreditNote'
            ,ID.dti_description
            ,IH.inv_pk_id
            ,IH.inv_serieFEL
            ,IH.inv_numberFEL
            ,IH.inv_certificationFEL
            ,IH.inv_cli_name
            ,IH.IdCountry
        FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
        INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
            ON IH.inv_pk_id = ID.dti_fk_header
        WHERE
            IH.inv_invoiceOfCreditNote IS NULL AND ID.MembershipId = @Membership
            AND IH.inv_dateFEL Between  @DateOf + ' 00:00:00'  AND @DateTo + ' 23:59:59'
            AND inv_certificationFEL IS NOT NULL
            AND IH.inv_creditNote IS NULL
            AND IH.inv_invoiceOfCreditNote IS  NULL

    END
    ELSE IF (@Subscription IS NOT NULL)
    BEGIN

        SELECT
             ISNULL(IH.inv_creditNote,0) 'HaveaCreditNote'
            ,ID.dti_description
            ,IH.inv_pk_id
            ,IH.inv_serieFEL
            ,IH.inv_numberFEL
            ,IH.inv_certificationFEL
            ,IH.inv_cli_name
            ,IH.IdCountry
        FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
        INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
            ON IH.inv_pk_id = ID.dti_fk_header
        WHERE
            IH.inv_invoiceOfCreditNote IS NULL AND  ID.SubscriptionId = @Subscription
            AND   IH.inv_dateFEL Between  @DateOf + ' 00:00:00'  AND @DateTo + ' 23:59:59'
            AND   inv_certificationFEL IS NOT NULL
            AND IH.inv_creditNote IS NULL
            AND  IH.inv_invoiceOfCreditNote IS   NULL

    END

END