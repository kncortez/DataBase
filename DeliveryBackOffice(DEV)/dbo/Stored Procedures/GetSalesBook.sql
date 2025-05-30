--USE DeliveryBackOffice
-- =============================================
-- Author:      Cristian Azurdia
-- Create date: <2024-12-30>
-- Description: Generación de libro de ventas GT, HN, SV
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

    IF(@IdCountry = 'GT')
    BEGIN
        SELECT ROW_NUMBER() OVER(ORDER BY INH.inv_numberFEL) [row_number]
              ,INH.inv_date       [date]
              ,INH.inv_cli_nit    [id_client]
              ,INH.inv_cli_name   [client_name]
              ,INH.inv_serieFEL [document_serie]
              ,INH.inv_numberFEL   [document_correlative]
              ,CASE WHEN INH.inv_type = 1 THEN 'FACTURA' 
                    WHEN INH.inv_type = 2 THEN 'NOTA DE CREDITO' 
                    ELSE 'NO DEFINIDO'
                END                    [document_type]
              ,0                       [exportation]
              ,0                       [sales]
              ,CASE WHEN MIN(IND.dti_category) = 'BIEN'  THEN INH.inv_amount
                     ELSE 0
                END [sales_goods]
              ,CASE WHEN MIN(IND.dti_category) = 'SERVICIO'  THEN INH.inv_amount
                ELSE 0
                END                     [sales_services]
              ,0                        [discount]
              ,(INH.inv_amount-INH.inv_IVA) [amount_base]
              ,INH.inv_IVA              [tax]
              ,DOR.CtsName              [document_type_description]
              --,MIN(IND.dti_description) [document_description]
              ,IIF(ISNULL(DOR.ConditionOfPaymentID, 1) =1 , 'CONTADO', 'CREDITO') [payment_method]
              ,CASE WHEN DOR.IsCollect = 1 THEN 'SI' ELSE 'NO' END                [IsCollect]
              ,DOR.SAPCardCode                       [SAPCardCode]
        FROM DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.invoiceDetail IND WITH (NOLOCK)
                ON IND.dti_fk_header = INH.inv_pk_id
            LEFT JOIN
            (
                SELECT  DO.Guide_Serie    [Guide_Serie]
                       ,DO.Guide_Number   [Guide_Number]
                       ,DO.IsCollect      [IsCollect]
                       ,Cs.ConditionOfPaymentID [ConditionOfPaymentID]
                       ,Cs.SAPCardCode    [SAPCardCode]
                       ,CTS.CtsName       [CtsName]
                FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
                INNER JOIN dbo.Customer cs WITH(NOLOCK) 
                    ON cs.IdCustomer = DO.IdCustomer
                LEFT JOIN CatTypeService cts WITH (NOLOCK)
                    ON DO.TypeService = cts.CtsShortName
            ) DOR
                ON DOR.Guide_Serie   = IND.dti_fk_orderSerie
                AND DOR.Guide_Number = IND.dti_fk_orderNumber
        WHERE  INH.inv_date >= @BeginDate
          AND  INH.inv_date <= @EndDate
          AND INH.IdCountry = @IdCountry
          AND INH.inv_certificationFEL IS NOT NULL
          AND INH.inv_type IN (1,2)
        GROUP BY inv_date
                ,inv_cli_nit
                ,inv_cli_name
                ,inv_serieFEL
                ,inv_certificationFEL
                ,inv_numberFEL
                ,inv_type
                ,inv_amount
                ,inv_IVA
                ,dor.CtsName
                ,dor.ConditionOfPaymentID
                ,dor.IsCollect
                ,dor.SAPCardCode
        ORDER BY [row_number] asc
    END
    ELSE IF(@IdCountry = 'HN')
    BEGIN
        SELECT ROW_NUMBER() OVER(ORDER BY INH.inv_numberFEL) [row_number]
              ,INH.inv_date       [date]
              ,INH.inv_cli_nit    [id_client]
              ,INH.inv_cli_name   [client_name]
              ,INH.inv_certificationFEL [document_serie]
              ,INH.inv_numberFEL   [document_correlative]
              ,CASE WHEN INH.inv_type = 1 THEN 'FACTURA' 
                    WHEN INH.inv_type = 2 THEN 'NOTA DE CREDITO' 
                    ELSE 'NO DEFINIDO'
                END                    [document_type]
              ,0                       [exportation]
              ,0                       [sales]
              ,CASE WHEN MIN(IND.dti_category) = 'BIEN'  THEN INH.inv_amount
                     ELSE 0
                END [sales_goods]
              ,CASE WHEN MIN(IND.dti_category) = 'SERVICIO'  THEN INH.inv_amount
                ELSE 0
                END                     [sales_services]
              ,0                        [discount]
              ,(INH.inv_amount-INH.inv_IVA) [amount_base]
              ,INH.inv_IVA              [tax]
              ,DOR.CtsName              [document_type_description]
              --,MIN(IND.dti_description) [document_description]
              ,IIF(ISNULL(DOR.ConditionOfPaymentID, 1) =1 , 'CONTADO', 'CREDITO') [payment_method]
              ,CASE WHEN DOR.IsCollect = 1 THEN 'SI' ELSE 'NO' END                [IsCollect]
              ,DOR.SAPCardCode                       [SAPCardCode]
        FROM DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.invoiceDetail IND WITH (NOLOCK)
                ON IND.dti_fk_header = INH.inv_pk_id
            LEFT JOIN
            (
                SELECT  DO.Guide_Serie    [Guide_Serie]
                       ,DO.Guide_Number   [Guide_Number]
                       ,DO.IsCollect      [IsCollect]
                       ,Cs.ConditionOfPaymentID [ConditionOfPaymentID]
                       ,Cs.SAPCardCode    [SAPCardCode]
                       ,CTS.CtsName       [CtsName]
                FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
                INNER JOIN dbo.Customer cs WITH(NOLOCK) 
                    ON cs.IdCustomer = DO.IdCustomer
                LEFT JOIN CatTypeService cts WITH (NOLOCK)
                    ON DO.TypeService = cts.CtsShortName
            ) DOR
                ON DOR.Guide_Serie   = IND.dti_fk_orderSerie
                AND DOR.Guide_Number = IND.dti_fk_orderNumber
        WHERE  INH.inv_date >= @BeginDate
          AND  INH.inv_date <= @EndDate
          AND INH.IdCountry = 'HN'
          AND INH.inv_certificationFEL IS NOT NULL
          AND INH.inv_type IN (1,2)
        GROUP BY inv_date
                ,inv_cli_nit
                ,inv_cli_name
                ,inv_serieFEL
                ,inv_certificationFEL
                ,inv_numberFEL
                ,inv_type
                ,inv_amount
                ,inv_IVA
                ,dor.CtsName
                ,dor.ConditionOfPaymentID
                ,dor.IsCollect
                ,dor.SAPCardCode
        ORDER BY [row_number] asc
    END
    ELSE IF (@IdCountry = 'SV')
    BEGIN
        SELECT ROW_NUMBER() OVER(ORDER BY INH.inv_numberFEL) [row_number]
              ,INH.inv_date       [date]
              ,INH.inv_cli_nit    [id_client]
              ,INH.inv_cli_name   [client_name]
              ,CASE WHEN @IdCountry = 'GT' THEN INH.inv_serieFEL
                    WHEN @IdCountry = 'HN' THEN INH.inv_certificationFEL ELSE '0' 
               END  [document_serie]
              ,INH.inv_numberFEL   [document_correlative]
              ,CASE WHEN INH.inv_type = 1 THEN 'FACTURA' 
                    WHEN INH.inv_type = 2 THEN 'NOTA DE CREDITO' 
                    ELSE 'NO DEFINIDO'
                END                    [document_type]
              ,0                       [exportation]
              ,0                       [sales]
              ,CASE WHEN MIN(IND.dti_category) = 'BIEN'  THEN INH.inv_amount
                     ELSE 0
                END [sales_goods]
              ,CASE WHEN MIN(IND.dti_category) = 'SERVICIO'  THEN INH.inv_amount
                ELSE 0
                END                     [sales_services]
              ,0                        [discount]
              ,(INH.inv_amount-INH.inv_IVA) [amount_base]
              ,INH.inv_IVA              [tax]
              ,DOR.CtsName              [document_type_description]
              --,MIN(IND.dti_description) [document_description]
              ,IIF(ISNULL(DOR.ConditionOfPaymentID, 1) =1 , 'CONTADO', 'CREDITO') [payment_method]
              ,CASE WHEN DOR.IsCollect = 1 THEN 'SI' ELSE 'NO' END                [IsCollect]
              ,DOR.SAPCardCode                       [SAPCardCode]
        FROM DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.invoiceDetail IND WITH (NOLOCK)
                ON IND.dti_fk_header = INH.inv_pk_id
            LEFT JOIN
            (
                SELECT  DO.Guide_Serie    [Guide_Serie]
                       ,DO.Guide_Number   [Guide_Number]
                       ,DO.IsCollect      [IsCollect]
                       ,Cs.ConditionOfPaymentID [ConditionOfPaymentID]
                       ,Cs.SAPCardCode    [SAPCardCode]
                       ,CTS.CtsName       [CtsName]
                FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
                INNER JOIN dbo.Customer cs WITH(NOLOCK) 
                    ON cs.IdCustomer = DO.IdCustomer
                LEFT JOIN CatTypeService cts WITH (NOLOCK)
                    ON DO.TypeService = cts.CtsShortName
            ) DOR
                ON DOR.Guide_Serie   = IND.dti_fk_orderSerie
                AND DOR.Guide_Number = IND.dti_fk_orderNumber
        WHERE  INH.inv_date >= @BeginDate
          AND  INH.inv_date <= @EndDate
          AND INH.IdCountry = 'SV'
          AND INH.inv_certificationFEL IS NOT NULL
          AND INH.inv_type IN (1,2,3,4)
        GROUP BY inv_date
                ,inv_cli_nit
                ,inv_cli_name
                ,inv_serieFEL
                ,inv_certificationFEL
                ,inv_numberFEL
                ,inv_type
                ,inv_amount
                ,inv_IVA
                ,dor.CtsName
                ,dor.ConditionOfPaymentID
                ,dor.IsCollect
                ,dor.SAPCardCode
        ORDER BY [row_number] asc
    END

END