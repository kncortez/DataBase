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

    INSERT INTO RetroactiveReconciliation
    SELECT CAST(do.dateCreated AS DATE)                         [Guidedate]
         , concat(do.Guide_Serie,'-',do.Guide_Number)           [Guide]
         , cs.[IdCustomer]                                      [CustomerId]
         , cs.[Name]                                            [CustomerName]
         , ISNULL(cs.ConditionOfPaymentID, 1)                   [TypeSaleId]
         , IIF(ISNULL(cs.ConditionOfPaymentID, 1) = 1 , 'CONTADO', 'CREDITO') [TypeSale]
         , so.StatusOrderId                                     [StatusId]
         , so.OrderDescription                                  [Status]
         , ISNULL(cas.SysIdSystem,-1)                           [SystemId]
         , ISNULL(cas.SysNameSystem,'No definido')              [SystemName]
         , ISNULL(inv.PaymentMethodId,0)                        [PaymentMethodId]
         , ISNULL(inv.PaymentMethod,'No Definido')              [PaymentMethod]
         , cts.CtsId                                            [TypePurchaseId]
         , cts.CtsName                                          [TypePurchase]
         , Concat(do.Sender_FirstName, ' ', do.Sender_LastName) [Sender]
         , ISNULL(inv.invoice,'Pendiente')                      [Invoice]
         , att.attempt                                          [Attempt]
         , ISNULL(bop.Amount,0)                                 [Overweight]
         , do.SenderCountryId                                   [CountryId]
    FROM DeliveryOrder do     WITH (NOLOCK)
    INNER JOIN StatusOrder so WITH (NOLOCK)
        ON so.StatusOrderId = do.StatusOrderId
    INNER JOIN dbo.cost c     WITH(NOLOCK)
        ON c.GuideSerie = do.Guide_serie
       AND c.GuideNumber = do.Guide_Number
    LEFT JOIN dbo.BreakdownOfPayment bop WITH(NOLOCK)
        ON c.IdCost = bop.IdCost
       AND bop.[Description] = 'Recargo por Peso'
    INNER JOIN dbo.Customer cs WITH(NOLOCK)
        ON cs.IdCustomer = do.IdCustomer
    LEFT JOIN CatTypeService cts WITH (NOLOCK)
        ON do.TypeService = cts.CtsShortName
    LEFT JOIN CatSystem cas WITH (NOLOCK)
        ON cas.SysIdSystem = do.CatSystemId
    OUTER APPLY(
                 SELECT IIF( IH.IdCountry = 'SV', IH.inv_NumberFEL, IH.inv_certificationFEL) [invoice]
                      , ID.dti_fk_orderSerie    [Guide_Serie]
                      , ID.dti_fk_orderNumber   [Guide_number]
                      ,  ISNULL(iomd.io_type,0)                  [PaymentMethodId]
                      , ISNULL(tiomd.tio_pk_name,'NO Definido') [PaymentMethod]
                 FROM invoiceDetail ID WITH(NOLOCK)
                 INNER JOIN invoiceHeader IH WITH(NOLOCK)
                   ON IH.inv_pk_id = ID.dti_fk_header
                 INNER JOIN dbo.InOutOfMoneyDetail iomd  WITH(NOLOCK)
                   ON iomd.io_invoice = inv_pk_id
                 INNER JOIN dbo.ctgTypeOfInOutOfMoney tiomd WITH(NOLOCK)
                   ON iomd.io_type = tiomd.tio_pk_id
                 WHERE ID.dti_fk_orderSerie = do.Guide_Serie
                   AND ID.dti_fk_orderNumber = do.Guide_number
               ) inv
    OUTER APPLY(
                 SELECT count(*) [attempt]
                 FROM DeliveryAttempt da WITH(NOLOCK)
                 WHERE da.Guide_Serie = do.Guide_Serie
                   AND da.Guide_Number = do.Guide_Number
               ) att
    WHERE do.DateCreated = DATEADD(DAY,-1,GETDATE())
      AND do.StatusOrderId in (Select StatusOrderId from @StatusOrderFinish)

    END TRY
    BEGIN CATCH
            SELECT 0 AS StatusCode, 
                   'Ha ocurrido un error en el proceso' AS StatusMessage
    END CATCH

END