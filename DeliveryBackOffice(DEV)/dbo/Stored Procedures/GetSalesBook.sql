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

    select  ROW_NUMBER() OVER(ORDER BY INH.inv_numberFEL) [row_number]
            ih.inv_date       [date]
            ,ih.inv_cli_nit   [id_client]
            ,ih.inv_cli_name  [client_name]
            ,CASE WHEN @IdCountry = 'GT' THEN ih.inv_serieFEL 
                WHEN @IdCountry = 'HN' THEN ih.inv_certificationFEL ELSE '0' 
             END  [document_serie]
            ,ih.inv_numberFEL [document_correlative]
            ,CASE WHEN ih.inv_type = 1 THEN 'FACTURA' 
                WHEN ih.inv_type = 2 THEN 'NOTA DE CREDITO' 
                ELSE 'NO DEFINIDO'
            END [document_type]
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
		    , iif (ISNULL( f.ConditionOfPaymentID, 1) =1 , 'CONTADO', 'CREDITO') 
		    ,CASE WHEN DOR.IsCollect = 1 THEN 'SI' ELSE 'NO' END                [IsCollect]
            ,DOR.SAPCardCode                       [SAPCardCode]
    from invoiceHeader ih          WITH (NOLOCK)
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
    WHERE INH.IdCountry = @IdCountry
          AND  INH.inv_date >= CAST(@BeginDate AS DATETIME)
          AND  INH.inv_date < CAST(DATEADD(DAY, 1, @EndDate) AS DATETIME)
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