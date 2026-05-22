/* =================================================
   SP:        [dbo].[sp_GetOperatorsWithActivityAsync]
   Propósito: Obtener operadores con actividad en un rango de fecha específico.
   Autor:     Keila Cortéz
   Historia:  FDAPI-5784 bloqueocncexc
   Fecha:     2026-05-21
   === CHANGELOG ================================
   2026-05-21 | Historia/épica: FDAPI-5784 bloqueocncexc | Autor: Keila Cortéz 
   ============================================
*/
CREATE PROCEDURE sp_GetOperatorsWithActivityAsync
    @CodeOfReference INT,
    @startDate DATETIME,
    @endDate DATETIME
AS
BEGIN
    SELECT DISTINCT dopt.AccountId
    FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction dopt WITH(NOLOCK)
    INNER JOIN (
        SELECT Guide_Serie, Guide_Number
        FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
        WHERE StatusOrderId != 7
    ) dor
        ON dor.Guide_Serie = dopt.GuideSerie
        AND dor.Guide_Number = dopt.GuideNumber
    WHERE dopt.VisitPoint = @CodeOfReference
      AND dopt.ShipmentCompleted = 1
      AND dopt.DateCreated >= @startDate
      AND dopt.DateCreated < @endDate
      AND (dopt.amount > 0 OR dopt.CODAmountProcess > 0)
      AND dopt.TypeofInOutMoneyId != 8
END;