--USE DeliveryBackOffice
-- =============================================
-- Author:      Cristian Azurdia
-- Create date: <2024-12-30>
-- Description: Generación de libro de ventas GT, HN
-- =============================================
CREATE PROCEDURE [dbo].[GetSalesBook]
	-- Add the parameters for the stored procedure here
	@BeginDate DATETIME,
	@EndDate   DATETIME,
	@IdCountry varchar(4) = 'GT'
AS
BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    select --top 100 
           ih.inv_date       [date]
           ,ih.inv_cli_nit   [id_client]
           ,ih.inv_cli_name  [client_name]
           ,CASE WHEN @IdCountry = 'GT' THEN ih.inv_serieFEL 
                 WHEN @IdCountry = 'HN' THEN ih.inv_certificationFEL ELSE '0' 
            END  [document_serie]
           ,ih.inv_numberFEL [document_correlative]
           --ctd.name [document_type], 
           ,CASE WHEN ih.inv_type = 1 THEN 'FACTURA' 
                 WHEN ih.inv_type = 2 THEN 'NOTA DE CREDITO' 
                 ELSE 'NO DEFINIDO'
            END [document_type]
           --,cit.Name [document_subtype_description]
           ,0 [exportation]
           ,0 [sales]
           ,CASE WHEN dt.category = 'BIEN'  THEN ih.inv_amount  
                 ELSE 0
            END [sales_goods]
           ,CASE WHEN dt.category = 'SERVICIO'  THEN ih.inv_amount  
            ELSE 0
            END [sales_services]
           ,0 [discount]
           ,(inv_amount-inv_IVA) [amount_base]
           ,inv_IVA [tax]
           ,f.CtsName   [document_type_description]
           ,dt.dti_description [document_description]
           --, do.*
		   , iif (ISNULL( f.ConditionOfPaymentID, 1) =1 , 'CONTADO', 'CREDITO') 
		   , f.IsCollect
		   ,f.SAPCardCode
		   
    from invoiceHeader ih          WITH (NOLOCK)
    --LEFT JOIN CatTypeDocument ctd
        --ON ih.inv_type = ctd.IdTypeDocument
    --LEFT JOIN CatInvoiceType cit  WITH (NOLOCK)
        --ON IH.CatInvoiceTypeId = cit.IdCatInvoiceType
    OUTER APPLY --generación si es bien o servicio solo se toma un articulo63.5
    (    
        SELECT TOP 1 
               id.dti_fk_orderSerie, 
               id.dti_fk_orderNumber,
               id.dti_description,
               cas.category
        FROM invoiceDetail id         WITH (NOLOCK)
        LEFT JOIN CatArticleSAP cas   WITH (NOLOCK)
            ON id.SAPCode = cas.SAPCode
        where id.dti_fk_header = ih.inv_pk_id
    ) dt
    OUTER APPLY --generación de datos subtipo
    (
        SELECT do.Guide_Serie, do.Guide_Number, cts.CtsName, cs.ConditionOfPaymentID, do.IsCollect,cs.SAPCardCode
        FROM DeliveryOrder do        WITH (NOLOCK)
			INNER JOIN dbo.Customer cs WITH(NOLOCK) ON cs.IdCustomer = do.IdCustomer
        LEFT JOIN CatTypeService cts WITH (NOLOCK)
             ON do.TypeService = cts.CtsShortName
        WHERE   do.Guide_Serie = dt.dti_fk_orderSerie
           AND  do.Guide_Number = dt.dti_fk_orderNumber
    ) f
    WHERE CONVERT(DATE,ih.inv_date) >= @beginDate
          AND CONVERT(DATE,ih.inv_date) <= @endDate
          AND ISNULL(ih.IdCountry,'GT') = @IdCountry
          AND ih.inv_type IN (1,2)
          --and ih.inv_status <> 0
          AND ISNULL(ih.inv_certificationFEL, ' ') <> ' '
       --and dti_category = 'BIEN'
    order by ih.inv_date desc

END