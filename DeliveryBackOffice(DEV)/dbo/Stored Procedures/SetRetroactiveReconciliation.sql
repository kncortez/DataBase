/* =================================================
   SP:        [dbo].[SetRetroactiveReconciliation]
   Propósito: <Datos para reportes de reconciliación retroactiva>
   Autor:     <Cristian Azurdia>
   Historia:  <FDAPI-5383>
   Fecha:     2026-02-02
============================================
=== CHANGELOG ================================
-- 2026-02-02 | Historia/épica: FDAPI-5383 | Autor: Cristian Azurdia |
=========================================== */

CREATE PROCEDURE [dbo].[SetRetroactiveReconciliation]

AS
BEGIN
    BEGIN TRY

    DECLARE @StatusOrderFinish TABLE
    (
        StatusOrderId INT PRIMARY KEY,
        StatusOrderDescription NVARCHAR(100) NOT NULL,
        StatusMessage NVARCHAR(512) NOT NULL
    );

    INSERT INTO @StatusOrderFinish (StatusOrderId, StatusOrderDescription, StatusMessage)
    SELECT StatusOrderId, OrderDescription, StatusMessage 
    FROM StatusOrder WITH (NOLOCK)
    WHERE CatCheckpointTypeId = 3
      AND RowStatus = 1;

    DECLARE @todayDate DATE = CAST(GETDATE() AS DATE);
    DECLARE @beginDate DATE = CAST(DATEADD(MONTH, -6, @todayDate) AS DATE);

    DELETE FROM RetroactiveReconciliation
    WHERE GuideDate >= @beginDate
      AND GuideDate <  @todayDate

    INSERT INTO RetroactiveReconciliation
    SELECT CAST(do.dateCreated AS DATE)                                                       [Guidedate]
        , concat(do.Guide_Serie,'-',do.Guide_Number)                                          [Guide]
        , cs.[IdCustomer]                                                                     [CustomerId]
        , cs.[Name]                                                                           [CustomerName]
        , ISNULL(cs.ConditionOfPaymentID, 1)                                                  [TypeSaleId]
        , IIF(ISNULL(cs.ConditionOfPaymentID, 1) = 1 , 'CONTADO', 'CREDITO')                  [TypeSale]
        , so.StatusOrderId                                                                    [StatusId]
        , StatusOrderDescription                                                              [Status]
        , ISNULL(cas.SysIdSystem,-1)                                                          [SystemId]
        , ISNULL(cas.SysNameSystem,'No definido')                                             [SystemName]
        , ISNULL(c.PaymentMethodId,0)                                                         [PaymentMethodId]
        , ISNULL(c.PaymentMethod,'No Definido')                                               [PaymentMethod]
        , ISNULL(cts.CtsId,0)                                                                 [TypePurchaseId]
        , IIF((mbl.SubscriptionId IS NULL AND mbl.MembershipId IS NULL), 'NORMAL', 'PAQUETE') [TypePurchase]
        , Concat(do.Sender_FirstName, ' ', do.Sender_LastName)                                [Sender]
        , ISNULL(inv.invoice,'Pendiente')                                                     [Invoice]
        , ISNULL(doad.GuideDeliveryAttemptCount, 0) + ISNULL(doad.GuideReturnAttemptCount, 0) [Attempt]
        , ISNULL(bop.Amount,0)                                                                [Overweight]
        , do.SenderCountryId                                                                  [CountryId]
        , (ISNULL(do.PriceShippment,0) + ISNULL(do.Collect_OnDelivery, 0))                    [Amount]
    FROM DeliveryOrder do     WITH (NOLOCK)
    INNER JOIN @StatusOrderFinish so
        ON so.StatusOrderId = do.StatusOrderId
    LEFT JOIN CatSystem cas WITH (NOLOCK)
        ON cas.SysIdSystem = do.CatSystemId
    INNER JOIN dbo.Customer cs WITH(NOLOCK)
        ON cs.IdCustomer = do.IdCustomer
    LEFT JOIN CatTypeService cts WITH (NOLOCK)
        ON do.TypeService = cts.CtsShortName
    LEFT JOIN MembershipSubscriptionLog mbl WITH (NOLOCK)
        ON mbl.LogGuideSerie = do.Guide_Serie 
      AND mbl.LogGuideNumber = do.Guide_Number
    LEFT JOIN DeliveryOrderAttemptData doad WITH(NOLOCK)
        ON doad.GuideSerie  = do.Guide_Serie
      AND doad.GuideNumber = do.Guide_Number
    OUTER APPLY(
              SELECT IIF( MAX(IH.IdCountry) = 'SV', MAX(IH.inv_NumberFEL), MAX(IH.inv_certificationFEL)) [invoice]
                  , MAX(ID.dti_fk_orderSerie)                     [Guide_Serie]
                  , MAX(ID.dti_fk_orderNumber)                    [Guide_number]
              FROM invoiceDetail ID WITH(NOLOCK)
              INNER JOIN invoiceHeader IH WITH(NOLOCK)
                ON IH.inv_pk_id = ID.dti_fk_header
              WHERE ID.dti_fk_orderSerie = do.Guide_Serie
                AND ID.dti_fk_orderNumber = do.Guide_number
            ) inv
        OUTER APPLY(
            SELECT  MAX(co.IdCost)                                [IdCost]
                  , ISNULL(MAX(cd.IdTypeOfMoney),0)               [PaymentMethodId]
                  , ISNULL(MAX(tiomd.tio_pk_name),'NO Definido')  [PaymentMethod]
            FROM dbo.cost co     WITH(NOLOCK)
            INNER JOIN dbo.CostDetail cd WITH(NOLOCK)
                ON co.IdCost = cd.IdCost
            INNER JOIN dbo.ctgTypeOfInOutOfMoney tiomd WITH(NOLOCK)
                ON cd.IdTypeOfMoney = tiomd.tio_pk_id
            WHERE co.GuideSerie =  do.Guide_Serie
              AND co.GuideNumber = do.Guide_Number
            ) c
    LEFT JOIN dbo.BreakdownOfPayment bop WITH(NOLOCK)
        ON bop.IdCost = c.IdCost
      AND bop.[Description] = 'Recargo por Peso'
    WHERE do.DateCreated >= @beginDate
      AND do.DateCreated <  @todayDate

    END TRY
    BEGIN CATCH
            SELECT 0 AS StatusCode, 
                   'Ha ocurrido un error en el proceso' AS StatusMessage
    END CATCH

END