/* =================================================
   SP:        [dbo].[GetSalesBook]
   Propósito: Generación de libro de ventas GT, HN y SV.
   Autor:     Cristian Azurdia
   Fecha:     <2024-12-30>
===== CHANGELOG ============================
2026-04-28 | Historia/épica: FDAPI-6107 | Autor: Hanss Espinoza |
=========================================== */
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

    DECLARE @NewEndDate DATETIME = CAST(DATEADD(DAY, 1, @EndDate) AS DATETIME);

    select  ROW_NUMBER() OVER(ORDER BY MAX(IH.inv_numberFEL)) [row_number]
            ,MAX(ih.inv_date)       [date]
            ,MAX(ih.inv_cli_nit)   [id_client]
            ,MAX(ih.inv_cli_name)  [client_name]
            ,CASE
                WHEN @IdCountry = 'GT' THEN ih.inv_serieFEL
                WHEN @IdCountry = 'HN' THEN ih.inv_certificationFEL
                WHEN @IdCountry = 'SV' THEN ih.inv_numberFEL
                ELSE '0'
             END  [document_serie]
            ,CASE
                WHEN @IdCountry = 'SV' THEN MAX(ih.inv_serieFEL)
                ELSE MAX(ih.inv_numberFEL)
             END [document_correlative]
            ,CASE
                WHEN @IdCountry = 'SV' AND MAX(ih.inv_type) = 1 THEN 'FACTURA - Factura'
                WHEN @IdCountry = 'SV' AND MAX(ih.inv_type) = 4 THEN 'FACTURA - Crédito Fiscal'
                WHEN MAX(ih.inv_type) IN (1, 4) THEN 'FACTURA'
                WHEN MAX(ih.inv_type) = 2 THEN 'NOTA DE CREDITO'
                ELSE 'NO DEFINIDO'
            END [document_type]
            ,0 [exportation]
            ,0 [sales]
            ,CASE WHEN MAX(IND.dti_category) = 'BIEN'  THEN ih.inv_amount
                ELSE 0
            END [sales_goods]
            ,CASE WHEN MAX(IND.dti_category) = 'SERVICIO'  THEN ih.inv_amount
            ELSE 0
            END [sales_services]
            ,0 [discount]
            ,(inv_amount-inv_IVA) [amount_base]
            ,inv_IVA [tax]
            ,MAX(DOR.CtsName)   [document_type_description]
            ,MAX(IND.dti_description) [document_description]
            ,IIF(ISNULL(MAX(DOR.ConditionOfPaymentID), 1) =1 , 'CONTADO', 'CREDITO') [payment_method]
            ,CASE WHEN DOR.IsCollect = 1 THEN 'SI' ELSE 'NO' END                [IsCollect]
            ,MAX(DOR.SAPCardCode)                       [SAPCardCode]
    from DeliveryBackOffice.dbo.invoiceHeader IH          WITH (NOLOCK)
        CROSS APPLY (
            SELECT TOP 1 dti_category, dti_description, dti_fk_orderSerie, dti_fk_orderNumber
            FROM DeliveryBackOffice.dbo.invoiceDetail IND WITH (NOLOCK)
            WHERE IND.dti_fk_header = IH.inv_pk_id
            ORDER BY IND.SAPCode DESC
        ) IND
        LEFT JOIN
        (
            SELECT  DO.Guide_Serie    [Guide_Serie]
                    ,DO.Guide_Number   [Guide_Number]
                    ,DO.IsCollect      [IsCollect]
                    ,Cs.ConditionOfPaymentID [ConditionOfPaymentID]
                    ,Cs.SAPCardCode    [SAPCardCode]
                    ,CTS.CtsName       [CtsName]
            FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.Customer cs WITH(NOLOCK)
                ON cs.IdCustomer = DO.IdCustomer
            LEFT JOIN DeliveryBackOffice.dbo.CatTypeService cts WITH (NOLOCK)
                ON DO.TypeService = cts.CtsShortName
        ) DOR
            ON DOR.Guide_Serie   = IND.dti_fk_orderSerie
            AND DOR.Guide_Number = IND.dti_fk_orderNumber
    WHERE IH.IdCountry = @IdCountry
          AND IH.inv_date >= @BeginDate
          AND IH.inv_date <  @NewEndDate
          AND IH.inv_certificationFEL IS NOT NULL
          AND IH.inv_type IN (1, 2, 4)
    GROUP BY inv_serieFEL
            ,inv_certificationFEL
            ,inv_numberFEL
            ,inv_amount
            ,inv_IVA
            ,DOR.IsCollect
    ORDER BY [row_number] asc

END
go
