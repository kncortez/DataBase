-- Author:      <Cristian, Azurdia>
-- Create date: <2025-02-10>
-- Description: <Retorna los datos de una partidas de facturas pagadas al credito>
-- =============================================
CREATE PROCEDURE [dbo].[GetVTSCreditForza]
    -- Add the parameters for the stored procedure here
    @DateInit DATE,
    @DateFinish DATE,
    @IdCountry NVARCHAR(4) = 'GT'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
       SET NOCOUNT ON;

    SELECT DOR.SAPCardCode           [CARDCODE]
          ,RIGHT('000' + CAST(ibh.Establishment AS NVARCHAR(3)), 3) + '-' + RIGHT('000' + CAST(ibh.Emision_Point AS NVARCHAR(3)), 3) + '-' + RIGHT('000' + CAST(ibh.TypeDocument AS NVARCHAR(3)), 3) + '-' +  RIGHT('00000000' + CAST(ibh.InitialRange AS NVARCHAR(8)), 8) [U_FACTURA_INI]
          ,RIGHT('000' + CAST(ibh.Establishment AS NVARCHAR(3)), 3) + '-' + RIGHT('000' + CAST(ibh.Emision_Point AS NVARCHAR(3)), 3) + '-' + RIGHT('000' + CAST(ibh.TypeDocument AS NVARCHAR(3)), 3) + '-' +  RIGHT('00000000' + CAST(ibh.FinalRange AS NVARCHAR(8)), 8)   [U_FACTURA_FIN]
          ,INH.inv_serieFEL          [U_CAI]
          ,INH.inv_certificationFEL  [U_NUMERO_DOCUMENTO]
          ,INH.inv_cli_nit           [U_FACNIT]
          ,INH.inv_amount            [U_AMOUNT]
          --,IIF(ISNULL(DOR.ConditionOfPaymentID, 1) =1 , 'CONTADO', 'CREDITO') [payment_method]
    FROM DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
         INNER JOIN(
              SELECT dti_fk_header, 
                     MIN(dti_fk_orderSerie) AS dti_fk_orderSerie,
                     MIN(dti_fk_orderNumber) AS dti_fk_orderNumber
               FROM DeliveryBackOffice.dbo.invoiceDetail WITH (NOLOCK)
               GROUP BY dti_fk_header) IND
            ON IND.dti_fk_header = INH.inv_pk_id
        INNER JOIN DeliveryBackOffice.dbo.InvoiceBatchHeader IBH
            ON INH.inv_serieFEL = ibh.CAI
            AND INH.inv_type = ibh.TypeDocument
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
            AND ISNULL(DOR.ConditionOfPaymentID, 0) = 0
    WHERE CONVERT(DATE,INH.inv_date) >= @DateInit
      AND CONVERT(DATE,INH.inv_date) <= @DateFinish
      AND INH.IdCountry = @IdCountry
      AND INH.inv_certificationFEL IS NOT NULL
      AND INH.inv_type IN (1,2)
    ORDER BY INH.inv_date desc

END;