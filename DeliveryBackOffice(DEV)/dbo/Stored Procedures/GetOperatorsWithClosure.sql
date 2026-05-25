/* =================================================
   SP:        [dbo].[GetOperatorsWithClosure]
   Propósito: Obtener operadores que realizaron cierre en un rango de fecha específico.
   Autor:     Keila Cortéz
   Historia:  FDAPI-5784 bloqueocncexc
   Fecha:     2026-05-21
   === CHANGELOG ================================
   2026-05-21 | Historia/épica: FDAPI-5784 bloqueocncexc | Autor: Keila Cortéz 
   ============================================
*/
CREATE PROCEDURE GetOperatorsWithClosure
    @CodeOfReference INT,
    @startDate DATETIME,
    @endDate DATETIME
AS
BEGIN
    SELECT DISTINCT rua.RuaIdAccount
    FROM DeliveryBackOffice.dbo.AccountingClosuresHeader ach WITH(NOLOCK)
    INNER JOIN (
        SELECT DISTINCT UsrIdUser
        FROM DeliveryBackOffice.dbo.RegisterUser WITH(NOLOCK)
        WHERE UsrIdUser IS NOT NULL
    ) ru
        ON ach.UserId = ru.UsrIdUser
    INNER JOIN (
        SELECT DISTINCT RuaIdUser, RuaIdAccount
        FROM DeliveryBackOffice.dbo.RolByUserByAccount WITH(NOLOCK)
        WHERE RuaRowStatus = 1
    ) rua
        ON rua.RuaIdUser = ru.UsrIdUser
    WHERE ach.VisitPoint = @CodeOfReference
      AND ach.ClosureDate >= @startDate
      AND ach.ClosureDate < @endDate
      AND ach.AccountingClosuresHeaderVisitPointId IS NULL
      AND ach.RowStatus = 1
END;